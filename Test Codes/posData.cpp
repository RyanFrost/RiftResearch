
#include "posData.h"




posData::posData()
{
	movingForward = false;
	movingBackward = false;
	heelStrike = false;
	toeOff = false;
}

void update()
{
	
	
	while(true)
	{
		
		
		xf = sdata->foot_pos_x;
		//xmid = sdata->mid_stance_x;
		posVec.erase(posVec.begin());		// Removes first element from list
		posVec.push_back(xf);			// Adds current foot pos to end of list
		vecReverse(vec.rbegin(),vec.rend());
		
		if( is_sorted(posVec))
		{
			movingBackward = true;
			movingForward = false;
			heelStrike = false;
			toeOff = false;
		}
		else if( is_sorted(vecReverse))
		{
			movingForward = true;
			movingBack = false;
			heelStrike = false;
			toeOff = false;
		}
		else if ( isMaximum(posVec) )
		{
			heelStrike = true;
			movingForward = false;
			movingBackward = false;
			toeOff = false;
		}
		else if ( isMinimum(posVec) )
		{
			toeOff = true;
			heelStrike = false;
			movingForward = false;
			movingBackWard = false;
		}
		else
		{
			toeOff = false;
			heelStrike = false;
			movingForward = false;
			movingBackWard = false;
		}
		
	}
	
}