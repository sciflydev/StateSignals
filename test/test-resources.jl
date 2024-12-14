using Test
using StateSignals

@testset "Basic Resource Operations" begin
    # Test resource creation
    s = Signal(0)
    r = Resource([s]) do
        s() * 2
    end

    @test r() === nothing  # Initial value should be nothing
    @test r.isloading() == false  # Should not be loading initially

    # Test resource loading
    s(5)
    sleep(0.1)
    @test r() == 10  # Should compute s() * 2
    @test r.isloading() == false  # Should be done loading
end

@testset "Resource Loading State" begin
    s = Signal(0)
    loading_states = []

    r = Resource([s]) do
        # Track loading state changes
        push!(loading_states, r.isloading())
        sleep(0.1)  # Simulate async work
        s() * 2
    end

    s(5)
    sleep(0.2)  # Wait for async operation

    @test loading_states[1] == true  # Should be loading during computation
    @test r.isloading() == false  # Should be done loading after computation
    @test r() == 10  # Should have correct final value
end

@testset "Multiple Dependencies" begin
    a = Signal(2)
    b = Signal(3)

    r = Resource([a, b]) do
        a() * b()
    end

    @test r() === nothing  # Initial value

    a(4)  # Should trigger resource update
    sleep(0.1)
    @test r() == 12  # 4 * 3

    b(5)  # Should trigger another update
    sleep(0.1)
    @test r() == 20  # 4 * 5
end

@testset "Error Handling" begin
    s = Signal(0)
    r = Resource([s]) do
        if s() < 0
            error("Value cannot be negative")
        end
        s() * 2
    end

    # Initial state
    @test r() === nothing
    @test r.error() === nothing
    @test r.isloading() == false

    # Test error condition
    s(-1)
    sleep(0.1)
    @test r() === nothing  # Value should be reset
    @test r.error() isa ErrorException  # Should have captured the error
    @test r.error().msg == "Value cannot be negative"
    @test r.isloading() == false  # Should not be loading after error
end
