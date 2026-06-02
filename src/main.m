%=========================================================================
%================================Naive Bayes==============================
%=========================================================================
function [results,times,t,z,vd]=testNaiveBayes(test,path,numOfTests,Naive_Bayes_with_gassian_log)
    amountData=10000;
    sizeFilter=10;
    columns=["class", ...            %class
                "z", ...                %redshift
                "spectroFlux_u", ...    %ultraviolet
                "spectroFlux_g", ...    %blue or violette
                "spectroFlux_r", ...    %red
                "spectroFlux_i", ...    %high infra-red
                "spectroFlux_z", ...    %low infra-red
                "velDisp", ...          %dispersion level
                "snMedian_r"         %precision;
         ];

    t=test;
    t = t.initializeData(path);
    t=t.dataLoading(amountData,columns);
    amountLearningData=0;
    times=zeros(1,numOfTests);
    %currency according to the learninDataSize
    for i=1:numOfTests
        if amountLearningData==15000
            break;
        end
        amountLearningData=i*10;
        cronometer=tic;
        [NaiveBayesResult,t]=t.testNaiveBayes(amountLearningData,sizeFilter,numOfTests,Naive_Bayes_with_gassian_log,3);
        times(i)=toc(cronometer);
        results(i) = sum(diag(NaiveBayesResult))/numOfTests;
    end

    z=t.redshifts;
    vd=t.velpdisps;
    t.displayGraphicsNaiveBayes(amountLearningData,results,z,vd,Naive_Bayes_with_gassian_log);
end

%=========================================================================
%================================Bloon Filter=============================
%=========================================================================
function [k,occupancy,fakePositives,negativesTested]=testBloonFilter(test,amount_of_data,path,n,numElemInsert,numSearches,numK)
    %test num of positives in function of
    % num inserts
    % filter's size
    % num hashes
    % num inserts
    t=test;
    t.displayFakePositivesInserts(amount_of_data,path,numElemInsert,n,numSearches);
    t.displayFakePositiveSize(amount_of_data,path,n,numElemInsert,numSearches);
    t.displayFakePositivesHashes(amount_of_data,path,numK,n,numElemInsert,numSearches);

    %capture the statistics
    
    fakePositives=0;
    negativesTested=0;
    k = round(n * log(2) / amount_of_data); % Optimal k formula
    k = max(1, k);
    filterTest=BloomFilter();
    filterTest=filterTest.getAllData(amount_of_data,path);
    filterTest=filterTest.initializeDataStructure(n);
    filterTest=filterTest.defineParams(k);
        
    indxs = randi([1, 50000], 1, numElemInsert);
    for j=1:numElemInsert
        filterTest=filterTest.addElement(indxs(j));
    end
    sndxs = randi([50001, 100000], 1, numSearches);
    for a=1:numSearches
        fk=filterTest.isFakePositive(sndxs(a));
        if (fk==true)
            fakePositives=fakePositives+1;
        end
        negativesTested=negativesTested+1;
    end
    occupancy=filterTest.getOccupancy();
    
end
%=========================================================================
%===================================Min Hash==============================
%=========================================================================
function [k, pairs, trueSims, estSims, k_values, mean_errors]=testMinHash(test)
    %->Similaridade real vs Similaridade estimada
    %->Erro vs Número de hashes
    test.testAccuracyTest();
    [k, pairs, trueSims, estSims, k_values, mean_errors]=test.testMinHash();
end
function testing()
    %results for Naive Bayes
    test=tests();
    fileName='DataSet.csv';
    pathFile=fullfile('/home/neves-default/Secretária/universidade de Aveiro/2ºano/2º semestre/Metodos_probabilisticos_EI/Projeto/Trabalho_Pratico/',fileName);
    numOfTests=100;
    %With Log Gaussian
    [results,times,t,z,vd]=testNaiveBayes(test,pathFile,numOfTests,1);
    test.showStatisticsNaiveBayes("With Log Gaussian",results,times,t,z,vd);
    %Without Log Gaussian
    [results,times,t,z,vd]=testNaiveBayes(test,pathFile,numOfTests,0);
    test.showStatisticsNaiveBayes("Without Log Gaussian",results,times,t,z,vd);
    %results for Bloom Filter
    amount_of_data=500;
    n=5000;
    numElemInsert=500;
    numSearches=500;
    optimalK=round(n * log(2) / amount_of_data); % Optimal k formula
    numK = max(10, 2 * optimalK);
    [k,occupancy,fakePositives,negativesTested]=testBloonFilter(test,amount_of_data,pathFile,n,numElemInsert,numSearches,numK);

    test.showStatisticsBloomFilter(n,k,occupancy,fakePositives,negativesTested,numElemInsert)
    %minHash
    [k, pairs, trueSims, estSims, k_values, mean_errors]=testMinHash(test);
    test.showStatisticsMinHash(k, pairs, trueSims, estSims, k_values, mean_errors);
end

function executeNaiveBayes(data,bayes)
    isFromDataSet=input("Os dados sobre o objeto provêm do dataSet(Y/n):","s");
            if (isempty(data))
                disp("Data is not load")
                return;
            end
            if strcmpi(isFromDataSet,"y")
                idx=str2double(input("Em que linnha ele se encontra?","s"));
                selectedData=data(idx,:);
                z=selectedData.z;
                spectroFlux_u=selectedData.spectroFlux_u;
                spectroFlux_g=selectedData.spectroFlux_g;
                spectroFlux_r=selectedData.spectroFlux_r;
                spectroFlux_i=selectedData.spectroFlux_i;
                spectroFlux_z=selectedData.spectroFlux_z;
                velDisp=selectedData.velDisp;
                snMedian_r=selectedData.snMedian_r;
            else
                z=str2double(input("redshift:","s"));
                spectroFlux_u=str2double(input("spectroFlux_u:","s"));
                spectroFlux_g=str2double(input("spectroFlux_g:","s"));
                spectroFlux_r=str2double(input("spectroFlux_r:","s"));
                spectroFlux_i=str2double(input("spectroFlux_i:","s"));
                spectroFlux_z=str2double(input("spectroFlux_z:","s"));
                velDisp=str2double(input("Veldisp:","s"));
                snMedian_r=str2double(input("snMedian_r(1-50):","s"));
            end
            tuple=table( ...
                z, ...
                spectroFlux_u, ...
                spectroFlux_g, ...
                spectroFlux_r, ...
                spectroFlux_i, ...
                spectroFlux_z, ...
                velDisp, ...
                snMedian_r, ...
                'VariableNames', { ...
                'z', ...
                'spectroFlux_u', ...
                'spectroFlux_g', ...
                'spectroFlux_r', ...
                'spectroFlux_i', ...
                'spectroFlux_z', ...
                'velDisp', ...
                'snMedian_r' ...
                });
            
            displayResults(bayes.estimateClass(tuple,1),z,spectroFlux_u,spectroFlux_g,spectroFlux_r,spectroFlux_i,spectroFlux_z,velDisp,snMedian_r);
end

function displayResults(bayesResult,z,spectroFlux_u,spectroFlux_g,spectroFlux_r,spectroFlux_i,spectroFlux_z,velDisp,snMedian_r)
    disp("==================Results==================")
    disp("Object type:"+bayesResult)
    disp("===========================================")
    disp("Given Data")
    disp("  ->redshift:"+z)
    disp("  ->spectroFlux_u:"+spectroFlux_u)
    disp("  ->spectroFlux_g:"+spectroFlux_g)
    disp("  ->spectroFlux_r:"+spectroFlux_r)
    disp("  ->spectroFlux_i:"+spectroFlux_i)
    disp("  ->spectroFlux_z:"+spectroFlux_z)
    disp("  ->velDisp:"+velDisp)
    disp("  ->snMedian_r:"+snMedian_r)
    disp("===========================================")
end

function executeMinHash(data)
    if isempty(data)
        disp("Data is not loaded");
        return;
    end

    interval = input("Pretende ver a semelhança de um intervalo? (y/n): ", "s");

    % Traduz SEMPRE o dataset completo
    adapter      = Translator(data);
    tableAdapted = adapter.buildTranslatedTabel();
    threshold    = 0.5;
    k            = 1000;

    mh       = MinHash(tableAdapted.finalData, threshold, k);
    identical = mh.identical;

    % Filtra os resultados depois
    if strcmpi(interval, "y")
        startIdx = str2double(input("Start: ", "s"));
        endIdx   = str2double(input("End: ",   "s"));
        mask     = (identical(:,1) >= startIdx & identical(:,1) <= endIdx) | ...
                   (identical(:,2) >= startIdx & identical(:,2) <= endIdx);
        identical = identical(mask, :);
    else
        idx  = str2double(input("Em que linha ele se encontra? ", "s"));
        mask = identical(:,1) == idx | identical(:,2) == idx;
        identical = identical(mask, :);
    end

    disp("===============Results-MinHash================")
    disp("==========Configuration======================")
    disp("      ->K (Hash Functions): "  + k)
    disp("      ->Total Pairs Tested: "  + (mh.n * (mh.n - 1)) / 2)
    disp("==========Similarity Results=================")
    if isempty(identical)
        disp("      Nenhum par semelhante encontrado com threshold=" + threshold);
    else
        for p = 1:size(identical, 1)
            disp("      ->Pair [" + identical(p,1) + ", " + identical(p,2) + "]" + ...
                 "  Dist: " + identical(p,3));
        end
    end
    disp("==============================================")
end

function parsing(data,cmd,bayes)
    switch upper(cmd)
        case "IDEN"
            executeNaiveBayes(data,bayes)
        case "SEM"
            executeMinHash(data)
    end
end

function displayMenu()
    disp("======================================================")
    disp("Seja bem-vindo ao identificador de objetos estrelares")
    disp("======================================================")
    disp("O que pretende fazer?")
    disp("-> IDEN: Indentificar objeto")
    disp("-> SEM: Ver objetos semelhantes")
    disp("-> TEST: Testar algoritmos")
    disp("-> HELP: rever opções")
    disp("-> QUIT: sair do programa")
    disp("======================================================")
end

function [finalData,bayes]=loadsAlgorithms()
    amountOfData=1000;
    fileName='DataSet.csv';
    pathFile=fullfile('/home/neves-default/Secretária/universidade de Aveiro/2ºano/2º semestre/Metodos_probabilisticos_EI/Projeto/Trabalho_Pratico/',fileName);
    
    dataManager = DataSetManager(pathFile,amountOfData);
    dataManager.loadData();
    finalData=dataManager.filter(["class", ...            %class
                "z", ...                %redshift
                "spectroFlux_u", ...    %ultraviolet
                "spectroFlux_g", ...    %blue or violette
                "spectroFlux_r", ...    %red
                "spectroFlux_i", ...    %high infra-red
                "spectroFlux_z", ...    %low infra-red
                "velDisp", ...          %dispersion level
                "snMedian_r" ...        %precision
                ]);
    %Naive Bayes
    sizeFilter=2000;
    bayes=Naive_Bayes(finalData,sizeFilter,0);
    bayes=bayes.buildFeature();
    bayes=bayes.Average();
    bayes=bayes.StandartDeviation();
    bayes=bayes.getEachClassesData();
end

function ui()
    mode=input("Quer executar a aplicação em mode de teste Y/n):","s");
    if strcmpi(mode,"y")
        testing();
        return
    end
    [data,bayes]=loadsAlgorithms();
    displayMenu()
    while true
        cmd=input(">","s");
        if strcmpi(cmd,"quit")
            disp("Clossing Program...")
            break
        end
        if strcmpi(cmd,"test")
            testing();
            break
        end
        if strcmpi(cmd,"help")
            displayMenu();
        else
            parsing(data,cmd,bayes);
        end
    end
end


ui()





