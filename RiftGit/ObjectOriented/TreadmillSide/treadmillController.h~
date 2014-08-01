#include "modbus/modbus.h"

#include <vector>


class treadmillController
{
private:
	modbus_t *ctx;
	
	std::vector<double> x;
	std::vector<double> xFilt;
	double aFilt[3];
	double bFilt[3];
	
	double uff;
	double xfoot;
	double Kd;
	uint16_t *mtp1;
	
	// These three are helper functions for moveTreadmill
	void feedForwardFunction(void);
	void moveTrack(float);
	void convert64to16(float);
	
public:
	treadmillController();
	~treadmillController();
	
	// Call this to initialize connection to the linear actuator. Will return 0 if successful,
	// or -1 if the initialization failed for any reason.
	int initializeModbus(void);
	
	// moveTreadmill takes the arguments (double footPosition, double desiredStiffness) and will
	// move the treadmill track to achieve the desired stiffness. This is a single action, so it
	// must be called continuously in a while loop with updated foot position to move the track
	// for a duration of time.
	void moveTreadmill(double, double);
	
	// infStiffness automatically sets the track position to give infinite stiffness. Only needs
	// to be called once to set.
	void infStiffness(void);
	
};