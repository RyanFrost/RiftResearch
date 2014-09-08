classdef CycleAnalyzer
    
    properties
        
        cycleArray;

        type0;
        type1;
        type2;
        type3;
        
        colors;
    end
    
    
    methods
        
        function CA = CycleAnalyzer(cycArray)
            CA.cycleArray = cycArray;
            
            
            for i = 2:length(CA.cycleArray)
                cycArray(i).insertAfter(CA.cycleArray(i-1));
            end
                
                
            CA.type0 = findobj(CA.cycleArray,'perturbType',0);
            CA.type1 = findobj(CA.cycleArray,'perturbType',1);
            CA.type2 = findobj(CA.cycleArray,'perturbType',2);
            CA.type3 = findobj(CA.cycleArray,'perturbType',3);
            
            CA.colors = [0, 0, 0; 1, 0, 0; 0, 0, 1; 0, 0.7, 0];
            
        end
        
        function plotRaw(CA,cycsBefore,cycsAfter,pertType,legStr,jointStr)
            
            angleNum = CA.parseInputForPlotting(legStr,jointStr);
            
            xSpace = linspace(-100*cycsBefore,100*(1+cycsAfter),1000*(cycsBefore+1+cycsAfter))';
            
            hold on;
                     
            for type = 1:length(pertType)
                % This converts each value of pertType 
                % to a call to the same-named property
                % (e.g. 0 becomes CA.type0)
                perts = CA.(['type' num2str(pertType(type))]); 
                color = CA.colors(pertType(type)+1,:);
                cyclesCut = 0;
                for i = 1:length(perts)
                    currentCyc = perts(i);
                    
                    cycles = CycleCollection(currentCyc,cycsBefore,cycsAfter,length(CA.cycleArray));
                    
                    if cycles.isPlottable == 1
                        plot(xSpace,cycles.angles(:,angleNum),'Color', color,'DisplayName',num2str(cycles.mainCycNum));
                    else
                        cyclesCut = cyclesCut+1;
                    end
                    
                end
                disp([num2str(cyclesCut) ' samples were removed from the type ' num2str(pertType(type)) ' perturbations.']);
            end
            hold off;
            title(jointStr);
            grid on;
        end
        
        function plotMeanStd(CA,cycsBefore,cycsAfter,pertType,legStr,jointStr)
            
            angleNum = CA.parseInputForPlotting(legStr,jointStr);
            
            xSpace = linspace(-100*cycsBefore,100*(1+cycsAfter),1000*(cycsBefore+1+cycsAfter))';
            
            
            plotVariance = @(x,lower,upper,color,opacity) set(fill([x;x(end:-1:1)],[upper,lower(end:-1:1)]',color),'FaceAlpha',opacity);
            
            legendStrings = {'Unperturbed Gait', 'Perturbation with Visual Warning', 'Visual Warning, No Perturbation', 'Perturbation, No Visual Warning'};
            
            hold on;
                     
            for type = 1:length(pertType)
                % This converts each value of pertType 
                % to a call to the same-named property
                % (e.g. 0 becomes CA.type0)
                perts = CA.(['type' num2str(pertType(type))]); 
                color = CA.colors(pertType(type)+1,:);
                plottableCycs = [];
                cyclesCut = 0;
                for i = 1:length(perts)
                    currentCyc = perts(i);
                    
                    cycles = CycleCollection(currentCyc,cycsBefore,cycsAfter,length(CA.cycleArray));
                    
                    if cycles.isPlottable == 1
                        plottableCycs = [plottableCycs,cycles.angles(:,angleNum)];
                    else
                        cyclesCut = cyclesCut+1;
                    end
                end
                disp(size(diff(plottableCycs)));
                disp(size(plottableCycs'));
                meanPlot = mean(diff(plottableCycs),1);
                stdPlot = std(diff(plottableCycs),1);
                top = meanPlot+stdPlot;
                bottom = meanPlot-stdPlot;
                legendHandle(type) = plot(xSpace,meanPlot,'LineWidth',2,'Color',color);
                
                if pertType(type) == 0
                    set(legendHandle(type),'LineStyle','--');
                end
                plotVariance(xSpace,bottom,top,color,0.25);
                
                disp([num2str(size(plottableCycs,2)) ' of ' num2str(length(perts)) ' samples were used from the type ' num2str(pertType(type)) ' perturbations.']);
                
            end
            hold off;
            
            titleStr = regexprep([legStr ' ' jointStr], '(\<\w)','${upper($1)}'); % This capitalizes the first letter of each word
            title(titleStr, 'FontSize', 15);
            set(gca,'FontSize',12);
            set(gcf,'Units','Normalized');
            set(gcf,'Position', [0.05,0.05,0.5,0.5]);
            xlabel('Percent Gait Cycle', 'FontSize', 14);%,'FontAngle','italic');
            ylabel('Angle ({\circ})', 'FontSize', 14);%,'FontAngle','italic');
            legend(legendHandle, legendStrings(pertType+1), 'Location', 'Best');
            
            
            grid on;
            
        end
        
        
    end
    
    
    methods (Access = private)
        
        function angleNum = parseInputForPlotting(~, leg, jointStr)
            
            switch leg
                case 'left'
                    legMult = 0;
                case 'right'
                    legMult = 1;
                otherwise
                    disp('Err in CycleAnalyzer plot input -> leg must be either "left" or "right".');
            end
            
            switch jointStr
                case 'hip'
                    joint = 1;
                case 'knee'
                    joint = 2;
                case 'ankle'
                    joint = 3;
                otherwise
                    disp('Err in CycleAnalyzer plot input -> jointStr must be "hip", "knee", or "ankle".');
            end
            
            angleNum = legMult * 3 + joint;
            
        end
    end
    
    
    
    
    
    
    
    
    
    
end