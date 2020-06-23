import HierarchicalUtils: _children_pairs_keys

@testset "children pairing" begin
    l1, l2, l3 = Leaf.([1, 2, 3])
    n1 = NTVertex(1, (a = l1, c = l3, b = l2))
    n2 = NTVertex(2, (c = l3, a = l1))
    n3 = Dict("b" => l2, "c" => l3)
    n4 = NTVertex(4, (b = l2,))
    n5 = [l1, l2, l3]
    n6 = VectorVertex(6, [l1, l3])

    @test _children_pairs_keys((n1, n2), false) == (a = (l1, l1), c = (l3, l3))
    @test _children_pairs_keys((n1, n2), true) == (a = (l1, l1), b = (l2, nothing), c = (l3, l3))

    @test _children_pairs_keys((n1, n3), false) == (b = (l2, l2), c = (l3, l3))
    @test _children_pairs_keys((n1, n3), true) == (a = (l1, nothing), b = (l2, l2), c = (l3, l3))
    @test _children_pairs_keys((n3, n1), true) == (a = (nothing, l1), b = (l2, l2), c = (l3, l3))

    @test _children_pairs_keys((n1, n4), false) == (b = (l2, l2),)
    @test _children_pairs_keys((n1, n4), true) == (a = (l1, nothing), b = (l2, l2), c = (l3, nothing))

    @test _children_pairs_keys((n1, n2, n3), false) == (c = (l3, l3, l3),)
    @test _children_pairs_keys((n1, n2, n3), true) == (a = (l1, l1, nothing), b = (l2, nothing, l2), c = (l3, l3, l3))

    @test _children_pairs_keys((n1, n2, n3, n4), false) == NamedTuple()
    @test _children_pairs_keys((n1, n2, n3, n4), true) == (a = (l1, l1, nothing, nothing), b = (l2, nothing, l2, l2), c = (l3, l3, l3, nothing))

    # tuple elements considered as indexed i1, i2, i3, ...
    @test _children_pairs_keys((n1, n5), false) == NamedTuple()
    @test _children_pairs_keys((n1, n5), true) == (; zip((:a, :b, :c, :(i1), :(i2), :(i3)), 
                                                         ((l1, nothing), (l2, nothing), (l3, nothing),
                                                         (nothing, l1), (nothing, l2), (nothing, l3)))...)
    @test _children_pairs_keys((n1, n6), false) == NamedTuple()
    @test _children_pairs_keys((n1, n6), true) == (; zip((:a, :b, :c, :(i1), :(i2)), 
                                                         ((l1, nothing), (l2, nothing), (l3, nothing),
                                                         (nothing, l1), (nothing, l3)))...)


    for n in (n1, n2, n3, n4, n5, n6), sn in SINGLE_NODES
        @test _children_pairs_keys((n, sn), false) == NamedTuple()
        ch1 = _children_pairs_keys((n,), true)
        vals = [(only(v), nothing) for v in values(ch1)]
        @test _children_pairs_keys((n, sn), true) == (; zip(keys(ch1), vals)...)
    end

end
