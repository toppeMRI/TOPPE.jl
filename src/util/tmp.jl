export recon3dft

using FFTW

homedir = "/export/home/jfnielse/"
homedir = "/home/jon/"
include(string(homedir, "github/TOPPE.jl/src/core/readmod.jl"))

function recon3dft(pfile::String;
	echo = 1,
	readoutfile::String = "readout.mod"
	);

	# load raw data and permute
	(dat, rdb_hdr) = loadpfile(pfile);        # [ndat ncoil nslice necho nview]
	dat = dat[end:-1:1,:,:,:,:];              # TOPPE saves data in reverse order
	dat = permutedims(dat, [1 5 3 2 4]);      # [ndat ny nz ncoil necho]

	# get flat portion of readout
	mod = readmod(readoutfile);
	nramp = 0; 
	nbeg = mod.paramsint16[1] + nramp;
	nx = mod.paramsint16[2];                       # number of acquired data samples per TR
	decimation = round(125.0/mod.paramsfloat[20]);
	dat = dat[nbeg:(nbeg+nx-1),:,:,:,echo];           # [nx*125/oprbw ny nz ncoils]

#	imstmp = ift3(d(:,:,:,coil));
#   imstmp = imstmp(end/2+((-nx/decimation/2):(nx/decimation/2-1))+1,:,:);               % [nx ny nz]

	(ndat, ny, nz, ncoils) = size(dat);


	# recon
	(ims, tmp) = recon3dft(dat);	

	return (dat, ims)

#	@show size(dat)

#	return (ims, imsos)
end

"""
`(ims, imsos) = recon3dft(dat::Array{Complex{<:Real},4})

WIP: need to make interface like toppe.utils.recon3dft
"""
function recon3dft(
	dat::Array{Complex{Int16},4}
	) 

	(nx,ny,nz,ncoil) = size(dat);

	ims = similar(dat);
	for ic = 1:ncoil
		ims[:,:,:,ic] = ifft(fftshift(dat[:,:,:,ic]));
		#ims[:,:,:,ic] = fftshift(dat[:,:,:,ic]);
	end

	imsos = sum(ims.*conj(ims), dims=4);

	return (ims, imsos)
end


"""
`recon_sense(:test)`
"""
function recon3dft(s::Symbol)

	s != :test && throw("call syntax: recon_sense(:test)")

	# ncoil = 8;
	# N = (64,64,24);
	# dat = Array{Complex{Float32}}(undef,N...,ncoil);

	datdir = "/export/data/jfnielse/stack-of-spirals-presto-bold-fmri/fbirn,14Aug2019/";
	pfile = string(datdir, "P,fbirn,14Aug2019,b0.7");
	readoutfile = string(datdir, "readout_withheader.mod");

	echo = 1;

	return recon3dft(pfile; echo = echo, readoutfile = readoutfile);
end
