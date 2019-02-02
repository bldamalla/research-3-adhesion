# files for xrd analysis and plotting

using PlotlyJS, ORCA
using DataFrames

# this should be able to plot the necessary peaks given in the specially created dataframe
function plt(df::DataFrame)
  # plot the intensity vs 2θ for S1
  # plot the intensity vs 2θ for S2
  # plot the intensity vs 2θ for S3
end

d_space(angle::T, λ::T=154e-13) where T <: AbstractFloat = λ / (2 * sin(angle/2 * π / 180))
two_θ(space::T, λ::T=154e-13) where T <: AbstractFloat = 2 * asin(λ / space) * 180 / π
