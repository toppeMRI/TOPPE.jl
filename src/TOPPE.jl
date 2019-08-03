# toppe.jl

"""
`TOPPE` is the Julia version of the TOPPE Matlab toolbox for MR pulse programming, https://toppemri.github.io/

Usage:

julia> include("TOPPE.jl")

julia> using Main.TOPPE
"""
module TOPPE
   # using Reexport
   # @reexport using MIRTio # make I/O routines available

   include("z-all.jl")

end # module
~                 
