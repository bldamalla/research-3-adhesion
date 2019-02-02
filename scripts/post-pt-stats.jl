"""
Include this in interactive state after `pt-stats` has finished
"""

rmprocs(2, 3)

s_vars = vec(sum(vars, dims=1))

CF = sortperm(s_vars)[2]

conf = ARR_MATRIX[:,CF]
gg = sortperm(conf)

println("Preferred orientation: $CF")

evone_fin = evone[gg]
two_pt_ens_fin = two_pt_ens[gg]
two_pt_ave_fin = two_pt_ave[gg]

bar(evone_fin[[1,4,7,10]]); savefig("plots/one_pt/evone_1.png")
bar(evone_fin[[2,5,8,11]]); savefig("plots/one_pt/evone_2.png")
bar(evone_fin[[3,6,9,12]]); savefig("plots/one_pt/evone_3.png")

for i in 1:3
  tf1 = contour(-220:220, -220:220, reshape(two_pt_ave_fin[0*3+i], 441, 441))
  tf2 = contour(-220:220, -220:220, reshape(two_pt_ave_fin[1*3+i], 441, 441))
  tf3 = contour(-220:220, -220:220, reshape(two_pt_ave_fin[2*3+i], 441, 441))
  tf4 = contour(-220:220, -220:220, reshape(two_pt_ave_fin[3*3+i], 441, 441))
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
    val = vcat(val, zeros(3*ens)')
  end
  for j in 1:outdim(mdl_i)-1 for k in j+1:outdim(mdl_i)
  q = val[:,1:ens]
  scatter(q[j,:], q[k,:])
  q = val[:,ens+1:2*ens]
  scatter!(q[j,:], q[k,:])
  q = val[:,2*ens+1:3*ens]
  scatter!(q[j,:], q[k,:])
  
  savefig("plots/PCA/scatter_$(i)_$(j)_$(k).png")
  end end
end

bar(vars[[1,4,7,10],CF]); savefig("plots/R2/fin_1.png")
bar(vars[[2,5,8,11],CF]); savefig("plots/R2/fin_2.png")
bar(vars[[3,6,9,12],CF]); savefig("plots/R2/fin_3.png")
