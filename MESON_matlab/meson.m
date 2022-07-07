function result = meson(file_input,varargin)
    close all;
    %segmentation process to detect bright tubular structures from the 3D images stack using a one-class classification approach where the distribution of the eigenvalues of
    %the Hessian matrix is computed from a training set (background voxels automatically detected) and assign a cost function to eliminate background voxels. 
    % Foreground voxels correspond to cost value larger than 0.5.
    % https://doi.org/10.1016/j.jneumeth.2016.03.019
    
    % Parameters:
    % file_input: file path to the 3D image stack to be segmented (tif or
    % mhd format) 

    % Parameters optional:
    % radius: radius of the tubular structures to be detected. default [2 3 4 5]
    % spacing: spacing (voxel size) of the 3D stack. Important to compute features (eigenvalues) if the stack
    % is anisotropic, current implementation of Laplacian does not take
    % into account anisotropic voxel
    % min_conn_comp: minimum value of voxels for a connected component to be
    % taken as noise. defaul 0;
    % training_accuracy: Computes automatically a threshold such that the
    % percentage of training set to be classified correctly as background
    % by the model is training accuracy. default 0.95. Must be in range (0,1)
    % threshold_seg: threshold value manually setted for the response of the model to segment structures.
    % Ignores the threshold obtained from training accuracy. Must be in range (0,1)
    % n_bins: number of bins to compute the histogram --- default 500
    % features_sorting_method: FRANGI sorting according to magnitud or SATO
    % sorting according to value
    % display_images: save an image with the main steps for debug purposes
    % apply_log: for low contrast images, applying the logarithm function
    % can help to increase the constrast

    %Example
    % meson_segmentation(stack, 'radius', [2 3 5 10]);


    [file_path, file_name, ~] = fileparts(file_input);
    img_3d_raw = read_stack(file_path,file_name);

    %gettting input parameters
    parameters = get_parameters(varargin);
    
    if parameters.apply_log
        %we assume that the img_3d have positive values
        if ~isempty(find(img_3d_raw(:)<0, 1))
            error('3D image stack must have positive values to apply log');
        end        
        img_3d = log(single(img_3d_raw)+1);
    else
        img_3d = img_3d_raw;
    end
    
    %creating file names to save outputs
    file_name_to_save_model_variables = [file_name '_probability_radius_' num2string(parameters.radius) '_n_bins_' num2string(parameters.n_bins) '_tra_' num2string(parameters.training_accuracy) '.mat'];
    file_name_to_save_segmentation = [file_name '_segmentation_radius_' num2string(parameters.radius) '_n_bins_' num2string(parameters.n_bins) '_threshold_' num2string(round(10^2 * parameters.threshold_seg)/10^2) ...
        '_tra_' num2string(parameters.training_accuracy) '_min_conn_' num2string(parameters.min_conn_comp)];  
    
    if ~exist(fullfile(file_path, file_name_to_save_model_variables),'file')
        %Run the code to genereta a one-class classification model
       
        %STEP1: Detecting training set consisting of background voxels using the Hermite
        %Distributed Approximation Functional (hdaf) 
        [training_set,scales]= readNegativeSamples(img_3d, 'radius', parameters.radius);

        %STEP 2: Compute the feature vector (eigenvalues of Hessian Matrix)
        %features = getFeatures(img_3d, file_path, file_name, 'radius', parameters.radius, 'spacing', parameters.spacing, 'selected_scales', scales);    
        features = compute_eigenvalues_hessian_matrix_3d(img_3d, parameters.radius, scales);

        %STEP 3: Construct the one-class classification model
        model = construct_models(features, training_set, scales, 'training_accuracy', parameters.training_accuracy, 'n_bins', parameters.n_bins);
        
        
        %STEP 4a: Predict the output of the model
        output_model = predict_output_of_model(model, features, scales);
        
        if not(parameters.predict_output_in_training_set)
            %we know that voxels in training set must belong to backgroun
            output_model(training_set) = 0;
        end          

        %%saving the output of the model
        save(fullfile(file_path, file_name_to_save_model_variables),'model','img_3d_raw','output_model','training_set', 'scales')
    else
        %reading the response to the current scales
        load(fullfile(file_path, file_name_to_save_model_variables));
    end
    
    % STEP 4b: doing the segmentation from the model's output
    % Section 4.4. Segmentation of Neurons from paper https://www.sciencedirect.com/science/article/am/pii/S0165027016300255
    segmentation = output_model>parameters.threshold_seg;


    % STEP 5: removing small components
    % Section 4.5. Post-processing from paper https://www.sciencedirect.com/science/article/am/pii/S0165027016300255
    if parameters.min_conn_comp>0
        segmentation = remove_small_conComp3D(segmentation, parameters.min_conn_comp,26);
    end
    
    %save the segmentation
    write_tif(uint8(255*segmentation), file_path, file_name_to_save_segmentation);
    
    %save the prediction
    %write_raw(output_model, file_path, file_name_to_save_prediction,'spacing', parameters.spacing);    

    if parameters.display_images
        display_images_steps_MESON(img_3d, model, output_model, segmentation);
        print(gcf,fullfile(file_path, [file_name '_output.png']),'-dpng');
    end
    
    result = struct('segmentation',segmentation, 'output_model',output_model);
    fprintf('MESON has finished ... \n');
    fprintf('Segmentation file saved in: %s \n\n',fullfile(file_path,[file_name_to_save_segmentation '.tif']));
    fprintf('Mat file saved in: %s \n\n',fullfile(file_path,[file_name_to_save_model_variables '.mat']));

end



function parameters = get_parameters(input_values)
    %default values for algoritm
    
    p = inputParser;
    addParameter(p,'radius', [2 3 4 5], @(x) isnumeric(x))
    addParameter(p,'min_conn_comp', 0, @(x) isnumeric(x))
    addParameter(p,'training_accuracy', 0.999, @(x) isnumeric(x) && (x > 0) && (x <= 1))
    addParameter(p,'threshold_seg', 0.5, @(x) isnumeric(x) && (x > 0) && (x < 1))
    addParameter(p,'n_bins', 500, @(x) isnumeric(x))
    addParameter(p,'spacing', [1 1 1], @(x) isnumeric(x))
    addParameter(p,'features_sorting_method', 'FRANGI', @(x) isstring(x));   
    addParameter(p,'predict_output_in_training_set', false, @(x) islogical(x))
    addParameter(p,'display_images', false, @(x) islogical(x))
    addParameter(p,'apply_log', false, @(x) islogical(x))
    
    parse(p,input_values{:});
    
    parameters = p.Results;
end
