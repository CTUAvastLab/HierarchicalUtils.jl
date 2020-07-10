fbroadcast(f::Function, a::NamedTuple{K}) where K = NamedTuple{K}(f.(values(a)))
fbroadcast(f::Function, a) = f.(a)

treemap(f::Function, t; kwargs...) = treemap((t, chs) -> f(only(t), chs), (t,); kwargs...)
treemap(f::Function, ts...; kwargs...) = treemap(f, ts; kwargs...)
function treemap(f::Function, ts::Tuple; complete::Bool=false, order::AbstractOrder=PostOrder())
    _treemap(f, ts, complete, order)
end

# TODO finish preorder, think about how both maps should behave in case of complete traversals
# maybe annotate about named tuples? With traits?
#
# select_keys(x, y) = @error "Inconsistent types of children of mapped vertex and original vertices"
# select_keys(x::Tuple, y::Tuple) = x[eachindex(y)]
# function select_keys(x::NamedTuple, y::NamedTuple)
#     NamedTuple{keys(y)}(tuple((x[k] for k in keys(y))...))
# end

function _treemap(f::Function, ts::Tuple, complete::Bool, order::PreOrder)
    @error "Treemaps using PreOrder() are not supported yet"
end

# function _treemap(f::Function, ts::Tuple, complete::Bool, order::PreOrder)
#     n = f(ts, _children_sorted.(ts))
#     isleaf(n) && return n
#     nchs = children(n)
#     chs = _children_pairs_keys(ts, complete)
#     @show keys(nchs), keys(chs)
#     @assert keys(nchs) ⊆ keys(chs)
#     mchs = fbroadcast(ts -> _treemap(f, ts, complete, order), select_keys(chs, nchs))
#     set_children(n, mchs)
# end

function _treemap(f::Function, ts::Tuple, complete::Bool, order::PostOrder)
    chs = fbroadcast(ts -> _treemap(f, ts, complete, order), _children_pairs(ts, complete))
    return f(ts, chs)
end

function _treemap(f::Function, ts::Tuple, complete::Bool, order::LevelOrder)
    @error "Treemaps using LevelOrder() are not supported yet"
end

function treemap!(f::Function, ts; complete::Bool=false, order::AbstractOrder=PostOrder())
    foreach(f, NodeIterator(ts; order=order, complete=complete))
end
function leafmap!(f::Function, ts; complete::Bool=false, order::AbstractOrder=PostOrder())
    foreach(f, LeafIterator(ts; order=order, complete=complete))
end
function typemap!(f::Function, ts, t::Union{Type, Tuple{Vararg{Type}}}; complete::Bool=false,
                  order::AbstractOrder=PostOrder())
    foreach(f, TypeIterator(ts, t; order=order, complete=complete))
end
function predicatemap!(f::Function, ts, pred::Function; complete::Bool=false,
                  order::AbstractOrder=PostOrder())
    foreach(f, PredicateIterator(ts, pred; order=order, complete=complete))
end
