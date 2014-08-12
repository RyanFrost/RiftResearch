classdef CycleAnalyzer
    
    properties
        
        cycleArray;
        
        type0;
        type1;
        type2;
        type3;
        
        
    end
    
    
    methods
        
        function CA = CycleAnalyzer(cycArray)
            CA.cycleArray = cycArray;
            
            
            for i = 2:length(CA.cycleArray)
                CA.cycleArray(i).insertAfter(CA.cycleArray(i-1));
            end
                
                
            CA.type0 = findobj(CA.cycleArray,'perturbType',0);
            CA.type1 = findobj(CA.cycleArray,'perturbType',1);
            CA.type2 = findobj(CA.cycleArray,'perturbType',2);
            CA.type3 = findobj(CA.cycleArray,'perturbType',3);
        end
        
        function plotRaw(CA,cycsBefore,cycsAfter)
            
            xSpace = linspace(-100*cycsBefore,100*(1+cycsAfter),1000*(cycsBefore+1+cycsAfter));
            
            hold on;
                     
            
            for i = 1:length(CA.type0)
                currentCyc = CA.type0(i);
                
                cycles = CycleCollection(currentCyc,cycsBefore,cycsAfter);
                if cycles.isPlottable == 1
                    plot(xSpace,cycles.angles(3,:));
                end
            end
            hold off;
        end
        
        function plotMeanStd(CA,type,joint)
            
            
            
            
        end
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
end