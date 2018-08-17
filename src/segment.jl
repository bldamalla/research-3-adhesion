include("./ImageHist.jl")

"""
Get the interclass variance of two groups split at a threshold
"""
function intervar(hist::ImageHist; thresh::Int)
  ω_0 = hist[1:thresh].sz / hist.sz
  μ_T = mean(hist) / hist.sz
  μ_0 = mean(hist[1:thresh]) / hist.sz
  μ_1 = (μ_T - ω_0*μ_0) / (1-ω_0)

  return (ω_0 * (1-ω_0)) * ((μ_0 - μ_1)^2)
end

"""
Get the direction of greater variance given an image histogram and a test threshold
"""
function var_dir(hist::ImageHist; thresh::Int)
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
function otsu_thresh_break(hist::ImageHist)
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
function alsaeed_otsu(hist::ImageHist)
  # get the necessary histogram means
  μ_T = Int(floor(mean(hist)))
  μ_0 = Int(floor(mean(hist[1:μ_T])))
  μ_1 = Int(floor(mean(hist[μ_T:end])))

  # determine the direction wrt global mean of greater variance
  dir = var_dir(hist, thresh=μ_T)

  # define local histogram reduction function
  function alsaeed_recursive(r_hist::ImageHist)
    # define special pointers
    l = firstindex(r_hist)
    r = lastindex(r_hist)
    md = (l+r) >> 1

    # define other "quartiles"
    qt1 = (l+md) >> 1
    qt3 = (md+r) >> 1

    # define recursion cases

    # if variance direction from median is to the right
    r_dir = var_dir(hist, thresh=md)
    if r_dir > 0
      # test direction from third quartile
      r_dir = var_dir(hist, thresh=qt3)
      if r_dir > 0
        return alsaeed_recursive(r_hist[qt3:r])
      elseif r_dir < 0
        return alsaeed_recursive(r_hist[md:qt3])
      else
        return qt3
      end
    elseif r_dir < 0
      # test direction from first quartile
      r_dir = var_dir(hist, thresh=qt1)
      if r_dir > 0
        return alsaeed_recursive(r_hist[qt1:md])
      elseif r_dir < 0
        return alsaeed_recursive(r_hist[l:qt1])
      else
        return qt1
      end
    else
      return md
    end
  end

  # determine histogram to apply recusrive function to
  if dir > 0
    # apply recursive function from global to positive mean
    return alsaeed_recursive(hist[μ_T:μ_1])
  elseif dir < 0
    # apply recursive function from negative mean to global mean
    return alsaeed_recursive(hist[μ_0:μ_T])
  else
    return μ_T
  end
end
