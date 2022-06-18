function delete_raw_and_mhd_files(input_file)
    %this function allows to delete the raw and mhd files
    %input_file: input file to be elliminated without extension

    if exist([input_file '.mhd'], 'file')
        delete([input_file '.mhd']);
    end
    
    if exist([input_file '.raw'], 'file')
        delete([input_file '.raw']);
    end

end