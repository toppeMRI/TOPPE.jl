using Interpolations

"""
`(kx,ky) = g2k(g, nint=1, delay=(0,0))`

in
- g            [N 2] array of Real numbers containing Gx and Gy in Gauss/cm
- nint         number of leaf rotations
- delay        Tuple{<:Real,<:Real} containing shift in gx and gy, in units of samples

out
- kx           [N nint] array containing kx locations (cycles/cm; Real)
- ky           [N nint] array containing ky locations (cycles/cm; Real)
"""
function g2k(
	g::Array{<:Real,2},
	nint::Integer=1,
	delay::Tuple{<:Real,<:Real}=(0,0)
	)

	# apply delay
	npad = 100      # maximum shift (samples)
	if any(i -> abs(i) > npad-1, delay)
		error("max delay is $npad");
	end
	glong = [zeros(npad,2); g; zeros(npad,2)]

	n = size(g)[1]
	for ii = 1:size(g)[2]
		itp = interpolate(glong[:,ii], BSpline(Linear()));
		g[:,ii] = itp(range(1+npad-delay[ii],step=1,n+npad-delay[ii]))
	end

	# calculate kspace
	gamma = 4.2576;            # kHz/Gauss
	dt = 4e-3                  # gradient sample duration (dwell time) (sec)
	k = gamma*dt*cumsum(g, dims=1)     # cycles/cm

	# apply (in-plane) rotations
	kc = Array{Complex{Float64}}(undef,n,nint);
	kprot = k[:,1] + 1im*k[:,2]
	for ii = 1:nint
		phi = (ii-1)/nint*2pi
		kc[:,ii] = kprot.*exp.(1im*phi)
	end

	if nint==1
		kc = kc[:,1]     # return vector
	end

	return (real(kc), imag(kc))
end

"""
`(kx,ky) = g2k(gx::Vector{<:Real}, gy::Vector{<:Real}, nint=1, delay=(0,0))`
"""
function g2k(
	gx::Vector{<:Real},
	gy::Vector{<:Real},
	nint::Integer=1,
	delay::Tuple{<:Real,<:Real}=(0,0)
	)

	return g2k([gx gy], nint, delay)
end