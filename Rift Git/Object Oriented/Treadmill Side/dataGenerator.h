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
	int numPatches;
	
	// Methods
	void angleFootPosGenerator();
	void patchGenerator();
	void patchTypeGenerator();
	void startAngleGen();
	char* loadBuffer(std::string);

public:
	dataGenerator(int);
	~dataGenerator();

	void start();
	
	std::vector<double> getAngles();
	std::vector<int> getPatches();
	std::vector<int> getPatchTypes();
	double getFootPos();



};

