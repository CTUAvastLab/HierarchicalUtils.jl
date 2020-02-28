using Setfield

fbroadcast(f, a::NamedTuple{K}) where K = NamedTuple{K}(f.(values(a)))
fbroadcast(f, a) = f.(a)

treemap(f::Function, n) = _treemap(f, NodeType(n), n)
_treemap(f, ::LeafNode, n) = f(n)
function _treemap(f, ::InnerNode, n)
    nn = f(n)
    isleaf(nn) && return nn
    @show nn
    @show children(nn)
    ch = fbroadcast(m -> _treemap(f, NodeType(m), m), children(nn))
    
    # ch = (m -> _treemap(f, NodeType(m), m)).(children(nn))
    @eval @set $n.$(childrenfield(n)) = $ch
end

function treemap!(f::Function, n)
    f(n)
    foreach(ch -> treemap!(f, ch), children(n))
    n
end

leafmap(f::Function, n) = _leafmap(f, NodeType(n), n)
_leafmap(f, ::LeafNode, n) = f(n)
function _leafmap(f, ::InnerNode, n)
    ch = fbroadcast(m -> _leafmap(f, NodeType(m), m), children(nn))
    # ch = (m -> _leafmap(f, NodeType(m), m)).(children(n))
    @eval @set $n.$(childrenfield(n)) = $ch
end

function leafmap!(f::Function, n)
    ls = collect(LeafIterator(n))
    foreach(f, ls)
    ls
end

zipmap(f::Function, ts...) = zipmap(f, ts)
function zipmap(f::Function, ts::Tuple)
    n = f(ts)
    if isleaf(n) || any(isleaf.(ts))
        return n
    end
    ch = fbroadcast(ts -> zipmap(f, ts...), collect(zip(children.(ts)...)))
    # ch = (ts -> zipmap(f, ts...)).(collect(zip(children.(ts)...)))
    @eval @set $n.$(childrenfield(n)) = $ch
end

zipmap!(f::Function, ts...) = zipmap!(f, ts)
function zipmap!(f::Function, ts::Tuple)
    f(ts)
    any(isleaf.(ts)) && return ts
    foreach(ch -> zipmap!(f, ch), zip(children.(ts)...))
    ts
end
