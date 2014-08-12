classdef CycleCollection
   
    
   properties
       angles;
       footPos;
       numCycs;
       isPlottable = 1;
       
       
       
   end
    
   methods
       function cycs = CycleCollection(cycle,cyclesBefore,cyclesAfter)
           cycs.angles = [];
           cycs.footPos = [];
           cycs.numCycs = cyclesBefore + 1 + cyclesAfter;
           
           
           
           currentCycle = cycle;
           
           
           
           for i = 0:cyclesBefore
               if isempty(currentCycle.Prev)
                   cycs.isPlottable = 0;
                   return;
               else
                currentCycle = currentCycle.Prev;
               end
           end
           
           
           
           for i = 0:cycs.numCycs
               if isempty(currentCycle)
                   cycs.isPlottable = 0;
                   break;
               end
               cycs.angles = [cycs.angles, currentCycle.angles];
               cycs.footPos = [cycs.footPos, currentCycle.footPos];
               currentCycle = currentCycle.Next;
           end
           
       end
       
       
   end
   
   methods (Access = private)
       function checkCycs(cycs,cycle)
            
           
           currentCycle = cycle;
           for i = 0:cyclesBefore
               if isempty(currentCycle.Prev)
                   cycs.isPlottable = 0;
                   return;
               else
                currentCycle = currentCycle.Prev;
               end
           end
    
    
    
end