const TEST_TREES_NUMBERED = [
                             SINGLE_NODE_1, SINGLE_NODE_2, SINGLE_NODE_3,
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

@testset "tuple x only tree handling" for t in TEST_TREES_NUMBERED
    for o in ORDERS
        @test collect(NodeIterator(t; order=o)) == collect(map(only, NodeIterator((t,); order=o)))
        @test collect(PredicateIterator(t, t -> t.n > 3; order=o)) ==
        collect(map(only, PredicateIterator((t,), t -> only(t).n > 3; order=o))) ==
        vcat(map(unique, PredicateIterator((t,t), t -> t[1].n > 3; order=o))...)
    end
end

@testset "type iterator same types" for t in TEST_TREES_NUMBERED
    for o in ORDERS, type in TYPES
        @test collect(TypeIterator(t, type; order=o)) ==
        collect(map(only, TypeIterator((t,), type; order=o))) ==
        collect(map(only, TypeIterator((t,), (type,); order=o))) ==
        vcat(map(unique, TypeIterator((t,t), type; order=o))...) ==
        vcat(map(unique, TypeIterator((t,t), (type, type); order=o))...)
    end
end

@testset "type iterator different types" for t in TEST_TREES_NUMBERED
    for o in ORDERS, type in TYPES
        @test collect(TypeIterator((t,t), (type, type); order=o)) ==
        zip(collect(TypeIterator(t, type; order=o)),
            collect(TypeIterator(t, type; order=o))) |> collect
    end
end

@testset "empty iterator" for o in ORDERS
    @test collect(NodeIterator((); order=o, complete=true)) ==
    collect(NodeIterator((); order=o, complete=false)) == Union{}[]
    @test collect(LeafIterator((); order=o, complete=true)) ==
    collect(LeafIterator((); order=o, complete=false)) == Union{}[]
end

@testset "complete traversals" for o in ORDERS
    FULL_ORDER = Dict(PreOrder() => PREORDERS[end], 
                        PostOrder() => POSTORDERS[end],
                        LevelOrder() => LEVELORDERS[end])
    for ts in powerset([T1, T2, T3, T4, T5])
        !isempty(ts) || continue
        full_it = NodeIterator(tuple(ts...); order=o, complete=true)
        res = collect(map(ts -> tuple([isnothing(t) ? t : t.n for t in ts]...), full_it))
        single_res = [collect(map(t -> t.n, NodeIterator(t; order=o))) for t in ts]
        idcs = intersect(FULL_ORDER[o], union(single_res...))
        @test all(irs -> all(r -> isnothing(r) || r == irs[1], irs[2]), zip(idcs, res))
    end
end

@testset "incomplete traversals" for o in ORDERS
    for ts in powerset([T1, T2, T3, T4, T5])
        !isempty(ts) || continue
        full_it = NodeIterator(tuple(ts...); order=o, complete=false)
        res = collect(map(ts -> tuple([isnothing(t) ? t : t.n for t in ts]...), full_it))
        @test all(r -> length(unique(r)) == 1, res)
        res = vcat([unique(r) for r in res]...)
        single_res = [collect(map(t -> t.n, NodeIterator(t; order=o))) for t in ts]
        @test intersect(single_res...) == res
    end
end
