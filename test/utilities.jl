import HierarchicalUtils: _children_pairs

@testset "children pairing" begin
    l1, l2, l3 = Leaf.([1, 2, 3])
    n1 = NTVertex(1, (a = l1, c = l3, b = l2))
    n2 = NTVertex(2, (c = l3, a = l1))
    n3 = Dict("b" => l2, "c" => l3)
    n4 = NTVertex(4, (b = l2,))
    n5 = [l1, l2, l3]
    n6 = VectorVertex(6, [l1, l3])

    @test _children_pairs((n1, n2), false) == (a = (l1, l1), c = (l3, l3))
    @test _children_pairs((n1, n2), true) == (a = (l1, l1), b = (l2, nothing), c = (l3, l3))

    @test _children_pairs((n1, n3), false) == (b = (l2, l2), c = (l3, l3))
    @test _children_pairs((n1, n3), true) == (a = (l1, nothing), b = (l2, l2), c = (l3, l3))
    @test _children_pairs((n3, n1), true) == (a = (nothing, l1), b = (l2, l2), c = (l3, l3))

    @test _children_pairs((n1, n4), false) == (b = (l2, l2),)
    @test _children_pairs((n1, n4), true) == (a = (l1, nothing), b = (l2, l2), c = (l3, nothing))

    @test _children_pairs((n1, n2, n3), false) == (c = (l3, l3, l3),)
    @test _children_pairs((n1, n2, n3), true) == (a = (l1, l1, nothing), b = (l2, nothing, l2), c = (l3, l3, l3))

    @test _children_pairs((n1, n2, n3, n4), false) == NamedTuple()
    @test _children_pairs((n1, n2, n3, n4), true) == (a = (l1, l1, nothing, nothing), b = (l2, nothing, l2, l2), c = (l3, l3, l3, nothing))

    @test_throws ErrorException _children_pairs((n1, n5), false)
    @test_throws ErrorException _children_pairs((n1, n5), true)
    @test_throws ErrorException _children_pairs((n1, n6), false)
    @test_throws ErrorException _children_pairs((n1, n6), true)

    @test _children_pairs((n5, n6), false) == ((l1, l1), (l2, l3))
    @test _children_pairs((n5, n6), true) == ((l1, l1), (l2, l3), (l3, nothing))

    for n in (n1, n2, n3, n4), sn in SINGLE_NODES[1:2]
        @test _children_pairs((n, sn), false) == NamedTuple()
        ch1 = _children_pairs((n,), true)
        vals = [(only(v), nothing) for v in values(ch1)]
        @test _children_pairs((n, sn), true) == (; zip(keys(ch1), vals)...)
    end

    for n in (n5, n6), sn in SINGLE_NODES[3:end]
        @test _children_pairs((n, sn), false) == tuple()
        ch1 = _children_pairs((n,), true)
        vals = [(only(v), nothing) for v in values(ch1)]
        @test _children_pairs((n, sn), true) == tuple(vals...)
    end

end
