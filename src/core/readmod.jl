
function readmod(fname)

	# read array of numbers directly (don't convert endianness just yet)
	fread = (n::Integer, T::DataType) ->
		begin
			data = Array{T}(undef, n)
			read!(fid, data)
			return data
		end

	# read string
   freadc = (n::Integer) -> rstrip(String(fread(n, UInt8)))

	# read ints and convert endianness
	freadint = (n::Integer, T::DataType) ->
		begin
			data = Vector{T}(undef, n)
			nb = sizeof(T)                     # number of bytes
			for ii = 1:n
				ba = Array{UInt8}(undef, nb)    # byte array
				readbytes!(fid, ba)
				reverse!(ba)
				data[ii] = Int16(1)*reinterpret(Int16,ba)[1]
			end

			if length(data) == 1
				data = data[1]
			end

         return data
      end

	fid = open(fname, "r");

   seek(fid, 0) 

   # read ASCII description
   @show asciisize = freadint(1, Int16)
   @show desc      = freadc(asciisize)

   # read rest of header
   @show ncoils  = freadint(1, Int16)
   @show res     = freadint(1, Int16)
   @show npulses = freadint(1, Int16)
	l = readline(fid);
	@show b1max = parse(Float64, l[(end-7):end]);    # b1max  = fscanf(fid, 'b1max:  %f\n');
	l = readline(fid);
	@show  gmax = parse(Float64, l[(end-7):end]);    # gmax   = fscanf(fid, 'gmax:   %f\n');

   nparamsint16 = freadint(1, Int16)
   paramsint16 = freadint(nparamsint16, Int16)[3:end]    # NB! Return only the user-defined ints passed to writemod.m

   nparamsfloat = freadint(1, Int16)
	paramsfloat = Array{Float64}(undef, nparamsfloat)
	for ii = 1:nparamsfloat
		paramsfloat[ii] = parse(Float64, readline(fid));
	end

	# read waveforms
	# @show position(fid)
	rho   = zeros(res,npulses,ncoils);
	theta = zeros(res,npulses,ncoils);
	gx = zeros(res,npulses);
	gy = zeros(res,npulses);
	gz = zeros(res,npulses);
	for ip = 1:npulses
		for ic = 1:ncoils
			rho[:,ip,ic] = freadint(res, Int16);
		end
		for ic = 1:ncoils
			theta[:,ip,ic] = freadint(res, Int16);
		end
		gx[:,ip] = freadint(res, Int16);
		gy[:,ip] = freadint(res, Int16);
		gz[:,ip] = freadint(res, Int16);
	end

	# @show position(fid)
   close(fid)

	# convert back to physical units
	max_pg_iamp = 2.0^15-2;                   # max instruction amplitude (max value of signed short)
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
k

end
