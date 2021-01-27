@testset "list traversal" for t in TEST_TREES
    for l in list_traversal(t)
        # shouldn't fail
        walk(t, l)
    end
end

@testset "find_traversal" for t in TEST_TREES
    for l in list_traversal(t)
        res = find_traversal(walk(t, l), t)
        @test all(c -> walk(t, c) === walk(t, l), res)
    end
end

