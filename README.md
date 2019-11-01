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
implement a Fifth interpreter. Fifth is also supposed to be
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
what to do. Generally, the `Term` at the top of the `stack`
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

## Notation for Functional Macro Signatures

Fifth has a conventional notation for describing in comments
the effect that a macro has on the `stack`.

The general format is:

```
(inputs -> outputs)
```

Where the inputs and outputs are given in the order that
they would appear if written literally in a Fifth program.

For example:

```
(dividend divisor div-rem -> quotient remainder)
```

means that the Fifth `Term`s `7 2 div-rem`, when executed
as part of a program, have exactly the same effect on the
stack as the `Term`s `3 1` (since 7/2 is 3 in integer math,
and the remainder of 7/2 is 1).

## Mathematics

The arithmetic operations `add`, `sub`, `mul`, and `div`
must be implemented by the Fifth interpreter. Other
mathematical operations are implemented in the standard
library.

The four arithmetic operations operate on rational
numbers and produce an exact rational representation of the
result. I.e. there is no rounding.

```
(a b add -> sum)
(minuend subtrahend sub -> difference)
(a b mul -> product)
(dividend divisor div -> fraction)
```

The standard library implements `div-rem` (which performs
division with a remainder), `abs` (absolute value), and the
integer-rounding functions `ceiling` and `floor`.

```
(dividend divisor div-rem -> quotient remainder)
(x abs -> absolute-value)
(x ceiling -> smallest-int-at-least-x)
(x floor -> largest-int-at-most-x)
```

### Irrational Numbers

The standard library implements the functions `pow`, `ln`,
`sin`, `cos`, `tan`, `asin`, `acos`, and `atan`. Since each
of these may produce irrational results, the Fifth
programmer must specify the maximum error allowed in the
result.

```
(base max-error exponent pow -> result)
(n max-error ln -> result)
```

The Fifth programmer can easily implement a square-root
function if required, using the fact that `sqrt(n)` is
`n^(1/2)`:

```
(n max-error sqrt -> root)
[sqrt]
[
  1/2 pow
]
define
```

When the value of a trigonometric function is `0`, `1`, or
`-1`, the corresponding Fifth function must output exactly
that value.

Additionally, the `pow` function is guaranteed to produce
an exact rational result whenever the `exponent` is an
integer.

Constants for `pi` and `e` are not provided, but they can
be calculated to any desired precision using the identities
`pi = acos(-1)` and `e = [0..inf].map(n -> 1/n!).sum`

## Interruptability

A Fifth interpreter may run in a single-threaded environment
with cooperative multitasking (e.g. a web page), where an
infinite loop would cause the interpreter and its user
interface to hang. A correct interpreter must be able to
yield the CPU after every interpretation step, though it
need not do so.

This requirement is reflected in the interface of the
`evolve` instruction, which allows a Fifth program to call
the interpreter:

```
(vm steps evolve -- vm)
```

To `evolve` a VM by 1000 steps, you'd do

```
my-vm 1000 evolve
```

Since every evolution step is a computation that must
terminate, there is no way for a Fifth program to force the
interpreter into an infinite loop. Even in a single-threaded
environment, running untrusted code, the user will always
be able to stop a runaway Fifth program without destroying
the VM state.

## Idioms

### Loops

```
[ (this list is the loop body)
  do something

  (loop again if should-continue? is true)
  should-continue? [
    dup
    eval
  ] [
    (else, remove the loop body from the stack)
    forget
  ] if
]
dup (duplicate the loop, so it can "call" itself recursively
  if another iteration should be performed)
eval
```

Since `dup eval` is so common in looping constructs, the
standard library defines a macro `loop` which simply does
`dup eval`.

## Optimization

To keep the core of Fifth simple, many seemingly basic
utilities, like the ability to create loops and define
functions, have been pushed off to the standard library
rather than specified as part of the language. This lowers
the amount of code one must write to implement a Fifth
interpreter, at some cost to performance.

The hope is that by keeping language features simple and
orthogonal, the language will be relatively easy to optimize
in the places where optimization is needed.

One language feature that could thwart optimization is the
ability of programs to redefine macros. I'm assuming that
optimization involves the interpreter looking ahead at the
program `Term`s to be evaluated, expanding macros to produce
a sequence of primitive instructions, and then looking for
sequences of instructions that can be transformed into
more efficient ones. In order for the interpreter to do
this, it needs to be certain that the macros it's expanding
are not going to be redefined before they are actually
reached in the course of execution. I believe JavaScript
engines run into similar optimization issues in the presence
of `with` statements, where it's impossible to determine
what a variable name refers to until the code actually runs.

To avoid running into the same problems that have plagued
JavaScript, I think it's important to have few ways of
modifying values in the environment, so that the optimizer
can definitively tell when a macro is redefined.

Instructions that change the environment include:

```
env-replace
env-set
yield
```

While `env-replace` is not orthogonal to `env-set`, I think
it's important for them to be separate, since `env-set` is
likely to be used in the majority of cases and since it may
be very useful for the optimizer to retain the ability to
expand macros that were *not* affected by the `env-set`.

`yield` and `env-replace` are both optimization firewalls,
since they can in principle change anything in the
environment.
