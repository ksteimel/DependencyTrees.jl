#  TransitionParser

"""
    TransitionParserConfiguration

Parser state representation for transition-based dependency parsing.
"""
abstract type TransitionParserConfiguration{T<:Dependency} end

include("transitions.jl")
include("arc_standard.jl")
include("arc_eager.jl")
