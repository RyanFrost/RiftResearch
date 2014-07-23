
#include "dataGenerator.h"
#include "socketManager.h"
#include "sharedMemObject.h"


#include <vector>
#include <iostream>
#include <iterator>
#include <boost/thread.hpp>


void startComm(void);
void printCharVec(std::vector<char>);
std::string charVecToStr(std::vector<char>);
std::vector<double> arrayToVec(double *);
void pertCycler(int, int);

socketManager sock(27015); // Creates socket object ---> opens socket on local port 27015
dataGenerator dataGen(120); // dataGen creates the patch & patch type vectors
sharedMemObject sharedMemory;


std::vector<char> response;
int currentPatch = 0;


int main()
{
	
	
	//Uncomment following line for automatic joint angle generation
	//dataGen.startAngleGen();
	
	
// 	while(true)
// 	{
// 		for(int iter = 0; iter< 6; iter++)
// 			std::cout << sharedMemory.sdata->joint_angles_rift[iter] << " ";
// 		std::cout << "\n";
// 		sock.loadDubArrayToBuf( arrayToVec(sharedMemory.sdata->joint_angles_rift) );
// 		sock.loadDubArrayToBuf(dataGen.getAngles());
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
	
	
	boost::thread commThread(startComm);
	std::cout << "Running..." << std::endl;
	
	int currentPatchType = dataGen.getPatchTypes()[currentPatch];

	int CHANGETHISVALUE = 1000; //This is a placeholder for the first argument of the perCycler function
	
// 	while( charVecToStr(response) != "Quit")
// 	{
// 	
// 		
// 		switch(dataGen.getPatchTypes()[currentPatch])
// 		{
// 		case 1:
// 			
// 			pertCycler(CHANGETHISVALUE, 1);
// 			currentPatch++;
// 			break;
// 		case 2:
// 			pertCycler(CHANGETHISVALUE, 2);
// 			currentPatch++;
// 			break;
// 		case 3:
// 			pertCycler(CHANGETHISVALUE, 3);
// 			currentPatch++;
// 			break;
// 		}
// 	}
		
	commThread.join();
	return 0;
}

void pertCycler(int stiffnessLevel, int patchType)
{
	
// 	if(patchType == 3)
// 	{}
// 		while(dataGen.getPatchSeparations()[currentPatch] >= 0.0);
// 	
// 	// Waits until foot is moving forward and foot is behind the 75cm mark
// 	while( ~movingForward or sharedMemory.sdata->xf >= 75.0)
// 	{}
// 	
// 	// Waits until foot passes the 75cm mark
// 	while(sharedMemory.sdata->xf <= 75.0)
// 	{}
// 	
// 	
// 	// Changes stiffness until the foot has gone through a full step to toe off, 
// 	// then goes back to infinite stiffness at midstance
// 	while(~movingForward or sharedMemory.sdata->xf <=50)
// 	{
// 		moveTrack(stiffnessLevel);
// 	}
}
	
	

void startComm(void)
{
// 	std::vector<char> response;
// 	while ( charVecToStr(response) != "Quit")
// 	{
// 		response = sock.recvData();  // This is the distance to next patch
// 		//printCharVec(response);
// 		sock.loadDubArrayToBuf( arrayToVec(sharedMemory.sdata->joint_angles_rift) );
// 		//printCharVec(sock.getBuf());
// 		sock.sendBuf();
// 
// 	}
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
	
	
	
	