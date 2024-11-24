using Test
using StateSignals

@testset "Basic Signal Operations" begin
    # Test signal creation and value access
    s = Signal(5)
    @test s() == 5

    # Test signal update
    s(10)
    @test s() == 10
end

@testset "Computed Signals" begin
    # Test basic computed signal
    a = Signal(1)
    b = Signal(2)
    c = computed(() -> a() + b())

    @test c() == 3

    # Test computed signal updates when dependencies change
    a(5)
    @test c() == 7

    b(3)
    @test c() == 8
end

@testset "Effects" begin
    # Test effect tracking
    s = Signal(0)
    effect_count = Ref(0)

    effect(() -> effect_count[] += 1)
    @test effect_count[] == 1  # Initial effect run

    s(1)  # Should not trigger effect as it's not tracked
    @test effect_count[] == 1

    # Test effect with signal tracking
    tracked_value = Ref(0)
    effect(() -> tracked_value[] = s())
    @test tracked_value[] == 1  # Initial effect run

    s(2)  # Should trigger effect
    @test tracked_value[] == 2
end

@testset "Signal Chain" begin
    # Test chain of computed signals
    a = Signal(1)
    b = computed(() -> a() * 2)
    c = computed(() -> b() + 1)

    @test c() == 3

    a(5)
    @test b() == 10
    @test c() == 11
end

@testset "Signal Invalidation" begin
    a = Signal(1)
    b = computed(() -> a() * 2)

    @test b() == 2

    # Test manual invalidation
    invalidate(b)
    a(3)
    @test b() == 6
end
