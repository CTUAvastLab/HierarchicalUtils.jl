@testset "list traversal" for t in TEST_TREES
    for l in list_traversal(t)
        # shouldn't fail
        walk(t, l)
    end
end

@testset "findin" for t in TEST_TREES
    for l in list_traversal(t)
        res = findin(walk(t, l), t)
        @test all(c -> walk(t, c) === walk(t, l), res)
    end
end

