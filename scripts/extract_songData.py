import bisect, contextlib, itertools, subprocess, sys

gb2hex = lambda x: x >> 2 & ~0x3FFF | x & 0x3FFF
hex2gb = lambda x: x << 2 & ~0xFFFF | x & 0x3FFF | 0x4000
longAddressString = lambda x: "{:X}:{:X}".format(x >> 16, x & 0xFFFF)
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])

rom = open("./M2.gb", "rb")

@contextlib.contextmanager
def romSeek(to):
    old = rom.tell()
    rom.seek(to)
    yield
    rom.seek(old)

def cls():
    subprocess.call('cls', shell = True)

def romReadArray(n_datum, start, end):
    'Return a list of n_datum size values for the pair of given pointers'
    ret = []
    for i in range(start, end, n_datum):
        rom.seek(gb2hex(i))
        ret += [romRead(n_datum)]
    return ret

def loadDataFromPointerTable(pointers, data_end, bank):
    'Given a list of pointers, orders them and returns a list of n_datum size values for each pair of pointers as a list'
    addresses = sorted(set([bank << 16 | pointer for pointer in sorted(set(pointers))]))
    endAddresses = addresses[1:] + [data_end]
    pools = [romReadArray(n_datum, start, end) for (start,end) in zip(addresses, endAddresses)]
    return (addresses, pools)

def textifyPool(label, address, data, n_datum = 1, n_row = 16):
    'Returns a string giving the formatted output of the pool data. All other parameters control the format of the output'
    dx = "bwld"[n_datum - 1] if n_datum - 1 in range(4) else 'x'
    text = ";;; ${:X}: {} ;;;\n".format(address & 0xFFFF, label)
    text += "{\n"
    text += "ROM{}              d{} ".format(longAddressString(address), dx)
    marginText = ""
    for i in range(0, len(data), n_row):
        text += marginText
        marginText = ",\n" + " " * 26
        text += ", ".join(["{{:0{}X}}".format(n_datum * 2).format(v) for v in data[i:i+n_row]])
    text += "\n"
    text += "}\n"
    return text

def textifyPoolPool(label, sublabels, addresses, dataPools, n_datum = 1, n_row = 16):
    'Returns a string giving the formatted output of the list of pools dataPools. All other parameters control the format of the output'
    text = ";;; ${:X}: {} ;;;\n".format(addresses[0] & 0xFFFF, label)
    text += "{\n"
    text += "\n\n".join([textifyPool("{} - {}".format(label, sublabel), address, dataPool, n_datum, n_row) for (sublabel, address, dataPool) in zip(sublabels, addresses, dataPools)])
    text += "}\n"
    return text

def outputSongData():
    class Song:
        class Header:
            def __init__(self, address, name):
                tempoMap = {
                    0x409E: 448,
                    0x40AB: 224,
                    0x40B8: 149,
                    0x40C5: 112,
                    0x40D2: 90,
                    0x40DF: 75,
                    0x40EC: 64,
                    0x40F9: 56,
                    0x4106: 50
                }
                
                self.address = address
                self.labels = [f'{name}_header']
                rom.seek(gb2hex(0x40000 | address))
                self.musicNoteOffset = romRead(1)
                self.p_tempo = romRead(2)
                if self.p_tempo not in tempoMap:
                    raise RuntimeError(f'Unknown tempo pointer ${self.p_tempo:X}')
                
                self.tempo = tempoMap[self.p_tempo]
                self.toneSweep = romRead(2)
                self.tone = romRead(2)
                self.wave = romRead(2)
                self.noise = romRead(2)
                self.p_end = hex2gb(rom.tell()) & 0xFFFF
                self.label_toneSweep = '$0000'
                self.label_tone = '$0000'
                self.label_wave = '$0000'
                self.label_noise = '$0000'
            
            def print(self):
                print(f'; ${self.address:X}')
                for label in self.labels:
                    print(f'{label}:')
                    
                print(f'    SongHeader ${self.musicNoteOffset:X}, tempoTable_{self.tempo}, {self.label_toneSweep}, {self.label_tone}, {self.label_wave}, {self.label_noise}')
            
            def addLabel(self, name):
                self.labels += [f'{name}_header']
        
        class Channel:
            class Section:
                class End:
                    def __str__(self):
                        return 'SongEnd'
                
                class Rest:
                    def __str__(self):
                        return 'SongRest'
                
                class Echo1:
                    def __str__(self):
                        return 'Echo1'
                
                class Echo2:
                    def __str__(self):
                        return 'Echo2'
                
                class Note:
                    def __init__(self, i_channel, i_note):
                        self.i_channel = i_channel
                        if i_channel == 4:
                            self.i_note = i_note // 4
                        else:
                            i_note = i_note // 2 - 1
                            self.i_note = i_note % 12
                            self.i_octave = i_note // 12
                        
                    def __str__(self):
                        if self.i_channel == 4:
                            return f'SongNoiseNote ${self.i_note:X}'
                            
                        noteNames = [
                            'C',
                            'Db',
                            'D',
                            'Eb',
                            'E',
                            'F',
                            'Gb',
                            'G',
                            'Ab',
                            'A',
                            'Bb',
                            'B'
                        ]
                        
                        return f'SongNote "{noteNames[self.i_note]}{self.i_octave + 2}"'
                
                class NoteLength:
                    def __init__(self, i_noteLength):
                        self.i_noteLength = i_noteLength & ~0xA0
                        if self.i_noteLength > 0xC:
                            raise RuntimeError(f'Invalid note length {self.i_noteLength:X}h')
                        
                    def __str__(self):
                        noteLengthNames = [
                            'Hemidemisemiquaver',
                            'Demisemiquaver',
                            'Semiquaver',
                            'Quaver',
                            'Crochet',
                            'Minum',
                            'DottedSemiquaver',
                            'DottedQuaver',
                            'DottedCrochet',
                            'TripletSemiquaver',
                            'TripletQuaver',
                            'Semihemidemisemiquaver',
                            'Semibreve'
                        ]
                        
                        return f'SongNoteLength_{noteLengthNames[self.i_noteLength]}'
                
                class Options:
                    def __init__(self, channel):
                        self.channel = channel
                        if channel != 3:
                            self.envelope = romRead(1)
                            self.sweep = romRead(1)
                            self.lengthDuty = romRead(1)
                        else:
                            self.p_wavePattern = romRead(2)
                            self.volume = romRead(1)
                        
                    def __str__(self):
                        ret = 'SongOptions'
                        if self.channel != 3:
                            if self.envelope >> 3 & 1 == 0:
                                ret += f'\n        DescendingEnvelopeOptions {self.envelope & 7}, ${self.envelope >> 4 & 0xF:X}'
                            else:
                                ret += f'\n        AscendingEnvelopeOptions {self.envelope & 7}, ${self.envelope >> 4 & 0xF:X}'
                                
                            if self.sweep >> 3 & 1 == 0:
                                ret += f'\n        AscendingSweepOptions {self.sweep & 7}, {self.sweep >> 4 & 7}'
                            else:
                                ret += f'\n        DescendingSweepOptions {self.sweep & 7}, {self.sweep >> 4 & 7}'
                            
                            # TODO: check if I should handle noise channel
                            ret += f'\n        LengthDutyOptions ${self.lengthDuty & 0x3F:X}, {self.lengthDuty >> 6 & 3}'
                        else:
                            ret += f'\n        WaveOptions ${self.p_wavePattern:X}, {self.volume >> 5}, ${self.volume & 0x1F}'
                        
                        return ret
                
                class Tempo:
                    def __init__(self):
                        tempoMap = {
                            0x409E: 448,
                            0x40AB: 224,
                            0x40B8: 149,
                            0x40C5: 112,
                            0x40D2: 90,
                            0x40DF: 75,
                            0x40EC: 64,
                            0x40F9: 56,
                            0x4106: 50
                        }
                        
                        self.p_tempo = romRead(2)
                        if self.p_tempo not in tempoMap:
                            raise RuntimeError(f'Unknown tempo pointer ${self.p_tempo:X}')
                        
                        self.tempo = tempoMap[self.p_tempo]
                        
                    def __str__(self):
                        return f'SongTempo tempoTable_{self.tempo}'
                
                class Transpose:
                    def __init__(self):
                        self.transpose = romRead(1)
                        
                    def __str__(self):
                        return f'SongTranspose ${self.transpose:X}'
                
                class RepeatSetup:
                    def __init__(self):
                        self.n_repetitions = romRead(1)
                        
                    def __str__(self):
                        return f'SongRepeatSetup ${self.n_repetitions:X}'
                
                class Repeat:
                    def __str__(self):
                        return 'SongRepeat'
                    
                def __init__(self, address, label, channel, i_section):
                    self.address = address
                    self.labels = {(label, i_section)}
                    self.channel = channel
                    self.instructions = []
                
                def load(self, p_end):
                    p_end = gb2hex(0x40000 | p_end)
                    with romSeek(gb2hex(0x40000 | self.address)):
                        while rom.tell() < p_end:
                            instructionId = romRead(1)
                            if instructionId == 0:
                                self.instructions += [self.End()]
                                break
                            elif instructionId == 1:
                                self.instructions += [self.Rest()]
                            elif instructionId == 3 and self.channel != 4:
                                self.instructions += [self.Echo1()]
                            elif instructionId == 5 and self.channel != 4:
                                self.instructions += [self.Echo2()]
                            elif instructionId < 0x9F:
                                self.instructions += [self.Note(self.channel, instructionId)]
                            elif instructionId < 0xF1:
                                self.instructions += [self.NoteLength(instructionId)]
                            elif instructionId == 0xF1:
                                self.instructions += [self.Options(self.channel)]
                            elif instructionId == 0xF2:
                                self.instructions += [self.Tempo()]
                            elif instructionId == 0xF3:
                                self.instructions += [self.Transpose()]
                            elif instructionId == 0xF4:
                                self.instructions += [self.RepeatSetup()]
                            elif instructionId == 0xF5:
                                self.instructions += [self.Repeat()]
                            else:
                                raise RuntimeError(f'Unknown instruction {instructionId:02X}h')
                        
                        self.p_end = hex2gb(rom.tell()) & 0xFFFF
                
                def print(self):
                    channelNames = ["toneSweep", "tone", "wave", "noise"]
                    
                    print(f'; ${self.address:X}')
                    for (label, i_section) in self.labels:
                        print(f'{label}_section{i_section:X}:')
                    
                    print(';{')
                    n_indent = 1
                    for instruction in self.instructions:
                        if isinstance(instruction, self.Repeat):
                            n_indent -= 1
                        indent = '    ' * n_indent
                        print(f'{indent}{instruction}')
                        if isinstance(instruction, self.RepeatSetup):
                            n_indent += 1
                        
                    print(';}')
                
                def addLabel(self, label, i_section):
                    self.labels |= {(label, i_section)}
        
            @staticmethod
            def makeExternalPoint(p_target, label, channel, isLoop):
                targetChannel = None
                if p_target in Song.data:
                    targetChannel = Song.data[p_target]
                else:
                    songDataKeys = sorted(Song.data.keys())
                    i_songDataKey = bisect.bisect(songDataKeys, p_target)
                    if i_songDataKey > 0:
                        targetChannelKey = songDataKeys[i_songDataKey - 1]
                        targetChannel = Song.data[targetChannelKey]
                        if not isinstance(targetChannel, Song.Channel) or p_target >= targetChannel.p_end:
                            targetChannel = None
                    
                if targetChannel is not None:
                    i_targetTarget = (p_target - targetChannel.address) // 2
                    if isLoop:
                        if targetChannel.i_loopTarget != i_targetTarget:
                            if targetChannel.i_loopTarget is not None:
                                raise RuntimeError(f'Found a Channel that needs multiple loop labels. Existing = {targetChannel.i_loopTarget}, new = {i_targetLoopTarget}, target channel = ${targetChannel.address:X}, p_target = ${p_target:X}')
                            
                            targetChannel.i_loopTarget = i_targetTarget
                            
                        targetLabel = f'{targetChannel.labels[0]}.loop'
                    else:
                        if targetChannel.i_alternateEntryTarget != i_targetTarget:
                            if targetChannel.i_alternateEntryTarget is not None:
                                raise RuntimeError(f'Found a Channel that needs multiple loop labels. Existing = {targetChannel.i_loopTarget}, new = {i_targetLoopTarget}, target channel = ${targetChannel.address:X}, p_target = ${p_target:X}')
                            
                            targetChannel.i_alternateEntryTarget = i_targetTarget
                            
                        targetLabel = f'{targetChannel.labels[0]}.alternateEntry'
                else:
                    targetLabel = label
                    Song.data[p_target] = Song.Channel(p_target, targetLabel, channel)
                
                return targetLabel

            def __init__(self, address, label, channel):
                # Note that in the instruction pointer list, an 00F0 is only ever used for looping, never for skipping
                self.address = address
                self.channel = channel
                self.labels = [label]
                self.data = []
                self.i_loopTarget = None
                self.i_alternateEntryTarget = None
                if address == 0x0000: ## think this can be removed
                    return
                
                if address < 0x5F90:
                    raise RuntimeError(f'Bad section address: ${address:X}')
                    
                with romSeek(gb2hex(0x40000 | address)):
                    i_section = 0
                    while True:
                        p_section = romRead(2)
                        self.data += [p_section]
                        
                        # Terminator
                        if p_section == 0x0000:
                            break
                            
                        # Goto
                        if p_section == 0x00F0:
                            p_target = romRead(2)
                            if p_target < address:
                                # External goto
                                self.targetLabel = Song.Channel.makeExternalPoint(p_target, f'{label}_loop', channel, True)
                            else:
                                # Internal goto
                                self.i_loopTarget = (p_target - address) // 2
                                self.targetLabel = '.loop'
                            
                            break
                            
                        # Section
                        # Instead of making these Sections straight away, I construct an ordered list and make them later in batch, so that I can handle overlapping
                        if p_section not in Song.sections:
                            Song.sections[p_section] = self.Section(p_section, label, channel, i_section)
                        else:
                            Song.sections[p_section].addLabel(label, i_section)
                        
                        i_section += 1
                    
                    self.p_end = hex2gb(rom.tell()) & 0xFFFF
            
            def print(self):
                channelNames = ["toneSweep", "tone", "wave", "noise"]
                print(f'; ${self.address:X}')
                for label in reversed(self.labels):
                    print(f'{label}:')
                    
                print(';{')
                for (i_section, datum) in enumerate(self.data):
                    if datum == 0x0000:
                        print('    dw $0000')
                    elif datum == 0x00F0:
                        print(f'    dw $00F0, {self.targetLabel}')
                    else:
                        if self.i_loopTarget is not None and i_section == self.i_loopTarget:
                            print('    .loop')
                        
                        if self.i_alternateEntryTarget is not None and i_section == self.i_alternateEntryTarget:
                            print('    .alternateEntry')
                        
                        print(f'    dw {self.labels[0]}_section{i_section:X} ; ${datum:X}') ##
                
                print(';}')
            
            def addLabel(self, label):
                self.labels += [label]

        data = {}
        sections = {}
        
    def loadSong(p_songData, name):
        header = Song.Header(p_songData, name)
        if p_songData in Song.data:
            Song.data[p_songData].addLabel(name)
        else:
            Song.data[p_songData] = header
        
        channelNames = ["toneSweep", "tone", "wave", "noise"]
        if header.toneSweep != 0:
            channelName = f'{name}_{channelNames[0]}'
            if header.toneSweep in Song.data:
                Song.data[header.toneSweep].addLabel(channelName)
                header.label_toneSweep = channelName
            else:
                header.label_toneSweep = Song.Channel.makeExternalPoint(header.toneSweep, channelName, 1, False)
        
        if header.tone != 0:
            channelName = f'{name}_{channelNames[1]}'
            if header.tone in Song.data:
                Song.data[header.tone].addLabel(channelName)
                header.label_tone = channelName
            else:
                header.label_tone = Song.Channel.makeExternalPoint(header.tone, channelName, 2, False)
        
        if header.wave != 0:
            channelName = f'{name}_{channelNames[2]}'
            if header.wave in Song.data:
                Song.data[header.wave].addLabel(channelName)
                header.label_wave = channelName
            else:
                header.label_wave = Song.Channel.makeExternalPoint(header.wave, channelName, 3, False)
        
        if header.noise != 0:
            channelName = f'{name}_{channelNames[3]}'
            if header.noise in Song.data:
                Song.data[header.noise].addLabel(channelName)
                header.label_noise = channelName
            else:
                header.label_noise = Song.Channel.makeExternalPoint(header.noise, channelName, 4, False)

    songDataTable_begin = 0x45F30
    songDataTable_end = 0x45F70
    songsDataBegin = 0x5F90
    songsDataEnd = 0x7D42
    songNames = [
        'song_babyMetroid',
        'song_metroidQueenBattle',
        'song_chozoRuins',
        'song_mainCaves',
        'song_subCaves1',
        'song_subCaves2',
        'song_subCaves3',
        'song_finalCaves',
        'song_metroidHive',
        'song_itemGet',
        'song_metroidQueenHallway',
        'song_metroidBattle',
        'song_subCaves4',
        'song_earthquake',
        'song_killedMetroid',
        'song_nothing_clone',
        'song_title',
        'song_samusFanfare',
        'song_reachedTheGunship',
        'song_chozoRuins_clone',
        'song_mainCaves_noIntro',
        'song_subCaves1_noIntro',
        'song_subCaves2_noIntro',
        'song_subCaves3_noIntro',
        'song_finalCaves_clone',
        'song_metroidHive_clone',
        'song_itemGet_clone',
        'song_metroidQueenHallway_clone',
        'song_metroidBattle_clone',
        'song_subCaves4_noIntro',
        'song_metroidHive_withIntro',
        'song_missilePickup'
    ]
    
    # Read song data table
    songDataPointers = romReadArray(2, songDataTable_begin, songDataTable_end)
    
    # Load song data
    songsHeaders = []
    for (i_song, (songName, p_songData)) in enumerate(zip(songNames, songDataPointers), 1):
        if i_song == 0x10:
            # Unused and broken
            #songsHeaders[p_songData] = [None]
            continue
            
        loadSong(p_songData, songName)
    
    Song.data[0x6FB9] = Song.Channel(0x6FB9, 'unused6FB9', 2)
    Song.sections[0x7D51] = Song.Channel.Section(0x7D51, 'unused7D51', 2, 0)
    Song.sections[0x7D56] = Song.Channel.Section(0x7D56, 'unused7D56', 2, 0)
    Song.sections[0x7D60] = Song.Channel.Section(0x7D60, 'unused7D60', 3, 0)
    Song.sections[0x7D65] = Song.Channel.Section(0x7D65, 'unused7D65', 3, 0)
    
    # Load song sections
    sectionPointers = sorted(Song.sections)
    for (p_section, p_section_next) in zip(sectionPointers, sectionPointers[1:] + [0xFFFF]):
        section = Song.sections[p_section]
        section.load(p_section_next)
        Song.data[p_section] = section
    
    # Print song data
    p_end = songsDataBegin
    for (_, data) in sorted(Song.data.items()):
        if p_end < data.address:
            print(f'ds ${data.address - p_end:X}, $00')
            
        p_end = data.p_end
        data.print()
        print()

def main():
    outputSongData()

main()
