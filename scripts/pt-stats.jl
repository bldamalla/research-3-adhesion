"""
This will be the main entry file for the calculation of point statistics

Depending on the use case, the calculation of StructureMatrix objects may be skipped by the file.
"""

"""
BEGIN THE ROUTINE HERE
"""

using Distributed

# ensemble configuration index

tk = @distributed for f in 1:64
  # compute only the variances caused by changing the different
  # configurations in two pt stats
  conf = ARR_MATRIX[:,f]
  gg = sortperm(conf)

  two_pt_arg = two_pt_ens[gg]
  println("Initialized: ens config $(f)")

  @nexprs 4 i -> begin
    cmpr_i = hcat(two_pt_arg[(i-1)*3+1], two_pt_arg[(i-1)*3+2], two_pt_arg[(i-1)*3+3])
    mdl_i = fit(PCA, cmpr_i)
  end

  println("Calculated: PCA config $(f)")

  @nexprs 4 i -> begin
    val = transform(mdl_i, cmpr_i)
    if size(val, 1) == 1
      val = vcat(val, zeros(3*ens)')
    end
    q = val[:,1:ens]
    vars[(i-1)*3+1, f] = tr(q'q)
    q = val[:,ens+1:2*ens]
    vars[(i-1)*3+2, f] = tr(q'q)
    q = val[:,2*ens+1:3*ens]
    vars[(i-1)*3+3, f] = tr(q'q)
  end

  println("Calculated: variances config $(f)")

end
