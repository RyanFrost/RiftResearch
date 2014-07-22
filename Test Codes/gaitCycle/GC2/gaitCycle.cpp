#include "gaitCycle.h"


gaitCycle::gaitCycle(std::vector<double> inputVector)
{
	footPos = inputVector;


}


gaitCycle::~gaitCycle()
{
}


void gaitCycle::getFootPos()
{
	for (int posIter = 0; posIter < footPos.size(); posIter++)
	{
		std::cout << footPos[posIter] << "\n";
	}

	std::cout << "\n\n";


}