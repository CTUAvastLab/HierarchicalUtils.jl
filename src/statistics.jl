nnodes(t) = nnodes(NodeType(t), t)
nnodes(::LeafNode, t) = 1
# nnodes(::SingletonNode, t) = 1 + nnodes(children(t))
# nnodes(::InnerNode, t) = 1 + mapreduce(nnodes, +, children(t); init=0)
nnodes(_, t) = 1 + mapreduce(nnodes, +, children(t); init=0)

# TODO nleafs again working only with types
# nleafs(t) = mapreduce(nleafs, +, children(t); init=0) + Int(nchildren(t) == 0)
nleafs(t) = nleafs(NodeType(t), t)
nleafs(::LeafNode, t) = 1
nleafs(_, t) = mapreduce(nleafs, +, children(t); init=0)


