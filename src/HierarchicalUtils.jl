# TODO
# tests - e.g. zero children inner node
# tests - unsorted children
# TODO 
# rewrite Mill (reflectinmodel -> treemap?)

module HierarchicalUtils

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

childrenfield(::T) where T = @error "Define childrenfield(::$T) to be the field of the structure pointing to the children"

# children are sorted by default
childsort(x) = x
childsort(x::NamedTuple{T}) where T = let ks = tuple(sort(collect(T))...)
    NamedTuple{ks}(x[k] for k in ks)
end

children(n) = children(NodeType(n), n)
children(::LeafNode, _) = []
children(_, ::T) where T = @error "Define children(n::$T) to return an iterable of children"

children_sorted(n) = childsort(children(n))

# printing utils
childrenstring(n) = childrenstring(NodeType(n), n)
childrenstring(::LeafNode, _) = []
childrenstring(::SingletonNode, n::T) where T = [""]
childrenstring(::InnerNode, n::T) where T = ["" for _ in eachindex(children(n))]

printchildren(n) = children(n)
printchildren_sorted(n) = childsort(printchildren(n))

noderepr(::T) where T = @error "Define noderepr(x) for type $T of x for hierarchical printing, empty string is possible"

nchildren(n) = nchildren(NodeType(n), n)
nchildren(::LeafNode, n) = 0
nchildren(::SingletonNode, n) = 1
nchildren(::InnerNode, n) = length(children(n))

export NodeType, LeafNode, SingletonNode, InnerNode
export childrenfield, children, nchildren
export noderepr, childrenstring, printchildren

include("statistics.jl")
export nnodes, nleafs

include("traversal_encoding.jl")
export encode_traversal, walk

include("printing.jl")
export printtree

include("iterators.jl")
export NodeIterator, LeafIterator, TypeIterator, PredicateIterator, ZipIterator, MultiIterator

include("maps.jl")
export treemap, treemap!, leafmap, leafmap!

end # module
