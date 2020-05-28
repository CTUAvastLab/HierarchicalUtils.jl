@testset "printtree" begin
	buf = IOBuffer()
	printtree(buf, LINEAR_TREE1, trav=true)
	str_repr = String(take!(buf))
	@test str_repr ==
"""
ProductNode [""]
  ├── ProductNode ["E"]
  │     ├─── b: BagNode with 2 bag(s) ["I"]
  │     │         └── ArrayNode(3, 4) ["K"]
  │     └── wb: WeightedNode with 2 bag(s) and weights Σw = 11 ["M"]
  │               └── ArrayNode(17, 4) ["O"]
  └── ArrayNode(10, 2) ["U"]"""
	buf = IOBuffer()
	printtree(buf, LINEAR_TREE1, trav=false)
	str_repr = String(take!(buf))
	@test str_repr ==
"""
ProductNode [""]
  ├── ProductNode ["E"]
  │     ├─── b: BagNode with 2 bag(s) ["I"]
  │     │         └── ArrayNode(3, 4) ["K"]
  │     └── wb: WeightedNode with 2 bag(s) and weights Σw = 11 ["M"]
  │               └── ArrayNode(17, 4) ["O"]
  └── ArrayNode(10, 2) ["U"]"""
	buf = IOBuffer()
    printtree(buf, LINEAR_TREE1, trav=false, trunc=1)
	str_repr = String(take!(buf))
	@test str_repr ==
"""
ProductNode [""]
  ├── ProductNode ["E"]
  │     ├─── b: BagNode with 2 bag(s) ["I"]
  │     │         └── ArrayNode(3, 4) ["K"]
  │     └── wb: WeightedNode with 2 bag(s) and weights Σw = 11 ["M"]
  │               └── ArrayNode(17, 4) ["O"]
  └── ArrayNode(10, 2) ["U"]"""
end
