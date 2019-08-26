export recon3dft

using FFTW

homedir = "/export/home/jfnielse/"
homedir = "/home/jon/"
include(string(homedir, "github/TOPPE.jl/src/core/readmod.jl"))

function recon3dft(pfile::String;
	echo = 1,
	readoutfile::String = "readout.mod"
	);

	# load raw data
	(dat, rdb_hdr) = loadpfile(pfile);        # [ndatAcquired ncoil nslice necho nview]
	dat = dat[end:-1:1,:,:,:,:];              # TOPPE saves data in reverse order

	# get flat portion of readout
	toppemod = readmod(readoutfile);

	return toppemod
end

"""
`(ims, imsos) = recon3dft(dat::Array{Complex{<:Real},4})

WIP: need to make interface like toppe.utils.recon3dft
"""
function recon3dft(
	dat::Array{Complex{Float32},4}
	) 

	(nx,ny,nz,ncoil) = size(dat)

	ims = similar(dat);
	for ic = 1:ncoil
		ims[:,:,:,ic] = fftshift(dat[:,:,:,ic]);
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
	readoutfile = string(datdir, "readout.mod");

	echo = 1;
	(ims, imsos) = recon3dft(pfile; echo = 1, readoutfile = readoutfile);

	return imsos
end
