increment!(n) = n.n += 1
function add_subtract!((n1, n2))
    c1 = isnothing(n1) ? 10 : n1.n
    c2 = isnothing(n2) ? 10 : n2.n
    if !isnothing(n1) n1.n += c2 end
    if !isnothing(n2) n2.n -= c1 end
end

flat_prod(ts::Union{Tuple, NamedTuple, Array, Dict}) = prod([flat_prod(t) for t in ts])
flat_prod(t) = t.n
flat_prod(::Nothing) = 1
function postorder_multiply_subtract(ts, chs)
    c = 0
    if !isempty(chs)
        c = flat_prod(chs)
    end
    c -= flat_prod(ts)
    if isempty(chs)
        return Leaf(c)
    elseif chs isa NamedTuple
        return NTVertex(c, chs)
    else
        return VectorVertex(c, collect(chs))
    end
end

@testset "treemap!" for o in ORDERS
        t = deepcopy(COMPLETE_BINARY_TREE_1)
        treemap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,5,6,7,8]
        t = deepcopy(COMPLETE_BINARY_TREE_2)
        treemap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,5,6,7,8]
        t = deepcopy(T1)
        treemap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,5,6,7,8]
        t = deepcopy(T2)
        treemap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,6,7,8]
        t = deepcopy(T3)
        treemap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,5,6]
        t = deepcopy(T4)
        treemap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,4,7,8]
        t = deepcopy(T5)
        treemap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2]

        t2, t3 = deepcopy.([T2, T3])
        treemap!(add_subtract!, t2, t3; complete=false, order=o)
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [2,4,3,10,6,7]
        @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [0,0,4,0]
        t2, t3 = deepcopy.([T2, T3])
        treemap!(add_subtract!, t2, t3; complete=true, order=o)
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [2,4,13,10,16,17]
        @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [0,0,-6,0]
end

@testset "leafmap!" for o in ORDERS
        t = deepcopy(COMPLETE_BINARY_TREE_1)
        leafmap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,5,6,7,8]
        t = deepcopy(COMPLETE_BINARY_TREE_2)
        leafmap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,5,6,7,8]
        t = deepcopy(T1)
        leafmap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,5,6,7,8]
        t = deepcopy(T2)
        leafmap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,6,7,8]
        t = deepcopy(T3)
        leafmap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,5,6]
        t = deepcopy(T4)
        leafmap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,3,7,8]
        t = deepcopy(T5)
        leafmap!(increment!, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2]

        t2, t3 = deepcopy.([T2, T3])
        leafmap!(add_subtract!, t2, t3; complete=false, order=o)
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,3,10,6,7]
        @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [1,2,4,0]
        t2, t3 = deepcopy.([T2, T3])
        leafmap!(add_subtract!, t2, t3; complete=true, order=o)
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,3,10,16,17]
        @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [1,2,-6,0]
end

@testset "typemap!" for o in ORDERS
        t = deepcopy(COMPLETE_BINARY_TREE_1)
        typemap!(increment!, BinaryVertex, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,4,5,6,7]
        t = deepcopy(COMPLETE_BINARY_TREE_2)
        typemap!(increment!, NTVertex, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,3,4,6,6,8]
        t = deepcopy(T1)
        typemap!(increment!, Leaf, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,5,5,7,7]
        t = deepcopy(T2)
        typemap!(increment!, Any, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,6,7,8]
        t = deepcopy(T3)
        typemap!(increment!, Union{Leaf, NTVertex}, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,6]
        t = deepcopy(T4)
        typemap!(increment!, BinaryVertex, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,4,6,7]
        t = deepcopy(T5)
        typemap!(increment!, NTVertex, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2]

        t1, t2 = deepcopy.([T1, T2])
        typemap!(add_subtract!, (BinaryVertex, BinaryVertex), t1, t2; complete=false, order=o)
        @test  [n.n for n in collect(NodeIterator(t1; order=LevelOrder()))] == [1,2,6,4,5,6,7]
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,0,5,6,7]
        t1, t2 = deepcopy.([T1, T2])
        typemap!(add_subtract!, (NTVertex, Leaf), t1, t2; complete=true, order=o)
        @test  [n.n for n in collect(NodeIterator(t1; order=LevelOrder()))] == [1,2,3,4,5,6,14]
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,3,5,6,0]
end

@testset "predicatemap!" for o in ORDERS
        t = deepcopy(COMPLETE_BINARY_TREE_1)
        predicatemap!(increment!, HierarchicalUtils._leaf_predicate, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,5,6,7,8]
        t = deepcopy(COMPLETE_BINARY_TREE_2)
        predicatemap!(increment!, HierarchicalUtils._leaf_predicate, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,5,6,7,8]
        t = deepcopy(T1)
        predicatemap!(increment!, HierarchicalUtils._leaf_predicate, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,5,6,7,8]
        t = deepcopy(T2)
        predicatemap!(increment!, HierarchicalUtils._leaf_predicate, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,6,7,8]
        t = deepcopy(T3)
        predicatemap!(increment!, HierarchicalUtils._leaf_predicate, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,5,6]
        t = deepcopy(T4)
        predicatemap!(increment!, HierarchicalUtils._leaf_predicate, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,3,7,8]
        t = deepcopy(T5)
        predicatemap!(increment!, HierarchicalUtils._leaf_predicate, t; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2]

        t2, t3 = deepcopy.([T2, T3])
        predicatemap!(add_subtract!, HierarchicalUtils._leaf_predicate, t2, t3; complete=false, order=o)
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,3,10,6,7]
        @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [1,2,4,0]
        t2, t3 = deepcopy.([T2, T3])
        predicatemap!(add_subtract!, HierarchicalUtils._leaf_predicate, t2, t3; complete=true, order=o)
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,3,10,16,17]
        @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [1,2,-6,0]
end

@testset "postorder treemap" begin
        t = treemap(postorder_multiply_subtract, COMPLETE_BINARY_TREE_1)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [701,18,39,-4,-5,-6,-7]
        t = treemap(postorder_multiply_subtract, COMPLETE_BINARY_TREE_1, COMPLETE_BINARY_TREE_1)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [694979,396,1755,-16,-25,-36,-49]

        t = treemap(postorder_multiply_subtract, T2, T3; complete=true)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [3743,96,39,-4,-25,-6,-7]
        t = treemap(postorder_multiply_subtract, T2, T3; complete=false)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [-30, -29, -25]
end
