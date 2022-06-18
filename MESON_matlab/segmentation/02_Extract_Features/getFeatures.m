function F = getFeatures(img_3d, file_path,file_name, varargin)
    %function that allow to get the Eigenvalues of the Hessian matrix as
    %features
    % Section 4.2. Feature extraction from paper https://www.sciencedirect.com/science/article/am/pii/S0165027016300255
    
    disp('Computing Features ... Eigenvalues of Hessian Matrix... ');
    tic;
    %gettting input parameters
    parameters = get_parameters(varargin);    
    
    file_name = [file_name '_tmp'];
    
    %this format is used to compute the eigenvalues of the hessian matrix
    %using ITK code.
    write_raw(img_3d, file_path, file_name, 'spacing', parameters.spacing);
    
    %this format is used to get the index of the radii selected to compute
    %the laplacian. Among the radii this is the best scale
    if isempty(parameters.selected_scales)
        %use the first scale to compute all the features
        selected_scales = ones(size(img_3d_log),'uint8');
        file_name_scales = [file_name '_scales_index_' num2string(parameters.radius(1))];
        write_raw(selected_scales, file_path, file_name_scales, 'spacing', parameters.spacing);
    else
        file_name_scales = [file_name '_scales_index_' num2string(parameters.radius)];
        write_raw(parameters.selected_scales, file_path, file_name_scales, 'spacing', parameters.spacing);
    end
    
    %computing the eigenvalues of the Hessian matrix using the scale
    %selected by the laplacian filter
    F = computeEigenvalues_Gaussian_Smoothing(file_path,file_name, file_name_scales, 'radius', parameters.radius);
        
    F = [F(:,2) F(:,3)];

    toc
    disp(['Done ' newline newline]);
    
end

function parameters = get_parameters(input_values)
    %default values for algoritm
    
    p = inputParser;
    addParameter(p,'radius', [], @(x) isnumeric(x))
    addParameter(p,'selected_scales', [], @(x) isnumeric(x))    
    addParameter(p,'spacing', [1 1 1], @(x) isnumeric(x))    
    
    parse(p,input_values{:});
    
    parameters = p.Results;
    
    if isempty(parameters.radius)
        error('radius values is required');
    end
end