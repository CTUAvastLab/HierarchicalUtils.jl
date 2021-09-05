function numlines(buf)
    s = String(take!(buf))
    sum(!isempty(strip(c)) for c in split(s, '\n'))
end

@testset "printtree length" for t in TEST_TREES
    buf = IOBuffer()
    printtree(buf, t)
    @test numlines(buf) == nnodes(t)
end

@testset "printtree horizontal truncation for infinite trees" begin
    t1 = VectorVertex(1, AbstractVertex[])
    push!(t1.chs, t1)
    t2 = Dict()
    t2["ch"] = t2
    buf1 = IOBuffer()
    printtree(buf1, t1; htrunc=10)
    buf2 = IOBuffer()
    printtree(buf2, t2; htrunc=20)
    @test numlines(buf1) == 10 + 1 # one line for ellipsis ⋮
    @test numlines(buf2) == 20 + 1 # one line for ellipsis ⋮
end

@testset "printtree vertical truncation for many children" for l in 0:20, vtrunc in 0:20
    v = 1:l |> collect
    buf = IOBuffer()
    printtree(buf, v; vtrunc=vtrunc)
    @test numlines(buf) == min(l, vtrunc + 1) + 1 # one line for ellipsis ⋮ and one for the header
end

@testset "printtree labelled children sorted" begin
    t1 = Dict("a" => Leaf(1), "b" => Leaf(2), "c" => Leaf(3))
    t2 = Dict("c" => Leaf(3), "a" => Leaf(1), "b" => Leaf(2))
    t3 = Dict("b" => Leaf(2), "c" => Leaf(3), "a" => Leaf(1))
    @test all([t1, t2, t3]) do t
        buff = IOBuffer()
        printtree(buff, t)
        String(take!(buff)) ==
        """
        Dict of
          ├── a: Leaf (1) comm
          ├── b: Leaf (2) comm
          └── c: Leaf (3) comm
        """
    end
end

@testset "printtree traversal encoding" begin
    t = COMPLETE_BINARY_TREE_1
    buf = IOBuffer()
    printtree(buf, t)
    @test String(take!(buf)) ==
        """
        BinaryVertex (1) comm
          ├── BinaryVertex (2) comm
          │     ├── Leaf (4) comm
          │     └── Leaf (5) comm
          └── BinaryVertex (3) comm
                ├── Leaf (6) comm
                └── Leaf (7) comm
        """
    buf = IOBuffer()
    printtree(buf, t; trav=true)
    @test String(take!(buf)) ==
        """
        BinaryVertex (1) [""] comm
          ├── BinaryVertex (2) ["E"] comm
          │     ├── Leaf (4) ["I"] comm
          │     └── Leaf (5) ["M"] comm
          └── BinaryVertex (3) ["U"] comm
                ├── Leaf (6) ["Y"] comm
                └── Leaf (7) ["c"] comm
        """
end
