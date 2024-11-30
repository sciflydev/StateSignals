module Signals

export Signal, computed, effect, invalidate, pull!
export CONTEXT_SIGNALS
CONTEXT::Union{Function,Nothing} = nothing

mutable struct Signal{T}
    value::T
    valid::Bool
    action::Union{Function,Nothing}
    children::Set{Signal}
    effects::Set{Function}
end

CONTEXT_SIGNALS::Set{Signal} = Set{Signal}()

Signal(x::Number) = Signal(x, true, nothing, Set{Signal}(), Set{Function}())
# Signal(f,x) = Signal(x, true, f, Set{Signal}(), Set{Function}())

function Signal(f::Function)
    Signal(f(), true, f, Set{Signal}(), Set{Function}())
end

# x() = s()
function computed(f::Function)
    global CONTEXT_SIGNALS
    CONTEXT_SIGNALS = Set{Signal}()
    s = Signal(f)
    for dependency in CONTEXT_SIGNALS
        push!(dependency.children, s)
    end
    CONTEXT_SIGNALS = Set{Signal}()
    s
end

function (s::Signal)()
    CONTEXT != nothing && push!(s.effects, CONTEXT)
    push!(CONTEXT_SIGNALS, s)
    s.valid && return s.value
    pull!(s)
end

function pull!(s::Signal)
    if !s.valid
        s.value = s.action()
        s.valid = true
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
