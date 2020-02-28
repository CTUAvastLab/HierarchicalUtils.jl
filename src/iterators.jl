import Base: iterate
using Base: SizeUnknown, EltypeUnknown

struct NodeIterator{T}
    t::T
end

struct LeafIterator{T}
    t::T
end

struct TypeIterator{T, U}
    t::U
    TypeIterator{T}(t::U) where {T, U} = new{T, U}(t)
end

struct PredicateIterator{T}
    t::T
    f::Function
end

struct ZipIterator
    ts::Tuple
    ZipIterator(ts...) = new(ts)
    ZipIterator(ts) = new(ts)
end

struct MultiIterator
    its::Tuple
    MultiIterator(ts...) = new(ts)
    MultiIterator(ts) = new(ts)
end

const IteratorTypes = Union{NodeIterator, LeafIterator, PredicateIterator,
                            TypeIterator, ZipIterator, MultiIterator}

Base.IteratorSize(::IteratorTypes) = SizeUnknown()
Base.IteratorEltype(::IteratorTypes) = EltypeUnknown()

defaultstack(it::IteratorTypes) = Any[it.t]
defaultstack(it::ZipIterator) = [Any[t] for t in it.ts]

function iterate(it::T, s=defaultstack(it)) where T <: IteratorTypes
    r = nextstate(it, s) 
    isnothing(r) && return nothing
    return r, s
end

expand(n, s) = append!(s, reverse(collect(children(n))))

function nextstate(it, s)
    isempty(s) && return nothing
    n = pop!(s)
    processnode(it, n, s)
end

function nextstate(it::ZipIterator, ss)
    any(isempty.(ss)) && return nothing
    ns = pop!.(ss)
    if !any(isleaf.(ns))
        for (n, s) in zip(ns, ss)
            expand(n, s)
        end
    end
    ns
end

function processnode(it::NodeIterator, n, s)
    expand(n, s)
    n
end

processnode(it::LeafIterator, n, s) = processnode(NodeType(n), it, n, s)
processnode(::LeafNode, it, n, s) = n
processnode(_, it, n, s) = nextstate(it, expand(n, s))

function processnode(it::PredicateIterator, n, s)
    expand(n, s)
    it.f(n) ? n : nextstate(it, s)
end

function processnode(it::TypeIterator{T, U}, n::T, s) where {T, U}
    expand(n, s)
    n
end
processnode(it::TypeIterator, n, s) = nextstate(it, expand(n, s))

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
