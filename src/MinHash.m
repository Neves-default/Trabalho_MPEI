%  class | redshift | u-g | g-r | r-i | i-z | snMedian_r | velDisp

classdef MinHash < handle
    properties
        table       % table of vals returned by the translator (line p/obj)
        threshold   % defined threshold
        k           % number of hash functions
        n           % number of objects (lines) in the dataset table
        uniquetable % table with unique values
        signatures  % an array with the signatures from the objs in table
        identical   % array containing identical pairs
    end
    methods
        function obj=MinHash(table, threshold, k)
            obj.table = table;
            obj.threshold = threshold;
            obj.k = k;
            obj.uniquetable = obj.getUniqueValuesTable(obj.table);
            obj.n = size(obj.uniquetable, 1);       % It should be the same as the original table dimension
            obj.signatures = obj.getSignatures(obj.uniquetable, obj.k, obj.n);
            obj.identical = obj.getIdenticalObjs(obj.signatures, obj.threshold, obj.k, obj.n);
        end
        function [uniquetable] = getUniqueValuesTable(obj, table)
            % In the table, the values in the columns are the index of each
            % quantile so they can be repeated across the different columns
            % (they all start at one and increment by one)
            % As we should not have duplicate values with different
            % meanings (or in different columns), we will use this formula
            % to create a table with no different values by shifting each
            % value a calculated amount depending on its table:
            % ShiftedValue=RawValue+(ColumnIndex×Multiplier),
            % where Multiplier must be greater than the maximum possible
            % value in table
            % This function should return the new table without duplicate
            % values
            table_matrix = table2array(table(:, 2:end));
            maxValue = max(table_matrix(:));           % Find the maximum value in the table
            multiplier = 100;                   % Set the multiplier to be greater than max value
            if maxValue > 100                   % In Translator code it maps quantiles from 1 to 50
                multiplier = maxValue + 1;      % So values should not be greater than that
            end                                 % However here's a check just in case
            % We do maxValue + 100 if there's a value greater than 100
            uniquetable = zeros(size(table_matrix));   % Initialize the unique table
            for col = 1:size(table_matrix, 2)
                % Shift values
                uniquetable(:, col) = table_matrix(:, col) + (col - 1) * multiplier;
            end
        end
        function [signatures] = getSignatures(obj, uniquetable, k, n)
            % This function will aplly the MinHash to create signatures
            % and add them all to the array signatures, returning it
            % >> Check functions from PL7 to do this
            % n is the number of lines (objects) in uniquetable
            maxValue = max(uniquetable);
            p = 999983;                         % Big prime
            if maxValue >= p
                p = 10000019;                   % Even bigger prime if maxValue is greater than that big prime
            end
            % Generate random coefficients 'a' and 'b' for k hash functions
            rng(42);                            % Fix the seed so that the result is always the same
            a = randi([1, p-1], 1, k);
            b = randi([0, p-1], 1, k);
            % Init the signatures array with infinites because we will do
            % the minimum element so we should not have 0
            signatures = inf(n, k);
            for i = 1 : n
                nvect = uniquetable(i, :);      % Vector with line i object's data                
                % nvect should be a column vector because of MATLAB's broadcasting
                if size(nvect, 2) > size(nvect, 1)
                    nvect = nvect';
                end
                
                % Apply hash functions to all values of this line (object)
                % nvect (M x 1) .* a (1 x k) + b (1 x k)
                % results on a (M x k) matrix
                hash_values = mod(nvect .* a + b, p);
                
                % MinHash saves only the minimum value obtained with each
                % hash function
                signatures(i, :) = min(hash_values, [], 1);
            end
        end
        function [identical] = getIdenticalObjs(obj, signatures, threshold, k, n)
            % This function should compare all the signatures and, for each
            % pair, add to the identical array a matrix with the two
            % objects and their Jaccard distance (matrix n x 3 where each
            % line corresponds to a pair)
            % Then it should return the array with the arrays corresponding
            % to the pairs found
            % >> Check functions from PL7 to do this
            identical = zeros(n, 3);            % Pre-allocate for efficiency
            idx = 1;                            % Index to populate the identical matrix
            
            for i = 1 : n
                for j = i + 1 : n
                    % Counts which of the k positions have identical
                    % signatures
                    num_equal_hashes = sum(signatures(i, :) == signatures(j, :));
                    
                    % Jaccard similarity is the fraction of equal hashes
                    jac_sim = num_equal_hashes / k;
                    jac_dist = 1 - jac_sim;
                    
                    % Add the pair to the identical matrix if the
                    % calculated distance (approximately) is less than the
                    % defined threshold
                    if jac_dist <= threshold
                        identical(idx, :) = [i, j, jac_dist];
                        idx = idx + 1;
                    end
                end
            end
        end
    end
end