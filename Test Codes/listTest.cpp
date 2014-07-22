#include <cmath>
#include <stdio.h>
#include <iostream>
#include <vector>
#include <algorithm>

#define PI 3.14159265

using namespace std;



int main()
{
	
	bool is_sorted(vector<double>);
	bool goneForward = true;
	bool goneBackward = true;
	double xf = 0;
	vector<double> pastVals(20, 0);
	vector<double> pastValsSmall(5,0);

	
	
	for (int i = 0; i<512; i++)
	{
		
		xf = sin(double(i)*PI/128);
		pastVals.erase(pastVals.begin());		// Adds current foot pos to front of list
		pastVals.push_back(xf);			// Removes last element from list
		
		for (int iter = 0; iter < pastValsSmall.size(); iter++)
		{
			pastValsSmall[iter] = pastVals[iter*pastVals.size()/pastValsSmall.size()];
		}
		
		//pastVals.size()/10
		
		
		//pastValsSpread[listPos] = pastVals(listPos);
		//fprintf(stdout,"sin(%f) = %f", (double(i)*PI/128),xf);
		
		if (is_sorted(pastValsSmall) && goneBackward)
		{
			fprintf(stdout,"Moving backwards!\n");
			goneForward = true;
			goneBackward = false;
		}
		
		else 
		{
			vector<double> vecReverse(pastValsSmall.rbegin(),pastValsSmall.rend());
			
			if (is_sorted( vecReverse ) && goneForward)
			{
				
				fprintf(stdout,"Moving forwards!\n");
				goneBackward = true;
				goneForward = false;
			}
		}
		
	}	
	
		//fprintf(stdout,"%f\n",xf);
	
	return 0;
}


bool is_sorted(vector<double> vec)
{
	for (int vecIter = 0; vecIter < vec.size()-1; vecIter++)
	{
		if ( vec[vecIter] > vec[vecIter+1] )
		{
			return false;
		}
	}
	return true;
}
