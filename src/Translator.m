classdef Translator
    properties
        data
        finalData
    end
    methods
        function obj=Translator(data)
            %filter for Naive_Bayes classifier calculation 
            obj.data = data(:, [ ...
                "class", ...            %class
                "z", ...                %redshift
                "spectroFlux_u", ...    %ultraviolet
                "spectroFlux_g", ...    %blue or violette
                "spectroFlux_r", ...    %red
                "spectroFlux_i", ...    %high infra-red
                "spectroFlux_z", ...    %low infra-red
                "velDisp", ...          %dispersion level
                ]);
            obj.finalData=table();
        end

        %objective: obtain the quartis for z
        function [quartizRedshift]=redshiftQuartiz(obj)
            quartizRedshift=quantile(obj.data{:,"z"},[1/3 2/3]);
        end

        %objective: average for VelpDisp
        function [verlpDispAverage]=velpDispAverage(obj)
            verlpDispAverage=sum(obj.data{:,"velDisp"})/length(obj.data{:,"z"});
        end

        %objective: filter the spectrum
        function [translatedSpectrum]=translateSpectrum(obj,column)
            if ~ismember(column,obj.data.Properties.VariableNames)
                disp("Column doesn't exists");
                return
            end
            numQuartiz=50;
            division=zeros(1,numQuartiz-1);
            for i=1:numQuartiz-1
                division(i)=i/numQuartiz;
            end
            translatedSpectrum=quantile(obj.data{:,column},division); 
        end

        function obj=buildTranslatedTabel(obj) 

            qz = obj.redshiftQuartiz();

            qu = obj.translateSpectrum("spectroFlux_u");
            qg = obj.translateSpectrum("spectroFlux_g");
            qr = obj.translateSpectrum("spectroFlux_r");
            qi = obj.translateSpectrum("spectroFlux_i");
            qz2 = obj.translateSpectrum("spectroFlux_z");
            v  = obj.velpDispAverage();
            
            z=discretize(obj.data.z,[-Inf qz Inf]);
            spectroU=discretize(obj.data.spectroFlux_u,[-Inf qu Inf]);
            spectroG=discretize(obj.data.spectroFlux_g,[-Inf qg Inf]);
            spectroR=discretize(obj.data.spectroFlux_r,[-Inf qr Inf]);
            spectroI=discretize(obj.data.spectroFlux_i,[-Inf qi Inf]);
            spectroZ=discretize(obj.data.spectroFlux_z,[-Inf qz2 Inf]);
            velDisp=discretize(obj.data.velDisp,[-Inf v Inf]);
            
            obj.finalData=table( ...
                obj.data.class, ...
                z, ...
                spectroU, ...
                spectroG, ...
                spectroR, ...
                spectroI, ...
                spectroZ, ...
                velDisp, ...
                'VariableNames', { ...
                    'class', ...
                    'redshift', ...
                    'spectroFlux_u', ...
                    'spectroFlux_g', ...
                    'spectroFlux_r', ...
                    'spectroFlux_i', ...
                    'spectroFlux_z', ...
                    'velDisp'
                });
        end
    end
end