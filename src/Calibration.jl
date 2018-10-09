# define calibration functions

"""
Definitions for circuit calibration
"""

# time dependent resistance (Resistance vs time)
function tdr_routine(data::DataFrame)
  # construction of R/hr calibration curve
  # determination of material degredation
  _data = dropmissing(data)
  model = lm(@formula(Resistance ~ Time + 1), _data)
  # write to summary text file ?
  print(model)
  return model
end

# fit IV curve (Ohm's empirical line) (Current vs Voltage)
function ohm_routine(data::DataFrame)
  # construction of 1/R calibration curve
  # determination of "ohmic" material character
  _data = dropmissing(data)
  model = lm(@formula(Current ~ Voltage + 1), _data)
  # write to summary text file ?
  print(model)
  return model
end

# fit IV curve (net average resistance) (Current vs Voltage)
function tmr_routine(data::DataFrame)
  # construct 1/R calibration curve for given intervals (circuit dependent)
  # determination of current distribution within the circuit
  _data = dropmissing(data)
  model = lm(@formula(Current ~ Voltage + 1), _data)
  # write summary to text file ?
  print(model)
  return model
end

# solve for the resistances using calibrated voltage from prev models
function solve_resistances(ratio::Vector{T}) where T <: AbstractFloat
  # define the coefficient matrix
  # none of the ratios should be 0
  coeff_matrix = [
  1 1 -1/ratio[1]
  1 -1/ratio[2] 1
  -1/ratio[3] 1 1
  ]
  # use backsolve? to solve for the reciprocal of the resistances
  recip = coeff_matrix \ zeros(T, 3)
  return 1 ./ recip
end
