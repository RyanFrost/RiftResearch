classdef CycleCollection
    
    
    properties
        angles;
        footPos;
        numCycs;
        isPlottable = 1;
        
        
        
    end
    
    methods
        function cycs = CycleCollection(cycle,cyclesBefore,cyclesAfter,totalCyclesInExperiment)
            
            if cycle.cycleNum - cyclesBefore < 2 || cycle.cycleNum + cyclesAfter > totalCyclesInExperiment
                cycs.isPlottable = 0;
                return
            end
            
            cycs.angles = [];
            cycs.footPos = [];
            cycs.numCycs = cyclesBefore + 1 + cyclesAfter;
            
            
            
            currentCycle = cycle;
            
            % navigate to first cycle in sequence to plot
            for i = 1:cyclesBefore
                currentCycle = currentCycle.Prev;
            end
            
            % append data for each cycle to the end of the sequence
            for i = 1:cycs.numCycs
                
                % if this cycle has lots of NaNs, discard entire cycle
                % collection
                if currentCycle.lowNaNs == 0
                    cycs.isPlottable = 0;
                    break;
                end
                
                
                cycs.angles = [cycs.angles, currentCycle.angles];
                cycs.footPos = [cycs.footPos, currentCycle.footPos];
                if i ~= cycs.numCycs
                    currentCycle = currentCycle.Next; % advance to next cycle if not at end
                end
            end
            
            
            
        end
        
        
    end
    
end