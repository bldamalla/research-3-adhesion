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

# calculate one-pt statistics
pt_stats = one_pt_stat.(struct_mat)

# calculate two-pt statistics
# stitch into a matrix (dims, size)
ppt_stats = hcat(two_pt_stat.(struct_mat)...)
