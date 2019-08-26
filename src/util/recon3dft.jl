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
	ndat = mod.paramsint16[2];                       # number of acquired data samples per TR
	oprbw = mod.paramsfloat[20];
	decimation = round(125.0/mod.paramsfloat[20]);
	dat = dat[nbeg:(nbeg+ndat-1),:,:,:,echo];           # [nx*125/oprbw ny nz ncoils]

	# convert to float and recon
	dat = convert(Array{Complex{Float32},4}, dat);	
	(imsFullfov, ) = recon3dft(dat);      # FOV in readout is still 125/oprbw too large here

	# image matrix size
	(ndat, ny, nz, ncoils) = size(dat);
	nx = Integer(round(ndat*oprbw/125));

	# crop FOV in readout direction
	ims = Array{Complex{<:Real}}(undef, nx, ny, nz, ncoils);
   ims = imsFullfov[range(Int(ndat/2-nx/2), length=nx), :, :, :];

	imsos = sum(ims.*conj(ims), dims=4);

	return (ims, imsos)
end

"""
`(ims, imsos) = recon3dft(dat::Array{Complex{<:Real},4})

WIP: need to make interface like toppe.utils.recon3dft
"""
function recon3dft(
	dat::Array{Complex{<:Real},4}
	) 

	(nx,ny,nz,ncoil) = size(dat);

	ims = similar(dat);
	for ic = 1:ncoil
		ims[:,:,:,ic] = fftshift(ifft(fftshift(dat[:,:,:,ic])));
	end

	imsos = sum(ims.*conj(ims), dims=4);

	return (ims, imsos)
end


"""
`recon_sense(:test)`
"""
function recon3dft(s::Symbol)

	s != :test && throw("call syntax: recon_sense(:test)")

	datdir = "/export/data/jfnielse/stack-of-spirals-presto-bold-fmri/fbirn,14Aug2019/";
	pfile = string(datdir, "P,fbirn,14Aug2019,b0.7");
	readoutfile = string(datdir, "readout_withheader.mod");

	echo = 1;

	return recon3dft(pfile; echo = echo, readoutfile = readoutfile);
end
