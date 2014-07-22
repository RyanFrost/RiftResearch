


#include <iostream>
#include <cstdio>
#include <vector>

using namespace std;




int main()
{
	
	bool isHeelStrike(vector<double>);
	
	double myDubs[] = { 1.0, 2.5, 3.0, 2.9, 2.6 };
	vector<double> vec (myDubs, myDubs +sizeof(myDubs)/sizeof(double));

	
	printf("size: %i, size/2: %i\n", vec.size(), vec.size()/2);
	
	cout << isHeelStrike(vec) << "\n";
	
	
	return 0;
}


bool isHeelStrike(vector<double> posVec)
{
	
	
	int mid = posVec.size()/2;
	
	for (int vecIter = 0; vecIter < mid; vecIter++)
	{
		
		if ( posVec[mid+vecIter+1] > posVec[mid+vecIter] || posVec[mid-vecIter-1] > posVec[mid-vecIter])
		{
			return false;
		}
	}
	return true;
}

bool isToeOff(vector<double> posVec)
{
	
	
	int mid = posVec.size()/2;
	
	for (int vecIter = 0; vecIter < mid; vecIter++)
	{
		
		if ( posVec[mid+vecIter+1] < posVec[mid+vecIter] || posVec[mid-vecIter-1] < posVec[mid-vecIter])
		{
			return false;
		}
	}
	return true;
}
