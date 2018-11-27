"""
This will be the main entry file for the calculation of the StructureMatrix objects.
"""

# load the needed packages
using Images

# include all material structure definition and functions
include("../src/segment.jl")

# generate initial model image matrix
imgs = [string("../data/test/microscope/s1/topleft/", i < 10 ? "0" : "", i, ".JPG") for i in 0:11]

# generate MaterialImage objects
imgs = load.(imgs)
mat_imgs = [float.(Gray.(imgs[i])) for i in 1:12]
mat_imgs = MaterialImage.(mat_imgs, 2)

# generate StructureMatrix
struct_mat = StructureMatrix(reshape(mat_imgs, 3, :))
