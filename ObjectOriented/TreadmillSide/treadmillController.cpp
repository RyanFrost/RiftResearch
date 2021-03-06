#include "treadmillController.h"


#include "lookup_table.h"

#include <vector>
#include <iostream>
#include <cmath>


treadmillController::treadmillController()
{
	x = std::vector<double> (3, 0.0);
	xFilt = std::vector<double> (3, 0.0);
	
	double aTemp[3] ={1.0000, -0.9428, 0.3333};
	double bTemp[3] = {0.0976, 0.1953, 0.0976};
	
	for(int i = 0; i<3; i++)
	{
		aFilt[i] = aTemp[i];
		bFilt[i] = bTemp[i];
	}
}


treadmillController::~treadmillController()
{
	modbus_close(ctx);
	modbus_free(ctx);
}


int treadmillController::initializeModbus(void)
{
	std::cout << "Initializing Modbus... " << std::flush;
	//establish connection
	ctx = modbus_new_tcp("192.168.0.35", 502);
	if (modbus_connect(ctx) == -1) {
    		std::cerr << "Connection failed: " << modbus_strerror(errno) << std::endl;
		return -1;
	}

	//enable drive
	const uint16_t drven[2]={0,1};
	if (modbus_write_registers(ctx,254,2,drven) < 0){
		std::cerr << "Drive enable failed" << std::endl;
		return -1;
	}

	//go home
	const uint16_t homeset[2]={1,1};
	if (modbus_write_registers(ctx,418,2,homeset) < 0){
		std::cerr << "Cannot go home" << std::endl;
		return -1;
	}
	
	// set resolution
	const uint16_t enc_res[1]={1024};
	modbus_write_registers(ctx,984,1,enc_res);
	
	std::cout << "successful." << std::endl;
	
	return 0;	
}

void treadmillController::moveTreadmill(double footPos, double kDesired)
{
	
	if(footPos < -10) {return;}
	
	if(footPos < 1) { footPos = 0.26; }
	
	if(footPos > 100) { footPos = 99; }
	
	xfoot = footPos;
	Kd = kDesired;

	treadmillController::feedForwardFunction();
	

	double u = uff;
	
	x[0] = u;
	xFilt[0] = bFilt[0]*x[0] + bFilt[1]*x[1] + bFilt[2]*x[2] - aFilt[1]*xFilt[1] - aFilt[2]*xFilt[2];
	u = xFilt[0];
	
	x[2] = x[1];
	x[1] = x[0];
	xFilt[2] = xFilt[1];
	xFilt[1] = xFilt[0];
	
	if(kDesired > 5e5) { u = 0.01; }
	
	if(u > 38) { u = 38; }
	
	if (u < 0.01) { u = 0.01; }
	
	treadmillController::moveTrack(u);
	
}

void treadmillController::infStiffness(void)
{
	treadmillController::moveTreadmill(50.0,1e6);
}



void treadmillController::feedForwardFunction(void)
{
	int K_table, xf_table;	
	const double dK1 = 1000.0;
	const double dK2 = 100000.0;
	const double K_01 = 10000.0;
	const double K_02 = 100000.0;	
	const double xf_0 = 1.0;
	const double dxf = 0.5;
	//const double theta1_0 = 0.1; // beginning value for theta1 table
	//const double dtheta1 = 0.5;

	/* ----( Feedforward )---- */
	if (Kd < 100001.0)
	K_table = static_cast<int>( ( (Kd - K_01)/dK1) + 0.5); // Note: +0.5 used for rounding
	else 
	K_table = static_cast<int>( (90 + (Kd - K_02)/dK2) + 0.5);
	
	xf_table = static_cast<int>( (xfoot - xf_0)/dxf + 0.5);
	uff = track_position_table(xf_table, K_table); // Updates desired track position
}

void treadmillController::moveTrack(float pos)
{

	convert64to16(pos); // updates the mtp1 array

	if(modbus_write_registers(ctx,550,4,mtp1) < 0)
		std::cerr << "Can't write position" << std::endl;
	
	const uint16_t mtcntl[1] = {768};
	if(modbus_write_registers(ctx,532,1,mtcntl) < 0)
		std::cerr << "Can't set control" << std::endl;
	
	const uint16_t mtset[2] = {0,1};
	if(modbus_write_registers(ctx,554,2,mtset) < 0)
		std::cerr << "Can't set motion" << std::endl;
	
	const uint16_t mtmove[2] = {0,0};
	if(modbus_write_registers(ctx,544,2,mtmove) < 0)
		std::cerr << "Can't move" << std::endl;
	
	return;
}

void treadmillController::convert64to16(float p)
{
	int a, b, c, d, e, f, h, q; //, g, i;
	q = p*(pow(2,20))*2500/2749;
	a = q/65536; 
	b = q%65536;
	c = a/65536;
	d = a%65536;
	e = c/65536; 
	f = c%65536;
	//g = e/65536; 
	h = e%65536;

	mtp1[0] = h;
	mtp1[1] = f;
	mtp1[2] = d;
	mtp1[3] = b;
}
