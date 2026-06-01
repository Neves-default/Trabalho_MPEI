% To classify a given object the system will guess using the follow data:
% -> redshift: the main divider:
%               -> Is higher in quasars and almost irrelevant to stars
% -> several zones of the spectro
%               -> This zones of the spectro is what it was used to know
%               what object it is. This makes a signatura of the object
%               -> We will teach the system to read this spectro and
%               identify what is the mosto probable object type(class)
%               using Naive Bayes


% Caracteristics
% -> Stars
%   -> Hot Stars
%       -> emits more blue and ultraviolette radiation
%   -> Cold Stars
%       -> emits more red and infra-red radiation
%   -> redshift is not relevant here because it transmits not enougth light

% -> Galaxies
%   -> Galaxies depends on the number of solar systems and stars inside it
%       -> If there's a few solar systems or multiples red stars(colder)
%           -> emits more red and infra-red radiation
%       -> else
%           -> emits more blue and ultraviolette radiation
%   -> redshift here is basically the sum of all redsifts emited by the 
%   multiple stars inside it so it is higher but not that much

% -> Quasars
%   -> This are the most luminous objects in the universe. Probably nowdays
%   this fenomeno does not exists once the closest that we have discover is
%   at 780 milion l.y from earth
%   -> It has a strong and caothic emission
%   -> redshift very high
classdef Naive_Bayes < handle
    properties
        DataSet
        Data
        %learning data
        Prob_Class
        AvgPerClass
        DeviationPerClass
    end
    methods
        function obj=Naive_Bayes(data)
            %filter for Naive_Bayes classifier calculation 
            %obj.DataSet = data(:, [ ...
            %    "class", ...            %class
            %    "z", ...                %redshift
            %    "spectroFlux_u", ...    %ultraviolet
            %    "spectroFlux_g", ...    %blue or violette
            %    "spectroFlux_r", ...    %red
            %    "spectroFlux_i", ...    %high infra-red
            %    "spectroFlux_z", ...    %low infra-red
            %    "velDisp", ...          %dispersion level
            %    "snMedian_r" ...        %precision
            %    ]);
            obj.DataSet=data;
        end
      
        %here will be the function to analyse the spectrum 
        % vector=[flux_u, flux_g, flux_r, flux_i, flux_z]        
        % after comparation-> vector=(i-z , r-i , g-r , u-g)
        function [diferences]=compareSpectros(obj,spectro)
            diferences = zeros(size(spectro,1),4);

	    u = max(spectro(:,1), eps);
    	    g = max(spectro(:,2), eps);
    	    r = max(spectro(:,3), eps);
    	    i = max(spectro(:,4), eps);
    	    z = max(spectro(:,5), eps);

    	    diferences(:,1) = -2.5 * log10(u ./ g); % u-g
    	    diferences(:,2) = -2.5 * log10(g ./ r); % g-r
    	    diferences(:,3) = -2.5 * log10(r ./ i); % r-i
    	   diferences(:,4) = -2.5 * log10(i ./ z); % i-z
        end
        
        %here we will join everything and buil the feature table, where the
        %Naive Bayes algorithm will learn to classify the objects though
        %their spectro
        function obj=buildFeature(obj)
            %first get each flux data from the dataSet
            u=obj.DataSet.spectroFlux_u;
            g=obj.DataSet.spectroFlux_g;
            r=obj.DataSet.spectroFlux_r;
            i=obj.DataSet.spectroFlux_i;
            z=obj.DataSet.spectroFlux_z;

            %then build the spectral matrix
            spectro=[
                u ...
                g ...
                r ...
                i ...
                z 
            ];
            %analyse the spetros
            colorFeatures=obj.compareSpectros(spectro);

            %build the feature data table
            obj.Data=table( ...
                obj.DataSet.class, ...
                obj.DataSet.z, ...
                colorFeatures(:,1), ...
                colorFeatures(:,2), ...
                colorFeatures(:,3), ...
                colorFeatures(:,4), ...
                obj.DataSet.velDisp, ...
                obj.DataSet.snMedian_r, ...
                'VariableNames', { ...
                    'class', ...
                    'redshift', ...
                    'u_g', ...
                    'g_r', ...
                    'r_i', ...
                    'i_z', ...
                    'velDisp', ...
                    'snMedian_r' ...
            });
            
            %removes the values that aren't valid
            obj.Data = rmmissing(obj.Data);
            obj.Data = obj.Data(all(isfinite(obj.Data{:,2:end}),2), :);
        end
        
        % The Naive Bayes Algorithm is basically this
        % calculates each probability(P(x|C)(x -> set of feature, C -> Class)) and
        % then he choose the class that has the highest probability
        
        % to obtain P(x|C) we must multiply each the probabily of each feature belongs to that class(P(xi|C)) and P(C)
        % P(x|C)=TT(P(xi|C))*P(C)

        %Obtains the occurence of each class
        function obj=getEachClassesData(obj)    
            classes_data=obj.Data.class;
            classes=unique(classes_data);
            probs=zeros(length(classes),1);
            for i=1:length(classes)
                occurs=sum(strcmp(classes_data,classes(i)));
                probs(i) = occurs/length(classes_data);
            end

            obj.Prob_Class=probs;
        end

        % for calculating P(xi|C) we will use two diferents gaussian formula 
        % P(xi|C)=1/sqrt(2πσ²)*​e^((x−μ)²/2σ²)
        % P(xi|C)= -0.5*log(2πσ²)-((x−μ)²/2σ²)
        % the first we need to multiply everything and the second is sum
        % every probability and then multiply by the probability of belong
        % to the class
        % where σ is the standart deviation
        % μ is the average
        % x is a feature
        % C is a class
        % AVG=(redshift , u_g , g_r , r_i , i_z , velDisp , snMedian_r)
        function obj=Average(obj)
            classes=unique(obj.Data.class);
            for i=1:length(classes)
                filter=obj.Data(strcmp(obj.Data.class,classes(i)), :);
                obj.AvgPerClass(i,1)=sum(filter.redshift)/length(filter.redshift);
                obj.AvgPerClass(i,2)=sum(filter.u_g)/length(filter.redshift);
                obj.AvgPerClass(i,3)=sum(filter.g_r)/length(filter.redshift);
                obj.AvgPerClass(i,4)=sum(filter.r_i)/length(filter.redshift);
                obj.AvgPerClass(i,5)=sum(filter.i_z)/length(filter.redshift);
                obj.AvgPerClass(i,6)=sum(filter.velDisp)/length(filter.redshift);
                obj.AvgPerClass(i,7)=sum(filter.snMedian_r)/length(filter.redshift);
            end
        end
        %we can use here the function std which give us exacly tha same
        function obj=StandartDeviation(obj)
            classes=unique(obj.Data.class);
            for i=1:length(classes)
                filter=obj.Data(strcmp(obj.Data.class,classes(i)), :);
                obj.DeviationPerClass(i,1)=sqrt(sum((filter.redshift-obj.AvgPerClass(i,1)).^2)/length(filter.redshift));
                obj.DeviationPerClass(i,2)=sqrt(sum((filter.u_g-obj.AvgPerClass(i,2)).^2)/length(filter.redshift));
                obj.DeviationPerClass(i,3)=sqrt(sum((filter.g_r-obj.AvgPerClass(i,3)).^2)/length(filter.redshift));
                obj.DeviationPerClass(i,4)=sqrt(sum((filter.r_i-obj.AvgPerClass(i,4)).^2)/length(filter.redshift));
                obj.DeviationPerClass(i,5)=sqrt(sum((filter.i_z-obj.AvgPerClass(i,5)).^2)/length(filter.redshift));
                obj.DeviationPerClass(i,6)=sqrt(sum((filter.velDisp-obj.AvgPerClass(i,6)).^2)/length(filter.redshift));
                obj.DeviationPerClass(i,7)=sqrt(sum((filter.snMedian_r-obj.AvgPerClass(i,7)).^2)/length(filter.redshift));
            end
        end

        function [class]=estimateClass(obj,tuple,useLog)
            %first get each flux data from the dataSet
            u=tuple.spectroFlux_u;
            g=tuple.spectroFlux_g;
            r=tuple.spectroFlux_r;
            i=tuple.spectroFlux_i;
            z=tuple.spectroFlux_z;

            %then build the spectral matrix
            spectro=[
                u ...
                g ...
                r ...
                i ...
                z 
            ];
            %analyse the spetros
            colorFeatures=obj.compareSpectros(spectro);

            featureTuple=table( ...
                tuple.z, ...%redshift, ...
                colorFeatures(:,1), ...
                colorFeatures(:,2), ...
                colorFeatures(:,3), ...
                colorFeatures(:,4), ...
                tuple.velDisp, ...
                tuple.snMedian_r, ...
                'VariableNames', { ...
                    'redshift', ...
                    'u_g', ...
                    'g_r', ...
                    'r_i', ...
                    'i_z', ...
                    'velDisp', ...
                    'snMedian_r' ...
            });
            %calculate probs
            prob=ones(1,length(obj.Prob_Class));
            %log gaussian
            for i=1:length(obj.Prob_Class)
                for j=1:7
                    x = featureTuple{1,j};
                    mu = obj.AvgPerClass(i,j);
                    sigma = obj.DeviationPerClass(i,j);
                    % avoids division by 0
                    if sigma == 0
                        sigma = 1e-6;
                    end
                    if (useLog==0)
                        gaussian = (1 / sqrt(2*pi*sigma^2)) * ...
                            exp(-((x - mu)^2) / (2*sigma^2));

                        prob(i) = prob(i) * gaussian;
                    else
                        % Gaussian log probability
                        gaussianLog = ...
                            -0.5*log(2*pi*sigma^2) ...
                            -((x - mu)^2)/(2*sigma^2);

                        prob(i) = prob(i) + gaussianLog;
                    end 
                end
                prob(i)=prob(i)*obj.Prob_Class(i);
            end
            %see the max
            [v, idx]=max(prob);
            classes=unique(obj.Data.class);
            class=classes(idx);
        end
    end
end

