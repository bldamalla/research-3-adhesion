# type definition for Images and Ensembles

import Base: getindex, firstindex, lastindex, eltype
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
getindex(img::MaterialImage, u1::UnitRange{Int}, u2::UnitRange{Int}) = MaterialImage(img[u1,u2], img.discs)
function mean(img::MaterialImage)
  return mean(img.data)
end

Ensemble = Vector{MaterialImage}

function Ensemble(img::MaterialImage; N=300::Int)
  ret = Ensemble()
  szx, szy = size(img); padx, pady = floor.(size(img) ./ 8)
  for i in 1:N
    thx = rand(1:szx-padx); thy = rand(1:szy-pady)
    push!(ret, img[thx:thx+padx-1,thy:thy+pady-1])
  end
  return ret
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
