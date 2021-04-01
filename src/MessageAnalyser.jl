module MessageAnalyser

CONFIG_LOCATION = joinpath(pwd(), "config.json")
function julia_main()::Cint
  include("gui.jl")
  wait(Condition())

  return 0
end

if abspath(PROGRAM_FILE) == @__FILE__
  julia_main()
end

end
