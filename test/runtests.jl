using Test
using HierarchicalUtils
using Combinatorics
# TODO
# tests - e.g. zero children inner node
# tests - unsorted children
# test sorting of children a children intersections

# definitions of all trees needed
abstract type AbstractVertex end

struct Leaf <: AbstractVertex
    n::Int64
end
struct VectorVertex{T <: AbstractVertex} <: AbstractVertex
    n::Int64
    chs::Vector{T}
end
struct NTVertex{T, U <: Tuple{Vararg{V}} where {V <: AbstractVertex}} <: AbstractVertex
    n::Int64
    chs::NamedTuple{T, U}
end
struct BinaryVertex{T <: AbstractVertex, U <: AbstractVertex} <: AbstractVertex
    n::Int64
    ch1::T
    ch2::U
end
struct SingletonVertex{T <: AbstractVertex} <: AbstractVertex
    n::Int64
    ch::T
end

import HierarchicalUtils: NodeType, noderepr, childrenfields, children

NodeType(::Type{Leaf}) = HierarchicalUtils.LeafNode()

NodeType(::Type{<:VectorVertex}) = HierarchicalUtils.InnerNode()
children(t::VectorVertex) = (; zip(Symbol.(1:length(t.chs)), t.chs)...)

NodeType(::Type{<:NTVertex}) = HierarchicalUtils.InnerNode()
children(t::NTVertex) = t.chs

NodeType(::Type{<:BinaryVertex}) = HierarchicalUtils.InnerNode()
children(t::BinaryVertex) = (t.ch1, t.ch2)

NodeType(::Type{<:SingletonVertex}) = HierarchicalUtils.SingletonNode()
children(t::SingletonVertex) = (t.ch,)

noderepr(t::T) where T <: AbstractVertex = string(Base.typename(T)) * " ($(t.n))"

# TODO
# childrenfields

# TODO dict+ array trees

const LINEAR_TREE1 = VectorVertex(1,[
                             NTVertex(2, (;
                                          a=SingletonVertex(3,
                                                            Leaf(4)
                                                           )
                                         ))
                            ])

const LINEAR_TREE2 = SingletonVertex(1, 
                             SingletonVertex(2, 
                                          a=VectorVertex(3, [
                                                            NTVertex(4, NamedTuple())
                                                           ])
                                         )
                            )

const TEST_TREES = [
    LINEAR_TREE1, LINEAR_TREE2
                   ]


@testset "Simple statistics" begin
    include("simple_statistics.jl")
end
