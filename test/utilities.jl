l1, l2, l3 = Leaf.([1, 2, 3])
n1nt = NTVertex(1, (a = l1, c = l3, b = l2))
n2nt = NTVertex(2, (c = l3, a = l1))
n3nt = NTVertex(3, (b = l2, c = l3))
n4nt = NTVertex(4, (b = l2,))
n5nt = NTVertex(5, NamedTuple())
n1d = Dict("a" => l1, "c" => l3, "b" => l2)
n2d = Dict("c" => l3, "a" => l1)
n3d = Dict("c" => l3, "b" => l2)
n4d = Dict("b" => l2)
n5d = Dict()
n1pv = VectorVertex(1, [l1, l2, l3])
n2pv = [3 => l3, 1 => l1]
n3pv = [3 => l3, 2 => l2]
n4pv = [2 => l2]
n5pv = Pair[]

n1v = [l1, l2, l3]
n2v = BinaryVertex(2, l1, l3)
n3v = [l2]
n4v = []

n1t = (l1, l2, l3)
n2t = (l1, l3)
n3t = SingletonVertex(2, l2)
n4t = ()

@testset "NamedTuple children pairing" begin
    @test _children_pairs((n1nt, n2nt), false) == (a = (l1, l1), c = (l3, l3))
    @test _children_pairs((n1nt, n2nt), true) == (a = (l1, l1), b = (l2, nothing), c = (l3, l3))

    @test _children_pairs((n1nt, n3nt), false) == (b = (l2, l2), c = (l3, l3))
    @test _children_pairs((n1nt, n3nt), true) == (a = (l1, nothing), b = (l2, l2), c = (l3, l3))
    @test _children_pairs((n3nt, n1nt), true) == (a = (nothing, l1), b = (l2, l2), c = (l3, l3))

    @test _children_pairs((n1nt, n4nt), false) == (b = (l2, l2),)
    @test _children_pairs((n1nt, n4nt), true) == (a = (l1, nothing), b = (l2, l2), c = (l3, nothing))

    @test _children_pairs((n1nt, n2nt, n3nt), false) == (c = (l3, l3, l3),)
    @test _children_pairs((n1nt, n2nt, n3nt), true) == (a = (l1, l1, nothing), b = (l2, nothing, l2), c = (l3, l3, l3))

    @test _children_pairs((n1nt, n2nt, n3nt, n4nt), false) == NamedTuple()
    @test _children_pairs((n1nt, n2nt, n3nt, n4nt), true) == (a = (l1, l1, nothing, nothing), b = (l2, nothing, l2, l2), c = (l3, l3, l3, nothing))

    for n in [n1nt, n2nt, n3nt, n4nt]
        @test _children_pairs((n, n5nt, nothing), false) == NamedTuple()
        @test _children_pairs((n, nothing), false) == NamedTuple()
        @test _children_pairs((n, n5nt), false) == NamedTuple()
        res = (; (Symbol(k) => (ch, nothing, nothing) for (k,ch) in _childsort(children(n)) |> pairs)...)
        @test _children_pairs((n, n5nt, nothing), true) == res
        res = (; (Symbol(k) => (ch, nothing) for (k,ch) in _childsort(children(n)) |> pairs)...)
        @test _children_pairs((n, nothing), true) == res
        @test _children_pairs((n, n5nt), true) == res
    end
end

@testset "Dict children pairing" begin
    @test _children_pairs((n1d, n2d), false) == OrderedDict("a" => (l1, l1), "c" => (l3, l3))
    @test _children_pairs((n1d, n2d), true) == OrderedDict("a" => (l1, l1), "b" => (l2, nothing), "c" => (l3, l3))

    @test _children_pairs((n1d, n3d), false) == OrderedDict("b" => (l2, l2), "c" => (l3, l3))
    @test _children_pairs((n1d, n3d), true) == OrderedDict("a" => (l1, nothing), "b" => (l2, l2), "c" => (l3, l3))
    @test _children_pairs((n3d, n1d), true) == OrderedDict("a" => (nothing, l1), "b" => (l2, l2), "c" => (l3, l3))

    @test _children_pairs((n1d, n4d), false) == OrderedDict("b" => (l2, l2),)
    @test _children_pairs((n1d, n4d), true) == OrderedDict("a" => (l1, nothing), "b" => (l2, l2), "c" => (l3, nothing))

    @test _children_pairs((n1d, n2d, n3d), false) == OrderedDict("c" => (l3, l3, l3),)
    @test _children_pairs((n1d, n2d, n3d), true) == OrderedDict("a" => (l1, l1, nothing), "b" => (l2, nothing, l2), "c" => (l3, l3, l3))

    @test _children_pairs((n1d, n2d, n3d, n4d), false) == OrderedDict()
    @test _children_pairs((n1d, n2d, n3d, n4d), true) == OrderedDict("a" => (l1, l1, nothing, nothing),
                                                                     "b" => (l2, nothing, l2, l2), "c" => (l3, l3, l3, nothing))

    for n in [n1d, n2d, n3d, n4d]
        @test _children_pairs((n, n5d, nothing), false) == OrderedDict()
        @test _children_pairs((n, nothing), false) == OrderedDict()
        @test _children_pairs((n, n5d), false) == OrderedDict()
        res = OrderedDict(k => (ch, nothing, nothing) for (k,ch) in children(n) |> pairs)
        @test _children_pairs((n, n5d, nothing), true) == res
        res = OrderedDict(k => (ch, nothing) for (k,ch) in children(n) |> pairs)
        @test _children_pairs((n, nothing), true) == res
        @test _children_pairs((n, n5d), true) == res
    end
end

@testset "PairVec children pairing" begin
    @test _children_pairs((n1pv, n2pv), false) == [1 => (l1, l1), 3 => (l3, l3)]
    @test _children_pairs((n1pv, n2pv), true) == [1 => (l1, l1), 2 => (l2, nothing), 3 => (l3, l3)]

    @test _children_pairs((n1pv, n3pv), false) == [2 => (l2, l2), 3 => (l3, l3)]
    @test _children_pairs((n1pv, n3pv), true) == [1 => (l1, nothing), 2 => (l2, l2), 3 => (l3, l3)]
    @test _children_pairs((n3pv, n1pv), true) == [1 => (nothing, l1), 2 => (l2, l2), 3 => (l3, l3)]

    @test _children_pairs((n1pv, n4pv), false) == [2 => (l2, l2),]
    @test _children_pairs((n1pv, n4pv), true) == [1 => (l1, nothing), 2 => (l2, l2), 3 => (l3, nothing)]

    @test _children_pairs((n1pv, n2pv, n3pv), false) == [3 => (l3, l3, l3),]
    @test _children_pairs((n1pv, n2pv, n3pv), true) == [1 => (l1, l1, nothing), 2 => (l2, nothing, l2), 3 => (l3, l3, l3)]

    @test _children_pairs((n1pv, n2pv, n3pv, n4pv), false) == []
    @test _children_pairs((n1pv, n2pv, n3pv, n4pv), true) == [1 => (l1, l1, nothing, nothing), 2 => (l2, nothing, l2, l2), 3 => (l3, l3, l3, nothing)]

    for n in [n1pv, n2pv, n3pv, n4pv]
        @test _children_pairs((n, n5pv, nothing), false) == []
        @test _children_pairs((n, nothing), false) == []
        @test _children_pairs((n, n5pv), false) == []
        res = [k => (ch, nothing, nothing) for (k,ch) in _childsort(children(n))]
        @test _children_pairs((n, n5pv, nothing), true) == res
        res = [k => (ch, nothing) for (k,ch) in _childsort(children(n))]
        @test _children_pairs((n, nothing), true) == res
        @test _children_pairs((n, n5pv), true) == res
    end
end

struct SameKeys
end

NodeType(::Type{<:SameKeys}) = HierarchicalUtils.InnerNode()
children(t::SameKeys) = ["a" => 1, "b" => 2, "a" => 2]

@testset "duplicate keys in Pair vecs" begin
    @test_throws ArgumentError _children_pairs((SameKeys(),), true)
    @test_throws ArgumentError _children_pairs((SameKeys(),), false)
    @test_throws ArgumentError _children_pairs((SameKeys(), SameKeys()), true)
    @test_throws ArgumentError _children_pairs((SameKeys(), SameKeys()), false)
end

@testset "Vector children pairing" begin
    @test _children_pairs((n1v, n2v), false) == [(l1, l1), (l2, l3)]
    @test _children_pairs((n1v, n2v), true) == [(l1, l1), (l2, l3), (l3, nothing)]

    @test _children_pairs((n1v, n3v), false) == [(l1, l2)]
    @test _children_pairs((n1v, n3v), true) == [(l1, l2), (l2, nothing), (l3, nothing)]

    @test _children_pairs((n2v, n3v), false) == [(l1, l2)]
    @test _children_pairs((n2v, n3v), true) == [(l1, l2), (l3, nothing)]

    for n in [n1v, n2v, n3v]
        @test _children_pairs((n, n4v, nothing), false) == []
        @test _children_pairs((n, nothing), false) == []
        @test _children_pairs((n, n4v), false) == []
        res = [(ch, nothing, nothing) for ch in _childsort(children(n))]
        @test _children_pairs((n, n4v, nothing), true) == res
        res = [(ch, nothing) for ch in _childsort(children(n))]
        @test _children_pairs((n, nothing), true) == res
        @test _children_pairs((n, n4v), true) == res
    end
end

@testset "Tuple children pairing" begin
    @test _children_pairs((n1t, n2t), false) == ((l1, l1), (l2, l3))
    @test _children_pairs((n1t, n2t), true) == ((l1, l1), (l2, l3), (l3, nothing))

    @test _children_pairs((n1t, n3t), false) == ((l1, l2),)
    @test _children_pairs((n1t, n3t), true) == ((l1, l2), (l2, nothing), (l3, nothing))

    @test _children_pairs((n2t, n3t), false) == ((l1, l2),)
    @test _children_pairs((n2t, n3t), true) == ((l1, l2), (l3, nothing))

    for n in [n1t, n2t, n3t]
        @test _children_pairs((n, n4t, nothing), false) == ()
        @test _children_pairs((n, nothing), false) == ()
        @test _children_pairs((n, n4t), false) == ()
        res = tuple(((ch, nothing, nothing) for ch in _childsort(children(n)))...)
        @test _children_pairs((n, n4t, nothing), true) == res
        res = tuple(((ch, nothing) for ch in _childsort(children(n)))...)
        @test _children_pairs((n, nothing), true) == res
        @test _children_pairs((n, n4t), true) == res
    end
end

@testset "Incompatible types" begin
    for (a, b) in product([n1nt, n2nt, n3nt, n4nt, n1d, n2d, n3d, n4d, n1pv, n2pv, n3pv, n4pv],
                          [n1v, n2v, n3v, n1t, n2t, n3t])
        @test_throws ArgumentError _children_pairs((a, b), true)
        @test_throws ArgumentError _children_pairs((b, a), true)
        @test_throws ArgumentError _children_pairs((a, b), false)
        @test_throws ArgumentError _children_pairs((b, a), false)
    end
end

