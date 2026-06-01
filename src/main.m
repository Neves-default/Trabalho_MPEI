%=========================================================================
%================================Naive Bayes==============================
%=========================================================================
function [results,times,t,z,vd]=testNaiveBayes(test,path,numOfTests,Naive_Bayes_with_gassian_log)
    amountData=20000;
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
        [NaiveBayesResult,t]=t.testNaiveBayes(amountLearningData,numOfTests,Naive_Bayes_with_gassian_log,3);
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
end

function menu()
    disp("======================================================")
    disp("Seja bem-vindo ao identificador de objetos planetários")
    disp("======================================================")
    disp("O que pretende fazer?")
    disp("-> : Indentificar objeto")
    disp("->S : Ver objetos semelhantes")
end



