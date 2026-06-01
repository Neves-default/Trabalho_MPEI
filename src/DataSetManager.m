%  class | redshift | u-g | g-r | r-i | i-z | snMedian_r | velDisp
classdef DataSetManager < handle
    properties
        fileName
        amount_of_data
        File
        Header
        Data
    end
    %methods (Static)
    %    function cleanedPath = cleanCSV(filePath)
    %        [folder, name, ext] = fileparts(filePath);
    %        cleanedPath = fullfile(folder, [name '_clean' ext]);
    %    
    %        % Se já existe o ficheiro limpo, reutiliza
    %        if isfile(cleanedPath)
    %           return;
    %        end
    %    
    %        fid_in  = fopen(filePath,    'r', 'n', 'UTF-8');
    %        fid_out = fopen(cleanedPath, 'w', 'n', 'UTF-8');
    %    
    %        % Lê header e conta colunas esperadas
    %        header = fgetl(fid_in);
    %        expectedCols = numel(strsplit(header, ','));
    %        fprintf(fid_out, '%s\n', header);
    %   
    %        removed = 0;
    %        while ~feof(fid_in)
    %            line = fgetl(fid_in);
    %            if ~ischar(line), break; end
    %        
    %            actualCols = numel(strsplit(line, ','));
    %            if actualCols == expectedCols
    %                fprintf(fid_out, '%s\n', line);
    %            else
    %                removed = removed + 1;
    %            end
    %        end
    %    
    %        fclose(fid_in);
    %        fclose(fid_out);
    %        fprintf('CSV limpo: %d linhas corrompidas removidas.\n', removed);
    %    end
    %end
    methods
        function obj=DataSetManager(fileName,amount_of_data)
            obj.fileName=fileName;
            obj.amount_of_data=amount_of_data;
            
            
            
            % Limpa o CSV removendo linhas com nº errado de colunas
            %cleanedFile = DataSetManager.cleanCSV(fileName);
            %obj.File=tabularTextDatastore(cleanedFile);
            obj.File=tabularTextDatastore(obj.fileName);
            obj.Header = obj.File.VariableNames;
            obj.Data=table();
        end
        %get Header
        function [header]=getHeader(obj)
            header = obj.Header;
        end
        %gets index from a column
        function [idx]=getColumn(obj,Column_name)
            idx = find(strcmp(obj.Header, Column_name),1);
        end

        %load Data
        function obj=loadData(obj)
            obj.File.ReadSize=obj.amount_of_data;
            obj.Data = read(obj.File);
        end
        %function obj = loadData(obj)
        %    obj.File.ReadSize = 10000; % chunk size seguro
        %    allChunks = {};
    
        %   while hasdata(obj.File)
        %        chunk = read(obj.File);
        %        allChunks{end+1} = chunk;
        %    end
    
        %   obj.Data = vertcat(allChunks{:});
    
            % Aplica o limite se definido (>0), senão retorna tudo
        %    if obj.amount_of_data > 0
        %        obj.Data = obj.Data(1:min(obj.amount_of_data, height(obj.Data)), :);
        %    end
        %end
        %function obj = loadData(obj)
        %    obj.Data = readall(obj.File);
    
        %    if obj.amount_of_data > 0
        %        obj.Data = obj.Data(1:min(obj.amount_of_data, height(obj.Data)), :);
        %    end
        %end
        %get Data
        function [data]=getData(obj)
            data=obj.Data;
        end

        function [dataFilter]=filter(obj,columns)
            if length(intersect(obj.Header,columns))~=length(columns)
                disp("Some columns dont exist on the dataset")
            end
            dataFilter = obj.Data(:, columns);
        end
    end
end