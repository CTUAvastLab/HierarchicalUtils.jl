correct_nchildren(::Leaf) = 0
correct_nchildren(::SingletonVertex) = 1
correct_nchildren(::BinaryVertex) = 2
correct_nchildren(t::Union{VectorVertex, NTVertex}) = length(t.chs)

@testset "nchildren" for T in TEST_TREES
    for n in NodeIterator(T)
        @test nchildren(n) == correct_nchildren(n)
    end
end

@testset "nnodes" for T in TEST_TREES
    for n in NodeIterator(T)
        @test nnodes(n) == NodeIterator(n) |> collect |> length
    end
end

isleaf(::Leaf) = true
isleaf(t::Union{VectorVertex, NTVertex}) = correct_nchildren(t) == 0
isleaf(t) = false

@testset "nleafs" for T in TEST_TREES
    for n in NodeIterator(T)
        @test nleafs(n) == filter(isleaf, NodeIterator(n) |> collect) |> length
    end
end
