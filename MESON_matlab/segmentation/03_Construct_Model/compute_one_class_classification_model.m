function model = compute_one_class_classification_model(F, varargin)
    %compute the cost function for a voxel to belong to background
    %F is a nx2 vector the columns are the 2nd and 3rd eigenvalue sorted
    %according to Frangi
    
    
    %gettting input parameters
    parameters = get_parameters(varargin);
    
    %We may have many points to compute the distribution of the eigenvalues.
    %Randomly selecting 1000000 will not affect the distribution
    n_samples = size(F,1);

    max_numberofSamples = 10^6;
    if n_samples > max_numberofSamples
        %randomly selecting 1,000,000 samples
        I = randsample(n_samples,max_numberofSamples);
        F = F(I,:);
    else
        warning('Few samples to compute the one-class classification model. Number of detected samples = %i. Reduce parameter n_bins (current_val = %i)',n_samples, parameters.n_bins);
    end

    %NOT SURE IF THIS STEP IS NECESSARY
    %removing noisy points to reduce size of bounding box
    I = remove_isolated_feaures(F(:,1)) | remove_isolated_feaures(F(:,2));
    F(I,:) = [];

    model.n_training = size(F,1);

    for i=1:2
        %get minimum and maximum values for the current feature vector
        min_ = min(F(:,i));
        max_ = max(F(:,i));

        %compute the bin size for the current feature
        model.step{i} = (max_ - min_)/parameters.n_bins;   

        %compute the edges of the histogram
        model.edges{i} = min_:model.step{i}:max_;
    end

    %compute 2D histogram for the given edges
    model.hist = hist3(F,'Edges',model.edges);
    model.training_accuracy = parameters.training_accuracy;

    %Transform the 2D histogram to a Cost function
    [model.one_class_model, model.automatic_threshold]= construct_model_from_2d_histogram(model);


end

function [one_class_model, T]= construct_model_from_2d_histogram(model)
    %parameter for the smoothing of the Histogram
    sigma_ = 2;

    %get the histogram
    h = model.hist;

    
    %Apply sigmoid function to normalize the volume.
    %This step allows to assign value 0.5 to bins with zero feature vectors
    %and values close to one to bins with 5 or more feature vectors
    h = 1./ (1 + exp(-h));


    %smoothing the histogram using a Gaussian kernel. 
    %To remove isolated responses
    filt = fspecial('gaussian', ceil(6*sigma_), sigma_);
    h = imfilter(h,filt,'replicate','same');

    %normalize to the interval [0,1]
    min_ = min(h(:)); max_ = max(h(:));
    h = (h-min_)/(max_ - min_);

    %compute automatic threshold to correctly classify
    %model.training_accuracy correctly as background
    one_class_model = h;
    T = getThreshold(one_class_model, model.hist, model.training_accuracy);


end


function T = getThreshold(model,histogram_features,training_accuracy)
    %Function that allows you to check that at least 95% of training set are
    %correctly classified as background with the given threshold
    %parameters:
    %T: the current threshold
    %step: the increase step

    %Getting the total number of samples
    TotalSamples = sum(histogram_features(:));
    
    %initial threshold value
    T = 1;
    
    num_ite = 10;
    for i=1:num_ite
        %precision/error of threshold value
        step = 10^(-i);
        
        accuracy_T     = sum( histogram_features(model>=T) )/TotalSamples; %accuracy_T = number of training set of samples correctly classified/number of samples;
        while accuracy_T < training_accuracy
            T = T - step; %decreasing a small amount the threshold
            accuracy_T = sum( histogram_features(model>=T) )/TotalSamples;
        end
        T = T+step;
    end
    
    %The current threshold is to segment the background. Change threshold
    %to segment foreground
    T = 1 - T;    
end

function I = remove_isolated_feaures(F)
    %we are interested only in getting the distribution where we have large
    %values of the histogram. We use random sampling to remove isolated responses
    %F: input vector of the features as column vector

    %number of time to average the bounding box
    n = 200;

    %size of rand sample
    rand_s = 200;
    if rand_s > size(F,1)
        rand_s = size(F,1);
    end

    min_ = 0;
    max_ = 0;
    for i=1:n
        %randonly select rand_s samples from the Feauture vector
        I = randsample(size(F,1),rand_s);

        %select the feature points
        T = F(I);

        %get the bounding box for the current sample. (We divide by n, because we average all the boxes sizes)
        min_ = min_ + min(T(:))/n;
        max_ = max_ + max(T(:))/n;
    end

    %compute interval size
    d = abs(max_ - min_);

    %computing the mean value
    m = (max_+min_)/2;

    %fprintf('min = %f   max = %f\n', min_, max_);
    %create tree times the interval size
    min_ = m - 2*d; 
    max_ = m + 2*d; 


    %get features vectors outside this box
    I = F<min_ | F>max_;

end


function parameters = get_parameters(input_values)
    %default values for algoritm
    
    p = inputParser;
    addParameter(p,'training_accuracy', 0.99, @(x) isnumeric(x) && (x > 0) && (x <= 1))
    addParameter(p,'n_bins', 500, @(x) isnumeric(x))
    
    parse(p,input_values{:});
    
    parameters = p.Results;
end