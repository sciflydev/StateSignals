using StateSignals
using Documenter

DocMeta.setdocmeta!(StateSignals, :DocTestSetup, :(using StateSignals); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
    file for file in readdir(joinpath(@__DIR__, "src")) if
    file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
    modules = [StateSignals],
    authors = "Pere Giménez <gimenezfebrer@gmail.com>",
    repo = "https://github.com/sciflydev/StateSignals.jl/blob/{commit}{path}#{line}",
    sitename = "StateSignals.jl",
    format = Documenter.HTML(; canonical = "https://sciflydev.github.io/StateSignals.jl"),
    pages = ["index.md"; numbered_pages],
)

deploydocs(; repo = "github.com/sciflydev/StateSignals.jl")
