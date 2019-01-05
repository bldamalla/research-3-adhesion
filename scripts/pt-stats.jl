"""
This will be the main entry file for the calculation of point statistics

Depending on the use case, the calculation of StructureMatrix objects may be skipped by the file.
"""

"""
BEGIN THE ROUTINE HERE
"""

using Distributed

# ensemble configuration index

tk = @distributed for f in 1:64 ### START OF MAIN FOR LOOP

  conf = ARR_MATRIX[:,f]
  gg = sortperm(conf)

  for i in 1:length(gg)
    eval(Meta.parse("ens_$((i-1)%3+1)_$(conf[gg[i]]) = ENSEMBLES[$(gg[i])]"))
  end

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
  savefig(one_pt, "./plots/one_pt/evone_$(f).png")

  @nexprs 3 i -> begin
    @nexprs 4 j -> begin
      tpt_i_j = contour(-112:112, -112:112, reshape(two_pt_i_j_ave, 225, 225))
      savefig(tpt_i_j, "./plots/two_pts/two_pt_$(i)_$(j)_$(f).png")
    end
  end

  # create the PCA models
  @nexprs 4 i -> begin
    cmpr_i = hcat(two_pt_1_i, two_pt_2_i, two_pt_3_i)
    mdl_i = fit(PCA, cmpr_i, maxoutdim=2)
  end

# create the plots and identify the variances
  @nexprs 4 i -> begin
    val = transform(mdl_i, cmpr_i)
    if size(val, 1) == 1
      val = vcat(val, zeros(180)')
    end
    q = val[:,1:60]
    scatter(val[2,1:60], val[1,1:60])
    vars[(i-1)*3+1, f] = tr(q'q)
    q = val[:,61:120]
    scatter!(val[2,61:120], val[1,61:120])
    vars[(i-1)*3+1, f] = tr(q'q)
    q = val[:,121:180]
    scatter!(val[2,121:180], val[1,121:180])
    vars[(i-1)*3+1, f] = tr(q'q)

    savefig("plots/PCA/mdl_$(f)_$(i).png")
  end

end ### END MAIN PLOT LOOP

while !(istaskdone(tk))
  nothing
end

vars = reshape(vars, :, 64)

for i in 1:64
  bar(vars[:,i])
  savefig("plots/R2/$(i).png")
end

println("Least variance is found at config: ", sortperm(vec(sum(vars, dims=1)))[1])
