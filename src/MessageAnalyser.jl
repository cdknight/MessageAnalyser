CONFIG_LOCATION = joinpath(pwd(), "config.json")

function julia_main()::Cint
  include("gui.jl")
  wait(Condition())

  return 0
end

julia_main()
