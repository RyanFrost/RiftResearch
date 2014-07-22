#ifndef GAIT_CYCLE_CLASS_H
#define GAIT_CYCLE_CLASS_H


#include <vector>
#include <iostream>


class gaitCycle
{
private:
	std::vector<double> footPos;



public:
	gaitCycle(std::vector<double>);
	~gaitCycle();

	void getFootPos();

};







#endif