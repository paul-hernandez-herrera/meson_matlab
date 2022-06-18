function model = construct_models(features, training_set, scales, varargin)
    % Section 4.3. Learning decision function for each scalefrom paper https://www.sciencedirect.com/science/article/am/pii/S0165027016300255
    disp('Constructing the model for each radius... ');
    tic;
    %gettting input parameters
    parameters = get_parameters(varargin);
    
    num_scales = max(scales(:));
    
    model = cell(num_scales,1);
    
    %generate a model (2d histogram) for each scale
    for i=1:num_scales
        %getting training set for the current scale
        training_set_current_scale = training_set & (scales==i);

        %getting feature vectors distribution for negative samples
        %STEP 3
        model{i} = compute_one_class_classification_model(features(training_set_current_scale,:), 'training_accuracy', parameters.training_accuracy, 'n_bins', parameters.n_bins);
    end    

    toc
    disp(['Done ' newline newline]);
    
end


function parameters = get_parameters(input_values)
    %default values for algoritm
    
    p = inputParser;
    addParameter(p,'training_accuracy', 0.999, @(x) isnumeric(x) && (x > 0) && (x <= 1))
    addParameter(p,'n_bins', 500, @(x) isnumeric(x))
    
    parse(p,input_values{:});
    
    parameters = p.Results;
end