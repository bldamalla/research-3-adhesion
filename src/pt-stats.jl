# n-point statistics
include("./MaterialImage.jl")

import FFTW: plan_fft, fft, ifft

"""
Calculate one-pt statistic from Ensemble
"""
function one_pt_stat(ens::Vector{MaterialImage})
  return mean(mean(ens))
end

"""
Plan fft routine based on ensemble data
"""
function plan_fft(ens::Vector{MaterialImage})
  gen = rand(length(ens[1].data))
  return plan_fft(gen)
end

"""
Perform fft on ensemble
"""
function fft(ens::Vector{MaterialImage})
  plan = plan_fft(ens)
  return hcat([plan * vec(i.data) for i in ens]...)
  end
end

"""
Get the two-pt statistics on Ensemble data
"""
function two_pt_stat(ens::Vector{MaterialImage})
  ft_ens = fft(ens); cc = conj.(ft_ens)
  # convolution theorem produces asymmetric vector
  off_center = real(ifft(ft_ens .* cc, 1)) ./ size(ft_ens, 1)
  ret = similar(off_center)
  len = size(ret, 1)
  # assume odd length for return vector
  shift = div(len, 2)
  for i in 1:len
    for j in 1:size(ret, 2)
      ret[(shift+i) % len == 0 ? len : ((shift+i) % len),j] = off_center[i,j]
    end
  end
  return ret, mean(ret, dims=2)
end
