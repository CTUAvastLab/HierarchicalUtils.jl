_childsort(x::Union{Tuple, Vector, OrderedDict}) = x
_childsort(x::Dict) = sort!(OrderedDict(x))
_childsort(x::PairVec) = sort(x, by=first)
function _childsort(x::NamedTuple{T}) where T
    ks = tuple(sort(collect(T))...)
    NamedTuple{ks}(x[k] for k in ks)
end
_children_sorted(n) = _childsort(children(n))

_iter(x::PairVec) = last.(x)
_iter(x) = values(x)

_isnothing_iter(x) = isnothing.(_iter(x))

function _ith_child(m::Union{Tuple, Vector, NamedTuple}, i::Integer)
    1 ≤ i ≤ length(m) || @error "Invalid index!"
    return m[i]
end
_ith_child(m::OrderedDict, i::Integer) = _ith_child(collect(m), i)
function _ith_child(m::PairVec, i::Integer)
    1 ≤ i ≤ length(m)  || @error "Invalid index!"
    return last(m[i])
end

function _children_pairs(ts, complete::Bool)
    chss1 = [_children_sorted(t) for t in ts if !(isnothing(t) || isleaf(t))]
    chss2 = [isnothing(t) || isleaf(t) ? nothing : _children_sorted(t) for t in ts]
    isempty(chss1) ? chss1 : _children_pairs_aux(chss1, chss2, complete)
end

# for performance reasons, this should always return the same type as input
function _children_pairs_aux(::Vector{<:Tuple}, chss, complete)
    chss = [isnothing(chs) ? tuple() : chs for chs in chss]
    ml = complete ? maximum(length.(chss)) : minimum(length.(chss))
    tuple(
          (tuple((i <= length(chs) ? chs[i] : nothing for chs in chss)...) for i in 1:ml)...
         )
end

function _children_pairs_aux(::Vector{<:Vector}, chss, complete)
    if any(isa.(chss, PairVec))
        throw_types(chss)
    end
    chss = [isnothing(chs) ? [] : collect(chs) for chs in chss]
    ml = complete ? maximum(length.(chss)) : minimum(length.(chss))
    [tuple((i <= length(chs) ? chs[i] : nothing for chs in chss)...) for i in 1:ml]
end

function _children_pairs_aux(::Vector{<:NamedTuple}, chss, complete)
    chss = [isnothing(chs) ? NamedTuple() : chs for chs in chss]
    ks = complete ? union(keys.(chss)...) : intersect(keys.(chss)...)
    (; (Symbol(k) => tuple(
                (k in keys(chss[i]) ? chss[i][k] : nothing for i in eachindex(chss))...
               ) for k in sort(ks))...)
end

function _children_pairs_aux(::Vector{<:OrderedDict}, chss, complete)
    chss = [isnothing(chs) ? OrderedDict() : chs for chs in chss]
    ks = complete ? union(keys.(chss)...) : intersect(keys.(chss)...)
    OrderedDict(k => tuple((k in keys(chss[i]) ? chss[i][k] : nothing for i in eachindex(chss))...)
        for k in sort(ks |> collect))
end

function _children_pairs_aux(::Vector{<:PairVec}, chss, complete)
    ks = [isnothing(chs) || length(Dict(chs)) == length(chs) for chs in chss]
    all(ks) || throw(ArgumentError("Two or more identical keys in children represented as a vector of pairs"))
    chss = [isnothing(chs) ? OrderedDict() : OrderedDict(chs) for chs in chss]
    ks = complete ? union(collect.(keys.(chss))...) : intersect(collect.(keys.(chss))...)
    OrderedDict(k => tuple((k in keys(chss[i]) ? chss[i][k] : nothing for i in eachindex(chss))...)
        for k in sort(ks |> collect)) |> collect
end

_children_pairs_aux(chss1, chss2, complete) = throw_types(chss1)

function throw_types(chss)
    throw(ArgumentError(
                        "Incompatible children types: " * join([typeof(chs) for chs in chss], ", ", " and ")
                       ))
end
