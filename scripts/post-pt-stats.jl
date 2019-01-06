"""
Include this in interactive state after `pt-stats` has finished
"""

# rmprocs(2, 3)

s_vars = vec(sum(vars, dims=1))

CF = sortperm(s_vars)[1]

conf = ARR_MATRIX[:,CF]
gg = sortperm(conf)

evone_fin = evone[gg]
two_pt_ens_fin = two_pt_ens[gg]
two_pt_ave_fin = two_pt_ave[gg]

bar(evone_fin[[1,4,7,10]]); savefig("plots/one_pt/evone_1.png")
bar(evone_fin[[2,5,8,11]]); savefig("plots/one_pt/evone_2.png")
bar(evone_fin[[3,6,9,12]]); savefig("plots/one_pt/evone_3.png")

for i in 1:3
  tf1 = contour(-112:112, -112:112, reshape(two_pt_ave_fin[0*3+i], 225, 225))
  tf2 = contour(-112:112, -112:112, reshape(two_pt_ave_fin[1*3+i], 225, 225))
  tf3 = contour(-112:112, -112:112, reshape(two_pt_ave_fin[2*3+i], 225, 225))
  tf4 = contour(-112:112, -112:112, reshape(two_pt_ave_fin[3*3+i], 225, 225))
  plot(tf1, tf3, tf2, tf4)
  savefig("plots/two_pts/contour_$(i).png")
end

@nexprs 4 i -> begin
  cmpr_i = hcat(two_pt_ens_fin[(i-1)*3+1], two_pt_ens_fin[(i-1)*3+2], two_pt_ens_fin[(i-1)*3+3])
  mdl_i = fit(PCA, cmpr_i)
end

@nexprs 4 i -> begin
  val = transform(mdl_i, cmpr_i)
  if size(val, 1) == 1
    val = vcat(val, zeros(450)')
  end
  q = val[:,1:150]
  scatter(q[1,:], q[2,:])
  q = val[:,151:300]
  scatter!(q[1,:], q[2,:])
  q = val[:,301:450]
  scatter!(q[1,:], q[2,:])

  savefig("plots/PCA/scatter_$(i).png")
end

bar(vars[[1,4,7,10],CF]); savefig("plots/R2/fin_1.png")
bar(vars[[2,5,8,11],CF]); savefig("plots/R2/fin_2.png")
bar(vars[[3,6,9,12],CF]); savefig("plots/R2/fin_3.png")
