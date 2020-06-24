increment!(n) = n.n += 1
function add_subtract!((n1, n2))
    c1 = isnothing(n1) ? 10 : n1.n
    c2 = isnothing(n2) ? 10 : n2.n
    if !isnothing(n1) n1.n += c2 end
    if !isnothing(n2) n2.n -= c1 end
end

function postorder_multiply_subtract(ts, chs)
    c = 0
    if !isempty(chs)
        c = prod([ch.n for ch in chs])
    end
    c -= prod([t.n for t in ts])
    if isempty(chs)
        return Leaf(c)
    elseif chs isa NamedTuple
        return NTVertex(c, chs)
    else
        return VectorVertex(c, chs)
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
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,6,7]
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
        treemap!(add_subtract!, (t2, t3); complete=false, order=o)
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [2,4,3,10,6]
        @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [0,0,4,0]
        t2, t3 = deepcopy.([T2, T3])
        treemap!(add_subtract!, (t2, t3); complete=true, order=o)
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [2,4,13,10,16]
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
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,6,7]
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
        leafmap!(add_subtract!, (t2, t3); complete=false, order=o)
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,3,10,6]
        @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [1,2,4,0]
        t2, t3 = deepcopy.([T2, T3])
        leafmap!(add_subtract!, (t2, t3); complete=true, order=o)
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,3,10,16]
        @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [1,2,-6,0]
end

@testset "typemap!" for o in ORDERS
        t = deepcopy(COMPLETE_BINARY_TREE_1)
        typemap!(increment!, t, BinaryVertex; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,4,5,6,7]
        t = deepcopy(COMPLETE_BINARY_TREE_2)
        typemap!(increment!, t, NTVertex; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,3,4,6,6,8]
        t = deepcopy(T1)
        typemap!(increment!, t, Leaf; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,5,5,7,7]
        t = deepcopy(T2)
        typemap!(increment!, t, Any; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,6,7]
        t = deepcopy(T3)
        typemap!(increment!, t, Union{Leaf, NTVertex}; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,6]
        t = deepcopy(T4)
        typemap!(increment!, t, BinaryVertex; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,4,6,7]
        t = deepcopy(T5)
        typemap!(increment!, t, NTVertex; order=o)
        @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2]

        t1, t2 = deepcopy.([T1, T2])
        typemap!(add_subtract!, (t1, t2), (BinaryVertex, VectorVertex); complete=false, order=o)
        @test  [n.n for n in collect(NodeIterator(t1; order=LevelOrder()))] == [1,2,6,4,5,6,7]
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,0,5,6]
        t1, t2 = deepcopy.([T1, T2])
        typemap!(add_subtract!, (t1, t2), (NTVertex, Nothing); complete=true, order=o)
        @test  [n.n for n in collect(NodeIterator(t1; order=LevelOrder()))] == [1,2,3,4,5,6,17]
        @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,3,5,6]
end

# @testset "postorder treemap" for o in ORDERS
#         # children are passed as named tuple
#         t = deepcopy(COMPLETE_BINARY_TREE_1)
#         typemap!(increment!, t, BinaryVertex; order=o)
#         @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,4,5,6,7]
#         t = deepcopy(COMPLETE_BINARY_TREE_2)
#         typemap!(increment!, t, NTVertex; order=o)
#         @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,2,3,4,5,7,7]
#         t = deepcopy(T1)
#         typemap!(increment!, t, Leaf; order=o)
#         @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,2,3,5,5,6,8]
#         t = deepcopy(T2)
#         typemap!(increment!, t, Any; order=o)
#         @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,6,7]
#         t = deepcopy(T3)
#         typemap!(increment!, t, Union{Leaf, NTVertex}; order=o)
#         @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [2,3,4,6]
#         t = deepcopy(T4)
#         typemap!(increment!, t, BinaryVertex; order=o)
#         @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1,4,6,7]
#         t = deepcopy(T5)
#         typemap!(increment!, t, NTVertex; order=o)
#         @test  [n.n for n in collect(NodeIterator(t; order=LevelOrder()))] == [1]

#         t2, t3 = deepcopy.([T2, T3])
#         typemap!(add_subtract!, (t2, t3), (NTVertex, Leaf); complete=false, order=o)
#         @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [1,2,3,10,6]
#         @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [1,2,4,0]
#         t2, t3 = deepcopy.([T2, T3])
#         typemap!(add_subtract!, (t2, t3), NTVertex; complete=true, order=o)
#         @test  [n.n for n in collect(NodeIterator(t2; order=LevelOrder()))] == [2,4,3,5,6]
#         @test  [n.n for n in collect(NodeIterator(t3; order=LevelOrder()))] == [0,0,4,5]
# end
