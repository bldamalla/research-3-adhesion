# type definition for Images and Ensembles

import Base: getindex, firstindex, lastindex, eltype
import Base: push!, length
import Base: size

import Statistics: mean

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

function MaterialImage(data::Array{T, 2}, discs::Int) where {T<:AbstractFloat}
  return MaterialImage(vec(data), size(data), discs)
end
size(img::MaterialImage) = img.dims
eltype(img::MaterialImage) = Dict{Symbol, Union{Int, NTuple{2, Int}}}(:dims=>size(img), :discs=>img.discs)
getindex(img::MaterialImage, i::Int) = getindex(img.data, i)
function mean(img::MaterialImage)
  return mean(img.data)
end

Ensemble = Vector{MaterialImage}

function eltype(ens::Ensemble)
  if length(ens) < 1 throw(ErrorException("ensemble is empty")) end
  return eltype(ens[1])
end
function mean(ens::Ensemble)
  length(ens) == 0 && throw(ErrorException("ensemble has no elements"))
  sm = zeros(length(ens[1].data))
  for i in 1:length(ens)
    for j in 1:length(ens[1].data)
      @inbounds sm[j] += ens[i][j] / length(ens)
    end
  end
  return MaterialImage(sm, ens[1].dims, ens[1].discs)
end
