# DO NOT HESITATE TO TELL ME IF YOU NEED ANYTHING
# OR ASK, WE CAN RESPECIFY
# ANSWER SOME DESIGN QUESTIONS SO THAT EVERYONE KNOWS THE ANSWER
#
# MAIN GOALS: PROVIDE FAST, TYPE-STABLE OPERATIONS FOR ALL OF OUR HIERARCHICAL STRUCTURES
# REDUCE BOILERPLATE CODE IN Mill.jl, MillExtensions.jl, ExplainMill.jl, ...
# UNIFY EVERYDAY TOOLS ALL OF US WILL PROBABLY NEED
# GENERALITY > SPEED, performance critical code may be optimized further once we identify it,
# though some operations may be inherently slow (changing types, mutability)
# SMALL BUILDING BLOCKS TO BUILD ANYTHING
# LeafNodes -> no children
# InnerNodes -> multiple children or in collection (can be empty)
# for leaves, redefine TypeNode(::T)
# for inner nodes, redefine TypeNode(::T), childrenfield, children and OPTIONALLY children string, getindex, setindex and/or Base.show
# childrenfield 
# Restrictions:
# Leaf types and inner types for at least a partial stability
# children must be indexable AND sorted

# TODO 
# decide about sorting children
# decide about leafs encoded as traits or data
# decide about SingletonNode and children being saved not in iterable

# TODO test zero children
using HierarchicalUtils

abstract type Expression end

mutable struct Value <: Expression
    x::Number
end

mutable struct Variable <: Expression
    x::Symbol
end

mutable struct Operation <: Expression
    op::Function
    ch::Vector{Expression}
end

macro infix(expr) parseinfix(expr) end
parseinfix(e::Expr) = Operation(eval(e.args[1]), collect(map(parseinfix, e.args[2:end])))
parseinfix(x::Number) = Value(x)
parseinfix(x::Symbol) = Variable(x)
evalinfix(n::Value) = n.x
evalinfix(n::Operation) = n.op(evalinfix.(n.ch)...)

t1 = @infix ((2 + y) * 5) / (4 - x)
t2 = @infix ((10 / y) + 5) - (8 * z)

# TODO delete, testing with empty children
t1[2].ch = []

printtree(t1)

# We need to extend some methods
import HierarchicalUtils: NodeType, treerepr, children, childrenfield

NodeType(::Type{Value}) = HierarchicalUtils.LeafNode()
treerepr(n::Value) = string(n.x)

treerepr(n::Variable) = string(n.x)
NodeType(::Type{Variable}) = HierarchicalUtils.LeafNode()

NodeType(::Type{Operation}) = HierarchicalUtils.InnerNode()
treerepr(n::Operation) = string(n.op)
childrenfield(::Operation) = :ch
children(n::Operation) = n.ch

printtree(t1)

# for the sake of demo, generally not really smart
import Base.show
Base.show(io::IO, ::MIME"text/plain", n::Expression) = printtree(n)
Base.show(io::IO, n::Operation) = print(io, n.op)
Base.show(io::IO, n::Expression) = print(io, n.x)

# TODO Remove children
children(t1)
nchildren(t1)
nnodes(t1)
# only leaf types!
nleafs(t1)

# TRAVERSALS
# getindex, setindex! must be defined for a concrete type and therefore cannot be in the lib
# TODO get index clashes with subset operator in Mill?
import Base.getindex
Base.getindex(t::Operation, i::Integer) = t.ch[i]
Base.getindex(t::Operation, idxs::NTuple{N, Integer}) where N = t.ch[first(idxs)][idxs[2:end]...]
Base.getindex(t::Operation, idxs::Integer...) = t[idxs]
Base.getindex(t::Expression, i::AbstractString) = walk(t, i)
Base.setindex!(t::Operation, e::Expression, i::Integer) = t.ch[i] = e
Base.setindex!(t::Operation, e::Expression, idxs::NTuple{N, Integer}) where N = t[idxs[1:end-1]...].ch[last(idxs)] = e
Base.setindex!(t::Operation, e::Expression, idxs::Integer...) = t[idxs] = e

printtree(t1; trav=true)
encode_traversal(t1, 1, 1)

t1[1,1] === t1[1][1] == t1[encode_traversal(t1, 1, 1)]

t_golden = @infix 1 + 1/0

# all equivalent
t_golden[2,2] = t_golden;
t_golden[2][2] = t_golden;
t_golden.ch[2][2] = t_golden;

# TRUNCATION
printtree(t_golden; trunc_level=10)

# iterators return references, so they can be used to mutate objects, however *map functions are better suited
# altering the tree during iteration may break it
collect(NodeIterator(t1))
# all nodes with leaf trait, not empty InnerNodes!
collect(LeafIterator(t1))
collect(TypeIterator{Value}(t1))
collect(TypeIterator{Operation}(t1))
collect(TypeIterator{Expression}(t1))

pred(n::Operation) = in(n.op, [+, -])
pred(n::Value) = isodd(n.x)
pred(n) = true
collect(PredicateIterator(t1, pred))

collect(ZipIterator(t1, t2))
t3 = @infix x+y
collect(ZipIterator(t1, t3))

collect(MultiIterator(NodeIterator(t1), NodeIterator(t1)))
collect(MultiIterator(NodeIterator(t1), LeafIterator(t1)))

# preorder walk, once a leaf is returned -> stop, mapping applied to children of a mapped node!
# change of type is ok
# Note: for dispatching on types do not use inline definition!
t1
assignment = Dict(:x => 1, :y => 2)
t1_assigned = treemap(t1) do n
    if typeof(n) === Variable
        return Value(assignment[n.x])
    else
        # if returning the same node, be careful about mutating
        return n
    end
end
t1_assigned

t1_assigned = treemap(t1) do n
    if typeof(n) === Operation && n.op == *
        # new children will get mapped as well
        return @infix x + y
    elseif typeof(n) === Variable
        return Value(assignment[n.x])
    else
        return n
    end
end
t1_assigned

# for treemap! make f -> f!, f! mustn't change a type!, again, once children change, we used them
# treemap is useful when types inherently change (but slower!), treemap! is better for cosmetic changes
t1_copy = deepcopy(t1)
treemap!(t1_copy) do n
    if typeof(n) === Operation
        n.op = +
    else
        return n
    end
end
t1_copy
t1

# leafmap returns a list of results, as Vilo requested
t1_assigned
sin!(n::Value) = n.x = sin(n.x)
import Base: asin
asin(n::Value) = Value(asin(n.x))
leafmap!(sin!, t1_assigned)
t1_assigned
t1_asin = leafmap(asin, t1_assigned)
t1_asin
t1_assigned

# zipmap, like ZipIterator stops on first leaf of input trees (or first mapped leaf)
t1
t2
t3 = zipmap(t1, t2) do (n1, n2)
    # not generally required, specific only to this application
    @assert typeof(n1) == typeof(n2)
    if typeof(n1) == Value
        return Value(n1.x + n2.x)
    elseif typeof(n1) == Variable
        return n1
    else
        return n2
    end
end

t2
t3
zipmap!(t2, t3) do (n1, n2)
    if typeof(n1) == Value
        n1.x = -n1.x
    end
    if typeof(n2) == Variable
        n2.x = :a
    end
end
t2
t3

import HierarchicalUtils: NodeType, treerepr, childrenfield, children, childrenstring

NodeType(::Type{<:Union{ArrayNode, ArrayModel, Missing}}) = LeafNode()
NodeType(::Type{<:AggregationFunction}) = LeafNode()
NodeType(::Type{<:AbstractNode}) = InnerNode()
NodeType(::Type{<:MillModel}) = InnerNode()

treerepr(::Missing) = "∅"
treerepr(n::ArrayNode) = "ArrayNode$(size(n.data))"
treerepr(n::BagNode) = "BagNode$(size(n.data))"
treerepr(n::BagNode) = "BagNode with $(length(n.bags)) bag(s)"
treerepr(n::WeightedBagNode) = "WeightedNode with $(length(n.bags)) bag(s) and weights Σw = $(sum(n.weights))"

childrenstring(::AbstractBagNode) = [""]
children(n::AbstractBagNode) = (n.data,)
childrenfield(::AbstractBagNode) = :data

key_labels(data::NamedTuple) = 
key_labels(data) = ["" for _ in 1:length(data)]

treerepr(n::TreeNode) = "TreeNode"
# tail_string(n::TreeNode) = ""
childrenstring(n::TreeNode{<:NamedTuple}) = ["$k: " for k in keys(n.data)]
childrenstring(n::TreeNode) = ["aa" for k in keys(n.data)]
children(n::TreeNode) = n.data
childrenfield(::TreeNode) = :data

treerepr(n::ArrayModel) = "ArrayModel($(n.m))"
# tail_string(x::ArrayModel) = ""

treerepr(n::T) where T <: AggregationFunction = "$(T.name)($(length(n.C)))"
treerepr(a::Aggregation{N}) where N = "⟨" * join(treerepr(f) for f in a.fs ", ") * "⟩"
# tail_string(::AggregationFunction) = ""

treerepr(n::BagModel) = "BagModel"
# tail_string(::BagModel) = ""
childrenstring(::BagModel) = ["", "", ""]
children(n::BagModel) = (n.im, n.a, n.bm)

treerepr(n::ProductModel) = "ProductModel ↦ $(treerepr(n.m))"
# tail_string(n::ProductModel) = " ) ↦  $(n.m)"
childrenstring(n::ProductModel{<:NamedTuple}) = ["$k: " for k in keys(n.ms)]
childrenstring(n::ProductModel) = ["" for k in keys(n.ms)]
children(n::ProductModel) = n.ms

ENV["DATADEPS_LOAD_PATH"]="/Users/simon.mandlik/data"
using SampleLoaders
dataset = fetch_data(CuckooSmall, "strain")
mb = minibatch(testdata(dataset), 3)
tm, _ = mb(3)

printtree(tm)
printtree(tm; trunc_level=1)
printtree(tm; trunc_level=2)

tm = tm.data.network

tm2, _ = mb(3)
tm2 = tm2.data.network

nnodes(tm)
nleafs(tm)
# PoC we may change what a leaf is and what isn't
nleafs(tm) == length(vcat(collect(TypeIterator{Missing}(tm)), collect(TypeIterator{ArrayNode}(tm))))

# TODO
# MILL Specific
# Work with individual samples and not whole batches. napr. map, viz. Slack
# pretizit view, aby slo ziskat jednotlive samply - Mill vymyslet
#
# TODO Matej's requirement
# delete a key everywhere
# treemap!()
# replace in specific path - getindex + treemap!
 
collect(NodeIterator(tm))
# all nodes with leaf trait, not empty InnerNodes!
collect(LeafIterator(tm))
collect(TypeIterator{BagNode}(tm))

pred(n::BagNode) = length(n.bags) > 3
pred(n::TreeNode) = :offset in keys(n.data)
pred(n) = true
collect(PredicateIterator(tm, pred))

pred2(n::TreeNode) = pred(n)
pred2(n) = false
collect(PredicateIterator(tm, pred2))

using Setfield
@set tm2.data.icmp.data = ArrayNode(randn(2,2))
collect(ZipIterator(tm, tm2))

collect(MultiIterator(NodeIterator(tm), NodeIterator(tm2)))

# preorder walk, once a leaf is returned -> stop, mapping applied to children of a mapped node!
# change of type is ok
tm
tm3 = treemap(tm) do n
    if typeof(n) === TreeNode
        return ArrayNode((randn(2,2)))
    else
        return n
    end
end
tm3

t1_assigned = treemap(t1) do n
    if typeof(n) === Operation && n.op == *
        # new children will get mapped as well
        return @infix x + y
    elseif typeof(n) === Variable
        return Value(assignment[n.x])
    else
        return n
    end
end
t1_assigned

# for treemap! make f -> f!, f! mustn't change a type!, again, once children change, we used them
# treemap is useful when types inherently change (but slower!), treemap! is better for cosmetic changes
t1_copy = deepcopy(t1)
treemap!(t1_copy) do n
    if typeof(n) === Operation
        n.op = +
    else
        return n
    end
end
t1_copy
t1

# leafmap returns a list of results, as Vilo requested
t1_assigned
sin!(n::Value) = n.x = sin(n.x)
import Base: asin
asin(n::Value) = Value(asin(n.x))
leafmap!(sin!, t1_assigned)
t1_assigned
t1_asin = leafmap(asin, t1_assigned)
t1_asin
t1_assigned

# zipmap, like ZipIterator stops on first leaf of input trees (or first mapped leaf)
t1
t2
t3 = zipmap(t1, t2) do (n1, n2)
    # not generally required, specific only to this application
    @assert typeof(n1) == typeof(n2)
    if typeof(n1) == Value
        return Value(n1.x + n2.x)
    elseif typeof(n1) == Variable
        return n1
    else
        return n2
    end
end

t2
t3
zipmap!(t2, t3) do (n1, n2)
    if typeof(n1) == Value
        n1.x = -n1.x
    end
    if typeof(n2) == Variable
        n2.x = :a
    end
end
t2
t3
