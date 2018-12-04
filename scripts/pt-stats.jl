"""
This will be the main entry file for the calculation of point statistics

Depending on the use case, the calculation of StructureMatrix objects may be skipped by the file.
"""

# calculate the StructureMatrix objects
# comment out if it has already been calculated
# include("struct-mat.jl")

# load the necessary packages
# using Plots; gr()

# include point statistics calculation function definitions
include("../src/pt-stats.jl")

# calculate one-pt statistics
@nexprs 3 i -> mat_one_pt_i = one_pt_stat.(mat_imgs_ens_i)

# calculate two-pt statistics
@nexprs 3 i -> mat_two_pt_i = two_pt_stat.(mat_imgs_ens_i)

# stitch two point statistics together
@nexprs 3 i -> struct_mat_i = reshape([hcat(mat_two_pt_i[:,j,k]...) for j in 1:2 for k in 1:2], 2, 2)

# using MultivariateStats

@nexprs 4 i -> mdl_i = fit(PCA, hcat(struct_mat_1[i], struct_mat_2[i], struct_mat_3[i]))

function plot_save(a::Vector{T}, b::Vector{T}, c::Vector{T}, i::Int) where T <: AbstractFloat
  ll = (length(a) == length(b) == length(c)) ? length(a) : error("Vectors should be of the same length")
  scatter(a, zeros(ll)); scatter!(b, ones(ll)); scatter!(c, ones(ll).*2)
  savefig("sv$(i).png")
end

@nexprs 4 i -> plot_save(vec(transform(mdl_i, struct_mat_1[i])), vec(transform(mdl_i, struct_mat_2[i])), vec(transform(mdl_i, struct_mat_3[i])), i)
