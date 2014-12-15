#include "dataGenerator.h"


#include <ctime>
#include <cstdlib>
#include <string>
#include <iostream>
#include <math.h>
#include <vector>
#include <algorithm>

#include <boost/lexical_cast.hpp>
#include <boost/thread.hpp>
#include <chrono>





dataGenerator::dataGenerator(int numberPatches) : numPatches(numberPatches)
{
	patchGenerator();
	patchTypeGenerator();
	patchSeparationGenerator();
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
	// To insert the special perturbations this function first fills a vector with half type 2 and half type 3 perturbations. Then
	// it shuffles the vector to randomize the perturbation order and inserts each element of the vector into the patch list
	// at random intervals.
	
	int numPert = 20;
	std::vector<int> patchTypeOrder;
	patchTypeOrder.insert(patchTypeOrder.end(), numPert / 2, 2);
	patchTypeOrder.insert(patchTypeOrder.end(), numPert / 2, 3);
	
	for (int i = 0; i < 5; i++)
	{
		std::random_shuffle(patchTypeOrder.begin(), patchTypeOrder.end());
	}
	
	patchTypes.insert(patchTypes.begin(), numPatches, 1);

	int currentPatch = 0;
	int startingBuffer = 10; // Number of patches before the first special perturbation
	int avgPatchesBetween = 6;
	currentPatch += startingBuffer;

	

	for (std::vector<int>::const_iterator iter = patchTypeOrder.begin(); iter != patchTypeOrder.end(); iter++)
	{
		patchTypes[currentPatch] = *iter;
		currentPatch += avgPatchesBetween - 2 + std::rand() % 5;
	}

}


void dataGenerator::patchSeparationGenerator(void)
{
	patchSeparations.reserve(numPatches);
	patchSeparations.push_back(0);
	for(uint i = 1; i < patches.size(); i++)
	{
		patchSeparations.push_back((patches[i] - patches[i-1]) /2);
	}
}


void dataGenerator::angleFootPosGenerator(void)
{

	typedef std::chrono::high_resolution_clock Clock;
	typedef std::chrono::duration<double> secDouble;
	
	std::chrono::high_resolution_clock timer;
	
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


// Starts the angle generation in a separate thread

void dataGenerator::startAngleGen(void)
{
	boost::thread t1(&dataGenerator::angleFootPosGenerator, this);
}

