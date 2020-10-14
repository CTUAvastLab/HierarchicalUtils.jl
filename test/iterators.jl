const TEST_TREES_NUMBERED = [
                             SINGLE_NODE_1, SINGLE_NODE_3, SINGLE_NODE_4,
                             LINEAR_TREE_1, LINEAR_TREE_2,
                             COMPLETE_BINARY_TREE_1, COMPLETE_BINARY_TREE_2
                            ]

const PREORDERS = [
                   [1],
                   [1],
                   [1],
                   [1,2,3,4],
                   [1,2,3,4],
                   [1,2,4,5,3,6,7],
                   [1,2,4,5,3,6,7]
                  ]

const POSTORDERS = [
                    [1],
                    [1],
                    [1],
                    [4,3,2,1],
                    [4,3,2,1],
                    [4,5,2,6,7,3,1],
                    [4,5,2,6,7,3,1]
                   ]

const LEVELORDERS = [
                     [1],
                     [1],
                     [1],
                     collect(1:4),
                     collect(1:4),
                     collect(1:7),
                     collect(1:7)
                    ]

@testset "preorder node iterator on single tree" for (t,r) in zip(TEST_TREES_NUMBERED, PREORDERS)
    @test r == map(t -> t.n, NodeIterator(t; order=PreOrder())) |> collect
end

@testset "postorder node iterator on single tree" for (t,r) in zip(TEST_TREES_NUMBERED, POSTORDERS)
    @test r == map(t -> t.n, NodeIterator(t; order=PostOrder())) |> collect
end

@testset "levelorder node iterator on single tree" for (t,r) in zip(TEST_TREES_NUMBERED, LEVELORDERS)
    @test r == map(t -> t.n, NodeIterator(t; order=LevelOrder())) |> collect
end

@testset "multiple tree handling" for t in TEST_TREES_NUMBERED
    for o in ORDERS
        @test collect(map(only, PredicateIterator(_node_predicate, (t,), false; order=o))) ==
                    collect(NodeIterator(t; order=o))
        @test collect(PredicateIterator(t -> t.n > 3, t; order=o)) ==
            collect(map(only, PredicateIterator(t -> only(t).n > 3, (t,), false; order=o))) ==
            vcat(map(unique, PredicateIterator(t -> t[1].n > 3, t, t; order=o))...)
    end
end

@testset "type iterator same types" for t in TEST_TREES_NUMBERED
    for o in ORDERS, type in TYPES
        @test collect(TypeIterator(type, t; order=o)) ==
        vcat(map(unique, TypeIterator(type, t, t; order=o))...) ==
        vcat(map(unique, TypeIterator((type, type), t, t; order=o))...)
    end
end

@testset "type iterator different types" for t in TEST_TREES_NUMBERED
    for o in ORDERS, type in TYPES
        @test collect(TypeIterator((type, type), t, t; order=o)) ==
        zip(collect(TypeIterator(type, t; order=o)),
            collect(TypeIterator(type, t; order=o))) |> collect
    end
end

@testset "empty iterator" for o in ORDERS
    @test collect(NodeIterator(; order=o, complete=true)) ==
    collect(NodeIterator(; order=o, complete=false)) == Union{}[]
    @test collect(LeafIterator(; order=o, complete=true)) ==
    collect(LeafIterator(; order=o, complete=false)) == Union{}[]
end

@testset "complete traversals" for o in ORDERS
    FULL_ORDER = Dict(PreOrder() => PREORDERS[end], 
                        PostOrder() => POSTORDERS[end],
                        LevelOrder() => LEVELORDERS[end])
    for ts in powerset([T1, T2, T3, T4, T5])
        !isempty(ts) || continue
        res = NodeIterator(ts...; order=o, complete=true)
        if length(ts) == 1
            res = map(tuple, res)
        end
        res = collect(map(ts -> tuple([isnothing(t) ? t : t.n for t in ts]...), res))
        single_res = [collect(map(t -> t.n, NodeIterator(t; order=o))) for t in ts]
        idcs = intersect(FULL_ORDER[o], union(single_res...))
        @test all(irs -> all(r -> isnothing(r) || r == irs[1], irs[2]), zip(idcs, res))
    end
end

@testset "incomplete traversals" for o in ORDERS
    for ts in powerset([T1, T2, T3, T4, T5])
        !isempty(ts) || continue
        res = NodeIterator(ts...; order=o, complete=false)
        if length(ts) == 1
            res = map(tuple, res)
        end
        res = collect(map(ts -> tuple([isnothing(t) ? t : t.n for t in ts]...), res))
        @test all(r -> length(unique(r)) == 1, res)
        res = vcat([unique(r) for r in res]...)
        single_res = [collect(map(t -> t.n, NodeIterator(t; order=o))) for t in ts]
        @test intersect(single_res...) == res
    end
end
