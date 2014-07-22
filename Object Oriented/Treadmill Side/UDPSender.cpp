
#include "dataGenerator.h"
#include "socketManagerLinux.h"
#include "sharedMemObject.h"


#include <vector>
#include <iostream>
#include <iterator>



void printCharVec(std::vector<char>);
std::string charVecToStr(std::vector<char>);
std::vector<double> arrayToVec(double *);

int main()
{
	socketManager sock(27015);
	dataGenerator dataGen(120);
	std::cout << dataGen.getPatches().size() << std::endl;
	sharedMemObject sharedMemory;
	
	
	
// 	while(true)
// 	{
// // 		for(int iter = 0; iter< 6; iter++)
// // 			std::cout << sharedMemory.sdata->joint_angles_rift[iter] << " ";
// // 		std::cout << "\n";
// 		
// 		sock.loadDubArrayToBuf( arrayToVec(sharedMemory.sdata->joint_angles_rift) );
// 		printCharVec(sock.getBuf());	
// 	}
	
	std::cout << "Waiting for Unity to start..." << std::endl;
	std::vector<char> response = sock.recvData();
	
	printCharVec(response);
	std::cout << "Received." << std::endl;

	std::vector<int> patchesVec = dataGen.getPatches();
	
	sock.loadIntArrayToBuf(patchesVec);
	printCharVec(sock.getBuf());
	sock.sendBuf();
	
	response = sock.recvData();
	printCharVec(response);
	std::vector<int> patchTypesVec = dataGen.getPatchTypes();

	sock.loadIntArrayToBuf(patchTypesVec);
	printCharVec(sock.getBuf());
	sock.sendBuf();
	std::cout << "Running..." << std::endl;
	
	while ( charVecToStr(response) != "Quit")
	{
		response = sock.recvData();  // This is the distance to next patch
		printCharVec(response);
		sock.loadDubArrayToBuf( arrayToVec(sharedMemory.sdata->joint_angles_rift) );
		//printCharVec(sock.getBuf());
		sock.sendBuf();

	}



	///////


// 	switch (currentPatchType)
// 	{
// 	case 1:
// 		//Normal pert
// 		break;
// 	case 2:
// 		//
// 
// 
// 
// 
// 
// 
// 	}







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

std::vector<double> arrayToVec(double *inputArray)
{
	
	return std::vector<double>(inputArray, inputArray + 6);

}
	
	
	
	