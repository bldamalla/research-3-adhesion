# get the dataframes and plot the values to manually get the peaks
using DataFrames, CSV

include("../src/xrd.jl")

pk_df = CSV.read("../data/test/XRD/set1/peaks.csv")
