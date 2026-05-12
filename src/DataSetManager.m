%  class | redshift | u-g | g-r | r-i | i-z | snMedian_r | velDisp
classdef DataSetManager < handle
    properties
        fileName
        amount_of_data
        File
        Header
        Data
    end
    methods
        function obj=DataSetManager(fileName,amount_of_data)
            obj.fileName=fileName;
            obj.amount_of_data=amount_of_data;
            
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

        %get Data
        function [data]=getData(obj)
            data=obj.Data;
        end
    end
end

%Obtains the occurence of each class
function [results]=getEachClassesData(data)
    inx_class_column=62; %idx of the column class(IMPORTANT FOR NAIVE BAYES)
    
    classes_data=data(:,inx_class_column);
    classes=unique(classes_data);
    results = zeros(length(classes),2);
    for i=1:length(classes)
        occurs=sum(classes_data==classes(i));
        results(i,1) = classes(i);
        results(i,2) = occurs/length(classes_data);
    end
end