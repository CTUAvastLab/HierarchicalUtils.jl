nnodes(t) = nnodes(NodeType(t), t)
nnodes(::LeafNode, t) = 1
nnodes(::InnerNode, t) = 1 + mapreduce(nnodes, +, children(t); init=0)

nleafs(t) = nleafs(NodeType(t), t)
nleafs(::LeafNode, t) = 1
nleafs(::InnerNode, t) = mapreduce(nleafs, +, children(t); init=0) + Int(nchildren(t) == 0)
