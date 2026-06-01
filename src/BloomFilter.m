% Overview:
% - We'll NOT use 'specObjID' in the hash function to insert the object into
% the filter because it's not unique, so we're using the *row number* instead;
% - We'll implement the hash function from 'PL6'
% Dataset link: https://dr17.sdss.org/sas/dr17/casload/spCSV/plates/

% Get data
function [data] = getAllData (amountOfData, fileName, path)
    pathFile=fullfile(path, fileName);
    dataManager = DataSetManager(pathFile,amountOfData);
    dataManager.loadData();
    data=dataManager.getData();
end


% Initialize bloom filter
function [bloomFilter] = initializeDataStructure (n)
    bloomFilter = zeros(1, n);
    fprintf('NEW bloom filter:\n');
    disp(bloomFilter);
end


% Get the array of the IDs from the entire dataset
function [IDdata] = getArrayOfIds (data)
    % This is not possible so let's do differently
    % IDdata = data(:, 1);
    IDdata = 1:size(data, 1);
    fprintf('NEW ID array:\n');
    disp(IDdata);
end


% Define parameters a and b for CArter-Wegman method
function [a_params, b_params, p] = defineParams (k)
    % Define family parameters a and b for k functions
    p = 10007; % A prime number: 10007 instead of 2^31 - 1
    a_params = randi([1, p-1], 1, k);
    b_params = randi([0, p-1], 1, k);
    fprintf('NEW parameters defined:\n');
    disp(a_params);
    disp(b_params);
end


% Returns k hashes for one value (auxiliary function)
function [results] = hashCode (bloomFilter, x, k, a_params, b_params, p)
    % Using the Carter-Wegman method
    n = length(bloomFilter);     % Filter size
    %m = length(IDdata);         % Where data is an array with the elements' IDs

    % To hash an element x k times:
    results = zeros(1, k);

    p = uint64(p);

    for i = 1:k
        a = uint64(a_params(i));
        b = uint64(b_params(i));
        hash_val = mod(mod(a*x + b, p), n) + 1;
        results(i) = hash_val;
    end
end


function [newBloomFilter] = addElement (bloomFilter, x, k, a_params, b_params, p)
    fprintf('NEW element to add to bloom filter:\n');
    disp(x);
    results = hashCode(bloomFilter, x, k, a_params, b_params, p);
    fprintf('NEW hash from added element:\n');
    disp(results);
    newBloomFilter = bloomFilter;
    for i = 1:length(results)
        newBloomFilter(results(i)) = 1;
    end
    fprintf('UPDATED bloom filter:\n');
    disp(newBloomFilter);
end


function [isThere] = isElementInFilter (bloomFilter, x, k, a_params, b_params, p)
    fprintf('INFO element to check if belongs to the set:\n');
    disp(x);
    results = hashCode(bloomFilter, x, k, a_params, b_params, p);
    isThere = true;
    for i = 1:length(results)
        if bloomFilter(results(i)) ~= 1
            isThere = false;
            fprintf('INFO element does NOT belong to the set\n');
            break
        end
    end
    fprintf('INFO element belongs to the set\n');
end


% == Main ==

rng('shuffle'); % Ensures different a and b parameters on every run

% Get atual data
amount_of_data = 10;
fileName='sqlSpecObj.csv';
path='/Users/lemadti/UA/MPEI2026/Trabalho_MPEI';
data = getAllData(amount_of_data, fileName, path);

% Get the IDs array
IdDataArr = getArrayOfIds(data);

n = 100;

% Get params a and b
k = round(n * log(2) / amount_of_data); % Optimal k formula

% Create a bloom filter
bloom = initializeDataStructure(n);
[a, b, p] = defineParams(k);

% Generate random indexes
indxs = randi([1, 10], 1, 3);
% Add elements
for i = 1:3
    bloom = addElement(bloom, indxs(i), k, a, b, p);
end


% Check if an element is in the bloom filter
for i = 1:3
    isPresent = isElementInFilter(bloom, indxs(i), k, a, b, p);  % Should be present - was added previously
end

rndmIndxs = randi([1, 10], 1, 3);

for i = 1:3
    isPresent = isElementInFilter(bloom, rndmIndxs(i), k, a, b, p);  % Shouldn't be present - wasn't added yet
end