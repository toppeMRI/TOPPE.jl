using Interpolations

"""
`(kx,ky) = g2k(g,nint,delay)`

in
- g             [N 2] array containing Gx and Gy in Gauss/cm
- nint=1        number of leaf rotations (default=1)
- delay=(0,0)   Tuple{<:Real,<:Real} containing shift in gx and gy, in units of samples
"""
function g2k(g,nint,delay)

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
	kc = zeros(Complex{Float64},n,nint);
	kprot = k[:,1] + 1im*k[:,2]
	for ii = 1:nint
		phi = (ii-1)/nint*2pi
		kc[:,ii] = kprot.*exp.(1im*phi)
	end

	return (real(kc), imag(kc))

end

