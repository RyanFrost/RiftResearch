#include "dataGenerator.h"


#include <ctime>
#include <cstdlib>
#include <string>
#include <iostream>
#include <math.h>
#include <vector>
#include <algorithm>

#include <boost/lexical_cast.hpp>
#include <chrono>
#include <boost/thread.hpp>


using namespace std;


dataGenerator::dataGenerator(int numberPatches) : numPatches(numberPatches)
{	
}


dataGenerator::~dataGenerator()
{
}


void dataGenerator::start()
{
	patchGenerator();
	patchTypeGenerator();
	startAngleGen();
}

void dataGenerator::patchGenerator(void)
{
	std::cout << "inside patchGenerator" << std::endl;
	
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
	
	std::cout<< "inside patchTypeGenerator" << std::endl;
	int numPert = 10;
	std::vector<int> patchTypeOrder;
	patchTypeOrder.insert(patchTypeOrder.end(), numPert / 2, 2);
	patchTypeOrder.insert(patchTypeOrder.end(), numPert / 2, 3);

	std::random_shuffle(patchTypeOrder.begin(), patchTypeOrder.end());

	patchTypes.insert(patchTypes.begin(), numPatches, 1);

	int currentPatch = 0;
	int startingBuffer = 20; // Number of patches before the first perturbation
	int avgPatchesBetween = 10;
	currentPatch += startingBuffer;

	

	for (std::vector<int>::const_iterator iter = patchTypeOrder.begin(); iter != patchTypeOrder.end(); iter++)
	{
		patchTypes[currentPatch] = *iter;
		currentPatch += avgPatchesBetween - 2 + std::rand() % 5;
	}

}



void dataGenerator::angleFootPosGenerator(void)
{

	std::cout<< "Inside anglefootPosGenerator" << std::endl;
	typedef std::chrono::high_resolution_clock Clock;
	typedef std::chrono::duration<double> secDouble;
	
	std::chrono::high_resolution_clock timer;
	
	Clock::time_point startTime = timer.now();
	secDouble secs;

	angles.resize(6);
	

	int runLoop = 1;
	while (runLoop)
	{
		secs = timer.now() - startTime;
		
		footPos = 45 * sin(secs.count()) + 50;
		
		angles[0] = 20 * sin(secs.count()) + 20;		// Toe angle
		angles[1] = 40 * sin(secs.count() - 1) + 40;	// Knee angle
		angles[2] = 30 * sin(secs.count() + 0.5) -10 ;	// Hip angle
		
		angles[3] = 20 * sin(secs.count() + 3.14) + 20;		// Toe angle
		angles[4] = 40 * sin(secs.count() - 1 + 3.14) + 40;	// Knee angle
		angles[5] = 30 * sin(secs.count() + 0.5 + 3.14) - 10 ;	// Hip angle
		
	}

}

void dataGenerator::startAngleGen(void)
{
	
	std::cout << "inside startAngleGen" << std::endl;
	boost::thread t1(&dataGenerator::angleFootPosGenerator, this);
	
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