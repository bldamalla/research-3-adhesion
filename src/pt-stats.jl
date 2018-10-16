# n-point statistics
include("./MaterialImage.jl")

using FFTW

"""
Calculate one-pt statistic from Ensemble
"""
function one_pt_stat(ens::Ensemble)
  return mean(mean(arr))
end

"""
Plan fft routine based on ensemble data
"""
function plan_fft(ens::Ensemble)
  gen = rand(length(ens[1].data))
  return plan_fft(gen)
end

"""
Perform fft on ensemble
"""
function fft(ens::Ensemble)
  holder = Vector{Vector{Complex}}
  plan = plan_fft(ens)
  for i in 1:length(ens)
    push!(holder, plan * ens[i].data)
  end
  return holder
end

"""
Get the two-pt statistics on Ensemble data
"""
function two_pt_stat(ens::Ensemble)
  mn = mean(fft(ens))
  return real(ifft(mn))
end
