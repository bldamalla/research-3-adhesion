# n-point statistics
include("./MaterialImage.jl")

using FFTW

function one_pt_stat(ens::Ensemble)
  return mean(mean(arr))
end

function plan_fft(ens::Ensemble)
  gen = rand(length(ens[1].data))
  return plan_fft(gen)
end

function fft(ens::Ensemble)
  holder = Vector{Vector{Complex}}
  plan = plan_fft(ens)
  for i in 1:length(ens)
    push!(holder, plan * ens[i].data)
  end
  return holder
end

function two_pt_stat(ens::Ensemble)
  mn = mean(fft(ens))
  return real(ifft(mn))
end
