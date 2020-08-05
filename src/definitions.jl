macro hierarchical_dict()
    return esc(
               quote
                   import HierarchicalUtils: NodeType, InnerNode, noderepr, children
                   NodeType(::Type{<:Dict}) = InnerNode()
                   children(d::Dict) = (; (Symbol(k) => v for (k, v) in d)...)
                   noderepr(d::Dict) = isempty(d) ? "Empty Dict" : "Dict of"
                   return
               end
              )
end

macro hierarchical_vector()
    return esc(
               quote
                   import HierarchicalUtils: NodeType, InnerNode, noderepr, children
                   NodeType(::Type{<:Vector}) = InnerNode()
                   children(v::Vector) = tuple(v...)
                   noderepr(v::Vector) = isempty(v) ? "Empty Vector" : "Vector of"
                   return
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
                   return
               end
              )
end
