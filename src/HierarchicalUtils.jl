module HierarchicalUtils

using Setfield
using DataStructures

abstract type NodeType end
struct LeafNode <: NodeType end
struct InnerNode <: NodeType end
struct SingletonNode <: NodeType end

NodeType(::Type{T}) where T = @error "Define NodeType(::Type{$T}) to be either LeafNode(), SingletonNode() or InnerNode()"
NodeType(x::T) where T = NodeType(T)

isleaf(n) = isleaf(NodeType(n), n)
isleaf(::LeafNode, _) = true
isleaf(::SingletonNode, _) = false
isleaf(::InnerNode, n) = nchildren(n) == 0

childrenfields(::Type{T}) where T = @error "Define childrenfields(::$T) to be the iterable over fields of the structure pointing to the children"
childrenfields(::T) where T = childrenfields(T)

children(n) = children(NodeType(n), n)
children(::LeafNode, _) = ()
children(_, ::T) where T = @error "Define children(n::$T) to return a NamedTuple or a Tuple of children"

function _childsort(x::Tuple)
    ks = tuple((Symbol('a' + i - 1) for i in eachindex(x))...)
    NamedTuple{ks}(x)
end
function _childsort(x::NamedTuple{T}) where T
    ks = tuple(sort(collect(T))...)
    NamedTuple{ks}(x[k] for k in ks)
end
_children_sorted(n) = _childsort(children(n))
function _children_pairs(ts, complete::Bool)
    chss = [isnothing(t) ? NamedTuple() : _children_sorted(t) for t in ts]
    ks = complete ? union(keys.(chss)...) : intersect(keys.(chss)...)
    [tuple((k in keys(chss[i]) ? chss[i][k] : nothing for i in eachindex(chss))...)
         for k in sort(ks)]
end

printchildren(n) = children(n)
_printchildren_sorted(n) = _childsort(printchildren(n))

# noderepr(::T) where T = @error "Define noderepr(x) for type $T of x for hierarchical printing, empty string is possible"
noderepr(x) = repr(x)

nchildren(n) = nchildren(NodeType(n), n)
nchildren(::LeafNode, n) = 0
nchildren(::SingletonNode, n) = 1
nchildren(::InnerNode, n) = length(children(n))

export NodeType, LeafNode, SingletonNode, InnerNode
export childrenfields, children, nchildren
export noderepr, printchildren

include("statistics.jl")
export nnodes, nleafs

include("traversal_encoding.jl")
export encode_traversal, walk, list_traversal

include("printing.jl")
export printtree

include("iterators.jl")
export NodeIterator, LeafIterator, TypeIterator, PredicateIterator, MultiIterator
export traverse!

# TODO
# include("maps.jl")
# export treemap, treemap!, leafmap, leafmap!

end # module
