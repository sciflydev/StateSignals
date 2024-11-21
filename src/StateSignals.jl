module StateSignals
include("Signals.jl")

using .Signals
export Signal, effect

"""
    hi = hello_world()
A simple function to return "Hello, World!"
"""
function hello_world()
    return "Hello, World!"
end

end
