nnodes(t) = _nnodes(NodeType(t), t)
_nnodes(::LeafNode, _) = 1
_nnodes(::InnerNode, t) = 1 + mapreduce(nnodes, +, children(t); init=0)

nleafs(t) = _nleafs(NodeType(t), t)
_nleafs(::LeafNode, _) = 1
_nleafs(::InnerNode, t) = mapreduce(nleafs, +, children(t); init=0) + Int(nchildren(t) == 0)

treeheight(t) = _treeheight(NodeType(t), t)
_treeheight(::LeafNode, _) = 0
_treeheight(::InnerNode, t) = mapreduce(treeheight, max, children(t); init=-1) + 1
