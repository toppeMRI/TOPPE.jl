

function readmod(fname)

   read1 = (T::DataType) -> read(fid, T);

   fread = (n::Integer, T::DataType) ->
      begin
         data = Array{T}(undef, n)
         read!(fid, data)
			for ii = 1:length(data)
            d = data[ii]
				for jj = 1:sizeof(eltype(d))
				   @show d
            end
			end
         return data
      end

	freadint = (n::Integer, T::DataType) ->
		begin
			data = Vector{T}(undef, n)
			nb = sizeof(T)
			for ii = 1:n
				ba = Vector{UInt8}(undef, nb)    # byte array
				readbytes!(fid, ba)
				reverse!(ba)
				reinterpret(Int16,ba)
				data[ii] = ba
			end

         return data
      end

   freadc = (n::Integer) -> rstrip(String(fread(n, UInt8)))

	fid = open(fname, "r");

   seek(fid, 0) 

   # read ASCII description
   #@show asciisize = read(fid, Int16)
   # @show asciisize = fread(1, Int16)
   @show asciisize = freadint(1, Int16)
   # desc      = freadc(asciisize)

   # read rest of header
   #ncoils = read1(Int16)
   #res    = read1(Int16)
   #npulses = read1(Int16)

   close(fid)

	return ( # NamedTuple
      asciisize = asciisize
   #   desc = desc,
   #   ncoils = ncoils
      )
k

end
