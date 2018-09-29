# files for xrd analysis and plotting

function xrd_plot(data::DataFrame)
  # expect that the headers are "Angle" and "Intensity"
  plot(data[:Angle], data[:Intensity])
end

function xrd_plot!(data::DataFrame)
  plot!(data[:Angle], data[:Intensity])
end
