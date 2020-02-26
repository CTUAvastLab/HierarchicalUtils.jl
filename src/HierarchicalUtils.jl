# TODO
# Vilo chce pracovat naraz se schematem a samplem, protoze schema nese informace/statistiky, problem je v tom, ze schema muze mit jinou strukturu nez ten sample! nejak to vymyslet
# Work with individual samples and not whole batches. napr. map, viz. Slack
# pretizit view, aby slo ziskat jednotlive samply - Mill vymyslet
# treemap, treemap!, map na listy a vratit seznam vysledku - treemap! nasledovany LeafIteratorem?, zipmap! -> funkce vice promennych, vraci tuple, ktery se zase rozprostre do stromu
# reflectinmodel -> treemap
# map over multiple trees with the same structure simultaneously using a function of multiple arguments.
# Matej neco na ten zpusob co chtel
# tests
# odebrat vse z Millu, zmenit dokumentaci Millu

module HierarchicalUtils

const COLORS = [:blue, :red, :green, :yellow, :cyan, :magenta]

abstract type NodeType end
struct LeafNode <: NodeType end
struct InnerNode <: NodeType end
NodeType(::Type{T}) where T = @error "Define NodeType(::Type{$T}) to be either LeafNode() or InnerNode()"
NodeType(x::T) where T = NodeType(T)

# TODO
childrenfield(x::T) where T = @error "Define childrenfield(::$T) to be the field of the structure pointing to the children"

isleaf(x) = isleaf(NodeType(x))
isleaf(::LeafNode) = true
isleaf(::InnerNode) = false

children_string(x) = children_string(NodeType(x), x)
children_string(::LeafNode, _) = []
# children_string(::InnerNode, ::T) where T = @error "Define children_string(x) for type $T of x returning an iterable of descriptions for each child, empty strings are possible"
children_string(::InnerNode, n::T) where T = ["" for _ in eachindex(children(n))]

children(x) = children(NodeType(x), x)
children(::InnerNode, ::T) where T = @error "Define children(x) for type $T of x returning an iterable of children of x"
children(::LeafNode, _) = []

nchildren(x) = nchildren(NodeType(x), x)
nchildren(::LeafNode, _) = 0
nchildren(::InnerNode, x) = length(children(x))

head_string(::T) where T = @error "Define head_string(x) for type $T of x for hierarchical printing, empty string is possible"
# tail_string(::InnerNode, ::T) where T = @error "Define tail_string(x) for type $T of x for hierarchical printing, empty string is possible"

function paddedprint(io, s...; color=:default, pad=[])
    for (c, p) in pad
        printstyled(io, p, color=c)
    end
    printstyled(io, s..., color=color)
end

function _printtree(io::IO, n, C, d, p, e, trav, trunc_level)
    c = NodeType(n) == LeafNode() ? :white : C[1+d%length(C)]
    gap = " " ^ min(2, length(head_string(n))-1)
    paddedprint(io, head_string(n) * (trav ? ' ' * "[\"$(stringify(e))\"]" : ""), color=c)
    nch = nchildren(n)
    if nch > 0 && d >= trunc_level
        println(io)
        paddedprint(io, gap * '⋮', color=c, pad=p)
    elseif nch > 0
        CH, CHS = children(n), children_string(n)
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

nnodes(t) = 1 + mapreduce(nnodes, +, children(t); init=0)
nleafs(t) = mapreduce(nleafs, +, children(t); init=0) + nchildren(t) == 0

# TODO imports
include("iterators.jl")
include("maps.jl")
include("traversal_encoding.jl")

# TODO exports
export print

end # module
