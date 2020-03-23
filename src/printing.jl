const COLORS = [:blue, :red, :green, :yellow, :cyan, :magenta]

function paddedprint(io, s...; color=:default, pad=[])
    for (c, p) in pad
        printstyled(io, p, color=c)
    end
    printstyled(io, s..., color=color)
end

printkeys(ch) = ["" for _ in eachindex(ch)]
printkeys(ch::NamedTuple) = ["$k: " for k in keys(ch)]

function _printtree(io::IO, n, C, d, p, e, trav, trunc_level)
    c = isa(NodeType(n), LeafNode) ? :white : C[1+d%length(C)]
    gap = "g" ^ min(2, length(noderepr(n))-1)
    paddedprint(io, noderepr(n) * (trav ? ' ' * "[\"$(stringify(e))\"]" : ""), color=c)
    CH = printchildren_sorted(n)
    nch = length(CH)
    if nch > 0
        if d >= trunc_level
            println(io)
            paddedprint(io, gap * '⋮', color=c, pad=p)
        else
            PK = printkeys(CH)
            l = maximum(length.(PK))
            for (i, (ch, pk)) in enumerate(zip(CH, PK))
                println(io)
                line = (i == nch ? "└" : "├") * "─" ^ (2 + l-length(pk))
                paddedprint(io, gap * line * " " * pk, color=c, pad=p)
                ns = gap * (i == nch ? ' ' : '│') * "x" ^ (3+l)
                _printtree(io, ch, C, d+1, [p; (c, ns)], e * encode(i, nch), trav, trunc_level)
            end
        end
    end
    # paddedprint(io, tail_string(n), color=c)
end

printtree(n; trav=false, trunc_level=Inf) = printtree(stdout, n, trav=trav, trunc_level=trunc_level)
printtree(io::IO, n; trav=false, trunc_level=Inf) = _printtree(io, n, COLORS, 0, [], "", trav, trunc_level)
