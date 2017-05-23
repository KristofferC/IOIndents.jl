__precompile__()

module IOIndents

import Base: convert, show, pipe_reader, pipe_writer, lock, unlock, write,
             getindex, in, haskey, get, print

export IOIndent, Indent, Dedent, Align, Dealign, indent_string!, alignment_char!

struct Indent end
struct Dedent end

struct Align end
struct Dealign end

mutable struct IOIndent{IO_t <: IO} <: Base.AbstractPipe
    io::IO_t
    indent_level::Int
    aligns::Vector{Int}
    offset::Int
    indented_line::Bool
    indent_str::String
    align_char::Char

    function IOIndent{IO_t}(io::IO_t, indent_level::Int, aligns::Vector{Int},
                            offset::Int, indented_line::Bool, indent_str::String,
                            align_char::Char) where IO_t <: IO
        assert(!(IO_t <: IOIndent))
        return new(io, indent_level, aligns, offset, indented_line, indent_str, align_char)
    end
end

indent_string!(io::IOIndent, str::String) = (io.indent_str = str; io)
alignment_char!(io::IOIndent, chr::Char) = (io.align_char = chr; io)

IOIndent(io::IO) = IOIndent{typeof(io)}(io, 0, Int[], 0, false, "    ", ' ')

convert(::Type{IOIndent}, io::IOIndent) = io

in(key_value::Pair, io::IOIndent) = in(key_value, io.io, ===)
haskey(io::IOIndent, key) = haskey(io.io, key)
getindex(io::IOIndent, key) = getindex(io.io, key)
get(io::IOIndent, key, default) = get(io.io, key, default)

function show(_io::IO, io::IOIndent)
    ioi = IOIndent(_io)
    print(ioi, "IOIndent:", Indent())
    print(ioi, "\nIO: "); show(ioi, io.io)
    print(ioi, "\nIndent string: \"", io.indent_str, "\"")
    print(ioi, "\nAlign char: \"", io.align_char, "\"")
    print(ioi, "\nIndent: ", io.indent_level)
    print(ioi, "\nAligns: ", join(io.aligns, ","))
end

pipe_reader(io::IOIndent) = io.io
pipe_writer(io::IOIndent) = io.io
lock(io::IOIndent) = lock(io.io)
unlock(io::IOIndent) = unlock(io.io)

displaysize(io::IOContext) = displaysize(io.io)

write(io::IOIndent, ::Indent) = (io.indent_level += 1; 0)
print(io::IOIndent, ::Indent) = write(io, Indent())
write(io::IOIndent, ::Dedent) = (io.indent_level = max(0, io.indent_level - 1); 0)
print(io::IOIndent, ::Dedent) = write(io, Dedent())

_align_length(io) = length(io.aligns) == 0 ? 0 : io.aligns[end]
write(io::IOIndent, ::Align) = (push!(io.aligns, io.offset + _align_length(io)); 0)
print(io::IOIndent, ::Align) = write(io, Align())
write(io::IOIndent, ::Dealign) = (length(io.aligns) > 0 && pop!(io.aligns); 0)
print(io::IOIndent, ::Dealign) = write(io, Dealign())

write_indent(io::IOIndent) = write(io.io, io.indent_str^io.indent_level)
write_offset(io::IOIndent) = write(io.io, string(io.align_char)^_align_length(io))

function write(io::IOIndent, str::String)
    written = 0
    for (i, line) in enumerate(split(str, "\n"))
        if i != 1
            written += write(io.io, "\n")
            io.indented_line = false
            io.offset = 0
        end
        if !io.indented_line && !isempty(line)
            written += write_indent(io)
            written += write_offset(io)
            io.indented_line = true
        end
        written += write(io.io, line)
        io.offset += strwidth(line)
    end
    return written
end

end # module
