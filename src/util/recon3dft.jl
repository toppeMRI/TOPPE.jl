export recon3dft

using FFTW

"""
`(ims, imsos) = recon3dft(dat::Array{Complex{<:Real},4})

WIP: need to make interface like toppe.utils.recon3dft

"""


"""
`(ims, imsos) = recon3dft(dat::Array{Complex{<:Real},4})
3D ift
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

	ncoil = 8;
	N = (64,64,24);
	dat = Array{Complex{Float32}}(undef,N...,ncoil);

	return recon3dft(dat)

end

