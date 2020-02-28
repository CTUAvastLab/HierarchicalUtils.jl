# TODO
# tests - e.g. zero children inner node
# TODO 
# rewrite Mill (reflectinmodel -> treemap?)

module HierarchicalUtils

abstract type NodeType end
struct LeafNode <: NodeType end
struct InnerNode <: NodeType end

NodeType(::Type{T}) where T = @error "Define NodeType(::Type{$T}) to be either LeafNode() or InnerNode()"
NodeType(x::T) where T = NodeType(T)

isleaf(n) = isleaf(NodeType(n), n)
isleaf(::LeafNode, _) = true
isleaf(::InnerNode, n) = nchildren(n) == 0

childrenfield(::T) where T = @error "Define childrenfield(::$T) to be the field of the structure pointing to the children"
children(n) = children(NodeType(n), n)
children(::InnerNode, ::T) where T = @error "Define children(n::$T) to return an iterable of children of n"
children(::LeafNode, _) = []

# childsort(x) = x
# childsort(x::NamedTuple{T}) where T = let ks = tuple(sort(collect(T))...)
#     NamedTuple{ks}(x[k] for k in ks)
# end

# TODO generated function everywhere to speedup?
# TODO should we enforce sorted children or sort here?
# @generated function children(n)
#     t = NodeType(n)
#     if isa(t, LeafNode) 
#         return ()
#     elseif isa(t, SingletonNode)
#         return :([n.$(childrenfield(n))])
#     elseif isa(t, InnerNode)
#         return :(childsort(n.$(childrenfield(n))))
#     else
#         @error "Unknown NodeType: $t in children! Please define it and restart Julia."
#     end
# end

# children(::InnerNode, n) = childsort(@eval $n.$(childrenfield(n)))
# children(::SingletonNode, _) = [@eval $n.$(childrenfield(n))]
# children(::LeafNode, _) = []

childrenstring(n) = childrenstring(NodeType(n), n)
childrenstring(::LeafNode, _) = []
childrenstring(::InnerNode, n::T) where T = ["" for _ in eachindex(children(n))]

nchildren(n) = length(children(n))
nnodes(t) = 1 + mapreduce(nnodes, +, children(t); init=0)
# TODO nleafs again working only with types
# nleafs(t) = mapreduce(nleafs, +, children(t); init=0) + Int(nchildren(t) == 0)
nleafs(t) = nleafs(NodeType(t), t)
nleafs(::LeafNode, t) = 1
nleafs(::InnerNode, t) = mapreduce(nleafs, +, children(t); init=0)

treerepr(::T) where T = @error "Define treerepr(x) for type $T of x for hierarchical printing, empty string is possible"

export NodeType, LeafNode, InnerNode
export childrenfield, children, treerepr, childrenstring
export nchildren, nnodes, nleafs

include("traversal_encoding.jl")
export encode_traversal, walk

include("printing.jl")
export printtree

include("iterators.jl")
export NodeIterator, LeafIterator, TypeIterator, PredicateIterator, ZipIterator, MultiIterator

include("maps.jl")
export treemap, treemap!, leafmap, leafmap!, zipmap, zipmap!

end # module
