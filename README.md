# Fifth

Fifth (working title) is a very simple programming language
inspired by Forth. One difference from Forth is that it has
a much more modern and convenient way of dealing with
arrays and maps.

Imagine, if you will, an imperative Lisp. Or, if you prefer,
a homoiconic assembly language with persistent, immutable
data structures.

## Design Goals

Fifth is designed to be a comfortable compilation target
for higher-level languages. It should be very simple to
implement a Fifth VM. Fifth is also supposed to be
reasonably pleasant to read.

## Status of This Document

This specification is a draft, and many parts of it are
incomplete. Everything is subject to change.

## Overall Structure

Fifth is a stack-based language where the computer's
"working memory" is represented as a stack. Data to be
manipulated are loaded onto the stack, and then operated on
by *instructions*. Instructions always affect the topmost
items of the stack.

Data values are immutable, though variables can be
reassigned.

## Syntax

A program in the Fifth language is represented textually as
a sequence of whitespace-separated items called `Term`s.

There are five types of `Term`s: Rational Numbers, Strings,
Names, Lists, and Maps.

### Rational Numbers

A `Rational Number` represents the result of dividing one
integer by another. Examples follow:

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
1.00
```

There are no floating-point numbers.

### Strings

A `String` represents a sequence of Unicode characters.
Strings are delimited by double quotes (ASCII 34).

Example:

```
"Hello, world!"
```

Between the quotes, all characters are represented by
themselves, with the exception of `"`, which is represented
by `""`. This implies that the text of a Fifth program must
use a Unicode-compatible encoding.

```
"""Hello,"" she said."
```

### Names

A `Name` is a sequence of characters in the (regex) set
`[a-z\-\?]` that starts with a letter.

Example:

```
print-line
```

### Lists

A `List` is a sequence of whitespace-separated `Term`s
surrounded by square brackets. No whitespace is required
around the square brackets, since they cannot be confused
for part of any other `Term`.

```
[
  "Hello, world!"
  print-line
]
```

### Maps

A `Map` is a data structure that establishes a one-way
correspondence between keys and values. The syntax (assuming
we're dealing with tokens that have already been split on
whitespace) is:

```
Map -> '{' Pair* '}'
Pair -> Term Term
```

No whitespace is required around the curly braces, since
they cannot be confused for part of any other `Term`.

Example:

```
{
  name "Elias"
  age 32
}
```

## Comments

Comments have no effect on the program. A comment is any
text surrounded by parentheses `()`. Comments nest; the
whole line below is a comment.

```
(a comment (with a parenthetical statement)!)
```

No whitespace is required around the parentheses, since
they cannot be confused for part of any other `Term`.

## Semantics

### Immutability

`Term`s are textual elements, but they are also data values
that Fifth programs manipulate. It's not a stretch to say
that the "true" representation of a Fifth program is a Fifth
`Term`, and that the textual representation is merely a
convenience.

This lack of distinction between data and syntactic
structures might seem odd, but it's core to how Fifth works.
It is possible to unite the two concepts only because Fifth
treats all data values as immutable. Because of
immutability, we can compare `Term`s by value, and not by
reference.

For example, the following code *must* evaluate to 1
(indicating "true") in a correct Fifth implementation:

```
["hello", "world"]
["hello", "world"]
equal?
```

And the map access in the following code *must* succeed,
evaluating to `"it worked"`.

```
{
  ["ok"] "it worked"
}
["ok"]
get
```

## The Fifth VM

The entire state of a running Fifth program can be
represented by a data structure called a "VM" or *Virtual
Machine*.

A VM comprises the following data:

Field       | Type
----------- | ----
program     | `List` of `Term`s
stack       | `List` of `Term`s
environment | `Map` of `Name`s to `List`s of `Term`s

The meanings of these fields and their data types will be
described in the following sections.

In brief:

The **program** stores the list of `Term`s to be `invoke`d
in the future. It's the VM's to-do list. The first item in
the list is the next to be `invoke`d. When a `Term` is
`invoke`d, it is removed from the `program`.

The **stack** stores `Term`s that the programmer wants to
save temporarily, for use later in the program. Invoking a
`Term` often adds an item to the `stack`, or removes items
from the `stack`. Items to be affected by a `Term` are
located by counting from the first item in the `stack`.
`Term`s almost always affect the first item (or first few
items) in the `stack`, rather than reaching for later items.

The **environment** stores items that the programmer wants
to save for a longer time, or preserve from the meddling
effects of the `Term`s that will be `invoke`d next. When the
interpreter encounters a `Name` that is not given a special
meaning by the Fifth language, it looks up the definition
for that name in the `environment` and prepends the
definition (a list of `Term`s) to the `program`. Such
`Name`-definition pairs are called `macro`s, and the act of
prepending their definitions to the `program` is called
*macro expansion*.

### Invoking a Term

To `invoke` a `Term` is to pop it off the `program` `List`
and possibly alter the VM state in some additional way.

When the `Term` being `invoke`d is a Number, String, List,
or Map, the effect of the invocation is simply to push the
`Term` onto the `stack`.

Therefore, after one execution step, the following VM:

```
{
  program ["hello"]
  stack []
  environment {}
}
```

will look like this:

```
{
  program []
  stack ["hello"]
  environment {}
}
```

For the last type of `Term`, `Name`, invocation is more
complex. If the `Name` refers to a built-in Fifth
instruction, the interpreter simply executes that
instruction. Details of each built-in instruction will be
given in a subsequent section.

If the `Name` isn't a built-in instruction, the
interpreter looks in the VM's `environment` for a key that
equals the `Name`. If there is one, the value (which must be
a list) is prepended to the VM's `program`.

Thus, after one execution step, the following VM:

```
{
  program [film]
  stack []
  environment { film [lights camera action] }
}
```

will look like this:

```
{
  program [lights camera action]
  stack []
  environment { film [lights camera action] }
}
```

...and on the subsequent step it will crash, because
`lights` isn't a built-in instruction, and there's no
definition for it in the `environment`.

### Self-Hosted VMs

It is possible, and indeed easy, to represent a VM state
as a Fifth `Term`. Thus, Fifth programs can simulate other
Fifth programs, by constructing a VM and handing it off to
the interpreter. This allows for things like test frameworks
and programs that safely execute untrusted third-party code.

## Interacting With the World

The VM, being merely a data value, does not provide a means
for a Fifth program to interact with the stateful, outside
world. Examples of such interactions include reading and
writing files, making network calls, getting the current
time, and generating random data.

These actions are not defined within the Fifth language *per
se*. However, Fifth programs can accomplish all of them and
more by **yielding** control to a higher power. Typically,
this is the language in which the Fifth interpreter is
implemented, though Santa Claus has also been known to
intervene in Fifth programs from time to time.

To escalate control to the interpreter, you use the `yield`
`Term`. When the interpreter reaches a `yield`, it stops
normal execution, and inspects the VM state to figure out
what to do. Generally, the `Term` at the top of the stack
provides further clues by naming a command: e.g. `[random]`
tells the interpreter to generate a random number. Assuming
the interpreter recognizes the command, it performs the
requested action and then modifies the state of the VM to
receive the results: e.g. by pushing a random number onto
the stack. The interpreter then continues executing the
program using the modified VM state.

If the interpreter does not recognize the command or the
execution of the command fails, the interpreter signals an
error to the user, and execution of the VM state does not
continue.
