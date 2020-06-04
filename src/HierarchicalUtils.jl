module HierarchicalUtils

# using Setfield
using DataStructures

abstract type NodeType end
struct LeafNode <: NodeType end
struct InnerNode <: NodeType end
# struct SingletonNode <: NodeType end

# NodeType(::Type{T}) where T = @error "Define NodeType(::Type{$T}) to be either LeafNode(), SingletonNode() or InnerNode()"
NodeType(::Type{T}) where T = @error "Define NodeType(::Type{$T}) to be either LeafNode() or InnerNode()"
NodeType(x::T) where T = NodeType(T)

isleaf(n) = isleaf(NodeType(n), n)
isleaf(::LeafNode, _) = true
# isleaf(::SingletonNode, _) = false
isleaf(::InnerNode, n) = nchildren(n) == 0

# childrenfields(::Type{T}) where T = @error "Define childrenfields(::$T) to be the iterable over fields of the structure pointing to the children"
# childrenfields(::T) where T = childrenfields(T)

children(n) = children(NodeType(n), n)
children(::LeafNode, _) = ()
children(_, ::T) where T = @error "Define children(n::$T) to return a NamedTuple or a Tuple of children"

# TODO rename NodeTypes?
# TODO solve better the NamedTuple x Tuple problem while storing
set_children(n, chs) = @error "Define set_children(n::$T, chs) where chs are new children to use PreOrder maps"
# function set_children(::SingletonNode, n::T, chs) where T
#     for (chf, ch) in zip(childrenfields(T), values(chs))
#         @eval @set! $n.$(chf) = $ch
#     end
#     n
# end
# function set_children(::InnerNode, n::T, chs) where T
#     @show T
#     @show @eval childrenfields(Operation)
#     @eval @set $n.$(only(childrenfields(T))) = $chs
# end


# function _childsort(x::Tuple)
#     # ks = tuple((Symbol('a' + i - 1) for i in eachindex(x))...)
#     # NamedTuple{ks}(x)
#     x
# end
_childsort(x) = x
function _childsort(x::NamedTuple{T}) where T
    ks = tuple(sort(collect(T))...)
    NamedTuple{ks}(x[k] for k in ks)
end
_children_sorted(n) = _childsort(children(n))
_children_pairs(ts, complete::Bool) = collect(values(_children_pairs_keys(ts, complete)))
# function _children_pairs(ts, complete::Bool)
#     chss = [isnothing(t) ? NamedTuple() : _children_sorted(t) for t in ts]
#     ks = complete ? union(keys.(chss)...) : intersect(keys.(chss)...)
#     [tuple((k in keys(chss[i]) ? chss[i][k] : nothing for i in eachindex(chss))...)
#          for k in sort(ks)]
# end
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
# nchildren(::SingletonNode, n) = 1
nchildren(::InnerNode, n) = length(children(n))

# export NodeType, LeafNode, SingletonNode, InnerNode
export NodeType, LeafNode, InnerNode
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
export PreOrder, PostOrder, LevelOrder
export traverse!

include("maps.jl")
export treemap, treemap!, leafmap, leafmap!, typemap!, typemap

end # module
