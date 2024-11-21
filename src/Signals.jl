module Signals

export Signal, effect
CONTEXT::Union{Function,Nothing} = nothing
mutable struct Signal{T}
    value::T
    # children::Vector{Signal}
    effects::Set{Function}
end

Signal(x) = Signal(x, Set{Function}())

function (s::Signal)()
    CONTEXT != nothing && push!(s.effects, CONTEXT)
    s.value
end

function (s::Signal)(value)
    s.value = value
    for fn in s.effects
        fn()
    end
    value
end

function effect(fn::Function)
    global CONTEXT
    CONTEXT = fn
    fn()
    CONTEXT = nothing
end

end
