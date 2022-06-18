function write_tif(imageStack,file_path,file_name)

%remove extension just in case it was given
[~, file_name_tmp, ext] = fileparts(file_name);

if strcmp(ext, '.tif')
    file_name = file_name_tmp;
end

full_file_path = fullfile(file_path,[file_name '.tif']);

numberOfImages = size(imageStack,3);
for k = 1:numberOfImages
    currentImage = imageStack(:,:,k);
    currentImage = currentImage';
    
    if (k==1)
        imwrite(currentImage,full_file_path,'tif', 'WriteMode','overwrite');
    else
        imwrite(currentImage,full_file_path,'tif', 'WriteMode','append');
    end
end 

end