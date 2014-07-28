
#include "dataGeneratorWindows.h"
#include "socketManagerWindows.h"

#include <vector>
#include <iostream>
#include <boost/thread.hpp>
#include <fstream>

void startComm(void);
void printCharVec(std::vector<char>);
std::string charVecToStr(std::vector<char>);
std::vector<double> arrayToVec(double *);
void pertCycler(int, int);
void dataSaver(void);


std::vector<char> response;
int currentPatch = 0;
int perturb = 0;
double distance = 10.0;
bool unityRunning = true;
bool movingForward;
bool movingBackward;

socketManager sock(27015);
dataGenerator dataGen(120);



int main()
{

	
	
	


	
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
	


	boost::thread commThread(startComm);
	boost::thread pastValsThread(dataSaver);



	int currentPatchType = dataGen.getPatchTypes()[currentPatch];

	int CHANGETHISVALUE = 1000; //This is a placeholder for the first argument of the perCycler function

	

	while (unityRunning)
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

	///////







	///////


	return 0;
}



void pertCycler(int stiffnessLevel, int patchType)
{
	
	while (distance > 0) { if (unityRunning == false) return; }
	std::cout << "Over patch ---- ";

	// Waits until foot is moving forward and foot is behind the 75cm mark
	while (!movingForward)
	{
		if (unityRunning == false) return;
	}
	std::cout << "moving forward ---- ";
	// Waits until foot passes the 75cm mark
	while (movingForward)
	{
		if (unityRunning == false) return;
	}
	std::cout << "moving backward ---- ";
	perturb = patchType;
	std::cout << "perturb = " << perturb << std::endl;
	// Changes stiffness until the foot has gone through a full step to toe off, 
	// then goes back to infinite stiffness at midstance
	while (!movingForward)
	{
		if (unityRunning == false) return;
	}

	std::cout << "done with pert." << std::endl;
	perturb = 0;
	
	while (distance < 0){}
	
}







void startComm(void)
{

	while (unityRunning)
	{
		response = sock.recvData();  // This is the distance to next patch
		if (charVecToStr(response) == "Quit")
		{
			unityRunning = false;
			break;
		}
		else
		{
			std::string strResp = charVecToStr(response);
			distance = std::stod(strResp);
		}
		sock.loadDubArrayToBuf(dataGen.getAngles());
		sock.sendBuf();
		
		sock.loadIntToBuf(perturb);
		sock.sendBuf();


	}
}


void dataSaver()
{
	std::vector<double> pastVals(5, 0.0);

	while (unityRunning)
	{
		
		pastVals.erase(pastVals.begin());
		pastVals.push_back(dataGen.getFootPos());
		if (is_sorted(pastVals.begin(), pastVals.end()))
		{
			movingForward = false;
			movingBackward = true;
		}
		else if (is_sorted(pastVals.rbegin(), pastVals.rend()))
		{
			movingForward = true;
			movingBackward = false;
		}
		else
		{
			movingForward = false;
			movingBackward = false;
		}
		Sleep(30);
	}
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