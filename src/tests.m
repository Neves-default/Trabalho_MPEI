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
            naiveBayesAlgorithm=Naive_Bayes(learningSet,sizeFilter,1);
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

        function testAccuracyTest(obj)
            clear; clc;

            fprintf('=================================================================\n');
            fprintf('       COMMENCING DETAILED MINHASH MATHEMATICAL PRECISION TEST   \n');
            fprintf('=================================================================\n\n');

            % 1. Create a perfectly calibrated 8-feature dataset (1 Class + 7 Metrics)
            % Ground Truth Context: Total Universal Features = 8
            classData = categorical({ ...
                'GALAXY'; ... % Object 1: Base Baseline Object
                'GALAXY'; ... % Object 2: 100% Exact Clone of Object 1
                'GALAXY'; ... % Object 3: 75% overlap with Object 1 (Matches 6 out of 8)
                'GALAXY'; ... % Object 4: 50% overlap with Object 1 (Matches 4 out of 8)
                'GALAXY'; ... % Object 5: 25% overlap with Object 1 (Matches 2 out of 8)
                'STAR';   ... % Object 6: Baseline for class column categorical test
                'QSO'         % Object 7: Completely disparate data profiles (0% match)
                });

            matrixData = [ ...
                1, 10, 20, 30, 40, 50, 5;   % Object 1: Baseline [101, 210, 320, 430, 540, 650, 705]
                1, 10, 20, 30, 40, 50, 5;   % Object 2: 100% Identical to 1
                1, 10, 20, 30, 40, 99, 9;   % Object 3: Matches Obj 1 in 6/8 positions (Dist = 0.40)
                1, 10, 20, 99, 99, 99, 9;   % Object 4: Matches Obj 1 in 4/8 positions (Dist = 0.6667)
                1, 10, 99, 99, 99, 99, 9;   % Object 5: Matches Obj 1 in 2/8 positions (Dist = 0.8571)
                3, 25, 35, 45, 11, 12, 8;   % Object 6: Secondary baseline for independent pair matching
                9, 99, 99, 99, 99, 99, 9    % Object 7: Strikingly isolated profiles
                ];

            testTable = table(classData, matrixData(:,1), matrixData(:,2), matrixData(:,3), ...
                matrixData(:,4), matrixData(:,5), matrixData(:,6), matrixData(:,7), ...
                'VariableNames', {'class', 'redshift', 'spectroFlux_u', ...
                'spectroFlux_g', 'spectroFlux_r', 'spectroFlux_i', ...
                'spectroFlux_z', 'velDisp'});

            % 2. Setup Test Scenarios
            % We run two separate evaluations to assess how your class thresholds adapt.
            k_hash_functions = 1000; % Higher k dramatically reduces the statistical variance

            % --- TEST 1: Loose Threshold (Should capture high and medium similarity) ---
            threshold_loose = 0.45;
            fprintf('-> [RUN 1] Executing with loose threshold (Dist <= %.2f)...\n', threshold_loose);
            minhashLoose = MinHash(testTable, threshold_loose, k_hash_functions);

            % --- TEST 2: Strict Threshold (Should ONLY capture perfect or near-perfect matches) ---
            threshold_strict = 0.05;
            fprintf('-> [RUN 2] Executing with strict threshold (Dist <= %.2f)...\n\n', threshold_strict);
            minhashStrict = MinHash(testTable, threshold_strict, k_hash_functions);


            % 3. Evaluate Results against Exact Analytical Jaccard Metrics
            % We define the exact mathematical targets:
            expectedPairs = [ ...
                1, 2, 0.0000, threshold_loose; ...  % Obj 1 & 2 match 8/8 cols. Intersection=8, Union=8. Dist = 1 - 8/8 = 0.0
                1, 3, 0.4000, threshold_loose; ...  % Obj 1 & 3 match 6/8 cols. Intersection=6, Union=10. Dist = 1 - 6/10 = 0.40
                1, 4, 0.6667, 999.0;           ...  % Obj 1 & 4 match 4/8 cols. Dist = 1 - 4/12 = 0.6667 (Above threshold)
                1, 5, 0.8571, 999.0                 % Obj 1 & 5 match 2/8 cols. Dist = 1 - 2/14 = 0.8571 (Above threshold)
                ];

            fprintf('=================================================================\n');
            fprintf('                 EMPIRICAL ACCURACY SCORECARD                    \n');
            fprintf('=================================================================\n');

            % Evaluate Loose Pass
            loosePairs = minhashLoose.identical;
            fprintf('\n[LOOSE RUN DETECTIONS] Found %d matching candidate pairs.\n', size(loosePairs,1));

            for p = 1:size(expectedPairs,1)
                i = expectedPairs(p, 1);
                j = expectedPairs(p, 2);
                trueDist = expectedPairs(p, 3);
                threshLimit = expectedPairs(p, 4);

                % Search if this pair exists in the loose output matrix
                matchIdx = (loosePairs(:,1) == i & loosePairs(:,2) == j) | (loosePairs(:,1) == j & loosePairs(:,2) == i);

                if any(matchIdx)
                    estDist = loosePairs(matchIdx, 3);
                    absError = abs(trueDist - estDist);
                    fprintf('  • Pair [%d, %d]: CAUGHT! True Dist: %.4f | MinHash Est: %.4f | Error Margin: %.4f\n', ...
                        i, j, trueDist, estDist, absError);
                else
                    if trueDist <= threshold_loose
                        fprintf('  • Pair [%d, %d]: ❌ CRITICAL FAILURE! Missed a true matching pair.\n', i, j);
                    else
                        fprintf('  • Pair [%d, %d]: SAFE. Correctly excluded (Distance %.4f exceeds %.2f threshold).\n', ...
                            i, j, trueDist, threshold_loose);
                    end
                end
            end

            % Evaluate Strict Pass
            strictPairs = minhashStrict.identical;
            fprintf('\n[STRICT RUN DETECTIONS] Found %d matching candidate pairs.\n', size(strictPairs,1));
            if size(strictPairs, 1) == 1 && strictPairs(1,1) == 1 && strictPairs(1,2) == 2
                fprintf('  • Strict Threshold Test: ✅ PASS! Successfully isolated ONLY the 100%% identical pair.\n');
            else
                fprintf('  • Strict Threshold Test: ❌ FAIL! Included pairs that exceed the strict threshold boundaries.\n');
            end
            fprintf('=================================================================\n');
        end

        function [k, pairs, trueSims, estSims, k_values, mean_errors]=testMinHash(obj)
            % ============================================================
            %  Gráfico 1: Similaridade Real vs Estimada
            %  Gráfico 2: Erro vs Número de Hashes
            % ============================================================

            % --- Dataset de teste ---
            classData = categorical({ ...
                'GALAXY'; 'GALAXY'; 'GALAXY'; 'GALAXY'; 'GALAXY'; 'STAR'; 'QSO' ...
                });
            matrixData = [ ...
                1, 10, 20, 30, 40, 50, 5;
                1, 10, 20, 30, 40, 50, 5;
                1, 10, 20, 30, 40, 99, 9;
                1, 10, 20, 99, 99, 99, 9;
                1, 10, 99, 99, 99, 99, 9;
                3, 25, 35, 45, 11, 12, 8;
                9, 99, 99, 99, 99, 99, 9
                ];
            testTable = table(classData, ...
                matrixData(:,1), matrixData(:,2), matrixData(:,3), ...
                matrixData(:,4), matrixData(:,5), matrixData(:,6), matrixData(:,7), ...
                'VariableNames', {'class','redshift','spectroFlux_u','spectroFlux_g', ...
                'spectroFlux_r','spectroFlux_i','spectroFlux_z','velDisp'});

            % --- Similaridades reais (Jaccard) para todos os pares ---
            % Calculadas analiticamente com base no dataset acima
            % Par (i,j) -> distância real conhecida
            pairs     = [1,2; 1,3; 1,4; 1,5; 1,6; 1,7; 2,3; 2,4; 2,5; 3,4];
            trueDists = [0.0; 0.4; 0.6667; 0.8571; 1.0; 1.0; 0.4; 0.6667; 0.8571; 0.5];
            trueSims  = 1 - trueDists;

            % ============================================================
            %  GRÁFICO 1: Similaridade Real vs Estimada  (k fixo = 500)
            % ============================================================
            k_fixed = 500;
            mh = MinHash(testTable, 1.0, k_fixed);   % threshold=1 para capturar todos os pares
            sigs = mh.signatures;

            n_pairs = size(pairs, 1);
            estSims = zeros(n_pairs, 1);
            for p = 1:n_pairs
                i = pairs(p,1);
                j = pairs(p,2);
                estSims(p) = sum(sigs(i,:) == sigs(j,:)) / k_fixed;
            end

            figure('Name','MinHash — Similaridade Real vs Estimada','NumberTitle','off');
            hold on;
            scatter(trueSims, estSims, 80, 'filled', 'MarkerFaceColor','#0072BD');
            % Linha de referência perfeita
            plot([0 1],[0 1],'r--','LineWidth',1.5,'DisplayName','Estimativa perfeita');
            xlabel('Similaridade Real (Jaccard)');
            ylabel('Similaridade Estimada (MinHash)');
            title(sprintf('Similaridade Real vs Estimada  (k = %d)', k_fixed));
            legend({'Pares observados','Estimativa perfeita'},'Location','northwest');
            grid on; xlim([-0.05 1.05]); ylim([-0.05 1.05]);
            hold off;

            % ============================================================
            %  GRÁFICO 2: Erro médio vs Número de Hashes (k)
            % ============================================================
            k_values   = [10, 25, 50, 100, 200, 500, 1000];
            mean_errors = zeros(size(k_values));

            for ki = 1:length(k_values)
                k = k_values(ki);
                mh_k = MinHash(testTable, 1.0, k);
                sigs_k = mh_k.signatures;

                errors = zeros(n_pairs, 1);
                for p = 1:n_pairs
                    i = pairs(p,1);
                    j = pairs(p,2);
                    estSim_k = sum(sigs_k(i,:) == sigs_k(j,:)) / k;
                    errors(p) = abs(trueSims(p) - estSim_k);
                end
                mean_errors(ki) = mean(errors);
            end

            figure('Name','MinHash — Erro vs Número de Hashes','NumberTitle','off');
            semilogx(k_values, mean_errors, 'o-', ...
                'LineWidth', 2, 'MarkerSize', 7, ...
                'Color','#D95319', 'MarkerFaceColor','#D95319');
            xlabel('Número de Funções de Hash (k)  [escala log]');
            ylabel('Erro Médio Absoluto');
            title('Erro Médio da Estimativa vs Número de Hashes');
            grid on;
            xticks(k_values);
            xticklabels(arrayfun(@num2str, k_values, 'UniformOutput', false));
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

        function showStatisticsMinHash(obj,k, pairs, trueSims, estSims, k_values, mean_errors)
            disp("===============Results-MinHash================")
            disp("==========Configuration======================")
            disp("      ->K (Hash Functions): " + k)
            disp("      ->Total Pairs Tested: " + size(pairs, 1))
            disp("==========Similarity Results=================")
            for p = 1:size(pairs, 1)
                disp("      ->Pair [" + pairs(p,1) + ", " + pairs(p,2) + "]" + ...
                    "  Real: " + round(trueSims(p), 4) + ...
                    "  Est: "  + round(estSims(p),  4) + ...
                    "  Err: "  + round(abs(trueSims(p) - estSims(p)), 4))
            end
            disp("      ->AVG Error (k="+k+"): " + ...
                round(mean(abs(trueSims - estSims)), 4))
            disp("==========Error vs K=========================")
            for ki = 1:length(k_values)
                disp("      ->k=" + k_values(ki) + ...
                    "  AVG Error: " + round(mean_errors(ki), 4))
            end
            disp("==============================================")
        end
    end
end