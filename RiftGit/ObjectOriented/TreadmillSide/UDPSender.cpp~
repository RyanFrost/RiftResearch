
#include "dataGenerator.h"
#include "socketManager.h"
#include "sharedMemObject.h"
#include "treadmillController.h"

#include <vector>
#include <queue>
#include <iostream>
#include <iterator>
#include <boost/thread.hpp>
#include <unistd.h>


#include <signal.h>


void startComm(void);
void printCharVec(std::vector<char>);
std::string charVecToStr(std::vector<char>);
std::vector<double> arrayToVec(double *);
void pertCycler(int, int);
void dataSaver(void);







socketManager sock(27015); // Creates socket object ---> opens socket on local port 27015
dataGenerator dataGen(120); // dataGen creates the patch & patch type vectors
sharedMemObject sharedMemory;
treadmillController treadmill;

std::vector<char> response;
int currentPatch = 0;
bool movingForward;
bool movingBackward;
double distance = 10.0;
bool unityRunning = true;







int main()
{
	
// 	struct sigaction sigIntHandler;
// 	
// 	sigIntHandler.sa_handler = my_handler;
// 	sigemptyset(&sigIntHandler.sa_mask);
// 	sigIntHandler.sa_flags = 0;
// 	sigaction(SIGINT, &sigIntHandler, NULL);
// 	
// 	
	if( treadmill.initializeModbus() < 0) { exit(1); }
// 	
	
	
	
	
	//Uncomment following line for automatic joint angle generation
	//dataGen.startAngleGen();

// 	while(true)
// 	{
// 		for(int iter = 0; iter< 6; iter++)
// 			std::cout << sharedMemory.sdata->joint_angles_rift[iter] << " ";
// 		std::cout << std::endl;
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
	
	//int currentPatchType = dataGen.getPatchTypes()[currentPatch];

	
	while( unityRunning )
	{
		
		int nextPatchType = dataGen.getPatchTypes()[currentPatch];
		std::cout << "next patch type: " << nextPatchType << ", next patch number: " << currentPatch << std::endl;
		
		
		
		switch (nextPatchType)
		{
		case 1:
			pertCycler(5e4, 1);
			currentPatch++;
			break;
		case 2:
			pertCycler(1e6, 2);
			currentPatch++;
			break;
		case 3:
			pertCycler(5e4, 3);
			currentPatch++;
			break;
		}
		
		while(distance < 0) {if(unityRunning == false) break; }
		
	}
	
	commThread.join();
	pastValsThread.join();
	
	sharedMemory.sdata->beep = false;
	
	return 0;
}

void pertCycler(int stiffnessLevel, int patchType)
{
	
	//Waits until the left foot has passed over the next patch (i.e. the distance to next patch is negative)
	
	while ( distance > 0.0) { if(unityRunning == false) return;}
	
	std::cout << "< Over patch -- " << std::flush;
	
	
	// Waits until foot is moving forward ( approximately toe-off)
	
	while( !movingForward) { if(unityRunning == false) return;}
	
	std::cout << "toe-off -- " << std::flush;
	
	
	
	// Waits until foot stops moving forward ( approximately heel-strike )
	
	while(movingForward) { if(unityRunning == false) return;}
	
	sharedMemory.sdata->perturb = patchType; // Sets perturb to current perturbation type for data analysis
	std::cout << "perturbing: " << sharedMemory.sdata->perturb << " -- " << std::flush;

	
	
	
	// Changes stiffness until the foot has gone through a full step to toe-off, 
	// then goes back to infinite stiffness at toe-off
	while(!movingForward)
	{
		
		if(unityRunning == false) return;
		treadmill.moveTreadmill(sharedMemory.sdata->xf, stiffnessLevel);
		usleep(50000);
	}
	
	std::cout << "done perturbing >" << std::endl;
	
 	treadmill.infStiffness();
	
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
		if( charVecToStr(response) == "Quit")
		{
			unityRunning = false;
			break;
		}
		else
		{
			std::string strResp = charVecToStr(response);
			distance = std::stod(strResp);
			//std::cout << distance << std::endl;
		}
		
		// Send Joint Angles
		sock.loadDubArrayToBuf( arrayToVec(sharedMemory.sdata->joint_angles_rift) );
		//sock.loadDubArrayToBuf(dataGen.getAngles());
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
		//pastVals.push_back(dataGen.getFootPos());
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
		
		
		sharedMemory.save2file(movingBackward,movingForward);
		
		// Sleep in between calls to foot position.
		// This helps negate the effect of noise on foot position,
		// which can cause a falsely reported change in direction
		usleep(30000);
	}
	
	
	
}		



// void my_handler(int s){
// 	fprintf(stdout, "Caught signal %d\n",s);
// 	sharedMemory.sdata->data_exchange = FALSE;
// 	//fclose(fp);
// 	modbus_close(ctx);
// 	modbus_free(ctx);
// 	//terminate_data_exchange(sdata);	   
// 	exit(1); 
// }

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
	
	
	
	