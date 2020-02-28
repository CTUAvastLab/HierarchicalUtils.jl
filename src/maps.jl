using Setfield

fbroadcast(f::Function, a::NamedTuple{K}) where K = NamedTuple{K}(f.(values(a)))
fbroadcast(f::Function, a) = f.(a)

function _assignchildren(::SingletonNode, n, ch)
    # TODO replace with only in 1.4
    @eval @set $n.$(childrenfield(n)) = $(ch[1])
end
function _assignchildren(::InnerNode, n, ch)
    @eval @set $n.$(childrenfield(n)) = $ch
end

function treemap(f::Function, n)
    nn = f(n)
    if isleaf(nn)
        return nn
    end
    ch = fbroadcast(m -> treemap(f, m), children(nn))
    _assignchildren(NodeType(nn), nn, ch)
end

leafmap(f::Function, n) = _leafmap(NodeType(n), f, n)

_leafmap(::LeafNode, f::Function, n) = f(n)
function _leafmap(_, f::Function, n)
    ch = fbroadcast(m -> _leafmap(NodeType(m), f, m), children(n))
    _assignchildren(NodeType(n), n, ch)
end

# TODO
zipmap(f::Function, ts...) = zipmap(f, ts)
function zipmap(f::Function, ts::Tuple)
    n = f(ts)
    # TODO paradox
    if isleaf(n) || any(isleaf.(ts))
        return n
    end
    ch = fbroadcast(ts -> zipmap(f, ts...), collect(zip(children.(ts)...)))
    # ch = (ts -> zipmap(f, ts...)).(collect(zip(children.(ts)...)))
    # @eval @set $n.$(childrenfield(n)) = $ch
    _assignchildren(NodeType(n), n, ch)
end

function treemap!(f::Function, n)
    f(n)
    foreach(ch -> treemap!(f, ch), children(n))
    n
end

leafmap!(f::Function, n) = _leafmap!(NodeType(n), f, n)
_leafmap!(::LeafNode, f, n) = f(n)
_leafmap!(_, f, n) = foreach(ch -> _leafmap!(NodeType(ch), f, ch), children(n))

zipmap!(f::Function, ts...) = zipmap!(f, ts)
function zipmap!(f::Function, ts::Tuple)
    f(ts)
    any(isleaf.(ts)) && return ts
    foreach(ch -> zipmap!(f, ch), zip(children.(ts)...))
    ts
end
