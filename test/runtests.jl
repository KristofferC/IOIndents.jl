using IOIndents
using Base.Test
using TestSetExtensions

function test_ioindent(input, output)
    iob = IOBuffer()
    io = IOIndent(iob)
    write(io, input...)
    @test String(take!(iob)) == output
end

@testset ExtendedTestSet "Tests" begin

@testset ExtendedTestSet "nops" begin
    test_ioindent("abc", "abc")
    test_ioindent("\nabc", "\nabc")
    test_ioindent("\nabc\n", "\nabc\n")
    test_ioindent("\nabc\n ", "\nabc\n ")

    test_ioindent(("abc", Indent()), "abc")
    test_ioindent(("abc", Align(), "\n"), "abc\n")
end

@testset ExtendedTestSet "Aligns" begin
    test_ioindent(("abc", Align(), "\nde"),
    """
    abc
       de""")

    test_ioindent(("αβγ", Align(), "\nϵκ"),
    """
    αβγ
       ϵκ""")


    test_ioindent(("abc", Align(), "\nde", Align(), "fg\nhi", "\nqr",
                   Dealign(), "\njk\n", Dealign(), "lm"),
    """
    abc
       defg
         hi
         qr
       jk
    lm""")


    test_ioindent(("abc", Align(), "\nde", Align(), "fg\nhi",
                   Dealign(), "\njk\n", Dealign(), "lm"),
    """
    abc
       defg
         hi
       jk
    lm""")

    test_ioindent((
    "\\begin{axis}[", Align(),
                   "\na = 5"),
    raw"""
    \begin{axis}[
                 a = 5""")
end


@testset ExtendedTestSet "Indents" begin
    test_ioindent(("abc\n", Indent(), Indent(), "cde", Dedent(),
                    "\nfgh\n", Dedent(), "ijk"),
    raw"""
    abc
            cde
        fgh
    ijk""")
end  # testset


@testset ExtendedTestSet "Mixed" begin
    test_ioindent((
    "\\begin{axis}[", Align(),
                   "a = 5,\nb = 5,", "\n",
                   "c = 5]",
        Dealign(), "\n",
        Indent(),
        "\\begin{plot}[", Align(),
                       "a = 5,\n", "b = 5,\n",
                        "c = 5]", Dealign(), "\n",
        "foo", Align(),
            "\nbar", Dealign(), Dedent(), Dedent(),
    "\nbase"),
    raw"""
    \begin{axis}[a = 5,
                 b = 5,
                 c = 5]
        \begin{plot}[a = 5,
                     b = 5,
                     c = 5]
        foo
           bar
    base""")
end

@testset ExtendedTestSet "README" begin

    test_ioindent(("[", Align(),
      "a = 1,",
      "\nb = ", Align(), "[",
      "c = 3,",
      "\n d = 4]", Dealign(),
      "\ne = 5]", Dealign()),
    raw"""
    [a = 1,
     b = [c = 3,
          d = 4]
     e = 5]""")

    test_ioindent(("function f(", Align(),
                          "a_long_argument,",
                          "\nanother_argument;",
                          "\na_keyword = :default", Dealign(),
                          "\nend"),
    raw"""
    function f(a_long_argument,
               another_argument;
               a_keyword = :default
    end""")


    test_ioindent(("function f(x)\n", Indent(),
                     "if x == 1\n", Indent(),
                     "return x\n", Dedent(),
                     "end\n", Dedent(),
                     "end"),
    raw"""
    function f(x)
        if x == 1
            return x
        end
    end""")
end

@testset ExtendedTestSet "IOContext" begin
    io = IOIndent(IOContext(IOBuffer(), :foo => true))
    @test get(io, :foo, false) == true
    @test get(io, :foobar, false) == false
    @test haskey(io, :foo) == true
    @test haskey(io, :foobar) == false
end

@testset ExtendedTestSet "nop normal IO" begin
    io = IOBuffer()
    print(io, "foo", Indent(), Dedent(), "bar\n", Indent(), "baz")
    @test String(take!(io)) == "foobar\nbaz"
end

@testset ExtendedTestSet "show" begin
    io = IOBuffer()
    show(io, IOIndent(IOBuffer()))
    @test String(take!(io)) == """
    IOIndent:
        IO: IOBuffer(data=UInt8[...], readable=true, writable=true, seekable=true, append=false, size=0, maxsize=Inf, ptr=1, mark=-1)
        Indent string: "    "
        Align char: " "
        Indent: 0
        Aligns: """
end

end
