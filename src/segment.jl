using StatsBase

"""
Get the interclass variance of two groups split at a threshold
"""
function intervar(hist::FrequencyWeights; thresh::Int)
  ω_0 = fweights(hist[1:thresh]).sum / hist.sum
  μ_T = StatsBase.mean(vec(1:length(hist)), hist) / hist.sum
  μ_0 = StatsBase.mean(vec(1:thresh), fweights(hist[1:thresh])) / hist.sum
  μ_1 = (μ_T - ω_0*μ_0) / (1-ω_0)

  return (ω_0 * (1-ω_0)) * ((μ_0 - μ_1)^2)
end

"""
Get the direction of greater variance given an image histogram and a test threshold
"""
function var_dir(hist::FrequencyWeights; thresh::Int)
  curr_thresh = intervar(hist, thresh=thresh)
  if intervar(hist, thresh=thresh+1) > curr_thresh
    return 1
  elseif intervar(hist, thresh=thresh-1) > curr_thresh
    return -1
  else
    return 0
  end
end
