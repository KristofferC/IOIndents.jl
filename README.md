# IOIndents

[![Build Status](https://travis-ci.org/KristofferC/IOIndents.jl.svg?branch=master)](https://travis-ci.org/KristofferC/IOIndents.jl)
[![codecov.io](http://codecov.io/github/KristofferC/IOIndents.jl/coverage.svg?branch=master)](http://codecov.io/github/KristofferC/IOIndents.jl?branch=master)

*IOIndents* facilitates writing indented and aligned text to buffers (like files or the terminal).
It provides the struct `IOIndent <: IO` that can be written to like a normal `IO` object
but, in addition, some special objects can be written to it in order to control indent and alignment.
These objects are

* `Indent()` - successive lines are indented one more level
* `Dedent()` - successive lines are indented one less level
* `Align()` - successive lines are aligned to where the "cursor" currently is
* `Dealign()` - pops the last alignment

Note that alignments work similar to a stack such that `Align()` pushes an alignment
on the stack and `Dealign()` pops it.

An `IOIndent` is created by wrapping another `IO` object e.g.

```jl
iobuffer = IOBuffer()
io = IOIndent(iobuffer)
```

**Note:** There are still some kinks that have not been entirely straightened out, leading to odd indentation in some cases.

## Examples

Indenting the body of a function:

```jl
julia> io = IOIndent(STDOUT);

julia> print(io, "function f(x)\n", Indent(),
                 "if x == 1\n", Indent(),
                 "return x\n", Dedent(),
                 "end\n", Dedent(),
                 "end")
function f(x)
    if x == 1
        return x
    end
end
```

Aligning the arguments in a function

```jl
julia> io = IOIndent(STDOUT);

julia> print(io, "function f(", Align(),
                 "a_long_argument,",
                 "\nanother_argument;",
                 "\na_keyword = :default", Dealign(),
                 "\nend")
function f(a_long_argument,
           another_argument;
           a_keyword = :default
end
```

Multiple aligns:

```jl
julia> io = IOIndent(STDOUT);

julia> print(io, "[", Align(),
                  "a = 1,",
                  "\nb = ", Align(), "[",
                  "c = 3,",
                  "\n d = 4]", Dealign(),
                  "\ne = 5]", Dealign())
[a = 1,
 b = [c = 3,
      d = 4]
 e = 5]
 ```

### Settings

You can set the indent string by using `indent_string!(::IOIndent, ::String)`, e.g:

```jl
julia> io = IOIndent(STDOUT);

julia> indent_string!(io, "xxxx")
IOIndent:
    IO: Base.TTY(RawFD(13) open, 0 bytes waiting)
    Indent string: "xxxx"
    Align char: " "
    Indent: 0
    Aligns:

julia> print(io, "Level 0", Indent(), "\nLevel1", Dedent(), "\nLevel 0")
Level 0
xxxxLevel1
Level 0
```

For alignments, the `Char` used can be set with `alignment_char!(::IOIndent, ::Char)`, e.g:

```jl
julia> io = IOIndent(STDOUT);

julia> alignment_char!(io, 'z')
IOIndent:
    IO: Base.TTY(RawFD(13) open, 0 bytes waiting)
    Indent string: "    "
    Align char: "z"
    Indent: 0
    Aligns:

julia> print(io, "Align:", Align(), "a\nb\nc", Dealign())
Align:a
zzzzzzb
zzzzzzc
```

## Misc

Printed `Indent()`, `Aling()` etc. to `IO` objects that are not of type `IOIdent`
are ignored:

```jl
julia> print(STDOUT, "foo", Indent(), "bar", Align(), "\nbaz")
foobar
baz
```

## Author

Kristoffer Carlsson - [@KristofferC](https://github.com/KristofferC)
