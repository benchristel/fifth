# Fifth

Fifth (working title) is a very simple programming language
inspired by Forth. One difference from Forth is that it has
a much more modern and convenient way of dealing with
arrays.

## Design Goals

Fifth is designed to be a comfortable compilation target
for higher-level languages. It should be very simple to
implement a Fifth VM. Fifth is also supposed to be reasonably
pleasant to read.

## Overall Structure

Fifth is a stack-based language where the computer's
"working memory" is represented as a stack. Data to be
manipulated are loaded onto the stack, and then operated on
by *instructions*. Instructions always affect the topmost
items of the stack.

Data values are immutable, though variables can be
reassigned.

## Syntax

A program is composed of a series of textual elements called
*phrases*. Phrases are processed in order, top-down, and take
effect immediately.

The most basic type of phrase is an instruction. For example,
the following instruction causes the computer to emit a
sound:

```
beep
```

All instructions match the regex `^[a-z\-]+$`.

The other types of phrases represent data. When the computer
encounters a data phrase, it pushes the phrase onto a stack.

Strings are one type of data. Strings are demarcated by
quotes.

To show off the use of strings, here is the Hello World
program in Fifth:

```
"Hello, world!"
print-line
```

Fifth also has rational numbers. Some examples:

```
456
314159/100000
22/7
-1
571895172834791800928419527190192
```

If the denominator of a rational number is a power of 10, it
can be abbreviated using a decimal point. The following are
valid:

```
123.
10.001
3.14159
.25
0.1
```

There are no floating-point numbers.

The last type of phrase is the list, which consists of any
number of phrases surrounded by square brackets.

```
[ "hello" print-line ]
```

## Macros

To make fifth more convenient to write, you can define macros
which expand to one or more phrases.

```
[ "a long message that I don't want to repeat" ] "msg" macro
msg print-line
msg print-line
```

You can think of macro expansion as copy-pasting the phrases
in the macro definition in place of the name. So you can
do this, too:

```
[
  "*****************"
  print-line
  print-line
  "*****************"
  print-line
] "banner" macro

"welcome to fifth!"
banner
```

This prints:

```
*****************
welcome to fifth!
*****************
```
