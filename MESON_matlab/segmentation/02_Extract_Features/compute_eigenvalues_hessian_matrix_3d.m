function F = compute_eigenvalues_hessian_matrix_3d(img_3d, radius, scales)
    %function to compute the eigenvalues of hessian matrix 3d using
    %frangi's sorting method
    disp('Computing Features ... Eigenvalues of Hessian Matrix... ');
    tic;

    F = zeros(numel(img_3d),2);
    img_3d = single(img_3d);
    for i=1:length(radius)
        %probabbly faster in the Fourier space for 3d volumes. Neeed to
        %implement.
        [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = Hessian3D(img_3d, radius(i));

        [~,Lambda2,Lambda3,~,~,~]=eig3volume(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);
        
        %select only the subset with the appropiate scale
        I = scales == i;

        F(I,1) = Lambda2(I);
        F(I,2) = Lambda3(I);

    end

    toc
    disp(['Done ' newline newline]);
end