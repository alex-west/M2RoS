# Style Guide

A rough style for keeping the contributors to this project on the same page. Contact the maintainer of this repository if you need clarification or have ideas for improvement.

Note that some parts of this disassembly were made before these rules were adopted. Feel free to submit a pull request to correct them.

## Naming Conventions

Variable and label names should use the `camelCase` convention. `ALL_CAPS` is reserved for hardware registers.

The underscore `_` can be used as an informal class or namespace marker. For example, the main pose-handler for Samus could be named `samus_poseHandler`.

Label names inside of functions should begin with a period `.likeThis` so they are scoped as local labels by the assembler. If for whatever reason they need to be referenced outside of the function, you can use the function name like so: `function.likeThis`.

Variables in HRAM should be prefixed with `h`, such as `hVBlankDoneFlag`.

## Labelling and Indentation

Many assembly-level expressions have rough equivalents to higher-level concepts. When possible, use labelling and indentation to make the connections clearer. Use `.localLabels` when at all possible.

If a jump cannot be expressed in terms of a simple, high-level control flow concept, give it a `.descriptiveName`.

### If Statements

```
    cp $ff
    jr z, .endIf
        code
        code
	.endIf:
    
    more code
```

If a function has multiple if statements, then post-fix each with an underscore `_` and letter. For instance:

```
    jr z, .endIf_A
        code
	.endIf_A:

    more code
    jr z, .endIf_B
        more code
	.endIf_B:
```

### If-Else

If-Else statements occur when two branches of code are mutually exclusive, like so:

```
    jr z, .else
        code
        jr .endIf
    .else:
        more code
	.endIf:
    
    more code
```

If there are multiple if statements in a function, the letter appended to the `.else_A` and `.endIf_A` labels should match whenever possible.

### If-Then

If-Then statements are similar to If-Else statements, except the branches in them are not mutually exclusive. Rather, if either condition is properly met, then the code following the `.then:` label is executed.

```
    jr z, .then
        code
        jr z, .endIf
        .then:
            more code
	.endIf:
    
    more code
```

### Returns

The `ret` function should be unindented when it is at the end of a function.

```
function:
    code
    code
    code
ret
```

However, if the function ends with an If-Else statement, both occurrances should remain indented, and an unindented comment should be left to indicate the end of the function.

```
    jr z, .else
        code
        ret
    .else:
        more code
        ret
; end proc
```

### Loops

```
    .loop:
        code
    jr z. .loop
```

It is often useful to give loops meaningful names, such as `.clearLoop` or `.enemyLoop`.

Sometimes loops end with unconditional jumps, and the exit point is embedded within the loop itself:

```
    .loop:
        code
            jr z, .break
        more code
    jr .loop
    .break:
```

### Conditional Returns, Calls, Jumps, etc.

Conditional returns and calls, and goto-like jumps should be indented.

```
    cmp [var]
		ret z
    cmp [var]
        call z, function
    cmp [var]
        jr z, trickyLabel
```

### Switch-Like Statements

```
    ld a, [foo]
    and a
        jr z, .case_doThing
    inc a
        jr z, .case_doOtherThing
    inc a
        jr z, .case_doAnotherThing
    ; etc.

; Do default thing
    code

.case_doThing:
	code
.case_doAnotherThing:
	code
.case_doOtherThing:
	code
```

### Splitting Labels

Sometimes a labels end up serving multiple purposes, such as being then end of an if statement and the start of a loop, like so:

```
    jr z, .label
        code
    .label
        code
    jr z, .label
```

Consider splitting the label into two labels for clarity:

```
    jr z, .endIf
        code
    .endIf

    .loop
        code
    jr z, .loop
```

### Multiple-Entry Points

Sometimes a block of code might have multiple entry points. This is a very difficult problem to work around, and no single solution necessarily works in all possible cases.

When the entrances are mutually exclusive, this approach is worth considering:

```
function:
    .left:
        code
        jr start
    .right:
        code
.start:
    code
```

This function can thus be called with both `call function.left` and `call function.right`.
