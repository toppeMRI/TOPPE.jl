

function readmod(fname)

   read1 = (T::DataType) -> read(fid, T);

   fread = (n::Integer, T::DataType) ->
      begin
         data = Array{T}(undef, n)
         read!(fid, data)
         return data
      end

   freadc = (n::Integer) -> rstrip(String(fread(n, UInt8)))

   fid = open(fname, "r");

   seek(fid, 0) 

   # read ASCII description
   @show asciisize = read1(Int16)
   #desc      = freadc(asciisize)

   # read rest of header
   #ncoils = read1(Int16)
   #res    = read1(Int16)
   #npulses = read1(Int16)

	return ( # NamedTuple
		a = 1,
		b = 2
    #  asciisize = asciisize
   #   desc = desc,
   #   ncoils = ncoils
      )

end
