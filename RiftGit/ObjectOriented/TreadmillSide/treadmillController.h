#include "modbus/modbus.h"


class treadmillController
{
private:
	modbus_t *ctx;
	
	std::vector<double> x ( 3, 0.0 );
	std::vector<double> xFilt ( 3, 0.0 );
	double aFiltd[3] = {1.0000, -0.9428, 0.3333};
	double bFiltd[3] = {0.0976, 0.1953, 0.0976};
	
	double uff;
	double xfoot;
	double Kd;
	uint16_t mtp1;
	
	int initializeModbus(void);
	void feedForwardFunction(void);
	void moveTrack(float);
	void convert64to16(float);
	
public:
	treadmillController();
	~treadmillController();
	
	void moveTreadmill(double, double);
	
	
};