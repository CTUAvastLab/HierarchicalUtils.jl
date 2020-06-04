using Test
using HierarchicalUtils
using Base.Iterators: product
using Combinatorics

# definitions of all trees needed
abstract type AbstractVertex end

mutable struct Leaf <: AbstractVertex
    n::Int64
end
mutable struct VectorVertex{T <: AbstractVertex} <: AbstractVertex
    n::Int64
    chs::Vector{T}
end
mutable struct NTVertex{T, U <: Tuple{Vararg{AbstractVertex}}} <: AbstractVertex
    n::Int64
    chs::NamedTuple{T, U}
end
mutable struct BinaryVertex{T <: AbstractVertex, U <: AbstractVertex} <: AbstractVertex
    n::Int64
    ch1::T
    ch2::U
end
mutable struct SingletonVertex{T <: AbstractVertex} <: AbstractVertex
    n::Int64
    ch::T
end

import HierarchicalUtils: NodeType, noderepr, childrenfields, children

NodeType(::Type{Leaf}) = HierarchicalUtils.LeafNode()

NodeType(::Type{<:VectorVertex}) = HierarchicalUtils.InnerNode()
set_children(t::VectorVertex, chs) = VectorVertex(t.n, collect(chs))
children(t::VectorVertex) = tuple(t.chs...)

NodeType(::Type{<:NTVertex}) = HierarchicalUtils.InnerNode()
set_children(t::NTVertex, chs::NameTuple) = VectorVertex(t.n, collect(chs))
children(t::NTVertex) = t.chs

NodeType(::Type{<:BinaryVertex}) = HierarchicalUtils.InnerNode()
set_children(t::BinaryVertex, chs) = BinaryVertex(t.n, chs[1], chs[2])
children(t::BinaryVertex) = (t.ch1, t.ch2)

# NodeType(::Type{<:SingletonVertex}) = HierarchicalUtils.SingletonNode()
NodeType(::Type{<:SingletonVertex}) = HierarchicalUtils.InnerNode()
set_children(t::SingletonVertex, chs) = SingletonVertex(t.n, only(chs))
children(t::SingletonVertex) = (t.ch,)

noderepr(t::T) where T <: AbstractVertex = string(Base.typename(T)) * " ($(t.n))"
Base.show(io::IO, t::T) where T <: AbstractVertex = print(io, "$(Base.typename(T))($(t.n))")

# NodeType(::Type{<:SingletonVertex}) = HierarchicalUtils.SingletonNode()
NodeType(::Type{<:SingletonVertex}) = HierarchicalUtils.InnerNode()
children(t::SingletonVertex) = (t.ch,)

noderepr(t::T) where T <: AbstractVertex = string(Base.typename(T)) * " ($(t.n))"
Base.show(io::IO, t::T) where T <: AbstractVertex = print(io, "$(Base.typename(T))($(t.n))")

# Dict and Vector as nodes
NodeType(::Type{T}) where T <: Union{Dict, Vector} = InnerNode()
children(t::Dict) = (; (Symbol(k) => v for (k, v) in t)...)
children(t::Vector) = tuple(t...)
set_children(::Vector, chs) = collect(chs)
set_children(::Dict, chs::NamedTuple) = Dict(chs)
noderepr(::Dict) = "Dict of"
noderepr(::Vector) = "Vector of"


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

const COMPLETE_BINARY_TREE_1 = BinaryVertex(1,
                                            BinaryVertex(2,
                                                         Leaf(4),
                                                         Leaf(5)
                                                        ),
                                            BinaryVertex(3,
                                                         Leaf(6),
                                                         Leaf(7)
                                                        )
                                           )

const COMPLETE_BINARY_TREE_2 = NTVertex(1, (
                                            b = VectorVertex(3, [NTVertex(6, NamedTuple()), Leaf(7)]),
                                            a = VectorVertex(2, [Leaf(4), VectorVertex(5, AbstractVertex[])])
                                           ))

const T1 = NTVertex(1, (
                        ch1 = NTVertex(2, (
                                           ch1 = Leaf(4),
                                           ch2 = VectorVertex(5, AbstractVertex[])
                                          )),
ch2 = BinaryVertex(3,
                   NTVertex(6, NamedTuple()),
                   Leaf(7))
))
const T2 = NTVertex(1, (
                        ch2 = VectorVertex(3, [
                                               Leaf(6)
                                              ])
                        ,
                        ch1 = NTVertex(2, (
                                           ch2 = NTVertex(5, NamedTuple()),
                                          ))
))
const T3 = NTVertex(1, (
                        ch1 = NTVertex(2, (
                                           ch1 = VectorVertex(4, AbstractVertex[]),
                                           ch2 = Leaf(5)
                                          )),
))
const T4 = NTVertex(1, (
                        ch2 = BinaryVertex(3,
                                           Leaf(6),
                                           Leaf(7)),
))
const T5 = NTVertex(1, NamedTuple())

const TEST_TREES = [
                    SINGLE_NODE_1, SINGLE_NODE_2, SINGLE_NODE_3, SINGLE_NODE_4, SINGLE_NODE_5,
                    LINEAR_TREE_1, LINEAR_TREE_2, LINEAR_TREE_3,
                    COMPLETE_BINARY_TREE_1, COMPLETE_BINARY_TREE_2,
                    T1, T2, T3, T4, T5
                   ]

const TYPES = [Leaf, VectorVertex, BinaryVertex, NTVertex, Vector, Dict]
const ORDERS = [PreOrder(), PostOrder(), LevelOrder()]

# TODO
# tests - e.g. zero children inner node
# tests - unsorted children
# test sorting of children a children intersections
@testset "Simple statistics" begin
    include("statistics.jl")
end
@testset "Printing" begin
    include("printing.jl")
end
@testset "Iterators" begin
    include("iterators.jl")
end
