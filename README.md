befunjit
========

befunjit is a just-in-time compiler for the befunge-93 language.

+ Try the [lazy runtime demo](http://adrianton3.github.io/befunjit/demos/visualizer-lazy/visualizer.html)
+ Try the [eager runtime demo](http://adrianton3.github.io/befunjit/demos/visualizer-eager/visualizer.html)

Use it from the command line via:

```
node build/befunjit.node.js [--lazy] [--time] <source>
```

Stdin/stdout are used for IO.

###Under the hood

befunjit executes programs in steps, called “jumps”. A naive befunge interpreter would move one cell at a time,
while befunjit executes more instructions at a time (called “static paths”), making the program counter\* (PC)
effectively jump from one cell to another (typically distant one).

Every jump befunjit checks its cache of compiled static paths starting from the cell indicated by the PC.

+ If a precompiled path is found then it gets executed. The compiler ceases control to the compiled code (which
 too can be thought of as a jump). Once the path is executed, control comes back to the compiler, the PC is
 updated to point to where the path ends and the process repeats - a new jump is ready to occur.

+ If, however, a precompiled path is not found then the “static path compiler” is called. This seeks out the
longest static path, compiles it, stores it and executes it as in the previous case.

A "static path" is simply the list of commands the PC encounters while running through the playfield up to
reaching an instruction which conditionally changes its direction (`|`, `_` or `?`) or detecting a cycle.
[This visualizer](http://adrianton3.github.io/befunjit/src/visualizer/visualizer.html) shows what static paths
remained cached after the execution of a program (hover the small arrows).

One of the advantages of compiling paths over interpreting them is that some instructions don't generate any
code: `^<v>`, `#`, `"` and whitespace. Even more, once isolated, a static path can be optimised using constant
folding for ex.

The reflective instruction `p` is the only thing that makes it very hard (if not impossible) to write an
ahead-of-time compiler for befunge. befunjit is a JIT compiler for that very reason: to allow handling of the
`p` command. When executed (from a compiled path), `p` alters the contents of the playfield and invalidates
any paths that pass through the affected cell. All these paths are eventually recompiled if and when the PC
gets to them. If the current executing path happens to be invalidated then it will continue executing only if
the affected cell comes before the current `p` instruction in the path. Otherwise, the compiled code ceases
control back to the compiler immediately which will in turn have to compile and execute the path starting from
the current PC.

*Note: the PC in the context of the befunjit runtime is composed of (line, colon and direction).


Changelog
---------

####r13 --- 13 mar 2016
 + added a better optimizing compiler (the StackingCompiler)
 + updated the visualizers to allow the user to pick the compiler

####r12 --- 9 mar 2016
 + fixed operand order for the compare operation
 + fixed the `\` operation in certain edge cases when using the lazy runtime
 + fixed the lazy runtime's path caching when any of `_|?` lead to a `^<v>`

####r11 --- 31 jan 2016
 + added a CLI

####r10 --- 28 jul 2015
 + reversed operand order for `-/%`
 + fixed the `\` operation for stacks with less than 2 elements
 + fixed reading chars when given no input
 + added sample programs to the visualizer

####r9 --- 26 jul 2015
 + the eager runtime recompiles the program only when reachable paths are mutated

####r8 --- 19 jul 2015
 + fixed jumping (`#`) on `_|?`
 + released a visualizer for the eager runtime

####r7 --- 6 jul 2015
 + added an alternative runtime that (eagerly) compiles the whole source code
 + fixed the `:` and the `\` instructions in edge cases
 + fixed the `g` instruction breaking the stack
 + adjusted terminology: renamed *Runtime* to *ProgramState* and *Interpreter* to *Runtime*

####r6 --- 6 aug 2014
 + replaced BasicCompiler with OptimizingCompiler

####r5 --- 1 aug 2014
 + `_|` outcomes have been swapped
 + released a visualizer for the runtime-generated code paths

####r4 --- 27 jul 2014
 + added support for `&~,` and `#`
 + handles edge cases (empty stack/input, writing/reading outside of the playfield)

####r3 --- 25 jul 2014
 + added support for `:\$`, `g` and strings

####r2 --- 22 jul 2014
 + funge-space is now toroidal
 + added support for `@` and `?`

####r1 --- 21 jul 2014
 + can compile code paths lazily and invalidate them on demand
 + supports `^<v>`, `0-9`, `+-*/%`, `|_`, ``!` ``, `&.` and `p`