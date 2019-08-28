# Fith

Fith (working title) is a very simple programming language
inspired by Forth. One difference from Forth is that it has
a much more modern and convenient way of dealing with
arrays.

## Design Goals

Fith is designed to be a comfortable compilation target
for higher-level languages. It should be very simple to
implement a Fith VM. Fith is also supposed to be reasonably
pleasant to read.

## Overall Structure

Fith is a stack-based language where the computer's
"working memory" is represented as a stack. Data to be
manipulated are loaded onto the stack, and then operated on
by *instructions*. Instructions always affect the topmost
items of the stack.

Data values are immutable, though variables can be
reassigned.

## Syntax

A program is composed of a series of textual elements called
*tings*. Tings are processed in order, top-down, and take
effect immediately.

The most basic type of ting is an instruction. For example,
the following instruction causes the computer to emit a
sound:

```
:beep
```

All instructions match the regex `^:[a-z\-]+$`.

The other types of tings represent data. When the computer
encounters a data ting, it pushes the ting onto a stack.

Strings are one type of data. Strings are demarcated by
quotes.

To show off the use of strings, here is the Hello World
program in Fith:

```
"Hello, world!"
:print-line
```

If a string consists only of alphabetic characters and
dashes, the quotes may be omitted:

```
hello
:print-line
```

Fith also has integers. Integers are arbitrarily long
sequences of decimal digits, optionally preceded by a minus
sign:

```
314159265358979
```

There are no floating-point numbers.

The last type of ting is the list, which consists of any
number of tings surrounded by square brackets.

```
[ hello :print ]
```

## Instructions

```
value name :set
```

Stores the value `value` in the variable `name`. Storage for
the variable is allocated if it doesn't yet exist.

```
name :get
```

Retrieves the current value of the variable `name` and puts
the value on top of the stack.

```
list item :append
```

Puts a list on top of the stack, obtained by appending the
given `item` to the end of the given `list`. The original
`list` is not modified.

```
list i :at
```

Retrieves the item in the `list` at index `i` and puts it on
top of the stack. Crashes if the index is out of bounds.

```
list :call
```

Evaluates the tings in the `list`, as if they appeared in
the program in place of the `:call` instruction.

```
else then condition :if
```

If `condition` is not `0`, `:call`s the `then` list.
Otherwise, `:call`s the `else` list.

```
else then condition :if-zero
```

If `condition` is `0`, `:call`s the `then` list. Otherwise,
`:call`s the `else` list.

```
loop condition :while
```

`condition` and `loop` are both lists. `:while` `:call`s
the `condition` and then removes the top item from the
stack. If that item is not `0`, it then `:call`s the `loop`.
It does this repeatedly until the result of the `condition`
is `0`.

```
:push
```

`:push` creates a new namespace for variables. Tings
evaluated after a `:push` cannot access any variables that
were defined before the `:push` happened.

```
:pop
```

`:pop` undoes the most recent `:push`. Any variables that
were `:set` since the `:push` happened vanish.
