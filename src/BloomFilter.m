% Overview:
% - We'll NOT use 'specObjID' in the hash function to insert the object into
% the filter because it's not unique, so we're using the *row number* instead;
% - We'll implement the hash function from 'PL6'
% Dataset link: https://dr17.sdss.org/sas/dr17/casload/spCSV/plates/
classdef BloomFilter
    properties
        data
        bloonfilter
        realValues
        a_params
        b_params
        p
        k
    end
    methods
        % Get data
        function obj = getAllData (obj,amountOfData, pathFile)%fileName, path)
            %pathFile=fullfile(path, fileName);
            dataManager = DataSetManager(pathFile,amountOfData);
            dataManager.loadData();
            obj.data=dataManager.getData();
        end


        % Initialize bloom filter
        function obj = initializeDataStructure (obj,n)
            bloomFilter = zeros(1, n);
            %fprintf('NEW bloom filter:\n');
            %disp(bloomFilter);
            obj.bloonfilter=bloomFilter;
            obj.realValues=[];
        end


        % Get the array of the IDs from the entire dataset
        function [IDdata] = getArrayOfIds (obj)
            % This is not possible so let's do differently
            % IDdata = data(:, 1);
            %========================
            IDdata = 1:size(obj.data, 1);
            %fprintf('NEW ID array:\n');
            %disp(IDdata);
        end


        % Define parameters a and b for CArter-Wegman method
        function obj = defineParams (obj,k)
            % Define family parameters a and b for k functions
            obj.p = 10007; % A prime number: 10007 instead of 2^31 - 1
            obj.k=k;
            obj.a_params = randi([1, obj.p-1], 1, obj.k);
            obj.b_params = randi([0, obj.p-1], 1, obj.k);
            %fprintf('NEW parameters defined:\n');
            %disp(obj.a_params);
            %disp(obj.b_params);
        end


        % Returns k hashes for one value (auxiliary function)
        function [results] = hashCode (obj, x)
            % Using the Carter-Wegman method
            n = length(obj.bloonfilter);     % Filter size
            %m = length(IDdata);         % Where data is an array with the elements' IDs

            % To hash an element x k times:
            results = zeros(1, obj.k);

            p64 = uint64(obj.p);

            for i = 1:obj.k
                a = uint64(obj.a_params(i));
                b = uint64(obj.b_params(i));
                hash_val = mod(mod(a*x + b, p64), n) + 1;
                results(i) = hash_val;
            end
        end


        function obj = addElement (obj, x)
            %fprintf('NEW element to add to bloom filter:\n');
            %disp(x);
            results = obj.hashCode(x);%obj.a_params, obj.b_params, obj.p);
            %fprintf('NEW hash from added element:\n');
            %disp(results);
            newBloomFilter = obj.bloonfilter;
            for i = 1:length(results)
                newBloomFilter(results(i)) = 1;
            end
            %fprintf('UPDATED bloom filter:\n');
            obj.bloonfilter=newBloomFilter;
            obj.realValues(end+1)=x;
            %disp(newBloomFilter);
        end


        function [isThere] = isElementInFilter (obj, x)
            %fprintf('INFO element to check if belongs to the set:\n');
            %disp(x);
            results = obj.hashCode(x);%, obj.a_params, obj.b_params, obj.p);
            isThere = true;
            for i = 1:length(results)
                if obj.bloonfilter(results(i)) ~= 1
                    isThere = false;
                    %fprintf('INFO element does NOT belong to the set\n');
                    break
                end
            end
            %fprintf('INFO element belongs to the set\n');
        end

        function [fakePositive]= isFakePositive (obj, x)
            isThere=obj.isElementInFilter(x);
            %checking now if it is a fakePositive
            exists = false;
            for i=1:length(obj.realValues)
                if obj.realValues(i)==x
                    %fprintf('INFO element belongs to the set\n');
                    exists=true;
                    break
                end
            end
            fakePositive=(isThere==true && exists==false);
        end

        function [occupancy]=getOccupancy(obj)
            occupancy=sum(obj.bloonfilter)/length(obj.bloonfilter);
        end
    end
end