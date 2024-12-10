# StateSignals

[![Test workflow status](https://github.com/sciflydev/StateSignals.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/sciflydev/StateSignals.jl/actions/workflows/Test.yml?query=branch%3Amain)
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

x(5) # Prints "Sum changed to: 7"
```
