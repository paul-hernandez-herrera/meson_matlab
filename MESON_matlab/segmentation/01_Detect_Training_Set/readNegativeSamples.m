function [I, scales]= readNegativeSamples(img_3d, varargin)
    % Section 4.1. Detect a training set of background points from paper https://www.sciencedirect.com/science/article/am/pii/S0165027016300255

    %radius <- radius of the tubular structures to be detected. default [2 3 4 5]
    
    tic;
    disp([newline 'Detecting training set of background samples... '])
    
    %gettting input parameters
    parameters = get_parameters(varargin);
    

    %Reading the maximum response of the Laplacian
    [multiscale_laplacian,scales]= multiscale_laplacian_3D_hdaf(img_3d, parameters.radius);

    %take only the positive values which we know belong to the background
    I = multiscale_laplacian>0;
    
    toc
    disp(['Done ' newline newline]);
    
end


function parameters = get_parameters(input_values)
    %default values for algoritm
    
    p = inputParser;
    
    addParameter(p,'radius', [2 3 4 5], @(x) isnumeric(x))
    
    parse(p,input_values{:});
    
    parameters = p.Results;
end