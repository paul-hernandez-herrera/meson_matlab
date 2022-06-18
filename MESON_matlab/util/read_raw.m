% Read an ITK-style MHD and load raw data from its associated RAW file
% Doesn't take LSB/MSB into account, but has some support for other
% datatypes. (Add support in switch statement below.)

function [data, spacingOut] = read_raw(folder_path, file_name)
    DEBUG=0;
    data = -1;    
    
    if(DEBUG); disp(file_name); end;    
    
    file_path = fullfile(folder_path, file_name);
    %Alberto
    if exist([file_path '.mhd'],'file')
        % Add the extension
        file_path = [file_path , '.mhd'  ];
    elseif exist(file_path,'file') && ~exist(file_path,'dir')
        % Do nothing, we are OK!
    else
        error('Couldn''t open file "%s"', file_path);
    end
            
    
    mhd = fopen(file_path, 'rt');
    if (mhd == -1)
        error('Couldn''t open file "%s"', file_path);
        return
    end
    
    % False==do not flip byte order
    byteOrder = false;
    
    while (~feof(mhd))
        % e.g., 'NDims = 3'
        line = fgetl(mhd);
        p = find(line == '=');
        lhs = line(1:p-2);
        rhs = line(p+2:end);
        
        switch (lhs)
            case 'NDims'
                NDims = rhs;
            case 'ElementType'
                elType = rhs;
            case 'DimSize'
                DimSize = rhs;
            case 'ElementDataFile'
                dataFile = rhs;
            case 'ElementByteOrderMSB'
                if (strcmpi(rhs,'true')), byteOrder = true; end
            %Alberto July 2006
            case 'ElementSpacing'                
                spacingString = rhs;
        end
    end
    fclose(mhd);
    
     %Alberto and Shan, July 07
     if (~exist('spacingString','var') )
         % This is the default spacing out
         spacingOut = [1 1 1];
     else
         %Otherwise, the output is the given space
         spacingOut = str2num(spacingString);
    end     

    
    % One thing not defined?
    if (~exist('NDims','var') || ~exist('elType','var') || ...
        ~exist('DimSize','var') || ~exist('dataFile','var'))
        fprintf('One or more fields undefined in MHD.\n');
        return
    end
    
    % Find matlab data type associated with type here
    switch (elType)
        case 'MET_UCHAR'
            elType = 'uint8';
        case 'MET_SHORT'
            elType = 'int16';
        case 'MET_USHORT'
            elType = 'uint16';
        case 'MET_ULONG'
            elType = 'uint32';
        case 'MET_UINT'
            elType = 'uint32';
        case 'MET_FLOAT'
            elType = 'float32';
        case 'MET_DOUBLE'
            elType = 'float64';            
        otherwise
            fprintf('Unknown data type: %s\nPlease add this type to RAWfromMHD.\n', elType);
            return
    end
    
    % Forcing cast?  %Added the option is empty
    if (exist('cast','var') && ~isempty(cast) )
        elType = sprintf('%s=>%s', elType, cast);
    else
        elType = [ '*' elType ];
    end
    
    % Get dimensions
    NDims = str2num(NDims);
    DimSize = sscanf(DimSize, '%d', [1 NDims]);
    
    %Alberto Jan 2006
    dataFile =  fullfile(folder_path, dataFile );
 
    
    % Open...
    rawfile = fopen(dataFile, 'rb');    
    if (rawfile == -1)
        emsg = sprintf('Failure: Could not open "%s"', dataFile);
        error(emsg);
    end
    
    % Handle byte ordering
    if (byteOrder)
        % Big-endian
        byteOrder = 'ieee-be';
    else
        % Little-endian
        byteOrder = 'ieee-le';
    end
    
    % Handle different dimensions
    if (length(DimSize) ~= 1)
        data = fread(rawfile, prod(DimSize), elType, byteOrder);
        data = reshape(data, DimSize);
    else
        data = fread(rawfile, prod(DimSize), elType, byteOrder);
        if (numel(DimSize)==1)
            data = data';
        end
    end
    
    fclose(rawfile);
return
