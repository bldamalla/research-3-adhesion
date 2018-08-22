# n-point statistics
include("./MaterialImage.jl")

function one_pt_stat(ens::Ensemble)
  return mean(mean(arr))
end
