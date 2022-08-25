function context_sprintf(f, args...; context=IOContext(IOBuffer()), kwargs...)
    f(context, args...; kwargs...)
    String(take!(context.io))
end

function numlines(f, args...; kwargs...)
    s = context_sprintf(f, args...; kwargs...)
    sum(!isempty(strip(c)) for c in split(s, '\n'))
end

@testset "printtree length" for t in TEST_TREES
    @test numlines(printtree, t) == nnodes(t)
end

@testset "printtree horizontal truncation for infinite trees" begin
    t1 = VectorVertex(1, AbstractVertex[])
    push!(t1.chs, t1)
    t2 = Dict()
    t2["ch"] = t2
    @test numlines(printtree, t1, htrunc=10, limit=false) == 10 + 1 # one line for ellipsis
    @test numlines(printtree, t2, htrunc=20, limit=false) == 20 + 1 # one line for ellipsis
end

@testset "printtree vertical truncation for many children" for l in 0:20, vtrunc in 0:20
    v = 1:l |> collect
    @test numlines(printtree, v, vtrunc=vtrunc, limit=false) == min(l, vtrunc + 1) + 1 # one line for ellipsis and one for the header
end

@testset "printtree limit" begin
    t = NTVertex(0, (a=Leaf(1), b=Leaf(2), c=Leaf(3)))
    displaysize = (1, 1)
    context = IOContext(IOBuffer(), :limit => true, :displaysize => displaysize)
    @test context_sprintf(printtree, t; context) ==
        """
        NTV ⋯
          ┊
        """
    displaysize = (10, 1)
    context = IOContext(IOBuffer(), :limit => true, :displaysize => displaysize)
    @test context_sprintf(printtree, t; context) ==
        """
        NTV ⋯
          ┊
        """
    displaysize = (1, 7)
    context = IOContext(IOBuffer(), :limit => true, :displaysize => displaysize)
    @test context_sprintf(printtree, t; context) ==
        """
        NTVer ⋯
          ┊
        """
    displaysize = (6, 8)
    context = IOContext(IOBuffer(), :limit => true, :displaysize => displaysize)
    @test context_sprintf(printtree, t; context) ==
        """
        NTVert ⋯
          ├──  ⋯
          ┊
        """
    displaysize = (7, 8)
    context = IOContext(IOBuffer(), :limit => true, :displaysize => displaysize)
    @test context_sprintf(printtree, t; context) ==
        """
        NTVert ⋯
          ├──  ⋯
          ├──  ⋯
          ┊
        """
    displaysize = (8, 8)
    context = IOContext(IOBuffer(), :limit => true, :displaysize => displaysize)
    @test context_sprintf(printtree, t; context) ==
        """
        NTVert ⋯
          ├──  ⋯
          ├──  ⋯
          ╰──  ⋯
        """
    displaysize = (6, 10)
    context = IOContext(IOBuffer(), :limit => true, :displaysize => displaysize)
    @test context_sprintf(printtree, t; context) ==
        """
        NTVertex ⋯
          ├── a: ⋯
          ┊
        """
    displaysize = (7, 8)
    context = IOContext(IOBuffer(), :limit => true, :displaysize => displaysize)
    @test context_sprintf(printtree, t; context, vtrunc=2) ==
        """
        NTVert ⋯
          ├──  ⋯
          ├──  ⋯
          ┊
        """
end

@testset "printtree labelled children not sorted" begin
    t = NTVertex(0, (a=Leaf(1), b=Leaf(2), c=Leaf(3)))
    buff = IOBuffer()
    printtree(buff, t)
    @test String(take!(buff)) ==
        """
        NTVertex (0) comm
          ├── a: Leaf (1) comm
          ├── b: Leaf (2) comm
          ╰── c: Leaf (3) comm
        """

    t = NTVertex(0, (c=Leaf(3), b=Leaf(2), a=Leaf(1)))
    buff = IOBuffer()
    printtree(buff, t)
    @test String(take!(buff)) ==
        """
        NTVertex (0) comm
          ├── c: Leaf (3) comm
          ├── b: Leaf (2) comm
          ╰── a: Leaf (1) comm
        """

    t = NTVertex(0, (b=Leaf(2), c=Leaf(3), a=Leaf(1)))
    buff = IOBuffer()
    printtree(buff, t)
    @test String(take!(buff)) ==
        """
        NTVertex (0) comm
          ├── b: Leaf (2) comm
          ├── c: Leaf (3) comm
          ╰── a: Leaf (1) comm
        """
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
          │     ╰── Leaf (5) comm
          ╰── BinaryVertex (3) comm
                ├── Leaf (6) comm
                ╰── Leaf (7) comm
        """
    buf = IOBuffer()
    printtree(buf, t; trav=true)
    @test String(take!(buf)) ==
        """
        BinaryVertex (1) [""] comm
          ├── BinaryVertex (2) ["E"] comm
          │     ├── Leaf (4) ["I"] comm
          │     ╰── Leaf (5) ["M"] comm
          ╰── BinaryVertex (3) ["U"] comm
                ├── Leaf (6) ["Y"] comm
                ╰── Leaf (7) ["c"] comm
        """
end
