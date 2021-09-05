macro hierarchical_dict()
    return esc(
               quote
                   @nospecialize
                   import HierarchicalUtils: NodeType, InnerNode, nodeshow, children
                   NodeType(::Type{<:Dict}) = InnerNode()
                   children(d::Dict) = d
                   nodeshow(io::IO, d::Dict) = print(io, isempty(d) ? "Empty Dict" : "Dict of")
                   @specialize
                   nothing
               end
              )
end

macro hierarchical_vector()
    return esc(
               quote
                   @nospecialize
                   import HierarchicalUtils: NodeType, InnerNode, nodeshow, children
                   NodeType(::Type{<:Vector}) = InnerNode()
                   children(v::Vector) = v
                   nodeshow(io::IO, v::Vector) = print(io, isempty(v) ? "[]" : "Vector of")
                   @specialize
                   nothing
               end
              )
end

macro hierarchical_tuple()
    return esc(
               quote
                   @nospecialize
                   import HierarchicalUtils: NodeType, InnerNode, nodeshow, children
                   NodeType(::Type{<:Tuple}) = InnerNode()
                   children(v::Tuple) = v
                   nodeshow(io::IO, v::Tuple) = print(io, isempty(v) ? "()" : "Tuple of")
                   @specialize
                   nothing
               end
              )
end

macro hierarchical_namedtuple()
    return esc(
               quote
                   @nospecialize
                   import HierarchicalUtils: NodeType, InnerNode, nodeshow, children
                   NodeType(::Type{<:NamedTuple}) = InnerNode()
                   children(v::NamedTuple) = v
                   nodeshow(io::IO, v::NamedTuple) = print(io, isempty(v) ? "()" : "NamedTuple of")
                   @specialize
                   nothing
               end
              )
end

macro hierarchical_pairvector()
    return esc(
               quote
                   @nospecialize
                   import HierarchicalUtils: NodeType, InnerNode, nodeshow, children
                   NodeType(::Type{<:HierarchicalUtils.PairVec}) = InnerNode()
                   children(v::HierarchicalUtils.PairVec) = v
                   function nodeshow(io::IO, v::HierarchicalUtils.PairVec)
                       print(io, isempty(v) ? "Empty Vector" : "Vector of pairs of")
                   end
                   @specialize
                   nothing
               end
              )
end

macro primitives()
    return esc(
               quote
                   @nospecialize
                   import HierarchicalUtils: NodeType, LeafNode
                   NodeType(::Type{<:Number}) = LeafNode()
                   NodeType(::Type{<:AbstractString}) = LeafNode()
                   NodeType(::Type{<:AbstractChar}) = LeafNode()
                   NodeType(::Type{Symbol}) = LeafNode()
                   NodeType(::Type{Missing}) = LeafNode()
                   NodeType(::Type{Nothing}) = LeafNode()
                   @specialize
                   nothing
               end
              )
end
