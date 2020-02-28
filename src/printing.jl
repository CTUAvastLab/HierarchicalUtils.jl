const COLORS = [:blue, :red, :green, :yellow, :cyan, :magenta]

function paddedprint(io, s...; color=:default, pad=[])
    for (c, p) in pad
        printstyled(io, p, color=c)
    end
    printstyled(io, s..., color=color)
end

function _printtree(io::IO, n, C, d, p, e, trav, trunc_level)
    c = isa(NodeType(n), LeafNode) ? :white : C[1+d%length(C)]
    gap = " " ^ min(2, length(treerepr(n))-1)
    paddedprint(io, treerepr(n) * (trav ? ' ' * "[\"$(stringify(e))\"]" : ""), color=c)
    nch = nchildren(n)
    if nch > 0 && d >= trunc_level
        println(io)
        paddedprint(io, gap * '⋮', color=c, pad=p)
    elseif nch > 0
        CH, CHS = children(n), childrenstring(n)
        for (i, (ch, chs)) in enumerate(zip(CH, CHS))
            println(io)
            paddedprint(io, gap * (i == nch ? "└" : "├") * "── " * chs, color=c, pad=p)
            ns = gap * (i == nch ? ' ' : '│') * repeat(" ", max(3, 2+length(chs)))
            _printtree(io, ch, C, d+1, [p; (c, ns)], e * encode(i, nch), trav, trunc_level)
        end
    end
    # paddedprint(io, tail_string(n), color=c)
end

printtree(n; trav=false, trunc_level=Inf) = printtree(stdout, n, trav=trav, trunc_level=trunc_level)
printtree(io::IO, n; trav=false, trunc_level=Inf) = _printtree(io, n, COLORS, 0, [], "", trav, trunc_level)
