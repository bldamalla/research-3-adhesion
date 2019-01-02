"""
This will be the main entry file for the calculation of point statistics

Depending on the use case, the calculation of StructureMatrix objects may be skipped by the file.
"""

# calculate the StructureMatrix objects
# comment out if it has already been calculated
include("struct-mat.jl")

# load the necessary packages
using Plots; gr()

# include point statistics calculation function definitions
include("../src/pt-stats.jl")

# collect all one point stats here
evone = Vector{Float64}()

# calculate the point statistics of the ensembles
@nexprs 3 i -> begin
  @nexprs 4 j -> begin
    one_pt_i_j = one_pt_stat(ens_i_j)
    two_pt_i_j, two_pt_i_j_ave = two_pt_stat(ens_i_j)
    push!(evone, one_pt_i_j)
  end
end

# compare the point statistics of the ensembles
one_pt = bar(evone)
savefig(one_pt, "./plots/evone.png")

@nexprs 3 i -> begin
  @nexprs 4 j -> begin
    tpt_i_j = contour(-112:112, -112:112, reshape(two_pt_i_j_ave, 225, 225))
    savefig(tpt_i_j, "./plots/two_pts/two_pt_$(i)_$(j).png")
  end
end

using MultivariateStats, LinearAlgebra

# create the PCA models
@nexprs 4 i -> begin
  cmpr_i = hcat(two_pt_1_i, two_pt_2_i, two_pt_3_i)
  mdl_i = fit(PCA, cmpr_i, maxoutdim=2)
end

# create the plots and identify the variances
@nexprs 4 i -> begin
  val = transform(mdl_i, cmpr_i)
  q = val[:,1:60]
  scatter(val[2,1:60], val[1,1:60])
  eval(Meta.parse("R2_$(i)_1 = $(tr(q' * q))"))
  q = val[:,61:120]
  scatter!(val[2,61:120], val[1,61:120])
  eval(Meta.parse("R2_$(i)_2 = $(tr(q' * q))"))
  q = val[:,121:180]
  scatter!(val[2,121:180], val[1,121:180])
  eval(Meta.parse("R2_$(i)_3 = $(tr(q' * q))"))

  savefig("plots/PCA/mdl_$(i).png")
end

@nexprs 4 j -> begin
  @nexprs 3 i -> begin
    println("R2_$(j)_$(i) = ", R2_j_i)
  end
  println()
end
