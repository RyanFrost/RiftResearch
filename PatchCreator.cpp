#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <ctime>
#include <cstring>
#include <boost/lexical_cast.hpp>
#include <algorithm>
using namespace std;





int main()
{
	std::srand(std::time(0));
	int numPatches = 150;
	int start = 20;
	int random;
	int patches [numPatches];
	string patchStr;
	int location = start;
	
	patches[0] = location;
	string locString = boost::lexical_cast<string>( location );
	patchStr.append(locString);
	
	
	for (int i = 1; i<numPatches; i++)
	{
		int separation = std::rand() % 5 + 3;
		location += separation;
		patches[i] = location;
		locString = boost::lexical_cast<string>( location );
		patchStr.append(",");
		patchStr.append(locString);
		
	}
	
	int numPert = 10;
	int pertTypes [numPert];
	
	
	for (int i = 0; i<numPert; i++)
	{
		
		pertTypes[i] = 0;
		
		if (i>=numPert/2)
		{
			pertTypes[i] = 1;
		}
		
	}
	
	random_shuffle(&pertTypes[0], &pertTypes[numPert]);
	
	
	int patchBufferStart = 20; // # of patches before the first perturbation
	int patchBufferEnd = 20; // # of patches after the last perturbation
	int patchesBetween = (numPatches-(patchBufferStart+patchBufferEnd))/numPert;
	cout << patchesBetween << " patches between\n";
	
	int typeZero [numPert/2-1]; int zeroCounter = 0;
	int typeOne [numPert/2-1]; int oneCounter = 0;
	int typeOneMidpoint [numPert/2];
	
	
	for (int i = 0; i<numPert; i++)
	{
		
		/* Type 0 perturbation - Sand patch but no stiffness change */
		if (pertTypes[i] == 0)
		{	
			typeZero[zeroCounter] = patchBufferStart + i*patchesBetween + rand() % 5 - 2;
			zeroCounter++;
		}
		else if (pertTypes[i] == 1) /* Type 1 perturbation - Stiffness change with no patch */
		{
			typeOne[oneCounter] = patchBufferStart + i*patchesBetween + rand() % 5 - 2;
			int currentPatch = typeOne[oneCounter];
			typeOneMidpoint[oneCounter] = (patches[currentPatch+1]-patches[currentPatch])/2;
			oneCounter++;
		}
		
	}
	
	
	char *patchChar = new char[patchStr.size()+1];
	patchChar[patchStr.size()]=0;
	memcpy(patchChar,patchStr.c_str(),patchStr.size());
	

	return 0;
}