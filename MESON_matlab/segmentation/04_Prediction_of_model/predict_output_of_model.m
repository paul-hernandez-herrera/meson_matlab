function output_model = predict_output_of_model(model, features, scales)
    % Section 4.4. Segmentation of Neurons from paper https://www.sciencedirect.com/science/article/am/pii/S0165027016300255
    disp('Predicting the output of the model in the 3D image stack... ');
    tic;    
    
    %this function allows to predict the response to the model
    
    %allocate memory to save the output of the model
    output_model=zeros(size(scales),'single');

    %compute the model (2d histogram) for each scale
    for i=1:max(scales(:))
        %predict the output of the model to voxels selected for the
        %current scale
        %STEP 4
        current_voxels_to_classify = (scales==i);          

        output_model(current_voxels_to_classify) = compute_one_class_classification_prediction(model{i},features(current_voxels_to_classify,:));

        output_model(current_voxels_to_classify) = normalize_output_one_class_classification(output_model(current_voxels_to_classify), model{i}.automatic_threshold);
    end   
    
    toc
    disp(['Done ' newline newline]);
        
end