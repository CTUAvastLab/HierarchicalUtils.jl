using Test
using HierarchicalUtils

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
Base.show(io::IO, t::T) where T <: AbstractVertex = print(io, "$(Base.typename(T))($(t.n))")

NodeType(::Type{<:SingletonVertex}) = HierarchicalUtils.SingletonNode()
children(t::SingletonVertex) = (t.ch,)

noderepr(t::T) where T <: AbstractVertex = string(Base.typename(T)) * " ($(t.n))"
Base.show(io::IO, t::T) where T <: AbstractVertex = print(io, "$(Base.typename(T))($(t.n))")

# Dict and Vector as nodes
NodeType(::Type{T}) where T <: Union{Dict, Vector} = InnerNode()
children(t::Dict) = (; (Symbol(k) => v for (k, v) in t)...)
children(t::Vector) = tuple(t...)
noderepr(::Dict) = "Dict of"
noderepr(::Vector) = "Vector of"

# TODO
# childrenfields

const SINGLE_NODE_1 = Leaf(1)
const SINGLE_NODE_2 = VectorVertex(1, AbstractVertex[])
const SINGLE_NODE_3 = NTVertex(1, NamedTuple())
const SINGLE_NODE_4 = []
const SINGLE_NODE_5 = Dict()

const LINEAR_TREE_1 = VectorVertex(1,[
                             NTVertex(2, (;
                                          a=SingletonVertex(3,
                                                            Leaf(4)
                                                           )
                                         ))
                            ])

const LINEAR_TREE_2 = SingletonVertex(1, 
                                     SingletonVertex(2, 
                                                     VectorVertex(3, [
                                                                      NTVertex(4, NamedTuple())
                                                                     ])
                                                    )
                                    )

const LINEAR_TREE_3 = [[[[[[[Leaf(1)]]]]]]]

const TEST_TREES = [
                    SINGLE_NODE_1, SINGLE_NODE_2, SINGLE_NODE_3, SINGLE_NODE_4, SINGLE_NODE_5,
                    LINEAR_TREE_1, LINEAR_TREE_2, LINEAR_TREE_3
                   ]


# TODO
# tests - e.g. zero children inner node
# tests - unsorted children
# test sorting of children a children intersections
@testset "Simple statistics" begin
    include("simple_statistics.jl")
end

# @testset "Printing" begin
#     include("printing.jl")
# end
