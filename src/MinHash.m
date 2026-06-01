classdef MinHash
    properties
        dataSet
        tuple
    end
    methods
        function obj=MinHash(dataSet,old_tuple)
            
        end

        function [Q]=Quartis(dataSet)
            
        end

        function [readySet]=CategorizeData(data)
            readySet = table('Size',[0 7], ...
                'VariableTypes', {'string','string','string','string','string','string','string'}, ...
                'VariableNames', {'redshift','u_g','g_r','r_i','i_z','velDisp'});
            for i=1:height(data)
                
                line = data(i,:);

                newline = table( ...
                    line.redshift, ...
                    line.u_g, ...
                    line.g_r, ...
                    line.r_i, ...
                    line.i_z, ...
                    line.velDisp, ...
                    line.snMedian_r, ...
                    'VariableNames', {'redshift','u_g','g_r','r_i','i_z','velDisp'} ...
                );

                readySet = [readySet; newline];
            end

            function [category]=defineValue(value,type)
                
                switch type 
                    case 'redshift'
                    case 'u_g'
                    case 'g_r'
                    case 'r_i'
                    case 'i_z'
                    case 'velDisp'
                end
            end
        end
    end
end
