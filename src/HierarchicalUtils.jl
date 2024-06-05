module HierarchicalUtils

using DataStructures
using OrderedCollections: OrderedDict

abstract type NodeType end
struct LeafNode <: NodeType end
struct InnerNode <: NodeType end

const PairVec = Vector{<:Pair}

NodeType(::Type{T}) where T = error("Define NodeType(::Type{$T}) to be either LeafNode() or InnerNode()")
NodeType(::T) where T = NodeType(T)

isleaf(n) = isleaf(NodeType(n), n)
isleaf(::LeafNode, _) = true
isleaf(::InnerNode, n) = nchildren(n) == 0

children(n) = children(NodeType(n), n)
children(::LeafNode, _) = ()
children(_, ::T) where T =
    error("Define children(n::$T) to return a collection of children (one of allowed types)")

printchildren(n) = children(n)

nodeshow(io, x) = Base.show(io, x)
nodecommshow(_, _) = nothing

nchildren(n) = nchildren(NodeType(n), n)
nchildren(::LeafNode, n) = 0
nchildren(::InnerNode, n) = length(children(n))
nprintchildren(n) = nchildren(n)

export NodeType, LeafNode, InnerNode
export children, nchildren, isleaf
export nodeshow, nodecommshow, printchildren

include("utilities.jl")

include("statistics.jl")
export nnodes, nleafs, treeheight

include("traversal_encoding.jl")
export encode_traversal, walk, list_traversal, find_traversal, pred_traversal

include("printing.jl")
export printtree

include("iterators.jl")
export NodeIterator, LeafIterator, TypeIterator, PredicateIterator, MultiIterator
export PreOrder, PostOrder, LevelOrder
export traverse!

include("maps.jl")
export treemap!, leafmap!, typemap!, predicatemap!, treemap

include("definitions.jl")
export @hierarchical_dict, @hierarchical_vector, @primitives

end # module
