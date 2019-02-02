std:
	julia -p 2 --project=@. -L scripts/struct-mat.jl -i scripts/pt-stats.jl

clean:
	rm plots/one_pt/* plots/two_pts/* plots/PCA/* plots/R2/*
