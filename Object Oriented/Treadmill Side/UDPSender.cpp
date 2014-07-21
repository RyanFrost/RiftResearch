
#include "dataGenerator.h"
#include "socketManager.h"

#include <vector>
#include <iostream>



void printCharVec(std::vector<char>);
std::string charVecToStr(std::vector<char>);

int main()
{
	socketManager sock(27015);
	dataGenerator dataGen(120);

	
	
	


	
	std::cout << "Waiting for Unity to start..." << std::endl;
	std::vector<char> response = sock.recvData();
	
	printCharVec(response);
	std::cout << "Received." << std::endl;

	std::vector<int> patchesVec = dataGen.getPatches();
	
	sock.loadIntArrayToBuf(patchesVec);
	sock.sendBuf();
	
	response = sock.recvData();

	std::vector<int> patchTypesVec = dataGen.getPatchTypes();

	sock.loadIntArrayToBuf(patchTypesVec);
	sock.sendBuf();
	
	
	while ( charVecToStr(response) != "Quit")
	{
		response = sock.recvData();  // This is the distance to next patch
		printCharVec(response);
		sock.loadDubArrayToBuf(dataGen.getAngles());
		sock.sendBuf();

	}



	///////


	switch (currentPatchType)
	{
	case 1:
		//Normal pert
		break;
	case 2:
		//






	}







	///////


	return 0;
}


void printCharVec(std::vector<char> vec)
{
	std::copy(vec.begin(), vec.end(), std::ostream_iterator<char>(std::cout));
	std::cout << std::endl;
}

std::string charVecToStr(std::vector<char> vec)
{
	std::string convertedStr(vec.begin(), vec.end());
	return convertedStr;
}