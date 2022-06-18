function [V1, V2, V3]=readEigenvaluesGaussianFilter(file_path, file_name, sigma,ID_label)

V1 = read_raw(file_path, [file_name ID_label '.EigVal1.Sigma.' num2str(sigma)]); 
V2 = read_raw(file_path, [file_name ID_label '.EigVal2.Sigma.' num2str(sigma)]); 
V3 = read_raw(file_path, [file_name ID_label '.EigVal3.Sigma.' num2str(sigma)]); 
%to avoid problems remove all NaN Number
I = isnan(V1) | isnan(V2)| isnan(V3); V1(I)=0; V2(I)=0; V3(I)=0;
clear I;
end