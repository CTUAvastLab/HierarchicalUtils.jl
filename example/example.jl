# MAIN GOALS: 
# SWISS KNIFE for working with trees - SMALL BUILDING BLOCKS TO BUILD ANYTHING
# REDUCE BOILERPLATE CODE IN Mill.jl, MillExtensions.jl, ExplainMill.jl, ...
# UNIFY EVERYDAY TOOLS ALL OF US WILL PROBABLY NEED
# GENERALITY > SPEED, performance critical code may be optimized further once we identify it,
# though some operations may be inherently slow (changing types, mutability)

# LeafNodes -> no children
# InnerNodes -> zero, one or more children in a collection 
# SingletonNodes -> one children saved as a field
#
# for leaves, redefine TypeNode(::T)
# for other nodes, redefine TypeNode(::T), childrenfields, children and OPTIONALLY printchildren and faster nchildren
#
# Restrictions:
# Leaf types and inner types for at least a partial stability
# children must be indexable structure - named tuple, tuple or vector

using HierarchicalUtils

abstract type Expression end

mutable struct Value <: Expression
    x::Number
end

mutable struct Variable <: Expression
    x::Symbol
end

# binary
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

printtree(t1)

# We need to extend some methods
import HierarchicalUtils: NodeType, noderepr, children, set_children
NodeType(::Type{Value}) = HierarchicalUtils.LeafNode()
noderepr(n::Value) = string(n.x)

noderepr(n::Variable) = string(n.x)
NodeType(::Type{Variable}) = HierarchicalUtils.LeafNode()

NodeType(::Type{Operation}) = HierarchicalUtils.InnerNode()
noderepr(n::Operation) = string(n.op)
set_children(n::Operation, chs) = Operation(n.op, collect(chs))
function children(n::Operation)
    keys = tuple([Symbol("op$i") for i in eachindex(n.ch)]...)
    NamedTuple{keys}(n.ch)
end

printtree(t1)

# for the sake of demo, generally not really smart
import Base.show
Base.show(io::IO, ::MIME"text/plain", n::Expression) = printtree(io, n)
Base.show(io::IO, n::Operation) = print(io, n.op)
Base.show(io::IO, n::Expression) = print(io, n.x)

children(t1)
nchildren(t1)
nnodes(t1)
# only leaf types!
nleafs(t1)

# TRAVERSALS
# getindex, setindex! must be defined for a concrete type and therefore cannot be in the lib
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
printtree(t_golden; trunc=10)

# iterators return references, so they can be used to slightly mutate objects, however *map functions are better suited
# altering the tree during iteration may break it
collect(NodeIterator(t1))
# all nodes with leaf trait, not empty InnerNodes!
collect(LeafIterator(t1))
collect(TypeIterator(t1, Value))
collect(TypeIterator(t1, Operation))
collect(TypeIterator(t1, Expression))
collect(TypeIterator(t1, Union{Value, Operation}))

pred(n::Operation) = in(n.op, [+, -])
pred(n::Value) = isodd(n.x)
pred(n) = true
collect(PredicateIterator(t1, pred))

collect(NodeIterator((t1, t2)))
t3 = @infix x+y
collect(NodeIterator((t1, t3); complete=false))
collect(NodeIterator((t1, t3); complete=true))

# collect(MultiIterator(NodeIterator(t1), NodeIterator(t1)))
# collect(MultiIterator(NodeIterator(t1), LeafIterator(t1)))

t1
assignment = Dict(:x => 1, :y => 2)
t1_assigned = treemap(t1) do n, chs
    if n isa Variable
        return Value(assignment[n.x])
    elseif n isa Operation
        return set_children(n, chs)
    else
        return n
    end
end

t1_assigned = treemap(t1; order=PreOrder()) do n, _
    if n isa Variable
        return Value(assignment[n.x])
    else
        return n
    end
end

t1_assigned = treemap(t1; order=PreOrder()) do n, _
    if n isa Operation && n.op == *
        # new children will get mapped as well
        return @infix x + y
    elseif n isa Variable
        return Value(assignment[n.x])
    else
        return n
    end
end

# for treemap! make f -> f!, f! mustn't change a type!, again, once children change, we used them
# treemap is useful when types inherently change (but slower!), treemap! is better for cosmetic changes
t1_copy = deepcopy(t1)
treemap!(t1_copy) do n
    if n isa Operation
        n.op = +
    else
        return n
    end
end
t1_copy
t1

# leafmap  may return a list of results, as Vilo requested, but for consistency, it is not there
# you can call leafiterator afterwards
t1_assigned
sin!(n::Value) = n.x = sin(n.x)
import Base: asin
asin(n::Value) = Value(asin(n.x))
leafmap!(sin!, t1_assigned)
t1_assigned
t1_asin = leafmap(asin, t1_assigned)
t1_asin
t1_assigned

# treemap, like ZipIterator stops on first leaf of input trees (or first mapped leaf)
# shouldn't change a structure of a tree to not
t1
t2
t3 = treemap(t1, t2) do (n1, n2)
    # not generally required, specific only to this application
    @assert typeof(n1) == typeof(n2)
    if n1 isa Value
        return Value(n1.x + n2.x)
    elseif n1 isa Variable
        return n1
    else
        return n2
    end
end

t2
t3
treemap!(t2, t3) do (n1, n2)
    if n1 isa Value
        n1.x = -n1.x
    end
    if n2 isa Variable
        n2.x = :a
    end
end
t2
t3

using Mill

ENV["DATADEPS_LOAD_PATH"]="/Users/simon.mandlik/data"
using SampleLoaders
dataset = fetch_data(CuckooSmall, "strain")
mb = minibatch(testdata(dataset), 3)
tm, _ = mb(3)

printtree(tm)
printtree(tm; trunc=0)
printtree(tm; trunc=1)
printtree(tm; trunc=2)

tm = tm.data.network

tm2, _ = mb(3)
tm2 = tm2.data.network

nnodes(tm)
nleafs(tm)
# PoC we may change what a leaf is and what isn't
nleafs(tm) == length(vcat(collect(TypeIterator{Missing}(tm)), collect(TypeIterator{ArrayNode}(tm))))

collect(NodeIterator(tm))
collect(LeafIterator(tm))
collect(TypeIterator{BagNode}(tm))

pred(n::BagNode) = length(n.bags) > 3
pred(n::TreeNode) = :offset in keys(n.data)
pred(n) = true
collect(PredicateIterator(tm, pred))

pred2(n::ArrayNode) = size(n.data, 2) > 10
pred2(n) = false
collect(PredicateIterator(tm, pred2))

using Setfield
tm2 = @set tm2.data.icmp.data = ArrayNode(randn(2,2))
collect(ZipIterator(tm, tm2))

collect(MultiIterator(NodeIterator(tm), NodeIterator(tm2)))

tm
tm3 = treemap(tm) do n
    if n isa TreeNode && length(n.data) < 8
        # different type - very powerful, but potentially very slow
        return ArrayNode((randn(3, 3)))
    else
        return n
    end
end

tm
tm3 = treemap(tm) do n
    if n isa TreeNode && length(n.data) < 8
        return ArrayNode((randn(3, 3)))
    else
        return n
    end
end

# MILL Specific
# Work with individual samples and not whole batches. napr. map, viz. Slack
# get individual samples - view override in Mill
# apply an algorithm on one sample to the whole batch - broadcast override in Mill
