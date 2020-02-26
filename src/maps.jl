using Setfield

treemap(f::Function, n) = _treemap(f, NodeType(n), n)
_treemap(f, ::LeafNode, n) = f(n)
function _treemap(f, ::InnerNode, n)
    nn = f(n)
    isleaf(nn) && return nn
    ch = (m -> _treemap(f, NodeType(m), m)).(children(nn))
    @eval @set $n.$(childrenfield(n)) = $ch
end

function treemap!(f::Function, n)
    f(n)
    map(f, children(n))
    n
end

leafmap(f::Function, n) = _leafmap(f, NodeType(n), n)
_leafmap(f, ::LeafNode, n) = f(n)
function _leafmap(f, ::InnerNode, n)
    ch = (m -> _leafmap(f, NodeType(m), m)).(children(n))
    @eval @set $n.$(childrenfield(n)) = $ch
end

function leafmap!(f::Function, n)
    ls = collect(LeafIterator(n))
    foreach(f, ls)
    ls
end

zipmap(f::Function, ts...) = zipmap(f, ts)
zipmap(f::Function, ts::Tuple) = _zipmap(f, ts)
function zipmap(f, ts)
    # TODO, co kdyz maji ruzny pocet deti? schema + 
    

end

# TODO zipmap
# TODO zipmap! s tuplem
