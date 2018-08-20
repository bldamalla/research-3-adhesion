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
function mean(img::MaterialImage)
  return mean(img.data)
end

struct Ensemble <: AbstractArray{MaterialImage, 1}
  data::Dict{Int, MaterialImage}
end

firstindex(::Ensemble) = 1
length(ens::Ensemble) = length(ens.data)
lastindex(ens::Ensemble) = length(ens)
getindex(ens::Ensemble, i::Int) = get(ens.data, i, throw(KeyError(i)))
function eltype(ens::Ensemble)
  length(ens) < 1 || throw(ErrorException("cannot get element type of empty Ensemble"))
  return Dict{Symbol, Union{Int, NTuple{2, Int}}}(:dims=>size(ens[1]), :discs=>ens[1].discs)
end
function push!(ens::Ensemble, v::MaterialImage)
  sz = length(ens) + 1
  if sz != 1
    eltype(ens) != eltype(v) && throw(ErrorException("image must have the same dims and discs"))
  end
  push!(ens.data, sz=>v)
end
function mean(ens::Ensemble)
  length(ens) == 0 || throw(ErrorException("ensemble has no elements"))
  sm = zeros(ens[1].data)
  for i in 1:length(ens)
    for j in 1:length(ens[1].data)
      @inbounds sm[j] += ens[i][j] / length(ens)
    end
  end
  return MaterialImage(sm, ens[1].dims, ens[1].discs)
end
