macro hierarchical_dict()
    return esc(
               quote
                   import HierarchicalUtils: NodeType, InnerNode, noderepr, children
                   NodeType(::Type{<:Dict}) = InnerNode()
                   children(t::Dict) = (; (Symbol(k) => v for (k, v) in t)...)
                   noderepr(::Dict) = "Dict of"
                   Base.show(io::IO, ::MIME"text/plain", t::Dict) = printtree(io, t; trunc=2)
                   return
               end
              )
end

macro hierarchical_vector()
    return esc(
               quote
                   import HierarchicalUtils: NodeType, InnerNode, noderepr, children
                   NodeType(::Type{<:Vector}) = InnerNode()
                   children(t::Vector) = tuple(t...)
                   noderepr(::Vector) = "Vector of"
                   Base.show(io::IO, ::MIME"text/plain", t::Vector) = printtree(io, t; trunc=2)
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
                   NodeType(::Type{<:Symbol}) = LeafNode()
                   NodeType(::Type{<:AbstractChar}) = LeafNode()
                   return
               end
              )
end
