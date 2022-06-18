function img_3d = read_stack(folder_path,file_name)

if (exist(fullfile(folder_path,[file_name '.mhd']),'file'))
    img_3d = read_raw(folder_path, file_name);
elseif(exist(fullfile(folder_path,[file_name '.tif']),'file'))
    img_3d = read_tif(folder_path,[file_name '.tif']);
else 
    warning('File not found %s with extension raw or tif ', fullfile(folder_path,file_name));
    img_3d = [];
end


end