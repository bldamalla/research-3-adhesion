"""
This will be the main entry file for the calculation of the StructureMatrix objects.
"""

# load the needed packages
using Images

using Base.Cartesian

# include all material structure definition and functions
include("../src/segment.jl")

# extension generation function
covv(a::Int) = (a >= 100) ? "$(a)" : ((a >= 10) ? "0$(a)" : "00$(a)")

# generate string placeholder matrices for the images
@nexprs 3 i -> imgs_i = [string("./data/actual/HPO/s$(i)/$(j)/IMG00$(covv(a)).JPG") for j in 1:4 for a in 1:30]

@nexprs 3 i -> imgs_i = reshape(imgs_i, 30, 2, 2)

# split into multiple tasks
# objects in the first dimension can be treated as homogeneous
@nexprs 3 i -> imgs_i = load.(imgs_i)
@nexprs 3 i -> mat_imgs_i = reshape([float.(Gray.(imgs_i[j])) for j in 1:120], 30, 2, 2)
@nexprs 3 i -> mat_imgs_i = MaterialImage.(mat_imgs_i, 2)

# generate structure matrices from collections of material images
@nexprs 3 i -> mat_imgs_ens_i = Ensemble.(mat_imgs_i, N=100, S=150)
