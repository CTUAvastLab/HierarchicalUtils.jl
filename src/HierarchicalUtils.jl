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

function _childsort(x::Tuple)
    ks = tuple((Symbol("i$i") for i in eachindex(x))...)
    # ks = tuple((Symbol.(eachindex(x)))...)
    NamedTuple{ks}(x)
end
function _childsort(x::NamedTuple{T}) where T
    ks = tuple(sort(collect(T))...)
    NamedTuple{ks}(x[k] for k in ks)
end
_children_sorted(n) = _childsort(children(n))
_children_pairs(ts, complete::Bool) = collect(values(_children_pairs_keys(ts, complete)))
function _children_pairs_keys(ts, complete::Bool)
    chss = [isnothing(t) ? NamedTuple() : _children_sorted(t) for t in ts]
    ks = complete ? union(keys.(chss)...) : intersect(keys.(chss)...)
    (; (Symbol(k) => tuple(
                (k in keys(chss[i]) ? chss[i][k] : nothing for i in eachindex(chss))...
               ) for k in sort(ks))...)
end

printchildren(n) = children(n)

# noderepr(::T) where T = @error "Define noderepr(x) for type $T of x for hierarchical printing, empty string is possible"
noderepr(x) = repr(x)

nchildren(n) = nchildren(NodeType(n), n)
nchildren(::LeafNode, n) = 0
nchildren(::InnerNode, n) = length(children(n))

export NodeType, LeafNode, InnerNode
export children, nchildren, set_children
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
export treemap, treemap!, leafmap, leafmap!, typemap!, typemap

end # module
