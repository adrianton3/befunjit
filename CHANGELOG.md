changelog
=========

####r16 --- 25 dec 2016
 + `p` is now a static path delimiter
 + tight loops bypass the stack

####r15 --- 14 aug 2016
 + the GraphCompiler generates simpler code for looping paths that originate from `_|`
 + the StackingCompiler uses a special variable for branching instead of the stack

####r14 --- 4 jun 2016
 + added the BinaryCompiler - based on the StackingCompiler

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