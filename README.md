# StateSignals

[![Build Status](https://github.com/sciflydev/StateSignals.jl/workflows/Test/badge.svg)](https://github.com/sciflydev/StateSignals.jl/actions)
[![Test workflow status](https://github.com/sciflydev/StateSignals.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/sciflydev/StateSignals.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Lint workflow Status](https://github.com/sciflydev/StateSignals.jl/actions/workflows/Lint.yml/badge.svg?branch=main)](https://github.com/sciflydev/StateSignals.jl/actions/workflows/Lint.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/sciflydev/StateSignals.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/sciflydev/StateSignals.jl)
[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)

This package implements a reactive graph-based state management system where values automatically update based on their dependencies. It is inspired by the Angular JS framework and built around three core concepts:

- **Signal**: wraps a value and notifies dependents when it changes.
- **Computed signal**: automatically derived values that update when their dependencies change.
- **Effect**: callback that run when its dependent signals change.

Simple example:
```julia
using StateSignals
x = Signal(1)
y = Signal(2)
z = computed(() -> x() + y())  # z is 3
effect(() -> println("Sum changed to: ", z()))

x(5)
z() # Prints "Sum changed to: 7"
```
Note that, as of now, a signal's value is only updated when calling its getter. Similarly, effects are called when the signal's value is retrieved.
