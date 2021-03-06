#pragma once

#include <vector>
#include <string>

class dataGenerator
{

private:
	
	// Properties
	double footPos;
	std::vector<double> angles;
	std::vector<int> patches;
	std::vector<int> patchTypes;
	std::vector<double> patchSeparations;
	int numPatches;
	
	// Methods
	
	
	// Use startAngleGen()
	void angleFootPosGenerator();
	
	
	// Fills the vector<int> patches which contains the 
	// location (in meters) of each patch to be sent
	void patchGenerator();
	
	
	// Fills the vector<int> patchTypes which contains the perturbation type for each patch
	// 	Types: 
	//		1: normal stiffness change at patch
	//		2: no stiffness change at patch
	//		3: stiffness change halfway between the previous patch and the current patch
	void patchTypeGenerator();
	
	
	void patchSeparationGenerator();
	
	
	
	
	char* loadBuffer(std::string);

public:
	dataGenerator(int);
	~dataGenerator();

	
	
	std::vector<int> getPatches() {return patches;}
	std::vector<int> getPatchTypes() {return patchTypes;}
	
	// Generates sinusoidal joint angle functions in 
	// place of actual data. For testing purposes.
	void startAngleGen();
	
	std::vector<double> getAngles() {return angles;}
	double getFootPos() {return footPos;}


};

