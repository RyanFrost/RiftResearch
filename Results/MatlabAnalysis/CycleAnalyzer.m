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
                       %plot(xSpace,cycles.angles(:,angleNum),'Color',color,'DisplayName',num2str(cycles.mainCycNum)); 
                        plot(cycles.angles(:,angleNum),cycles.angVelocity(:,angleNum),'Color', color,'DisplayName',num2str(cycles.mainCycNum));
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
        
        function angss = plotMeanStd(CA,cycsBefore,cycsAfter,pertType,legStr,jointStr)
            
            angleNum = CA.parseInputForPlotting(legStr,jointStr);
            
            xSpace = linspace(-100*cycsBefore,100*(1+cycsAfter),1000*(cycsBefore+1+cycsAfter))';
            
            
            plotVariance = @(x,mean,std,color,opacity) set(fill([x;x(end:-1:1)],[(mean+std),fliplr(mean-std)]',color),'FaceAlpha',opacity);
            
            legendStrings = {'Unperturbed Gait', 'Perturbation with Visual Warning', 'Visual Warning, No Perturbation', 'Perturbation, No Visual Warning'};
            
            
      
            for type = 1:length(pertType)
                % This converts each value of pertType 
                % to a call to the same-named property
                % (e.g. 0 becomes CA.type0)
                perts = CA.(['type' num2str(pertType(type))]);
                color = CA.colors(pertType(type)+1,:);
                
                goodAngles = [];
                goodAngVel = [];

                for i = 1:length(perts)
                    currentCyc = perts(i);
                    
                    cycles = CycleCollection(currentCyc,cycsBefore,cycsAfter,length(CA.cycleArray));
                    
                    if cycles.isPlottable == 1
                        
                        goodAngles = [goodAngles,cycles.angles(:,angleNum)];
                        goodAngVel = [goodAngVel,cycles.angVelocity(:,angleNum)];
                    end
                end
                
                
                
                for cycle=1:size(goodAngles,1)
                    covmat(:,:,cycle)=cov(goodAngles(cycle,:),goodAngVel(cycle,:));
                    
                end
                

                meanAng = mean(goodAngles,2)';
                stdAng = std(goodAngles,0,2)';
                
                
                
                meanPlus = meanAng+stdAng;
                meanMinus= meanAng-stdAng;
                lowerVel = gradient(meanMinus,1.1583/1000);
                upperVel = gradient(meanPlus,1.1583/1000);
                angV = gradient(meanAng,1.1583/1000);
                [a,b] = butter(2,(6/1.1583)/500,'low');
                angV = filtfilt(a,b,angV);
                lowerVel=filtfilt(a,b,lowerVel);
                upperVel=filtfilt(a,b,upperVel);
                
                size(xSpace)
                size(goodAngles)
                angss(1,:,type) = meanAng';
                meanAngVel = mean(goodAngVel,2)';
                angss(2,:,type) = meanAngVel';
                stdAngVel = std(goodAngVel,0,2)';
       
                
                assignin('base',['meanAnglesJoint' num2str(angleNum) 'Type' num2str(pertType(type))], meanAng);
                assignin('base',['meanAngVelocityJoint' num2str(angleNum) 'Type' num2str(pertType(type))], meanAngVel);
                
                %reg = max(meanAng')
                %pol = max(meanAng'*(pi/180))
                
                %legendHandle(type) = polar(meanAng*(pi/180),meanAngVel);
                %(meanAngVel-min(meanAngVel)+10)
                %set(legendHandle(type),'Color',color,'LineWidth',2);
                
                %legendHandle(type) = plot(meanAng,meanAngVel,'LineWidth',2,'Color',color);
                legendHandle(type) = plot(xSpace,meanAng,'LineWidth',2,'Color',color);
                
                hold on;
                %plot(xSpace,angV,'LineWidth',1,'Color',color);
                for cycle=1:size(goodAngles,1)
                    %error_ellipse(squeeze(covmat(:,:,cycle)),meanAng(cycle),meanAngVel(cycle),color);
                end
                
                %plot(meanAng,angV,'LineWidth',1,'Color',color);
                %plot(meanPlus,upperVel,'Linewidth',1,'Color',color);
                %plot(meanMinus,lowerVel,'LineWidth',1,'Color',color);
                % Toeoff for left leg
                
                toeOffLocationsLeft = NaN(1,length(meanAngVel));
                toeOffLocationsLeft(cycles.toeOffLocsLeft) = meanAng(cycles.toeOffLocsLeft);
                %plot(xSpace,toeOffLocationsLeft,'kx','MarkerSize',30,'LineWidth',2);
                
                % Heelstrike for left leg
                
                heelStrikeLocationsLeft = NaN(1,length(meanAngVel));
                heelStrikeLocationsLeft(cycles.heelStrikeLocsLeft) = meanAng(cycles.heelStrikeLocsLeft);
                %plot(xSpace,heelStrikeLocationsLeft,'ko','MarkerSize',30,'LineWidth',2);
                
                % Toeoff for right leg
                toeOffLocationsRight = NaN(1,length(meanAngVel));
                toeOffLocationsRight(cycles.toeOffLocsRight) = meanAng(cycles.toeOffLocsRight);
                %plot(xSpace,toeOffLocationsRight,'rx','MarkerSize',30,'LineWidth',2);
                
                % Heelstrike for right leg
                heelStrikeLocationsRight = NaN(1,length(meanAngVel));
                heelStrikeLocationsRight(cycles.heelStrikeLocsRight) = meanAng(cycles.heelStrikeLocsRight);
                %plot(xSpace,heelStrikeLocationsRight,'ro','MarkerSize',30,'LineWidth',2);
                
                
                if pertType(type) == 0
                    set(legendHandle(type),'LineStyle','--');
                end
                %plotVariance(xSpace,meanAngVel,stdAngVel,color,0.25);
                plotVariance(xSpace,meanAng,stdAng,color,0.25);
                
                
                
                disp([num2str(size(goodAngles,2)) ' of ' num2str(length(perts)) ' samples were used from the type ' num2str(pertType(type)) ' perturbations.']);
                
            end
%             pertLineY = min(get(legendHandle(2),'YData'))-5;
%             plot([0,70],[pertLineY,pertLineY],'-m','LineWidth',5,'MarkerFaceColor','r','MarkerSize',18);
%             hold off;
            


            titleStr = regexprep([legStr ' ' jointStr], '(\<\w)','${upper($1)}'); % This capitalizes the first letter of each word
            title(titleStr, 'FontSize', 24);
            set(gca,'FontSize',24);
            set(gcf,'Units','Normalized');
            set(gcf,'Position', [0.05,0.05,0.8,0.8]);
            xlabel('Joint Angle ({\circ})', 'FontSize', 24);%,'FontAngle','italic');
            ylabel('Angular Velocity ( {\circ}/sec)', 'FontSize', 24);%,'FontAngle','italic');
            %ylabel('Angular Velocity ( {\circ}/sec)', 'FontSize', 14);
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
                case 'sum'
                    joint = 0;
                otherwise
                    disp('Err in CycleAnalyzer plot input -> jointStr must be "hip", "knee", or "ankle".');
            end
            
            if joint == 0
                angleNum = 7 + legMult;
            else
                angleNum = legMult * 3 + joint;
            end
        end
    end
    
    
    
    
    
    
    
    
    
    
end