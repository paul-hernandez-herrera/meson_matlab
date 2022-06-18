function filt=Makefilter(nx,ny,nz,n,size_filter,flag)
    %make the filter (Laplacian or Lowpass ) depending on the 
    
    % Determine maximum kx and ky
    kxmax=pi;
    kymax=pi;
    kzmax=pi;

    % Determine kx and ky intervals
    dkx=2*pi/nx;       
    dky=2*pi/ny;
    dkz=2*pi/nz;

    % Make kx and ky arrays and grids
    kx=0:dkx:kxmax;  
    ky=0:dky:kymax; 
    kz=0:dkz:kzmax; 

    [Kx,Ky,Kz]=ndgrid(kx,ky,kz);                % create kx and ky grids
    Kxyz = Kx.^2+Ky.^2+Kz.^2;                    % kx^2 + ky^2 + kz^2 \\ Este es el LAPLACIANO
    %Kxyz = single(Kxyz);

    %HDAF parameters
    %Maximum degree for taylor approximation
    %it is n
    c_nk=sqrt(2.0*n+1)/(sqrt(2)*size_filter*kxmax);

    %Generate filter
    nhx=floor(nx/2)+1;
    nhy=floor(ny/2)+1;
    nhz=floor(nz/2)+1;


    flipx=mod(nx,2);
    flipy=mod(ny,2);
    flipz=mod(nz,2);

    %Allocating memory to save the filter
    filt=zeros(nx,ny,nz);

    if flag==0
        %LAPLACIAN FILTER
        %Multiply the Laplacian filter by the Ideal low-pass filter hdaf
        filt(1:nhx,1:nhy,1:nhz)= -Kxyz.*hdaf(n,c_nk,Kxyz);
    elseif flag==1
        %LOW PASS FILTER
        filt(1:nhx,1:nhy,1:nhz)= hdaf(n,c_nk,Kxyz);
    end

    %filling the filter with replicas of the current filter
    filt(nhx+1:nx,:,:) = filt(nhx+flipx-1:-1:nhx+flipx-(nx-nhx),:,:);
    filt(:,nhy+1:ny,:) = filt(:,nhy+flipy-1:-1:nhy+flipy-(ny-nhy),:);
    filt(:,:,nhz+1:nz) = filt(:,:,nhz+flipz-1:-1:nhz+flipz-(nz-nhz));    
end