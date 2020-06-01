# TODO types of traversal?
# TODO fix error when trying to assign a named tuple to an array
fbroadcast(f::Function, a::NamedTuple{K}) where K = NamedTuple{K}(f.(values(a)))
fbroadcast(f::Function, a) = f.(a)

function _assignchildren(::SingletonNode, n::T, ch) where T
    @eval @set $n.$(only(childrenfields(T))) = $(only(ch))
end
function _assignchildren(::InnerNode, n::T, ch) where T
    @eval @set $n.$(only(childrenfields(T))) = $ch
end

function treemap(f::Function, n)
    nn = f(n)
    if isleaf(nn)
        return nn
    end
    ch = fbroadcast(m -> treemap(f, m), children_sorted(nn))
    _assignchildren(NodeType(nn), nn, ch)
end

treemap(f::Function, ts...) = treemap(f, ts)
function treemap(f::Function, ts::Tuple)
    n = f(ts)
    # TODO paradox
    if isleaf(n) || any(isleaf.(ts))
        return n
    end
    ch = fbroadcast(ts -> treemap(f, ts...), collect(zip(children_sorted.(ts)...)))
    # ch = (ts -> treemap(f, ts...)).(collect(zip(children.(ts)...)))
    # @eval @set $n.$(childrenfield(T)) = $ch
    _assignchildren(NodeType(n), n, ch)
end

leafmap(f::Function, n) = _leafmap(NodeType(n), f, n)

_leafmap(::LeafNode, f::Function, n) = f(n)
function _leafmap(_, f::Function, n)
    ch = fbroadcast(m -> _leafmap(NodeType(m), f, m), children_sorted(n))
    _assignchildren(NodeType(n), n, ch)
end

function treemap!(f::Function, n)
    f(n)
    foreach(ch -> treemap!(f, ch), children_sorted(n))
    n
end

treemap!(f::Function, ts...) = treemap!(f, ts)
function treemap!(f::Function, ts::Tuple)
    f(ts)
    any(isleaf.(ts)) && return ts
    foreach(ch -> treemap!(f, ch), zip(children_sorted.(ts)...))
    ts
end

leafmap!(f::Function, n) = _leafmap!(NodeType(n), f, n)
_leafmap!(::LeafNode, f, n) = f(n)
_leafmap!(_, f, n) = foreach(ch -> _leafmap!(NodeType(ch), f, ch), children_sorted(n))
