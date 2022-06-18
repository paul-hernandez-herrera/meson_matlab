function val=hdaf(n,c_nk,x)  
    %Function to approximate the ideal low-pass filter
    %Higher values correspond to better approaximations to ideal-low pass
    %filter
    %Value equal to zero means gaussian filter
    
    %n : degree of the polinomial approximation to the exponential
    %sigma: -------
    %x: values to compute the laplacian 

    %changing the values of x 
    x = x*c_nk^2;

    %computing coefficients for taylor expansion of exponential to degree n
    coefficients = 1./factorial(n:-1:0);  

    %evaluate the taylor expansion of exponential to degree n
    en = polyval(coefficients,x);

    %evaluation of the filter
    val=en.*exp(-x);

end
