"""
This will be the main entry file for the calculation of the StructureMatrix objects.
"""

using Pkg
Pkg.activate(".")

using Images, SharedArrays

include("../src/MaterialImage.jl")

# extension generation function
covv(a::Int) = (a >= 10) ? "0$(a)" : "00$(a)"

"""
  Use the following images

  S1:
  1 - 36
  2 - 27
  3 - 3
  4 - 36

  S2:
  1 - 30
  2 - 38
  3 - 37
  4 - 19

  S3:
  1 - 8
  2 - 17
  3 - 38
  4 - 12
"""
images = [
  (1, 1, 36),
  (1, 2, 27),
  (1, 3, 3),
  (1, 4, 36),
  (2, 1, 30),
  (2, 2, 38),
  (2, 3, 37),
  (2, 4, 19),
  (3, 1, 8),
  (3, 2, 17),
  (3, 3, 38),
  (3, 4, 3)
]

function segment!(img::Array{T, 2}) where T <: AbstractFloat
  q = yen_threshold(img)
  x, y = size(img)
  for i in 1:x
    for j in 1:y
      @inbounds img[i,j] = ceil(q - img[i,j])
    end
  end
end

function parse_load(arg::NTuple{3, Int})
  i, j, k = arg

  img = float.(Images.Gray.(Images.load("./data/actual/HPO/s$(i)/$(j)/IMG00$(covv(k)).JPG")))

  segment!(img)

  return Ensemble(MaterialImage(img, 2); N=150, S=225)
end

ENSEMBLES = map(parse_load, images)

"""
  Configuration of corners

  1:
  | 1 | 3 |
  ---------
  | 2 | 4 |

  2:
  | 2 | 4 |
  ---------
  | 1 | 3 |

  3:
  | 4 | 2 |
  ---------
  | 3 | 1 |

  4:
  | 3 | 1 |
  ---------
  | 4 | 2 |
"""
cf = [[1, 2, 3, 4],
  [2, 1, 4, 3],
  [4, 3, 2, 1],
  [3, 4, 1, 2]]

ARR_MATRIX = hcat([vcat(cf[i], cf[j], cf[k]) for i in 1:4 for j in 1:4 for k in 1:4]...)

"""
ACCESSORIES FROM pt-stats.jl
"""

# load the necessary packages
using Plots; gr()
using Base.Cartesian

using MultivariateStats, LinearAlgebra
# include point statistics calculation function definitions
include("../src/pt-stats.jl")

vars = SharedArray{Float64}(12, 64)

evone = zeros(12)
two_pt_ens = Vector{Array{Float64, 2}}()
two_pt_ave = Vector{Vector{Float64}}()

# populate the shared arrays
for i in 1:12
  evone[i] = one_pt_stat(ENSEMBLES[i])
  ens, ave = two_pt_stat(ENSEMBLES[i])
  push!(two_pt_ens, ens)
  push!(two_pt_ave, vec(ave))
end
