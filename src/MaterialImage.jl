# type definition for Images and Ensembles

struct MaterialImage
  data::Vector{T} where {T<:AbstractFloat}
  dims::NTuple{2, Int}
  discs::Int

  MaterialImage(data, dims, discs) = begin
    if prod(dims) != length(data)
      throw(DimensionMismatch("data cannot be converted to dimension dims"))
    elseif discs < 2
      throw(ErrorException("there should be at least two discrete local states"))
    else
      return new(data, dims, discs)
    end
  end
end

struct Ensemble
  data::Dict{Int, MaterialImage}
  sz::Int
end

function MaterialImage(data::Array{T, 2}, discs::Int) where {T<:AbstractFloat}
  return MaterialImage(vec(data), size(data), discs)
end

function Ensemble()
  return Ensemble(Dict{Int, MaterialImage}, 0)
end
