%teste
%1 tuple -> class = {'GALAXY'}
amountOfData=1000;
fileName='DataSet.csv';
lineTOEstimate=14;
% 3 -> QSO
% 14 -> STAR
% mostly galaxies
Naive_Bayes_with_gassian_log=0;

pathFile=fullfile('/home/neves-default/Secretária/universidade de Aveiro/2ºano/2º semestre/Metodos_probabilisticos_EI/Projeto/Trabalho_Pratico/',fileName);
dataManager = DataSetManager(pathFile,amountOfData);

dataManager.loadData();
data=dataManager.getData();
disp(data{:,"snMedian_r"})%["z" , "spectroFlux_u" , "spectroFlux_g" , "spectroFlux_r" , "spectroFlux_i" , "spectroFlux_z"]})
%==========================================================================
%machineLearning=Naive_Bayes(data);

%selectedData=data(lineTOEstimate,:);
%tuple=table( ...
%    selectedData.z, ...
%    selectedData.spectroFlux_u, ...
%    selectedData.spectroFlux_g, ...
%    selectedData.spectroFlux_r, ...
%    selectedData.spectroFlux_i, ...
%    selectedData.spectroFlux_z, ...
%    selectedData.velDisp, ...
%    selectedData.snMedian_r, ...
%    'VariableNames', { ...
%        'redshift', ...
%        'spectroFlux_u', ...
%        'spectroFlux_g', ...
%        'spectroFlux_r', ...
%        'spectroFlux_i', ...
%        'spectroFlux_z', ...
%        'velDisp', ...
%        'snMedian_r' ...
%});
%machineLearning.buildFeature();
%machineLearning.Average;
%machineLearning.StandartDeviation();
%machineLearning.getEachClassesData();
%class=machineLearning.estimateClass(tuple,Naive_Bayes_with_gassian_log);
%disp(class);


%funciona omg :)))))))))))

%==========================================================================

%adapter=Translator(data);
%tableAdapted=adapter.buildTranslatedTabel();
%disp(tableAdapted.finalData);

%funciona lets goooo omggg :))))))))))))))))))
%==========================================================================

%amountData=20000;
%amountLearningData=10000;
%numOfTests=10000;
%Naive_Bayes_with_gassian_log=0;
%t=tests();
%t = t.initializeData(pathFile);
%columns=["class", ...            %class
%                "z", ...                %redshift
%                "spectroFlux_u", ...    %ultraviolet
%                "spectroFlux_g", ...    %blue or violette
%                "spectroFlux_r", ...    %red
%                "spectroFlux_i", ...    %high infra-red
%                "spectroFlux_z", ...    %low infra-red
%                "velDisp", ...          %dispersion level
%                "snMedian_r"         %precision;
%         ];
%t=t.dataLoading(amountData,columns);
%NaiveBayesResult=t.testNaiveBayes(amountLearningData,numOfTests,Naive_Bayes_with_gassian_log,3);
%disp(NaiveBayesResult);

%classe teste naive bayes funciona :)))))))))

%bloon filter
% == Main ==

%rng('shuffle'); % Ensures different a and b parameters on every run

% Get atual data
%amount_of_data = 10;
%fileName='sqlSpecObj.csv';
%path='/Users/lemadti/UA/MPEI2026/Trabalho_MPEI';
%filter=BloomFilter();
%filter=filter.getAllData(amount_of_data, pathFile);
%data = getAllData(amount_of_data, fileName, path);

% Get the IDs array
%IdDataArr = filter.getArrayOfIds();
%IdDataArr = getArrayOfIds(data);

%n = 100;

% Get params a and b
%k = round(n * log(2) / amount_of_data); % Optimal k formula

% Create a bloom filter
%filter=filter.initializeDataStructure(n);
%filter=filter.defineParams(k);
%bloom = initializeDataStructure(n);
%[a, b, p] = defineParams(k);

% Generate random indexes
%indxs = randi([1, 10], 1, 3);
% Add elements
%for i = 1:3
%    filter= filter.addElement(indxs(i));
    %bloom = addElement(bloom, indxs(i), k, a, b, p);
%end


% Check if an element is in the bloom filter
%for i = 1:3
%    isPresent = filter.isElementInFilter(indxs(i));  % Should be present - was added previously
    %isPresent = isElementInFilter(bloom, indxs(i), k, a, b, p);  % Should be present - was added previously
%end

%rndmIndxs = randi([1, 10], 1, 3);

%for i = 1:3
%    isPresent = filter.isElementInFilter(rndmIndxs(i));  % Shouldn't be present - wasn't added yet
    %isPresent = isElementInFilter(bloom, rndmIndxs(i), k, a, b, p);  % Shouldn't be present - wasn't added yet
%end

