const COLORS = [:blue, :red, :green, :yellow, :cyan, :magenta]
const H_LINE = '─'
const H_ELLIPSIS = '⋯'
const V_LINE = '│'
const V_ELLIPSIS = '┊'
const SPLIT = '├'
const ENDING = '╰'

mutable struct DisplaySizePrinter{T <: IO, U <: Number}
    io::T
    W::U
    w::U
    h::U
end

DisplaySizePrinter(io::IO, W::Number, H::Number) = DisplaySizePrinter(io, W, W, H)

function Base.println(p::DisplaySizePrinter, pad)
    p.h > 0 || return
    if p.h ≥ 1
        println(p.io)
        p.w = p.W
    end
    if p.h == 1
        print_last(p, pad)
    end
    p.h -= 1
end

function printstyled(p::DisplaySizePrinter, s; kwargs...)
    (p.w > 0 && p.h > 0) || return
    if p.w ≤ 1 + length(s)
        s = chop(s, tail=length(s) - p.w + 1)
        if !endswith(s, ' ')
            s = chop(s, tail=1) * ' '
        end
        Base.printstyled(p.io, s; kwargs...)
        Base.printstyled(p.io, repeat(' ', p.w - length(s) - 1) * H_ELLIPSIS; color=:light_black)
        p.w = 0
    else
        p.w -= length(s)
        Base.printstyled(p.io, s; kwargs...)
    end
end

function print_last(printer::DisplaySizePrinter, pad; kwargs...)
    printer.h -= 1
    for (c, p) in pad
        Base.printstyled(printer.io, replace(p, V_LINE => V_ELLIPSIS); color=c)
    end
end

function paddedprint(io, s; pad=[], color=:default, kwargs...)
    @nospecialize
    for (c, p) in pad
        printstyled(io, p; color=c, kwargs...)
    end
    printstyled(io, s; color, kwargs...)
end

_printkeys(ch) = ["" for _ in eachindex(ch)]
_printkeys(ch::Union{NamedTuple, Dict, OrderedDict}) = ["$k: " for k in keys(ch)]
_printkeys(ch::PairVec) = ["$k: " for (k, _) in ch]

function _print_current(printer, n, c, e, trav, comments)
    nr = sprint(nodeshow, n, context=printer.io)
    if trav
        nr *= " [\"" * stringify(e) * "\"]"
    end
    paddedprint(printer, nr, color=c)
    if comments
        nc = sprint(nodecommshow, n, context=printer.io)
        if !isempty(nc)
            paddedprint(printer, ' ' * nc, color=:light_black)
        end
    end
    gap = repeat(' ', clamp(length(nr)-1, 0, 2))
    return gap
end

function _printtree(printer, n, C, d, p, pl, e, trav, htrunc, vtrunc, comments)
    @nospecialize
    printer.h > 0 || return

    c = isa(NodeType(n), LeafNode) ? :default : C[1 + d % length(C)]
    gap = _print_current(printer, n, c, e, trav, comments)

    CH = printchildren(n)
    PK = _printkeys(CH)
    CH = _iter(CH)
    nch = length(CH)

    function _printchild(i, ch, pk, l)
        println(printer, [p; (c, gap * V_LINE)])
        line = (i == nch ? ENDING : SPLIT) * repeat(H_LINE, 2 + l - length(pk))
        paddedprint(printer, gap * line * ' ' * pk, color=c, pad=p)
        ns = gap * (i == nch ? ' ' : V_LINE) * repeat(' ', 3 + l)
        _printtree(printer, ch, C, d+1, [p; (c, ns)], pl + length(ns),
                    e * encode(i, nch), trav, htrunc, vtrunc, comments)
    end

    if nch > 0
        if d+1 >= htrunc || pl + length(gap) + 6 > printer.W
            println(printer, [p; (c, gap * V_LINE)])
            paddedprint(printer, gap * V_ELLIPSIS, color=c, pad=p)
        elseif nch > vtrunc && vtrunc + 1 < printer.h
            l2 = vtrunc < 2 ? 0 : (vtrunc < 4 ? 1 : 2)
            l1 = vtrunc - l2
            int1, int2 = 1:l1, nch-l2+1:nch
            l = reduce(max, vcat(length.(PK)[int1], length.(PK)[int2]), init=0)
            coll = enumerate(zip(CH, PK)) |> collect

            for (i, (ch, pk)) in coll[int1]
                _printchild(i, ch, pk, l)
            end

            println(printer, [p; (c, gap * V_LINE)])
            paddedprint(printer, gap * V_ELLIPSIS , color=c, pad=p)

            for (i, (ch, pk)) in coll[int2]
                _printchild(i, ch, pk, l)
            end
        else
            l = maximum(length.(PK))
            for (i, (ch, pk)) in enumerate(zip(CH, PK))
                _printchild(i, ch, pk, l)
            end
        end
    end
end

printtree(n; kwargs...) = printtree(stdout, n; kwargs...)
function printtree(io::IO, n; trav::Bool=false, htrunc::Number=Inf, vtrunc::Number=Inf,
                    limit::Bool=get(io, :limit, false), breakline::Bool=true, comments::Bool=true)
    @nospecialize
    @assert htrunc ≥ 0 "htrunc must be ≥ 0"
    @assert vtrunc ≥ 0 "vtrunc must be ≥ 0"
    H, W = limit ? displaysize(io) : (Inf, Inf)
    # for "julia>" prompts and newline
    H -= 4
    # print at least one node + ellipsis
    H = max(H, 2)
    # print at least three characters before ellipsis
    W = max(W, 5)
    _printtree(DisplaySizePrinter(io, W, H), n, COLORS, 0, [], 0, "", trav, htrunc, vtrunc, comments)
    if breakline
        println(io)
    end
end
