_impose_order(x::Union{Tuple, NamedTuple, Vector, OrderedDict}) = x
_impose_order(x::AbstractDict) = sort!(OrderedDict(x))

_children_ordered(n) = _impose_order(children(n))

_iter(x::PairVec) = last.(x)
_iter(x) = values(x)

_isnothing_iter(x) = isnothing.(_iter(x))

_ith_child(m::Union{Tuple, Vector, NamedTuple}, i::Integer) = m[i]
_ith_child(m::OrderedDict, i::Integer) = _ith_child(collect(m), i)
_ith_child(m::AbstractDict, i::Integer) = _ith_child(_impose_order(m), i)
_ith_child(m::PairVec, i::Integer) = last(m[i])

_indexed(::Union{Vector, Tuple}) = true
_indexed(_) = false
_named(::Union{NamedTuple, Dict, OrderedDict, PairVec}) = true
_named(_) = false

function _children_pairs(ts, complete::Bool)
    chss1 = [_children_ordered(t) for t in ts if !(isnothing(t) || isleaf(t))]
    chss2 = [isnothing(t) || isleaf(t) ? nothing : _children_ordered(t) for t in ts]
    isempty(chss1) && return chss1
    # type stability here is impossible
    if all(isa.(chss2, PairVec))
        _children_pairs_aux(PairVec[], chss2, complete)
    else
        _children_pairs_aux(chss1, chss2, complete)
    end
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
    ks = complete ? union(collect.(keys.(chss))...) : intersect(collect.(keys.(chss))...)
    OrderedDict(k => tuple((k in keys(chss[i]) ? chss[i][k] : nothing for i in eachindex(chss))...)
        for k in sort(ks |> collect))
end

function _children_pairs_aux(::Vector{<:PairVec}, chss, complete)
    ks = [isnothing(chs) || length(Dict(chs)) == length(chs) for chs in chss]
    all(ks) || throw(ArgumentError("Two or more identical keys in children represented as a vector of pairs"))
    chss = [isnothing(chs) ? OrderedDict() : OrderedDict(chs) for chs in chss]
    _children_pairs_aux(chss, chss, complete) |> collect
end

# fallback definition, this should be avoided as much as possible
function _children_pairs_aux(chss1, chss2, complete)
    if all(_indexed.(chss1))
        chss2 = [isnothing(chs) ? chs : chs |> collect for chs in chss2]
        return _children_pairs_aux(Vector[], chss2, complete)
    elseif all(_named.(chss1))
        chss2 = [isnothing(chs) || chs isa PairVec ? chs : chs |> pairs |> collect for chs in chss2]
        return _children_pairs_aux(PairVec[], chss2, complete)
    end
    throw_types(chss1)
end

function throw_types(chss)
    throw(ArgumentError(
                        "Incompatible children types: " * join([typeof(chs) for chs in chss], ", ", " and ")
                       ))
end
