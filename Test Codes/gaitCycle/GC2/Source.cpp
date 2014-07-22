#include <iostream>
#include <cstdio>
#include <thread>

#include <vector>
#include "gaitCycle.h"
#include <random>

#ifndef PI
#define PI 3.1415926535898
#endif



int main()
{
	
	void sineWave(double *);
	
	bool isHeelStrike(std::vector<double>);
	bool isToeOff(std::vector<double>);

	void addCycle(std::vector<gaitCycle>*, std::vector<double>*);
	void printVec(std::vector<double>*);
	double val = 0;
	double *val_ptr = &val;
	std::thread(sineWave, &val).detach();
	bool stop = false;
	int n = 0;
	

	std::vector<double> vec (5, 0);
	std::vector<double> cycleVec;
	std::vector<gaitCycle> gaitObjVec;
	while (n < 10)
	{
		
		

		/*vec.erase(vec.begin());
		vec.push_back(val);*/

		cycleVec.push_back(val);
		if (cycleVec.size() >= 5)
		{
			std::copy(cycleVec.end() - 5, cycleVec.end(), vec.begin());


			//std::cout << "Before = " << val << std::endl;
			if (isHeelStrike(vec))
			{
				//std::thread(addCycle, &gaitObjVec, &cycleVec).detach();
				addCycle(&gaitObjVec, &cycleVec);
				n++;
				std::cout << n + 1 << "\n";
			}
			//std::cout << "After = " << val << std::endl;
		}
		Sleep(11);

	}
	

	for (int objIter = 0; objIter < gaitObjVec.size(); objIter++)
	{
		std::cout << "Position vec for cycle #" << objIter + 1 << "\n";
		gaitObjVec[objIter].getFootPos();


	}
	
	
	return 0;
}



void sineWave(double *value)
{
	std::cout << "Executing sineWave thread.\n";
	
	
	double omega;
	
	int prec = 20;
	while (true)
	{
		omega = double(std::rand() % 50) / 50 + 1;


		for (int theta = 0; theta < prec; theta ++ )
		{
			*value = std::sin(double(theta)*omega*PI/(prec/2))*50 + 50;
			//std::cout << value << "\n";
			Sleep(10);
		}
	}
}



bool isHeelStrike(std::vector<double> posVec)
{

	int mid = posVec.size() / 2;
	for (int i = 0; i < mid; i++)
	{
		if (posVec[mid + i] >= posVec[mid + i + 1] || posVec[mid - i] >= posVec[mid - i - 1])
			return false;
	}

	return true;

}
bool isToeOff(std::vector<double> posVec)
{

	int mid = posVec.size() / 2;

	for (int i = 0; i < mid; i++)
	{
		if (posVec[mid + i] <= posVec[mid + i + 1] || posVec[mid - i] <= posVec[mid - i - 1])
			return false;
	}

	return true;

}

void addCycle(std::vector<gaitCycle> *objVec, std::vector<double> *cycleVector)
{
	(*objVec).push_back(gaitCycle::gaitCycle(*cycleVector));
	(*cycleVector).clear();


}

void printVec(std::vector<double> *vector)
{
	for (std::vector<double>::iterator iter = (*vector).begin(); iter != (*vector).end(); iter++)
	{
		std::cout << *iter << "\n";
	}

}