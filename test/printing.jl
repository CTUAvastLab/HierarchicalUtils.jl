function numlines(buf)
    s = String(take!(buf))
    sum(!isempty(strip(c)) for c in split(s, '\n'))
end

@testset "printtree length" for t in TEST_TREES
    buf = IOBuffer()
    printtree(buf, t)
    @test numlines(buf) == nnodes(t)
end

@testset "printtree truncation for infinite trees" begin
    t1 = VectorVertex(1, AbstractVertex[])
    push!(t1.chs, t1)
    t2 = Dict()
    t2["ch"] = t2
    buf1 = IOBuffer()
    printtree(buf1, t1; trunc=10)
    buf2 = IOBuffer()
    printtree(buf2, t2; trunc=20)
    @test numlines(buf1) == 10 + 1 # one line for ellipsis ⋮
    @test numlines(buf2) == 20 + 1 # one line for ellipsis ⋮
end

@testset "printtree labelled children sorted" begin
    t1 = Dict("a" => Leaf(1), "b" => Leaf(2), "c" => Leaf(3))
    t2 = Dict("c" => Leaf(3), "a" => Leaf(1), "b" => Leaf(2))
    t3 = Dict("b" => Leaf(2), "c" => Leaf(3), "a" => Leaf(1))
    @test all([t1, t2, t3]) do t
        buf = IOBuffer()
        printtree(buf, t)
        String(take!(buf)) ===
        """
Dict of
  ├── a: Leaf (1)
  ├── b: Leaf (2)
  └── c: Leaf (3)"""
    end
end

@testset "printtree traversal encoding" begin
    t = COMPLETE_BINARY_TREE_1
    buf = IOBuffer()
    printtree(buf, t)
    @test String(take!(buf)) ===
        """
BinaryVertex (1)
  ├── BinaryVertex (2)
  │     ├── Leaf (4)
  │     └── Leaf (5)
  └── BinaryVertex (3)
        ├── Leaf (6)
        └── Leaf (7)"""
    buf = IOBuffer()
    printtree(buf, t; trav=true)
    @test String(take!(buf)) ===
        """
BinaryVertex (1) [""]
  ├── BinaryVertex (2) ["E"]
  │     ├── Leaf (4) ["I"]
  │     └── Leaf (5) ["M"]
  └── BinaryVertex (3) ["U"]
        ├── Leaf (6) ["Y"]
        └── Leaf (7) ["c"]"""
end
