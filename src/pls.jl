# Partial Least Squares Analysis

#### PLS Type

struct PLS{T<:AbstractFloat}
  p::Int                    # number of feature variables
  B::Matrix{T}              # regression coefficients
  b::Union{T, Vector{T}}    # error terms
  vars::NTuple{2, T}        # variances captured for (X, Y) variables
  vtot::NTuple{2, T}        # total variance of (X, Y) variables
  pcs::Int                  # number of "latent vectors" used for projection
end

## constructor

function PLS(p::Int, B::Matrix{T}, b::Union{T, Vector{T}},
            vars::NTuple{2, T}, vtot::NTuple{2, T},
            pcs::Int) where T <: AbstractFloat
  varX, varY = vars; vtotX, vtotY = vtot
  p == size(B, 1) == length(b) || throw(ArgumentError("Regression coefficient matrix, intercept vector, and num"))
  (varX <= vtotX) & (varY <= vtotY) || throw(ArgumentError("Variance captured by latent vectors should not exceed original variance"))
  pcs < p || throw(ArgumentError("Number of latent vectors should be less than the number of feature variables"))
  PLS(p, B, b, vars, vtot, pcs)
end

## properties

indim(M::PLS) = M.p
outdim(M::PLS) = M.pcs

coeffs(M::PLS) = M.B
intercepts(M::PLS) = M.b

vars(M::PLS) = M.vars
vars(M::PLS, d::Int) = M.vars[d]
vtot(M::PLS) = M.vtot
vtot(M::PLS, d::Int) = M.vtot[d]

r2_X(M::PLS) = vars(M, 1) / vtot(M, 1)
r2_Y(M::PLS) = vars(M, 2) / vtot(M, 2)

## interface functions

function fit(::Type{PLS}, X::Matrix{F}, Y::VecOrMat{F};
             maxpcs=size(X, 2)::Int) where F <: AbstractFloat
  # set the needed matrices and vectors to nothing
  # set the limits for the number of latent vectors
  N, p = size(X); m = size(Y, 2)
  matY = isa(Y, Matrix)
  R = T = P = Q = U = V = nothing
  lim_ = matY ? lim : 1
  # start implementation of SIMPLS
  meanY = matY ? vec(mean(Y, dims=1)) : mean(Y)
  X_0 = centralize(X, mean(X, dims=1)); vtotX = tr(X_0'X_0)/(N-1)
  Y_0 = centralize(Y, meanY); vtotY = tr(Y_0'Y_0)/(N-1)
  S = X'*Y_0
  for i in 1:maxpcs
    q = matY ? svd(S'S).Vt[1,:] : S'S
    r = S*q
    t = X*r
    t .-= mean(t); normT = norm(t)
    t /= normT; r /= normT
    p = X'*t
    q = Y_0'*t
    u = Y_0*q
    v = p
    if i > 1
      v = v - V*(V'p)
      u = u - T*(T'u)
    end
    v /= norm(v)
    S = S - v*(v'S)
    if i == 1
      R = r; T = t; P = p; Q = q; U = u; V = v
    else
      R = hcat(R, r); T = hcat(T, t); P = hcat(P, p)
      Q = hcat(Q, q); U = hcat(U, u); V = hcat(V, v)
    end
  end

  # compute the necessary model descriptors
  B = R*Q'
  varX = tr(P'P) / (N-1)
  varY = tr(Q'Q) / (N-1)
  # create the PLS object
  return PLS(N, B, meanY, varX, varY, vtotX, vtotY, lim_)
end

predict(M::PLS, X_t::Matrix{T}) where T <: AbstractFloat = X_t * M.B .+ M.b'
