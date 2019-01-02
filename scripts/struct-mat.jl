"""
This will be the main entry file for the calculation of the StructureMatrix objects.
"""

# load the needed packages
using Images

using Base.Cartesian

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
  (3, 4, 12)
]

val = nothing

function parse_load(arg::NTuple{3,Int})
  i, j, k = arg
  global val

  vnm = "s_$(i)_$(j)"

  val = float.(Images.Gray.(Images.load("../../c++/research/data/actual/HPO/s$(i)/$(j)/IMG00$(covv(k)).JPG")))

  eval(Meta.parse("$(vnm) = val"))
end

for img in images
  parse_load(img)
end

q = 0;

@nexprs 3 i -> begin
  @nexprs 4 j -> begin
    q = otsu_threshold(s_i_j)
    img_i_j = MaterialImage(ceil.(q .- s_i_j), 2)
    ens_i_j = Ensemble(img_i_j, N=60, S=225)
  end
end
