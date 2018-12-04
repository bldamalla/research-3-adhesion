# type definition for Images and Ensembles

import Base: getindex, firstindex, lastindex, eltype, setindex!
import Base: push!, length
import Base: size

import Statistics: mean

struct MaterialImage
  data::Array{T, 2} where {T<:AbstractFloat}
  discs::Int

  MaterialImage(data, discs) = begin
    if discs < 2
      throw(ErrorException("there should be at least two discrete local states"))
    else
      return new(data, discs)
    end
  end
end

size(img::MaterialImage) = size(img.data)
length(img::MaterialImage) = length(img.data)
getindex(img::MaterialImage, i::Int) = getindex(img.data, i)
getindex(img::MaterialImage, u1::UnitRange{Int}, u2::UnitRange{Int}) = MaterialImage(img.data[u1,u2], img.discs)
setindex!(img::MaterialImage, v::T, i::Int) where T<:AbstractFloat = setindex!(img.data, v, i)
function mean(img::MaterialImage)
  return mean(img.data)
end

function pad!(img::MaterialImage)
end

function mask(img::MaterialImage)
  return img
end

function Ensemble(img::MaterialImage; N=300::Int, S=201)
  ret = Vector{MaterialImage}()
  szx, szy = size(img); padx, pady = (S, S)
  for i in 1:N
    thx = rand(1:szx-padx+1); thy = rand(1:szy-pady+1)
    push!(ret, img[thx:thx+padx-1,thy:thy+pady-1])
  end
  return ret
end

function mean(ens::Vector{MaterialImage})
  ret = MaterialImage(zeros(size(ens[1].data)), ens[1].discs)
  for i in 1:length(ens)
    for j in 1:length(ens[1].data)
      ret[j] += ens[i][j] / length(ens)
    end
  end
  return ret
end
