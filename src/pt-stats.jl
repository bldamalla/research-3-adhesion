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
  holder = Vector{Vector{Complex{Float64}}}()
  plan = plan_fft(ens)
  for i in 1:length(ens)
    push!(holder, plan * vec(ens[i].data))
  end
  return mean(holder)
end

"""
Get the two-pt statistics on Ensemble data
"""
function two_pt_stat(ens::Vector{MaterialImage})
  ft_ens = fft(ens); cc = conj(ft_ens)
  # convolution theorem produces asymmetric vector
  off_center = real(ifft(ft_ens .* cc)) ./ length(ens[1].data)
  ret = similar(off_center)
  # assume odd length for return vector
  shift = div(length(ret), 2)
  for i in 1:length(ret)
    ret[(shift+i) % length(ret) == 0 ? length(ret) : ((shift+i) % length(ret))] = off_center[i]
  end
  return ret
end
