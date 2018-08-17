# type definition for image histograms

import Base: length, eltype, similar
import Base: getindex, setindex!, firstindex, lastindex

struct ImageHist
  data::Array{Int, 1}
  s_idx::Int
  sz::Int

  ImageHist(data, s_idx, sz) = (sz != sum(data)) ? throw(ErrorException("sz should be the sum of elements in data")) : new(data, s_idx, sz) ;
end

ImageHist(data::Array{Int, 1}, s_idx::Int) = ImageHist(data, s_idx, sum(data))
ImageHist(data::Array{Int, 1}) = ImageHist(data, 1, sum(data))

length(hist::ImageHist) = length(hist.data)
eltype(::ImageHist) = Int
similar(hist::ImageHist) = ImageHist(similar(hist.data), hist.s_idx)

firstindex(hist::ImageHist) = hist.s_idx
lastindex(hist::ImageHist) = firstindex(hist)+length(hist.data)-1

getindex(hist::ImageHist, i::Int) = getindex(hist.data, i-firstindex(hist)+1)
getindex(hist::ImageHist, i::UnitRange{Int}) = ImageHist(getindex(hist.data, i.-firstindex(hist).+1), first(i))
setindex!(hist::ImageHist, v::Int, i::Int) = setindex!(hist.data, v, i)

function mean(hist::ImageHist)
  ret = 0
  for i in firstindex(hist) : lastindex(hist)
    @inbounds ret += hist[i] * (i-firstindex(hist)+1) / hist.sz
  end
  return ret
end
