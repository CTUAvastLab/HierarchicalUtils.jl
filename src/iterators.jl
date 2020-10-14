import Base: iterate
using Base: SizeUnknown, EltypeUnknown

abstract type AbstractOrder end
struct PreOrder <: AbstractOrder end
struct PostOrder <: AbstractOrder end
struct LevelOrder <: AbstractOrder end

# S indicates whether a tuple in ts is a single tree or a collection of trees
struct PredicateIterator{S, T, O <: AbstractOrder}
    f::Function
    ts::T
    complete::Bool
    order::O
    function PredicateIterator(f::Function, ts::T, single::Bool; complete::Bool=true,
                                  order::O=PreOrder()) where {T, O <: AbstractOrder}
        new{single, T, O}(f, ts, complete, order)
    end
end

PredicateIterator(f::Function, t; kwargs...) = PredicateIterator(f, (t,), true; kwargs...)
PredicateIterator(f::Function, ts...; kwargs...) = PredicateIterator(f, ts, false; kwargs...)

_leaf_predicate(ns::Tuple) = all(n -> isnothing(n) || isleaf(n), ns)
_leaf_predicate(n) = isleaf(n)
_node_predicate(ns::Tuple) = true
_node_predicate(n) = true
function _type_predicate_object(ts::Tuple, t::Tuple{Vararg{Type}})
    @assert length(ts) == length(t)
    (ns::Tuple) -> all([ns[i] isa t[i] for i in eachindex(ts)])
end
function _type_predicate_object(ts::Tuple, t::Type{T}) where T
    (ns::Tuple) -> all(n -> n isa T, ns)
end

LeafIterator(ts...; kwargs...) = PredicateIterator(_leaf_predicate, ts...; kwargs...)
NodeIterator(ts...; kwargs...) = PredicateIterator(_node_predicate, ts...; kwargs...)
function TypeIterator(t::Union{Type, Tuple{Vararg{Type}}}, ts...; kwargs...)
    PredicateIterator(_type_predicate_object(ts, t), ts...; kwargs...)
end
TypeIterator(t::Type{T}, ts; kwargs...) where T = PredicateIterator(n -> n isa T, ts; kwargs...)

Base.IteratorSize(::PredicateIterator) = SizeUnknown()
Base.IteratorEltype(::PredicateIterator) = EltypeUnknown()

# TODO implement with stack?
# TODO maybe implement faster version with types
traverse!(o::AbstractOrder, complete::Bool, ts::Nothing, res::Vector) = res

function traverse!(o::AbstractOrder, complete::Bool, ts::Tuple, res::Vector)
    if !all(_isnothing_iter(ts))
        o isa PreOrder && push!(res, ts)
        for chs in _children_pairs(ts, complete) |> _iter
            traverse!(o, complete, chs, res)
        end
        o isa PostOrder && push!(res, ts)
    end
    res
end

function traverse!(o::LevelOrder, complete::Bool, ts::Tuple, res::Vector)
    q = Queue{Any}()
    enqueue!(q, ts)
    while !isempty(q)
        ts = first(q)
        if !all(_isnothing_iter(ts))
            push!(res, ts)
            for chs in _children_pairs(ts, complete) |> _iter
                enqueue!(q, chs)
            end
        end
        dequeue!(q)
    end
    res
end

Base.iterate(it::PredicateIterator{S, Tuple{}}) where S = nothing

function Base.iterate(it::PredicateIterator)
    ns = []
    traverse!(it.order, it.complete, it.ts, ns)
    return iterate(it, (1, ns))
end

function Base.iterate(it::PredicateIterator{true}, (i, ns))
    while i <= length(ns) && !it.f(only(ns[i]))
        i += 1
    end
    i <= length(ns) || return nothing
    return only(ns[i]), (i+1, ns)
end

function Base.iterate(it::PredicateIterator{false}, (i, ns))
    while i <= length(ns) && !it.f(ns[i])
        i += 1
    end
    i <= length(ns) || return nothing
    return ns[i], (i+1, ns)
end

# TODO implement MultiIterator, so that nothing below doesn't clash with complete iterators
# struct MultiIterator
#     its::Tuple
#     MultiIterator(ts...) = new(ts)
#     MultiIterator(ts) = new(ts)
# end

# function iterate(it::MultiIterator) 
#     r = collect(map(iterate, it.its))
#     any(isnothing.(r)) && return nothing
#     return collect(zip(r...))
# end

# function iterate(it::MultiIterator, ss)
#     r = [iterate(i, s) for (i, s) in zip(it.its, ss)]
#     any(isnothing.(r)) && return nothing
#     return collect(zip(r...))
# end

# defaultstack(it::IteratorTypes) = Any[it.t]
# defaultstack(it::ZipIterator) = [Any[t] for t in it.ts]

# function iterate(it::PredicateIterator, s=Stack{Tuple}(it.ts))
#     r = nextstate(it, s) 
#     isnothing(r) && return nothing
#     return r, s
# end

# expand(n, s) = append!(s, reverse(collect(_children_sorted(n))))

# function nextstate(it, s)
#     isempty(s) && return nothing
#     n = pop!(s)
#     processnode(it, n, s)
# end

# function nextstate(it::ZipIterator, ss)
#     any(isempty.(ss)) && return nothing
#     ns = pop!.(ss)
#     if !any(isleaf.(ns))
#         for (n, s) in zip(ns, ss)
#             expand(n, s)
#         end
#     end
#     tuple(ns...)
# end

# function processnode(it::NodeIterator, n, s)
#     expand(n, s)
#     n
# end

# processnode(it::LeafIterator, n, s) = processnode(NodeType(n), it, n, s)
# processnode(::LeafNode, it, n, s) = n
# processnode(_, it, n, s) = nextstate(it, expand(n, s))

# function processnode(it::PredicateIterator, n, s)
#     expand(n, s)
#     it.f(n) ? n : nextstate(it, s)
# end

# function processnode(it::TypeIterator{T, U}, n::T, s) where {T, U}
#     expand(n, s)
#     n
# end
# processnode(it::TypeIterator, n, s) = nextstate(it, expand(n, s))

