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
  # always assume that variance increases in one direction relative to a threshold
  curr_thresh = intervar(hist, thresh=thresh)

  # if variance is higher to the right
  if intervar(hist, thresh=thresh+1) > curr_thresh
    return 1

  # else if variance is higher to the left
  elseif intervar(hist, thresh=thresh-1) > curr_thresh
    return -1

  # else (variance is maxed at threshold) return still
  else
    return 0
  end
end

"""
Original Otsu's method implementation with breaking on max
"""
function otsu_thresh_break(hist::FrequencyWeights)
  curr_max = 0; thresh = 0
  # iterate over the whole length of the histogram
  for curr in 1:length(hist)
    t_curr = intervar(hist, thresh=curr)

    # if the calculated threshold is larger than current maximum
    # update threshold and current maximum
    if t_curr > curr_max
      thresh = curr
      curr_max = t_curr

    # assuming concavity around the threshold
    # break at maximum
    else
      break
    end
  end
  return thresh
end

"""
Implementation of Alsaeed (2016) algorithm for Otsu-Checkpoints
"""
function alsaeed_otsu(hist::FrequencyWeights)
  bins = vec(1:length(hist))

  # set the first thresholds
  curr = μ_T = Int(floor(StatsBase.mean(bins, hist)))
  μ_0 = Int(floor(StatsBase.mean(bins[1:μ_T], fweights(hist[1:μ_T]))))
  μ_1 = Int(floor(StatsBase.mean(bins[μ_T:end], fweights(hist[μ_T:end]))))

  # get the direction with respect to the global mean
  dir = var_dir(hist, thresh=μ_T)

  # set up initial reduced histogram
  if dir == 0
    return μ_T
  elseif dir < 0
    r_hist = fweights(hist[μ_0:μ_T])
  else
    rhist = fweights(hist[μ_T:μ_1])
  end
end
