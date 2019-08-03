"""
`mod = readmod(fname)`

Read TOPPE .mod file

in

-- `fname::String`   .mod file name

out

-- `mod::NamedTuple` with header and waveforms, accessed by mod.key
-   `mod.rf`     RF waveform (Gauss)       [n npulses ncoils] Array{Complex{Float32},3}
-   `mod.gx`     Gx waveform (Gauss/cm)    [n npulses] Array{Float32,2}
-   `mod.gy`     Gy waveform (Gauss/cm)    [n npulses] Array{Float32,2}
-   `mod.gz`     Gz waveform (Gauss/cm)    [n npulses] Array{Float32,2}
-   `mod.paramsint16`  30-element Array{Int16,1}
-   `mod.paramsfloat`  32-element Array{Float64,1}

example

   include("readmod.jl")

   mod = readmod("readout.mod").

   using Plots

   plot([mod.gx mod.gy mod.gz])
"""
function readmod(fname)

	# read number(s) directly (doesn't change endianness)
	fread = (n::Integer, T::DataType) ->
		begin
			data = Array{T}(undef, n)
			read!(fid, data)
			return data
		end

	# read string
   freadc = (n::Integer) -> rstrip(String(fread(n, UInt8)))

	# read number(s) and change endianness
	freadce = (n::Integer, T::DataType) ->
		begin
			data = Vector{T}(undef, n)
			nb = sizeof(T)                     # number of bytes
			for ii = 1:n
				ba = Array{UInt8}(undef, nb)    # byte array
				readbytes!(fid, ba)
				reverse!(ba)
				data[ii] = reinterpret(Int16,ba)[1]    # note the [1], since reinterpret returns a type that's array-like
			end

			if n == 1
				data = data[1]
			end

         return data
      end

	fid = open(fname, "r");

   seek(fid, 0) 

   # read ASCII description
   asciisize = freadce(1, Int16)
   desc      = freadc(asciisize)

   # read rest of header
   ncoils  = freadce(1, Int16)
   res     = freadce(1, Int16)
   npulses = freadce(1, Int16)
	l = readline(fid);
	b1max = parse(Float32, l[(end-7):end]);    # b1max  = fscanf(fid, 'b1max:  %f\n');
	l = readline(fid);
	gmax = parse(Float32, l[(end-7):end]);    # gmax   = fscanf(fid, 'gmax:   %f\n');

   nparamsint16 = freadce(1, Int16)
   paramsint16 = freadce(nparamsint16, Int16)[3:end]    # NB! Return only the user-defined ints passed to writemod.m

   nparamsfloat = freadce(1, Int16)
	paramsfloat = Array{Float64}(undef, nparamsfloat)
	for ii = 1:nparamsfloat
		paramsfloat[ii] = parse(Float64, readline(fid));
	end

	# read waveforms
	# @show position(fid)
	rho   = zeros(Float32,res,npulses,ncoils);
	theta = zeros(Float32,res,npulses,ncoils);
	gx = zeros(Float32,res,npulses);
	gy = zeros(Float32,res,npulses);
	gz = zeros(Float32,res,npulses);
	for ip = 1:npulses
		for ic = 1:ncoils
			rho[:,ip,ic] = freadce(res, Int16);
		end
		for ic = 1:ncoils
			theta[:,ip,ic] = freadce(res, Int16);
		end
		gx[:,ip] = freadce(res, Int16);
		gy[:,ip] = freadce(res, Int16);
		gz[:,ip] = freadce(res, Int16);
	end

   close(fid)

	# convert to physical units
	max_pg_iamp = Float32(2^15-2);                   # max instruction amplitude (max value of signed short)
	rho   = rho*b1max/max_pg_iamp;     			# Gauss
	theta = theta*pi/max_pg_iamp;      			# radians
	gx = gx*gmax/max_pg_iamp;                 # Gauss/cm
	gy = gy*gmax/max_pg_iamp;                 # Gauss/cm
	gz = gz*gmax/max_pg_iamp;                 # Gauss/cm

	return ( # NamedTuple
      desc = desc,
		rf = rho.*exp.(1im*theta),
		gx = gx,
		gy = gy,
		gz = gz,
		paramsint16 = paramsint16,
		paramsfloat = paramsfloat
      )

end
