function output = compute_one_class_classification_prediction(model,F)
    %this function obtains the prediction of the model to belong to the background for
    %features F


    %For each feature vector compute the position in the histogram
    for i=1:2
        %get current feature
        features = F(:,i);

        %Getting the appropiated model for the feature i
        %minimum and maximum value used to compute the histogram
        min_bin = model.edges{i}(1);
        max_bin = model.edges{i}(end);

        %Getting the bin size
        bin_step = model.step{i};

        %features falling outside the range of the histogram. Move to the
        %boundary of the histogram (it will not affect the value of the response because we have low values close to the boundary)
        I = features < min_bin;
        features(I) = min_bin;
        I = features > max_bin;
        features(I) = max_bin;

        %computing the position of the bin
        pos{i} = floor((features - min_bin)/bin_step)+1;
    end

    %getting the discriminant function

    %changing values of the bins from (bin_i,bin_j) to index
    index = sub2ind(size(model.one_class_model),pos{1},pos{2});

    %creating the prediction of each voxel
    output = model.one_class_model(index);

    %calculating the response for foreground
    output = 1- output;
end