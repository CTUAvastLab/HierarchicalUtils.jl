# DO NOT HESITATE TO TELL ME IF YOU NEED ANYTHING
# OR ASK, WE CAN RESPECIFY

import Mill.HierarchicalUtils: printtree, head_string, children_string, children, nchildren, NodeType, LeafNode, InnerNode, NodeIterator, LeafIterator, PredicateIterator, TypeIterator, ZipIterator, nnodes, nleafs, encode_traversal, walk, treemap, treemap!, leafmap!, childrenfield, leafmap

import Base.getindex

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

NodeType(::Type{Value}) = LeafNode()
head_string(n::Value) = string(n.x)
NodeType(::Type{Variable}) = LeafNode()
head_string(n::Variable) = string(n.x)

NodeType(::Type{Operation}) = InnerNode()
children(n::Operation) = n.ch
head_string(n::Operation) = string(n.op)

# TODO ukazat, jak mne to vyfakuje, kdyz nezadefinuji potrebne metody

macro infix(expr) parseinfix(expr) end
parseinfix(e::Expr) = Operation(eval(e.args[1]), collect(map(parseinfix, e.args[2:end])))
parseinfix(x::Number) = Value(x)
parseinfix(x::Symbol) = Variable(x)

evalinfix(n::Value) = n.x
evalinfix(n::Operation) = n.op(evalinfix.(n.ch)...)

t1 = @infix ((2 + y) * 5) / (4 - x)

# PRINTING
printtree(t1)

# TRAVERSALS
# TODO set index???
Base.getindex(t::Operation, i::Integer) = t.ch[i]
Base.getindex(t::Operation, idxs::NTuple{N, Integer}) where N = t.ch[idxs[1]][idxs[2:end]...]
Base.getindex(t::Operation, idxs::Integer...) = t[idxs]
Base.getindex(t::Expression, i::AbstractString) = walk(t, i)
printtree(t1; trav=true)
encode_traversal(t1, 1, 1)

t1[1,1] === t1[1][1] == t1[encode_traversal(t1, 1, 1)]

# TRUNCATION
t2 = @infix 1 + 1/0
t2.ch[2].ch[2] = t2
printtree(t2; trunc_level=10)

# iterators return references, so they can be used to mutate objects, however *map functions are better suited
# altering the tree during iteration may break it
collect(NodeIterator(t1))
collect(LeafIterator(t1))
collect(TypeIterator{Value}(t1))
collect(TypeIterator{Operation}(t1))
collect(TypeIterator{Expression}(t1))

pred(n::Operation) = in(n.op, [+, -])
pred(n::Value) = isodd(n.x)
pred(n) = true
collect(PredicateIterator(t1, pred))

collect(ZipIterator(NodeIterator(t1), NodeIterator(t1)))
collect(ZipIterator(NodeIterator(t1), LeafIterator(t1)))

nnodes(t1)
nleafs(t1)

childrenfield(::Operation) = :ch
childrenfield(::AbstractNode) = :data
childrenfield(::BagModel) = :im
childrenfield(::ProductModel) = :ms

# preorder walk, once a leaf is returned -> stop, mapping applied to children of a mapped node!
# change of type is ok
assignment = Dict(:x => 1, :y => 2)
t1_assigned = treemap(t1) do n
    if typeof(n) === Variable
        return Value(assignment[n.x])
    else
        return n
    end
end
printtree(t1_assigned)
t1_assigned = treemap(t1) do n
    if typeof(n) === Operation && n.op == *
        return @infix x + y
    elseif typeof(n) === Variable
        return Value(assignment[n.x])
    else
        return n
    end
end
printtree(t1_assigned)
# for treemap! make f -> f!, f! mustn't change a type!, again, once children change, we used them
t1_copy = deepcopy(t1)
treemap!(t1_copy) do n
    if typeof(n) === Operation
        n.op = +
    else
        return n
    end
end
printtree(t1_copy)

printtree(t1_assigned)
sin!(n::Value) = n.x = sin(n.x)
import Base: asin
asin(n::Value) = Value(asin(n.x))
leafmap!(sin!, t1_assigned)
printtree(t1_assigned)
t1_asin = leafmap(asin, t1_assigned)
printtree(t1_asin)

# zipmap, like ZipIterator stops on first leaf of input trees (or first mapped leaf)
zipmap
 
# TODO ukazat neco na MILLu
