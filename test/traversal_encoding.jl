@testset "list traversal" for t in TEST_TREES
    for l in list_traversal(t)
        # shouldn't fail
        walk(t, l)
    end
end

