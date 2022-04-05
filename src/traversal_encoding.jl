const ALPHABET = [Char(x) for x in vcat(collect.([42:43, 48:57, 65:90, 97:122])...)]
const INV_ALPHABET = Dict(c => i for (i,c) in enumerate(ALPHABET))

_segment_width(l::Integer) = ceil(Int, log2(l+1))
encode(i::Integer, l::Integer) = string(i, base=2, pad=_segment_width(l))
function decode(c::AbstractString, l::Integer)
    k = max(1, min(_segment_width(l), length(c)))
    parse(Int, c[1:k], base=2), c[k+1:end]
end

function stringify(c::AbstractString)
    if length(c) % 6 != 0
        c = c * '0' ^ mod(6-length(c), 6)
    end
    join(ALPHABET[parse(Int, x, base=2) + 1] for x in [c[i:i+5] for i in 1:6:(length(c)-1)])
end

function destringify(c::AbstractString)
    join(string(INV_ALPHABET[x] - 1, base=2, pad=6) for x in c)
end

walk(n::T, c) where T = _walk(n, destringify(c))

_walk(n::T, c) where T = _walk(NodeType(T), n, c)

function _walk(::LeafNode, n, c::AbstractString)
    !isempty(c) || return n
    i, nc = decode(c, length(c))
    if i == 0 && Set(nc) ⊆ ['0']
        return n
    else
        error("Invalid index!")
    end
end

function _walk(::InnerNode, n, c::AbstractString)
    !isempty(c) || return n
    i, nc = decode(c, nprintchildren(n))
    0 <= i <= nprintchildren(n) || error("Invalid index!")
    if i == 0
        if Set(nc) ⊆ ['0']
            return n
        else
            error("Invalid index!")
        end
    end
    _walk(_ith_child(printchildren(n), i), nc)
end

encode_traversal(t, idxs::Integer...) = stringify(_encode_traversal(t, idxs...))

function _encode_traversal(t, idxs...)
    !isempty(idxs) || return ""
    n = _ith_child(printchildren(t), idxs[1])
    return encode(idxs[1], nchildren(t)) * _encode_traversal(n, idxs[2:end]...)
end

pred_traversal(n::T, p::Function, s::String="") where T = _pred_traversal(NodeType(T), n, p, s)

_pred_traversal(::LeafNode, n, p, s="") = p(n) ? [stringify(s)] : String[]
function _pred_traversal(::InnerNode, n, p, s="")
    d = printchildren(n)
    l = length(d)
    z = Vector{String}[pred_traversal(_ith_child(d, i), p, s * encode(i, l)) for i in 1:l]
    res = isempty(z) ? String[] : reduce(vcat, z)
    p(n) ? vcat(stringify(s), res) : res
end

list_traversal(n) = pred_traversal(n, t -> true)
find_traversal(n, x) = pred_traversal(n, t -> x === t)
