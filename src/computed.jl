# Dependencies are assumed to be already imported from Signals.jl

mutable struct SignalTracker
    tracking::Bool
    accessed_signals::Set{Signal}
end

const SIGNAL_TRACKER = SignalTracker(false, Set{Signal}())

# Override both getindex and function call
function Base.getindex(s::Signal)
    if SIGNAL_TRACKER.tracking
        push!(SIGNAL_TRACKER.accessed_signals, s)
    end
    Signals.value(s)
end

function (s::Signal)()
    if SIGNAL_TRACKER.tracking
        push!(SIGNAL_TRACKER.accessed_signals, s)
    end
    Signals.pull!(s)
end

"""
    computed(f::Function; strict_push=false)

Creates a computed signal that automatically tracks its dependencies.
The computation function `f` will be re-run whenever any accessed signals change.
"""
function computed(f::Function; strict_push=false)
    # Reset the tracker
    SIGNAL_TRACKER.accessed_signals = Set{Signal}()
    SIGNAL_TRACKER.tracking = true
    
    # Run the function once to collect dependencies and get initial value
    initial_value = try
        f()
    finally
        SIGNAL_TRACKER.tracking = false
    end
    
    # Get the collected dependencies
    dependencies = collect(SIGNAL_TRACKER.accessed_signals)
    
    # Create a new signal with the collected dependencies
    Signal(dependencies...; strict_push=strict_push) do args...
        f()
    end
end

# Utility function to get current dependencies of a computed signal
function get_dependencies(s::Signal)
    SIGNAL_TRACKER.accessed_signals = Set{Signal}()
    SIGNAL_TRACKER.tracking = true
    try
        s()
    finally
        SIGNAL_TRACKER.tracking = false
    end
    collect(SIGNAL_TRACKER.accessed_signals)
end
