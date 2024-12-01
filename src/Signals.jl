module Signals

export Signal, @signal, computed, effect, invalidate, pull!
export COMPUTED_DEPS
CONTEXT::Union{Function,Nothing} = nothing

mutable struct Signal{T}
    value::T
    id::Union{Symbol, Nothing}
    valid::Bool
    action::Union{Function,Nothing}
    children::Set{Signal}
    effects::Set{Function}
end

COMPUTED_DEPS::Set{Signal} = Set{Signal}()

Signal(x) = Signal(x, nothing, true, nothing, Set{Signal}(), Set{Function}())
Signal(x, id::Union{Symbol,Nothing}) = Signal(x, id, true, nothing, Set{Signal}(), Set{Function}())
Signal(f::Function, id::Union{Symbol,Nothing}=nothing) = Signal(f(), id, true, f, Set{Signal}(), Set{Function}())

function Signal(f::Function)
    Signal(f(), true, f, Set{Signal}(), Set{Function}())
end

"""
    @signal var = value

Macro that creates a signal and set its id to the variable name.
Example: @signal x = 2 expands to x = Signal(2, :x)
"""
macro signal(expr)
    if expr.head != :(=)
        error("@signal macro expects an assignment expression, e.g., @signal x = 2")
    end

    var = expr.args[1]
    val = expr.args[2]
    return :($(esc(var)) = Signal($(esc(val)), $(QuoteNode(var))))
end

export @signal
# x() = s()
function computed(f::Function, id::Union{Symbol,Nothing}=nothing)
    global COMPUTED_DEPS
    COMPUTED_DEPS = Set{Signal}()
    s = Signal(f, id)
    for dependency in COMPUTED_DEPS
        push!(dependency.children, s)
    end
    COMPUTED_DEPS = Set{Signal}()
    s
end

function (s::Signal)()
    CONTEXT != nothing && push!(s.effects, CONTEXT)
    push!(COMPUTED_DEPS, s)
    s.valid && return s.value
    pull!(s)
end

function pull!(s::Signal)
    if !s.valid
        s.value = s.action()
        s.valid = true
        for fn in s.effects
            fn()
        end
    end
    s.value
end

function (s::Signal)(value)
    s.action != nothing && error("Can't modify state of computed signal.")
    invalidate(s)
    s.value = value
    s.valid = true
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

function invalidate(s::Signal)
    s.valid = false
    for c in s.children
        invalidate(c)
    end
end

end
