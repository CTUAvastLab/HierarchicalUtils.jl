@testset "find_traversal & list_traversal" for t in TEST_TREES
    for l in list_traversal(t)
        res = find_traversal(t, walk(t, l))
        @test all(c -> walk(t, c) === walk(t, l), res)
    end
    @test isempty(find_traversal(t, Leaf(-1)))
    @test isempty(find_traversal(t, [t, t]))
    @test isempty(find_traversal(t, BinaryVertex(-1, t, t)))
end
