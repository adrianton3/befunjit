befunjit
========

befunjit is a just-in-time compiler for the befunge-93 language. [Try it!](http://madflame991.github.io/befunjit/src/visualizer/visualizer.html)


###Under the hood

befunjit executes programs in steps, called “jumps”. A naive befunge interpreter would move one cell at a time while befunjit executes more instructions at a time (called “static paths”) making the IP effectively jump from one cell to another (typically distant one).

Every jump befunjit will check its cache of compiled static paths starting from the cell indicated by the IP*.

+ If a precompiled path is found then it will get executed. The compiler will cease control to the compiled code (which too can be thought of as a jump). Once the path is executed control comes back to the compiler, the IP is updated to point to where the path ends and the process repeats - a new jump is ready to occur.
+ If however, a precompiled path is not found then the “static path compiler” will be called. This will seek out the longest static path, compile it, store it and execute it as in the previous case.

A "static path" is just the list of commands the instruction pointer (IP) encounters while running through the playfield until an instruction which conditionally changes the direction of the PC is encountered (`|`, `_` or `?`) or a cycle is detected. [This visualizer](http://madflame991.github.io/befunjit/src/visualizer/visualizer.html) shows what static paths remained cached after the execution of a program (hover the small arrows).

One of the advantages of compiling paths over interpreting them is that some instructions don't generate any code: `^<v>`, `#`, `"` and whitespace. Even more, once isolated, a static path can be optimised using constant folding for ex.

The reflective instruction `p` is the only thing that makes it very hard (if not impossible) to write an ahead-of-time compiler for befunge. befunjit is a JIT compiler for exactly the same reason: to allow handling of the `p` command. When executed (from a compiled path), the `p` will alter the contents of the playfield and invalidate any paths that pass through the affected cell. All these paths will be eventually recompiled if and when the IP gets to them. If the current executing path happens to be invalidated then it will continue executing only if the affected cell comes before the current `p` instruction in the path. Otherwise, the compiled code ceases control back to the compiler immediately which will in turn have to compile and execute the path starting from the current IP.

*Note: the IP in the context of the befunjit runtime is composed of (line, colon and direction).


Changelog
---------

####v0.5.0 --- 6 aug 2014
 + replaced BasicCompiler with OptimizingCompiler

####v0.4.1 --- 1 aug 2014
 + `_|` outcomes have been swapped
 + released a visualizer for the runtime-generated code paths 

####v0.4.0 --- 27 jul 2014
 + added support for `&~,` and `#`
 + handles edge cases (empty stack/input, writing/reading outside of the playfield)

####v0.3.0 --- 25 jul 2014
 + added support for `:\$`, `g` and strings

####v0.2.0 --- 22 jul 2014
 + funge-space is now toroidal
 + added support for `@` and `?`

####v0.1.0 --- 21 jul 2014
 + can compile code paths lazily and invalidate them on demand
 + supports `^<v>`, `0-9`, `+-*/%`, `|_`, ``!` ``, `&.` and `p`