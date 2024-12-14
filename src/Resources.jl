module Resources
using ..Signals
export Resource

struct Resource
    id::Symbol
    value::Signal
    loader::Function
    isloading::Signal{Bool}
    sources::Vector{Signal}
    error::Signal
end

function Resource(loader::Function, sources::Vector{<:Signal}, id = :none)
    value = Signal(nothing)
    isloading = Signal(false)
    error = Signal(nothing)

    resource = Resource(id, value, loader, isloading, sources, error)

    # Create computed signal to track dependencies
    trigger = computed(() -> begin
        # Read all source signals
       map(s -> s(), sources)
       nothing
    end)

    effect_fn = () -> begin
        isloading() && return
        isloading(true)
        try
            result = loader()
            value(result)
            error(nothing)
        catch e
            error(e)
            value(nothing)
        finally
            isloading(false)
        end
    end
    push!(trigger.effects, effect_fn)

    resource
end

function (resource::Resource)()
    resource.value()
end

loading(resource::Resource) = resource.isloading()
value(resource::Resource) = resource.value()

end
