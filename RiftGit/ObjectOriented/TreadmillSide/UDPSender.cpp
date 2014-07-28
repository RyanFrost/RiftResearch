
#include "dataGenerator.h"
#include "socketManager.h"
#include "sharedMemObject.h"


#include <vector>
#include <queue>
#include <iostream>
#include <iterator>
#include <boost/thread.hpp>


void startComm(void);
void printCharVec(std::vector<char>);
std::string charVecToStr(std::vector<char>);
std::vector<double> arrayToVec(double *);
void pertCycler(int, int);
void dataSaver(void);


socketManager sock(27015); // Creates socket object ---> opens socket on local port 27015
dataGenerator dataGen(120); // dataGen creates the patch & patch type vectors
sharedMemObject sharedMemory;


std::vector<char> response;
int currentPatch = 0;
bool movingForward;
bool movingBackward;
double distance = 10.0;
bool unityRunning = true;

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
	boost::thread pastValsThread(dataSaver);
	std::cout << "Running..." << std::endl;
	
	int currentPatchType = dataGen.getPatchTypes()[currentPatch];

	int CHANGETHISVALUE = 1000; //This is a placeholder for the first argument of the perCycler function
	
	while( unityRunning )
	{
	
		
		int nextPatchType = dataGen.getPatchTypes()[currentPatch];
		std::cout << "next patch type: " << nextPatchType << ", next patch number: " << currentPatch << std::endl;
		switch (nextPatchType)
		{
		case 1:
			pertCycler(CHANGETHISVALUE, 1);
			currentPatch++;
			break;
		case 2:
			pertCycler(CHANGETHISVALUE, 2);
			currentPatch++;
			break;
		case 3:
			pertCycler(CHANGETHISVALUE, 3);
			currentPatch++;
			break;
		}
	}
	commThread.join();
	pastValsThread.join();
	
	sharedMemory.sdata->beep = false;
	
	
	return 0;
}

void pertCycler(int stiffnessLevel, int patchType)
{
	//Waits until the left foot has passed over the next patch (i.e. the distance to next patch is negative)
	while ( distance > 0) { if(unityRunning == false) return;}
	std::cout << "< Over patch -- ";
	
	
	// Waits until foot starts moving forward ( approximately toe-off)
	while( !movingForward) { if(unityRunning == false) return;}
	std::cout << "toe-off -- ";
	
	
	// Waits until foot stops moving forward ( approximately heel-strike )
	while(movingForward) { if(unityRunning == false) return;}
	
	sharedMemory.sdata->perturb = patchType; // 
	std::cout << "perturbing: " << sharedMemory.sdata->perturb << " -- ";
	
	// Changes stiffness until the foot has gone through a full step to toe-off, 
	// then goes back to infinite stiffness at toe-off
	while(!movingForward)
	{
		sharedMemory.sdata->beep = true;
		if(unityRunning == false) return;
	}
	
	std::cout << "done perturbing >" >> std::endl;
	
	sharedMemory.sdata->perturb = 0;
	sharedMemory.sdata->beep = false;
}
	
	

void startComm(void)
{

	while ( unityRunning )
	{
		response = sock.recvData(); // This will usually be the distance to the next perturbation
		
		// Check if Unity has sent the "Quit" command, and if so, stop all processes by setting
		// unityRunning to false. Otherwise, convert the byte message to a double.
		if( charVecToStr(response) != "Quit")
		{
			unityRunning = false;
			break;
		}
		else
		{
			std::string strResp = charVecToStr(response);
			distance = std::stod(strResp);
		}
		
		// Send Joint Angles
		sock.loadDubArrayToBuf( arrayToVec(sharedMemory.sdata->joint_angles_rift) );
		sock.sendBuf();
		
		// Send perturbation status
		// This will send either a 0 for not perturbing, or {1, 2, 3} for the type of perturbation.
		// This lets Unity know when it starts perturbing, stops perturbing, and also if it
		// is a type 3 perturbation lets Unity destroy the following patch.
		sock.loadIntToBuf(sharedMemory.sdata->perturb);
		sock.sendBuf();
		
		
	}
}

void dataSaver()
{
	std::vector<double> pastVals(5, 0.0);
	
	while( unityRunning )
	{
		pastVals.erase(pastVals.begin());
		pastVals.push_back(sharedMemory.sdata->xf);
		if(is_sorted(pastVals.begin(),pastVals.end()))
		{
			movingForward = false;
			movingBackward = true;
		}
		else if(is_sorted(pastVals.rbegin(),pastVals.rend()))
		{
			movingForward = true;
			movingBackward = false;
		}
		else
		{
			movingForward = false;
			movingBackward = false;
		}
	}
	
	boost::this_thread::sleep_for(  boost::posix_time::milliseconds(30));
	
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
	
	
	
	