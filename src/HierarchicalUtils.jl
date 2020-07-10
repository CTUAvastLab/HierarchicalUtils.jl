module HierarchicalUtils

using DataStructures

abstract type NodeType end
struct LeafNode <: NodeType end
struct InnerNode <: NodeType end

NodeType(::Type{T}) where T = @error "Define NodeType(::Type{$T}) to be either LeafNode() or InnerNode()"
NodeType(x::T) where T = NodeType(T)

isleaf(n) = isleaf(NodeType(n), n)
isleaf(::LeafNode, _) = true
isleaf(::InnerNode, n) = nchildren(n) == 0

children(n) = children(NodeType(n), n)
children(::LeafNode, _) = ()
children(_, ::T) where T = @error "Define children(n::$T) to return a NamedTuple or a Tuple of children"

# set_children(n::T, chs::U) where {T, U} = @error "Define set_children(n::$T, chs::$U) where chs are new children to use PreOrder maps"

# function _childsort(x::Tuple)
#     ks = tuple((Symbol("i$i") for i in eachindex(x))...)
#     NamedTuple{ks}(x)
# end
_childsort(x) = x
function _childsort(x::NamedTuple{T}) where T
    ks = tuple(sort(collect(T))...)
    NamedTuple{ks}(x[k] for k in ks)
end
_children_sorted(n) = _childsort(children(n))

# _children_pairs(ts, complete::Bool) = collect(values(_children_pairs_keys(ts, complete)))

function _children_pairs(ts, complete::Bool)
    chss = [isnothing(t) || isleaf(t) ? nothing : _children_sorted(t) for t in ts]
    if all(ch -> ch isa Nothing || ch isa NamedTuple, chss)
        chss = [isnothing(chs) ? NamedTuple() : chs for chs in chss]
        _children_pairs_nts(chss, complete)
    elseif all(ch -> ch isa Nothing || ch isa Tuple, chss)
        chss = [isnothing(chs) ? tuple() : chs for chs in chss]
        _children_pairs_tuples(chss, complete)
    else
        s = "Incompatible children types (NamedTuple and Tuple) of nodes: " * join([typeof(t) for t in ts], ", ", " and ")
        error(s)
    end
end

function _children_pairs_nts(chss::Vector{<:NamedTuple}, complete::Bool)
    ks = complete ? union(keys.(chss)...) : intersect(keys.(chss)...)
    (; (Symbol(k) => tuple(
                (k in keys(chss[i]) ? chss[i][k] : nothing for i in eachindex(chss))...
               ) for k in sort(ks))...)
end

function _children_pairs_tuples(chss::Vector{<:Tuple}, complete::Bool)
    ml = complete ? maximum(length.(chss)) : minimum(length.(chss))
    tuple(
          (tuple((i <= length(chs) ? chs[i] : nothing for chs in chss)...) for i in 1:ml)...
         )
end

printchildren(n) = children(n)

# noderepr(::T) where T = @error "Define noderepr(x) for type $T of x for hierarchical printing, empty string is possible"
noderepr(x) = repr(x)

nchildren(n) = nchildren(NodeType(n), n)
nchildren(::LeafNode, n) = 0
nchildren(::InnerNode, n) = length(children(n))

export NodeType, LeafNode, InnerNode
# export children, nchildren, set_children
export children, nchildren
export noderepr, printchildren

include("statistics.jl")
export nnodes, nleafs

include("traversal_encoding.jl")
export encode_traversal, walk, list_traversal

include("printing.jl")
export printtree

include("iterators.jl")
export NodeIterator, LeafIterator, TypeIterator, PredicateIterator, MultiIterator
export PreOrder, PostOrder, LevelOrder
export traverse!

include("maps.jl")
export treemap!, leafmap!, typemap!, predicatemap!, treemap

end # module
