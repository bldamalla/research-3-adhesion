# type definition for image histograms

import Base: length, eltype, similar
import Base: getindex, setindex!, firstindex, lastindex

mutable struct ImageHist
  data::Array{Int, 1}
  s_idx::Int
  sz::Int

  ImageHist(data, s_idx, sz) = (sz != sum(data)) ? error("sz must hold the sum of elements of passed data array") : new(data, s_idx, sz) ;
end

ImageHist(data::Array{Int, 1}, s_idx::Int) = ImageHist(data, s_idx, sum(data))
ImageHist(data::Array{Int, 1}) = ImageHist(data, 1, sum(data))

length(hist::ImageHist) = hist.sz
eltype(::ImageHist) = Int
similar(hist::ImageHist) = ImageHist(similar(hist.data), hist.s_idx)

getindex(hist::ImageHist, i::Int) = getindex(hist.data, i)
setindex!(hist::ImageHist, v::Int, i::Int) = setindex!(hist.data, v, i)

firstindex(hist::ImageHist) = 1
lastindex(hist::ImageHist) = length(hist)
