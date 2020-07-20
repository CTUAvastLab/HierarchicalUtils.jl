const COLORS = [:blue, :red, :green, :yellow, :cyan, :magenta]

function paddedprint(io, s...; color=:default, pad=[])
    for (c, p) in pad
        printstyled(io, p, color=c)
    end
    printstyled(io, s..., color=color)
end

printkeys(ch) = ["" for _ in eachindex(ch)]
printkeys(ch::NamedTuple) = ["$k: " for k in keys(ch)]

# sort for named tuples only
_printchildrensort(x) = x
function _printchildrensort(x::NamedTuple{T}) where T
    ks = tuple(sort(collect(T))...)
    NamedTuple{ks}(x[k] for k in ks)
end

function _printtree(io::IO, n, C, d, p, e, trav, trunc)
    c = isa(NodeType(n), LeafNode) ? :white : C[1+d%length(C)]
    nr = noderepr(n)
    gap = " " ^ clamp(length(nr)-1, 0, 2)
    paddedprint(io, nr * (trav ? ' ' * "[\"$(stringify(e))\"]" : ""), color=c)
    CH = _printchildrensort(printchildren(n))
    nch = length(CH)
    if nch > 0
        if d >= trunc
            println(io)
            paddedprint(io, gap * '⋮', color=c, pad=p)
        else
            PK = printkeys(CH)
            l = maximum(length.(PK))
            for (i, (ch, pk)) in enumerate(zip(CH, PK))
                println(io)
                line = (i == nch ? "└" : "├") * "─" ^ (2 + l-length(pk))
                paddedprint(io, gap * line * " " * pk, color=c, pad=p)
                ns = gap * (i == nch ? ' ' : '│') * " " ^ (3+l)
                _printtree(io, ch, C, d+1, [p; (c, ns)], e * encode(i, nch), trav, trunc)
            end
        end
    end
end

printtree(n; trav=false, trunc=Inf) = printtree(stdout, n, trav=trav, trunc=trunc)
printtree(io::IO, n; trav=false, trunc=Inf) = _printtree(io, n, COLORS, 1, [], "", trav, trunc)
