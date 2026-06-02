%====================================================================
% TESTS
%====================================================================
classdef tests
    properties
        path
        data
        %Naive Bayes
        redshifts
        velpdisps
        distribution
    end
    methods
        function obj=initializeData(obj,path)
            obj.path = path;
        end

        function [idx]=ConvertClass(obj,class)
            classes=["GALAXY","STAR","QSO"];
            idx = find(classes==class);
        end
        function obj=dataLoading(obj,amountData,columnsNeeded)
            manager=DataSetManager(obj.path,amountData);
            manager.loadData();
            obj.data=manager.getData();
            obj.data=manager.filter(columnsNeeded);
        end

        function [naiveBayesAlgorithm]=ConfiguringNaiveBayes(obj,amount,sizeFilter)
            learningSet = obj.data(amount+1:end,:);
            %break part of the data
            naiveBayesAlgorithm=Naive_Bayes(learningSet,sizeFilter);
            naiveBayesAlgorithm.buildFeature();
            naiveBayesAlgorithm.Average;
            naiveBayesAlgorithm.StandartDeviation();
            naiveBayesAlgorithm.getEachClassesData();
        end

        function [results, obj]=testNaiveBayes(obj,amount,sizeFilter,numOftests,using_gassian_log,numClasses)
            % test with diferent amounts(diferente from the original data)
            % checkng the right and wrong results
            % generating grafics and results from the tests

            %calculates accuracy precision 
            testSet=obj.data(1:amount, :);
            obj.redshifts=zeros(3,numOftests);
            obj.velpdisps=zeros(3,numOftests);
            obj.distribution=zeros(1,3);
            algorithm=obj.ConfiguringNaiveBayes(amount,sizeFilter);
            results=zeros(numClasses);
            for i=1:numOftests
                line=randi([1 size(testSet,1)]);
                selectedData=obj.data(line,:);

                previsionClass=algorithm.estimateClass(selectedData,using_gassian_log);
                realClass=selectedData.class;

                prevision=obj.ConvertClass(previsionClass{1});
                real=obj.ConvertClass(realClass{1});
                
                results(real,prevision)=results(real,prevision)+1;

                obj.redshifts(prevision,i) = selectedData.z;
                obj.velpdisps(prevision,i) = selectedData.velDisp;
                if i ~= 1
                    idxZ = setdiff(1:size(obj.redshifts,1), prevision);
                    idxVD = setdiff(1:size(obj.velpdisps,1), prevision);
                    obj.redshifts(idxZ,i) = obj.redshifts(idxZ,i-1);
                    obj.velpdisps(idxVD,i)= obj.velpdisps(idxVD,i-1);
                end

                obj.distribution(prevision)=obj.distribution(prevision)+1;
                
            end
        end

        function displayGraphicsNaiveBayes(obj,amountLearningData,results,z,vd,use_gaussian_log)
            %plot graphic
            figure;
            plot(1:10:amountLearningData,results,'o-')
            if use_gaussian_log==1
                title("Learning set size vs Precision(Using Gaussian Log)")
            else
                title("Learning set size vs Precision(Without Gaussian Log)")
            end
            xlabel("set's size")
            ylabel("precision")

            z_galaxy=z(1,:);
            z_star=z(2,:);
            z_qso=z(3,:);
            %plot graphic
            figure;
            plot(1:length(z_galaxy), z_galaxy, 'b', 'LineWidth', 1.5);
            hold on;
            plot(1:length(z_star), z_star, 'r', 'LineWidth', 1.5);
            plot(1:length(z_qso), z_qso, 'g', 'LineWidth', 1.5);
            hold off;
            if use_gaussian_log==1
                title('Redshifts comparation per Classe(Using Gaussian Log');
            else
                title('Redshifts comparation per Classe(Without Gaussian Log)');
            end
            xlabel('Results');
            ylabel('Redshift (z)');
            legend('Galaxy', 'Star', 'QSO');
            grid on;

            vd_galaxy=vd(1,:);
            vd_star=vd(2,:);
            vd_qso=vd(3,:);
            %plot graphic
            figure;
            plot(1:length(vd_galaxy), vd_galaxy, 'b', 'LineWidth', 1.5);
            hold on;
            plot(1:length(vd_star), vd_star, 'r', 'LineWidth', 1.5);
            plot(1:length(vd_qso), vd_qso, 'g', 'LineWidth', 1.5);
            hold off;
            if use_gaussian_log==1
                title('VelDisp comparation per Classe(Using Gaussian Log)');
            else
                title('VelDisp comparation per Classe(Without Gaussian Log)');
            end

            xlabel('Results');
            ylabel('VelDisp)');
            legend('Galaxy', 'Star', 'QSO');
            grid on;
        end

        function [results]=testBloonFilter(obj,numOfTests)
            %test insertion
            %test false positives and search

        end
        function display(obj,x,y,t,labelX,labelY)
            figure;
            plot(x,y,'b','LineWidth',1.5);
            title(t);
            xlabel(labelX);
            ylabel(labelY);
            grid on;
        end
        function [filter]=bloonFilterInit(obj,amount_of_data,path)
            filter=BloomFilter();
            filter=filter.getAllData(amount_of_data,path);
        end
        function displayFakePositivesInserts(obj,amount_of_data,path,numElemInsert,n,numSearches)
            % num inserts
            x=1:numElemInsert;
            y=zeros(1,numElemInsert);

            k = round(n * log(2) / amount_of_data); % Optimal k formula
            k = max(1, k);

            filterTestInserts=obj.bloonFilterInit(amount_of_data,path);
            for i=1:length(x)
                filterTestInserts=filterTestInserts.initializeDataStructure(n);
                filterTestInserts=filterTestInserts.defineParams(k);
                indxs = randi([1, 50000], 1, i);
                for j=1:i
                    filterTestInserts=filterTestInserts.addElement(indxs(j));
                end
                sndxs = randi([50001, 100000], 1, numSearches);
                for a=1:numSearches
                    fk=filterTestInserts.isFakePositive(sndxs(a));
                    if (fk==true)
                        y(i)=y(i)+1;
                    end
                end
            end
            
            obj.display(x,y,"False Positives vs Number of Inserts","Number of Inserts","False Positives");
        end

        function displayFakePositiveSize(obj,amount_of_data,path,n,numElemInsert,numSearches)
            %size
            x=1:n;
            y=zeros(1,n);

            filterTestSize=obj.bloonFilterInit(amount_of_data,path);
            for i=1:n
                filterTestSize=filterTestSize.initializeDataStructure(i);
                k_i = max(1, round(i * log(2) / numElemInsert));  % k proporcional ao tamanho atual
                filterTestSize=filterTestSize.defineParams(k_i);
        
                indxs = randi([1, 100000], 1, numElemInsert);
                for j=1:numElemInsert
                    filterTestSize=filterTestSize.addElement(indxs(j));
                end
                sndxs = randi([1, 100000], 1, numSearches);
                for a=1:numSearches
                    fk=filterTestSize.isFakePositive(sndxs(a));
                    if (fk==true)
                        y(i)=y(i)+1;
                    end
                end
            end
            obj.display(x,y,"False Positives vs Filter Size","Filter Size","False Positives"); 
        end

        function displayFakePositivesHashes(obj,amount_of_data,path,numK,n,numElemInsert,numSearches)
            %num hashes
            x=1:numK;
            y=zeros(1,numK);

            filterTestHashes=obj.bloonFilterInit(amount_of_data,path);
            for i=1:numK
                filterTestHashes=filterTestHashes.initializeDataStructure(n);
                filterTestHashes=filterTestHashes.defineParams(i);
        
                indxs = randi([1, 100000], 1, numElemInsert);
                for j=1:numElemInsert
                    filterTestHashes=filterTestHashes.addElement(indxs(j));
                end
                sndxs = randi([1, 100000], 1, numSearches);
                for a=1:numSearches
                    fk=filterTestHashes.isFakePositive(sndxs(a));
                    if (fk==true)
                        y(i)=y(i)+1;
                    end
                end
            end
            obj.display(x,y,"False Positives vs Number of Hashes (k)","k","False Positives"); 
        end

        function [results]=testMinHash(obj,numOfTests)
            
        end

        function showStatisticsNaiveBayes(obj,title,results,times,t,z,vd)
            z_galaxy=z(1,:);
            z_star=z(2,:);
            z_qso=z(3,:);

            vd_galaxy=vd(1,:);
            vd_star=vd(2,:);
            vd_qso=vd(3,:);
    
            disp("===============Results-Naive_bayes================")
            disp("=============="+title+"==================")
            disp("Distribution")
            disp("      ->Galaxies:"+(t.distribution(1)/length(results))*100+"%")
            disp("      ->Star:"+(t.distribution(2)/length(results))*100+"%")
            disp("      ->Quasar:"+(t.distribution(3)/length(results))*100+"%")
            disp("AVG Accuracy:"+sum(results)/length(results))
            disp("AVG Processing Time:"+sum(times)/length(times));
            disp("AVG redshifts:")
            disp("      ->Galaxy:"+sum(z_galaxy)/length(z_galaxy))
            disp("      ->Star:"+sum(z_star)/length(z_star))
            disp("      ->Quasar:"+sum(z_qso)/length(z_qso))
            disp("AVG VelDisp:")
            disp("      ->Galaxy:"+sum(vd_galaxy)/length(vd_galaxy))
            disp("      ->Star:"+sum(vd_star)/length(vd_star))
            disp("      ->Quasar:"+sum(vd_qso)/length(vd_qso))
            disp("==================================================")
        end

        function showStatisticsBloomFilter(obj,n,k,occupancy,fakePositives,negativesTested,numElemInsert)
            disp("===============Results================")
            disp("Occupancy:"+occupancy*100+"%")
            disp("False Positives:"+fakePositives)
            disp("False Positive Rate(observed):"+fakePositives/negativesTested *100)
            disp("False Positive Rate(theoretical):"+((1 - exp(-k * numElemInsert / n))^k)*100)
            disp("======================================")
        end
    end
end