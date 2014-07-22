#ifndef POS_DATA_H
#define POS_DATA_H


#include <vector>

class posData
{
	
	
private:
	std::vector<double> posVec;
	std::vector<double> posVecReverse;
	double xf;
	bool moveForward;
	bool moveBackward;
	bool heelStrike;
	bool toeOff;
	void update();
public:
	posData();
	
	void startUpdate() {update();}
	
	bool isMovingForward() { return moveForward; }
	bool isMovingBackward() { return moveBackward; }
	bool isHeelStrike() { return heelStrike; }
	bool isToeOff() { return toeOff; }
	
	
};
#endif