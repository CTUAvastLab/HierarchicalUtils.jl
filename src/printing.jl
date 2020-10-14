const COLORS = [:blue, :red, :green, :yellow, :cyan, :magenta]

function paddedprint(io, s...; color=:default, pad=[])
    for (c, p) in pad
        printstyled(io, p, color=c)
    end
    printstyled(io, s..., color=color)
end

_printkeys(ch) = ["" for _ in eachindex(ch)]
_printkeys(ch::Union{NamedTuple, Dict, OrderedDict}) = ["$k: " for k in keys(ch)]
_printkeys(ch::PairVec) = ["$k: " for (k,v) in ch]

function _printtree(io::IO, n, C, d, p, e, trav, htrunc, vtrunc)
    c = isa(NodeType(n), LeafNode) ? :white : C[1+d%length(C)]
    nr = noderepr(n)
    gap = " " ^ clamp(length(nr)-1, 0, 2)
    paddedprint(io, nr * (trav ? ' ' * "[\"$(stringify(e))\"]" : ""), color=c)
    CH = printchildren(n)
    PK = _printkeys(CH)
    CH = _iter(CH)
    nch = length(CH)

    function _printchild(i, ch, pk, l)
        println(io)
        line = (i == nch ? "└" : "├") * "─" ^ (2 + l-length(pk))
        paddedprint(io, gap * line * " " * pk, color=c, pad=p)
        ns = gap * (i == nch ? ' ' : '│') * " " ^ (3+l)
        _printtree(io, ch, C, d+1, [p; (c, ns)], e * encode(i, nch), trav, htrunc, vtrunc)
    end

    if nch > 0
        if d+1 >= htrunc
            println(io)
            paddedprint(io, gap * '⋮', color=c, pad=p)
        elseif nch > vtrunc
            l2 = vtrunc < 2 ? 0 : (vtrunc < 4 ? 1 : 2)
            l1 = vtrunc - l2
            int1, int2 = 1:l1, nch-l2+1:nch
            l = reduce(max, vcat(length.(PK)[int1], length.(PK)[int2]), init=0)
            coll = enumerate(zip(CH, PK)) |> collect

            for (i, (ch, pk)) in coll[int1]
                _printchild(i, ch, pk, l)
            end

            println(io)
            line = "│" * " " ^ l
            paddedprint(io, gap * line * " ⋮" , color=c, pad=p)

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
function printtree(io::IO, n; trav::Bool=false, htrunc::Real=Inf, vtrunc::Real=Inf)
    @assert htrunc ≥ 0 "htrunc must be ≥ 0"
    @assert vtrunc ≥ 0 "vtrunc must be ≥ 0"
    _printtree(io, n, COLORS, 0, [], "", trav, htrunc, vtrunc)
end
