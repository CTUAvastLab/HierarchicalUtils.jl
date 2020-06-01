import Base: iterate
using Base: SizeUnknown, EltypeUnknown

abstract type AbstractOrder end
struct PreOrder <: AbstractOrder end
struct PostOrder <: AbstractOrder end
struct LevelOrder <: AbstractOrder end

struct PredicateIterator{T, O <: AbstractOrder}
    ts::T
    f::Function
    complete::Bool
    order::O
    function PredicateIterator(ts::T, f::Function; complete::Bool=true,
                                  order::O=PreOrder()) where {T, O <: AbstractOrder}
        new{T, O}(ts, f, complete, order)
    end
end

_leaf_predicate(ns::Tuple) = all(n -> isnothing(n) || isleaf(n), ns)
_leaf_predicate(n) = isnothing(n) || isleaf(n)
_node_predicate(ns::Tuple) = true
_node_predicate(n) = true

LeafIterator(ts; kwargs...) = PredicateIterator(ts, _leaf_predicate; kwargs...)
NodeIterator(ts; kwargs...) = PredicateIterator(ts, _node_predicate; kwargs...)
function TypeIterator(ts::Tuple, t::Type{T}; kwargs...) where T
    PredicateIterator(ts, (ns::Tuple) -> all(n -> isnothing(n) || n isa T, ns); kwargs...)
end
function TypeIterator(ts, t::Type{T}; kwargs...) where T
    PredicateIterator(ts, n -> isnothing(n) || n isa T; kwargs...)
end

Base.IteratorSize(::PredicateIterator) = SizeUnknown()
Base.IteratorEltype(::PredicateIterator) = EltypeUnknown()

# TODO implement with stack?
function traverse!(o::AbstractOrder, complete::Bool, ts::Tuple, res::Vector)
    if !all(isnothing.(ts))
        o isa PreOrder && push!(res, ts)
        chss = [isnothing(t) ? NamedTuple() : children_sorted(t) for t in ts]
        l = complete ? maximum(length.(chss)) : minimum(length.(chss))
        for i in 1:l
            chs = tuple([i <= length(chss[j]) ? chss[j][i] : nothing for j in eachindex(ts)]...)
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
        push!(res, first(q))
        chss = [isnothing(t) ? NamedTuple() : children_sorted(t) for t in first(q)]
        l = complete ? maximum(length.(chss)) : minimum(length.(chss))
        for i in 1:l
            chs = tuple([i <= length(chss[j]) ? chss[j][i] : nothing for j in eachindex(first(q))]...)
            enqueue!(q, chs)
        end
        dequeue!(q)
    end
    res
end

function Base.iterate(it::PredicateIterator{<:Tuple})
    ns = []
    traverse!(it.order, it.complete, it.ts, ns)
    return iterate(it, (1, ns))
end

function Base.iterate(it::PredicateIterator)
    ns = []
    traverse!(it.order, it.complete, tuple(it.ts), ns)
    return iterate(it, (1, ns))
end

function Base.iterate(it::PredicateIterator{<:Tuple}, (i, ns))
    i <= length(ns) || return nothing
    return ns[i], (i+1, ns)
end

function Base.iterate(it::PredicateIterator, (i, ns))
    i <= length(ns) || return nothing
    return only(ns[i]), (i+1, ns)
end


struct MultiIterator
    its::Tuple
    MultiIterator(ts...) = new(ts)
    MultiIterator(ts) = new(ts)
end

function iterate(it::MultiIterator) 
    r = collect(map(iterate, it.its))
    any(isnothing.(r)) && return nothing
    return collect(zip(r...))
end

function iterate(it::MultiIterator, ss)
    r = [iterate(i, s) for (i, s) in zip(it.its, ss)]
    any(isnothing.(r)) && return nothing
    return collect(zip(r...))
end

# defaultstack(it::IteratorTypes) = Any[it.t]
# defaultstack(it::ZipIterator) = [Any[t] for t in it.ts]

# function iterate(it::PredicateIterator, s=Stack{Tuple}(it.ts))
#     r = nextstate(it, s) 
#     isnothing(r) && return nothing
#     return r, s
# end

# expand(n, s) = append!(s, reverse(collect(children_sorted(n))))

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

