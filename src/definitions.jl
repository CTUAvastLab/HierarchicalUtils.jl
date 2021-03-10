macro hierarchical_dict()
    return esc(
               quote
                   import HierarchicalUtils: NodeType, InnerNode, noderepr, children
                   NodeType(::Type{<:Dict}) = InnerNode()
                   children(d::Dict) = d
                   noderepr(d::Dict) = isempty(d) ? "Empty Dict" : "Dict of"
                   nothing
               end
              )
end

macro hierarchical_vector()
    return esc(
               quote
                   import HierarchicalUtils: NodeType, InnerNode, noderepr, children
                   NodeType(::Type{<:Vector}) = InnerNode()
                   children(v::Vector) = v
                   noderepr(v::Vector) = isempty(v) ? "[]" : "Vector of"
                   nothing
               end
              )
end

macro hierarchical_tuple()
    return esc(
               quote
                   import HierarchicalUtils: NodeType, InnerNode, noderepr, children
                   NodeType(::Type{<:Tuple}) = InnerNode()
                   children(v::Tuple) = v
                   noderepr(v::Tuple) = isempty(v) ? "()" : "Tuple of"
                   nothing
               end
              )
end

macro hierarchical_namedtuple()
    return esc(
               quote
                   import HierarchicalUtils: NodeType, InnerNode, noderepr, children
                   NodeType(::Type{<:NamedTuple}) = InnerNode()
                   children(v::NamedTuple) = v
                   noderepr(v::NamedTuple) = isempty(v) ? "()" : "NamedTuple of"
                   nothing
               end
              )
end

macro hierarchical_pairvector()
    return esc(
               quote
                   import HierarchicalUtils: NodeType, InnerNode, noderepr, children
                   NodeType(::Type{<:HierarchicalUtils.PairVec}) = InnerNode()
                   children(v::HierarchicalUtils.PairVec) = v
                   noderepr(v::HierarchicalUtils.PairVec) = isempty(v) ? "Empty Vector" : "Vector of pairs of"
                   nothing
               end
              )
end

macro primitives()
    return esc(
               quote
                   import HierarchicalUtils: NodeType, LeafNode
                   NodeType(::Type{<:Number}) = LeafNode()
                   NodeType(::Type{<:AbstractString}) = LeafNode()
                   NodeType(::Type{<:AbstractChar}) = LeafNode()
                   NodeType(::Type{Symbol}) = LeafNode()
                   NodeType(::Type{Missing}) = LeafNode()
                   NodeType(::Type{Nothing}) = LeafNode()
                   nothing
               end
              )
end
