export dict2namedtuple

"""
`function nt = dict2namedtuple(D)`

Convert Dict (key, value pairs) to NamedTuple

Example:

D = Dict("A"=>1, "B"=>2)

nt = dict2namedtuple(D)

nt.A == D["A"]     # true
nt.B == D["B"]     # true

""" 
function dict2namedtuple(D)

	# get keys and convert to Symbol array
	k = collect(keys(D))

	sym = Array{Symbol}(undef, length(k))
	for ii = 1:length(k)
		sym[ii] = Symbol(k[ii])
	end
	
	# get values
	v = collect(values(D))

	# convert to named tuple
	return NamedTuple{Tuple(sym)}(v)

end
