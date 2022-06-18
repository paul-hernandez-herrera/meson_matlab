function prediction = normalize_output_one_class_classification(prediction,threshold)
    %function that allows to normalize the output of the model such that
    %the values in the range [threshold 1] are assigned to the range [0.5 1] while
    %values [0 threshold] are asigned to [0 0.5].
    %This is important for segmentation purposes. Note that threshold is
    %selected such that p.training percent of the training set is classified
    %correctly. Thus with this normalization p.training percentage of the
    %training set is classified correctly for T =0.5;

    I = prediction<=threshold;
    
    prediction(I) =  normalize_data(prediction(I),0,0.5);
    prediction(not(I)) = normalize_data(prediction( not(I)), 0.5, 1);
end

function vol=normalize_data(vol,m,M)
    %function to normalize the data such that the minimum and maximum values
    %are given at m and M, respectively;

    % vol=single(vol);

    a = min(vol(:));
    b = max(vol(:));
    if a~=b
        vol=((M-m)/(b-a)).*vol + (m*b-M*a)/(b-a);  
    end
end