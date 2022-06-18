function write_raw(X, folder_path, file_name, varargin)
    % Write a raw file and associated MHD.

    %gettting input parameters
    parameters = get_parameters(varargin);
    
    
    mhdFile = [ file_name '.mhd' ];
    rawFile = [ file_name '.raw' ];
    
    elType = class(X);
    switch elType
        case 'int16'
            elTypeOut.mhd = 'MET_SHORT';
        case 'uint8'
            elTypeOut.mhd = 'MET_UCHAR';
            elTypeOut.vvi =  3;                        
        case 'uint16'
            elTypeOut.mhd = 'MET_USHORT';
            elTypeOut.vvi =  5;              
        case 'uint32'
            elTypeOut.mhd = 'MET_ULONG';
            elTypeOut.vvi =  9;                          
        case 'single'
            elTypeOut.mhd = 'MET_FLOAT';
            elTypeOut.vvi =  8;            
        case 'double'
            elTypeOut.mhd = 'MET_DOUBLE';
            elTypeOut.vvi =  8;      
        case 'logical'
            elTypeOut.mhd = 'MET_UCHAR';
            elTypeOut.vvi =  3;                                    
        otherwise
            error('Data type unknown ("%s") - please modify WriteRAWandMHD.', elType);
    end

    mhdFileWithPath =  fullfile( folder_path,mhdFile );        
    mhd = fopen(mhdFileWithPath, 'wt');                        
    
    %Write mhd file
    fprintf(mhd, 'ObjectType = Image\n');
    fprintf(mhd, 'NDims = 3\n');
    fprintf(mhd, 'BinaryData = True\n');
    fprintf(mhd, 'BinaryDataByteOrderMSB = False\n');
    fprintf(mhd, 'ElementSpacing =  %g  %g   %g \n', parameters.spacing(1), parameters.spacing(2), parameters.spacing(3));    
    fprintf(mhd, 'DimSize = %d %d %d\n', size(X,1), size(X,2), size(X,3));
    fprintf(mhd, 'ElementType = %s\n', elTypeOut.mhd);
    fprintf(mhd, 'ElementDataFile = %s\n', rawFile);
    fclose(mhd);

    %Write raw file
    rawFileWithPath =  fullfile( folder_path,rawFile );    
    raw = fopen(rawFileWithPath, 'wb');                        

    fwrite(raw, X, class(X)); 
    fclose(raw);
    
end

function parameters = get_parameters(input_values)
    %default values for algoritm
    
    p = inputParser;

    addParameter(p,'spacing', [1 1 1], @(x) isnumeric(x))
        
    parse(p,input_values{:});
    
    parameters = p.Results;
end