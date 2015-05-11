#include "dataGeneratorWindows.h"


#include <ctime>
#include <cstdlib>
#include <string>
#include <iostream>
#include <math.h>
#include <vector>

#include <boost/lexical_cast.hpp>
#include <boost/chrono.hpp>
#include <boost/thread.hpp>

#include <Windows.h>

using namespace std;


dataGenerator::dataGenerator(int numberPatches) : numPatches(numberPatches)
{
	
	patchGenerator();
	patchTypeGenerator();
	startAngleGen();
	
}


dataGenerator::~dataGenerator()
{
}


void dataGenerator::patchGenerator(void)
{
	patches.clear(); // Clears patch vector for reuse
	
	srand(std::time(0));
	int patchStart = 20;
	patchStart -= 500;
	
	int pLocation = patchStart;



	for (int i = 0; i<numPatches; i++)
	{
		int separation = std::rand() % 3 + 5;
		pLocation += separation;
		patches.push_back(pLocation);
	}
}


void dataGenerator::patchTypeGenerator(void)
{
	
	int numPert = 10;
	std::vector<int> patchTypeOrder;
	patchTypeOrder.insert(patchTypeOrder.end(), numPert / 2, 2);
	patchTypeOrder.insert(patchTypeOrder.end(), numPert / 2, 3);

	std::random_shuffle(patchTypeOrder.begin(), patchTypeOrder.end());

	patchTypes.insert(patchTypes.begin(), numPatches, 1);

	int currentPatch = 0;
	int startingBuffer = 2; // Number of patches before the first perturbation
	int endingBuffer = 5; // Number of patches after the last perturbation
	int avgPatchesBetween = 5;
	currentPatch += startingBuffer;

	

	for (std::vector<int>::const_iterator iter = patchTypeOrder.begin(); iter != patchTypeOrder.end(); iter++)
	{
		patchTypes[currentPatch] = *iter;
		currentPatch += avgPatchesBetween - 2 + std::rand() % 3;
	}

}



void dataGenerator::angleFootPosGenerator(void)
{

	typedef boost::chrono::high_resolution_clock Clock;
	typedef boost::chrono::duration<double> secDouble;
	
	boost::chrono::high_resolution_clock timer;
	
	Clock::time_point startTime = timer.now();
	secDouble secs;

	angles.resize(6);
	

	int runLoop = 1;
	float freqMult = 2;
	while (runLoop)
	{
		secs = timer.now() - startTime;
		
		footPos = 45 * sin(secs.count()*freqMult) + 50;
		
		angles[0] = 20 * sin(secs.count()*freqMult) - 20;		// Hip angle
		angles[1] = 40 * sin(secs.count()*freqMult - 1) + 40;	// Knee angle
		angles[2] = 30 * sin(secs.count()*freqMult + 0.5) - 30;	// Toe angle
		
		angles[3] = 20 * sin(secs.count()*freqMult + 3.14) - 20;		// Hip angle
		angles[4] = 40 * sin(secs.count()*freqMult - 1 + 3.14) + 40;	// Knee angle
		angles[5] = 30 * sin(secs.count()*freqMult + 0.5 + 3.14) + 30;	// Toe angle
		
	}

}

void dataGenerator::startAngleGen(void)
{
	boost::thread t1(&dataGenerator::angleFootPosGenerator,this);
	
}




vector<int> dataGenerator::getPatches(void)
{
	return patches;
}

vector<int> dataGenerator::getPatchTypes(void)
{
	return patchTypes;
}

vector<double> dataGenerator::getAngles(void)
{
	return angles;
}

double dataGenerator::getFootPos(void)
{
	return footPos;
}