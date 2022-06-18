function [multiscaleLaplacian,scales] = multiscale_laplacian_3D_hdaf(img_3d, r)   
    %function that computes the laplacian at multiple scales using the
    %hermite distributed approximate functional (almost an ideal low pass
    %filter). This function returns the laplacian and the radius with the
    %maximum response at each voxel.
    
    %computing the size of the filter in the Fourier domain to detect structures of the given radius. 
    %obtained by visual inspection of the size of laplacian in the spatial domain of filter
	size_filter = 0.66./r;
%     size_filter = 1.6227./(0.0531 + r);
    flag = 0; %compute Laplacian
    
    %fourier transform
    img_3d=fftn(img_3d);    
    
    %getting the size of the image
    [nx, ny, nz]=size(img_3d);
    
    for i =1:length(size_filter)
        %Getting the size of the filter to compute the Laplacian
        sigma = size_filter(i);    
        
        %generate Normalized Laplacian filter
        filt=Makefilter(nx, ny, nz, 60, sigma, flag)/ConstantToNormalizeFilter(sigma);

        %Apply the laplacian filter
        ImageN=img_3d.*filt;

        %obtain the inverse fourier transform
        Laplacian_Spatial_Domain=ifftn(ImageN,'symmetric');
        
        %getting the maximum Laplacian response across the scales in case
        %of multiple radius
        if i==1
            multiscaleLaplacian = Laplacian_Spatial_Domain;
            scales = ones(size(Laplacian_Spatial_Domain),'uint8');
        else
            %Multiscale approach
            I = abs(Laplacian_Spatial_Domain)>=abs(multiscaleLaplacian);
            scales(I) = i;
            multiscaleLaplacian(I) = Laplacian_Spatial_Domain(I);
        end        
        
    end
end

function N_c = ConstantToNormalizeFilter(sigma)
%function that allows to normalize the response of the filter
%see http://cbl.uh.edu/blogs/orion/2013/10/13/a-more-general-analysis-of-the-normalization-constant-for-the-laplacian-filter/
N_c = sigma^2;
end