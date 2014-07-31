
#include "dataGenerator.h"
#include "socketManager.h"
#include "sharedMemObject.h"


#include <vector>
#include <queue>
#include <iostream>
#include <iterator>
#include <boost/thread.hpp>
#include <unistd.h>



#include "modbus/modbus.h"
#include "lookup_table.h"
#include <signal.h>


void startComm(void);
void printCharVec(std::vector<char>);
std::string charVecToStr(std::vector<char>);
std::vector<double> arrayToVec(double *);
void pertCycler(int, int);
void dataSaver(void);


void moveTreadmill(double,double);
double feedForwardFunction(double,double);
void move_track(float);
uint16_t* convert64to16(float);
int initialize_modbus(void);
void my_handler(int);





socketManager sock(27015); // Creates socket object ---> opens socket on local port 27015
dataGenerator dataGen(120); // dataGen creates the patch & patch type vectors
sharedMemObject sharedMemory;


std::vector<char> response;
int currentPatch = 0;
bool movingForward;
bool movingBackward;
double distance = 10.0;
bool unityRunning = true;







int main()
{
	
// 	struct sigaction sigIntHandler;
// 	
// 	sigIntHandler.sa_handler = my_handler;
// 	sigemptyset(&sigIntHandler.sa_mask);
// 	sigIntHandler.sa_flags = 0;
// 	sigaction(SIGINT, &sigIntHandler, NULL);
// 	
// 	
// 	if( initialize_modbus() < 0) { exit(1); }
// 	
	
	
	
	
	//Uncomment following line for automatic joint angle generation
	//dataGen.startAngleGen();

// 	while(true)
// 	{
// 		for(int iter = 0; iter< 6; iter++)
// 			std::cout << sharedMemory.sdata->joint_angles_rift[iter] << " ";
// 		std::cout << "\n";
// 		sock.loadDubArrayToBuf( arrayToVec(sharedMemory.sdata->joint_angles_rift) );
// 		sock.loadDubArrayToBuf(dataGen.getAngles());
// 		printCharVec(sock.getBuf());	
// 	}
	
	std::cout << "Waiting for Unity to start..." << std::endl;
	std::vector<char> response = sock.recvData();
	
	printCharVec(response);
	std::cout << "Received." << std::endl;

	std::vector<int> patchesVec = dataGen.getPatches();
	sock.loadIntArrayToBuf(patchesVec);
	printCharVec(sock.getBuf());
	sock.sendBuf();
	
	response = sock.recvData();
	printCharVec(response);
	
	std::vector<int> patchTypesVec = dataGen.getPatchTypes();
	sock.loadIntArrayToBuf(patchTypesVec);
	printCharVec(sock.getBuf());
	sock.sendBuf();
	
	
	boost::thread commThread(startComm);
	boost::thread pastValsThread(dataSaver);
	std::cout << "Running..." << std::endl;
	
	//int currentPatchType = dataGen.getPatchTypes()[currentPatch];

	int CHANGETHISVALUE = 1000; //This is a placeholder for the first argument of the perCycler function
	
	while( unityRunning )
	{
		
		int nextPatchType = dataGen.getPatchTypes()[currentPatch];
		std::cout << "next patch type: " << nextPatchType << ", next patch number: " << currentPatch << std::endl;
		
		
		
		switch (nextPatchType)
		{
		case 1:
			pertCycler(5e4, 1);
			currentPatch++;
			break;
		case 2:
			pertCycler(1e6, 2);
			currentPatch++;
			break;
		case 3:
			pertCycler(5e4, 3);
			currentPatch++;
			break;
		}
		
		while(distance < 0) {if(unityRunning == false) break; }
		
	}
	
	commThread.join();
	pastValsThread.join();
	
	sharedMemory.sdata->beep = false;
	
	return 0;
}

void pertCycler(int stiffnessLevel, int patchType)
{
	
	//Waits until the left foot has passed over the next patch (i.e. the distance to next patch is negative)
	while ( distance > 0.0) 
	{
		if(unityRunning == false) return;
		
	}
	
	std::cout << "< Over patch -- " << std::flush;
	
	
	// Waits until foot starts moving forward ( approximately toe-off)
	while( !movingForward) { if(unityRunning == false) return;}
	std::cout << "toe-off -- " << std::flush;
	
	
	// Waits until foot stops moving forward ( approximately heel-strike )
	while(movingForward) { if(unityRunning == false) return;}
	
	sharedMemory.sdata->perturb = patchType; // 
	std::cout << "perturbing: " << sharedMemory.sdata->perturb << " -- " << std::flush;
	sharedMemory.sdata->beep = true;
	// Changes stiffness until the foot has gone through a full step to toe-off, 
	// then goes back to infinite stiffness at toe-off
	while(!movingForward)
	{
		
		if(unityRunning == false) return;
// 		moveTreadmill(sharedMemory.sdata->xf, stiffnessLevel);
		usleep(50000);
	}
	
	std::cout << "done perturbing >" << std::endl;
	
// 	moveTreadmill(dataGen.getFootPos(), 1e6);
	
	sharedMemory.sdata->perturb = 0;
	sharedMemory.sdata->beep = false;
}
	
	

void startComm(void)
{

	while ( unityRunning )
	{
		response = sock.recvData(); // This will usually be the distance to the next perturbation
		
		// Check if Unity has sent the "Quit" command, and if so, stop all processes by setting
		// unityRunning to false. Otherwise, convert the byte message to a double.
		if( charVecToStr(response) == "Quit")
		{
			unityRunning = false;
			break;
		}
		else
		{
			std::string strResp = charVecToStr(response);
			distance = std::stod(strResp);
			//std::cout << distance << std::endl;
		}
		
		// Send Joint Angles
		sock.loadDubArrayToBuf( arrayToVec(sharedMemory.sdata->joint_angles_rift) );
		//sock.loadDubArrayToBuf(dataGen.getAngles());
		sock.sendBuf();
		
		// Send perturbation status
		// This will send either a 0 for not perturbing, or {1, 2, 3} for the type of perturbation.
		// This lets Unity know when it starts perturbing, stops perturbing, and also if it
		// is a type 3 perturbation lets Unity destroy the following patch.
		sock.loadIntToBuf(sharedMemory.sdata->perturb);
		sock.sendBuf();
		
		
	}
}

void dataSaver()
{

	std::vector<double> pastVals(5, 0.0);

	while( unityRunning )
	{
		pastVals.erase(pastVals.begin());
		pastVals.push_back(sharedMemory.sdata->xf);
		//pastVals.push_back(dataGen.getFootPos());
		if(is_sorted(pastVals.begin(),pastVals.end()))
		{
			movingForward = false;
			movingBackward = true;
		}
		else if(is_sorted(pastVals.rbegin(),pastVals.rend()))
		{
			movingForward = true;
			movingBackward = false;
		}
		else
		{
			movingForward = false;
			movingBackward = false;
		}
		
		
		sharedMemory.save2file(movingBackward,movingForward);
		
		// Sleep in between calls to foot position.
		// This helps negate the effect of noise on foot position,
		// which can cause a falsely reported change in direction
		usleep(30000);
	}
	
	
	
}		


// void moveTreadmill(double footPos, double kDesired)
// {
// 	if(footPos < -10) {return;}
// 	
// 	if(footPos < 1) { footPos = 0.26; }
// 	
// 	if(footPos > 100) { footPos = 99; }
// 	
// 	
// 	
// 	double uFeedForward = feedForwardFunction(footPos,kDesired);
// 	
// 	double u = uFeedForward;
// 	
// 	x[0] = u;
// 	xFilt[0] = bFilt[0]*x[0] + bFilt[1]*x[1] + bFilt[2]*x[2] - aFilt[1]*xFilt[1] - aFilt[2]*xFilt[2];
// 	u = xFilt[0];
// 	
// 	x[2] = x[1];
// 	x[1] = x[0];
// 	xFilt[2] = xFilt[1];
// 	xFilt[1] = xFilt[0];
// 	
// 	
// 	if(kDesired > 5e5) { u = 0.01; }
// 	
// 	if(u > 38) { u = 38; }
// 	
// 	if (u < 0.01) { u = 0.01; }
// 	
// 	sharedMemory.sdata->xd = u;
// 	
// 	move_track(u);
// 	
// 	//sdata->Kd = kDesired;
// 	
// }
// 
// 
// double feedForwardFunction(double xfoot, double Kd)
// {
// 
// 	int K_table, xf_table;	
// 	const double dK1 = 1000.0;
// 	const double dK2 = 100000.0;
// 	const double K_01 = 10000.0;
// 	const double K_02 = 100000.0;	
// 	const double xf_0 = 1.0;
// 	const double dxf = 0.5;
// 	const double theta1_0 = 0.1; // beginning value for theta1 table
// 	const double dtheta1 = 0.5;
// 	double uff;
// 
// 	/* ----( Feedforward )---- */
// 	if (Kd < 100001.0)
// 	K_table = static_cast<int>( ( (Kd - K_01)/dK1) + 0.5); // Note: +0.5 used for rounding
// 	else 
// 	K_table = static_cast<int>( (90 + (Kd - K_02)/dK2) + 0.5);
// 	
// 	xf_table = static_cast<int>( (xfoot - xf_0)/dxf + 0.5);
// 	uff = track_position_table(xf_table, K_table); // Updates desired track position
// 	
// 	return uff;
// }
// 
// 
// void move_track(float pos)
// {
// 	
// 	uint16_t *mtp1 = convert64to16(pos);
// 	
// 	if(modbus_write_registers(ctx,550,4,mtp1) < 0)
// 		fprintf(stdout,"Can't write position\n");
// 	
// 	const uint16_t mtcntl[1] = {768};
// 	if(modbus_write_registers(ctx,532,1,mtcntl) < 0)
// 		fprintf(stdout, "Can't set control\n");
// 	
// 	const uint16_t mtset[2] = {0,1};
// 	if(modbus_write_registers(ctx,554,2,mtset) < 0)
// 		fprintf(stdout,"Can't set motion\n");
// 	
// 	const uint16_t mtmove[2] = {0,0};
// 	if(modbus_write_registers(ctx,544,2,mtmove) < 0)
// 		fprintf(stdout,"Can't move\n");
// 	
// 	return;
// }
// 
// 
// 
// uint16_t* convert64to16(float p)
// {
// 	uint16_t *mtp1 = new uint16_t[4];
// 	
// 	int a, b, c, d, e, f, g, h, q, i;
// 	q = p*(pow(2,20))*2500/2749;
// 	a = q/65536; 
// 	b = q%65536;
// 	c = a/65536;
// 	d = a%65536;
// 	e = c/65536; 
// 	f = c%65536;
// 	g = e/65536; 
// 	h = e%65536;
// 
// 	mtp1[0] = h;
// 	mtp1[1] = f;
// 	mtp1[2] = d;
// 	mtp1[3] = b;
// 	
// 	return mtp1;
// }
// 
// 
// int initialize_modbus(void){
// 
// 	//establish connection
// 	ctx = modbus_new_tcp("192.168.0.35", 502);
// 	if (modbus_connect(ctx) == -1) {
//     		fprintf(stderr, "Connection failed: %s\n", modbus_strerror(errno));
//     		modbus_free(ctx);
// 		return -1;
// 	}
// 
// 	//enable drive
// 	const uint16_t drven[2]={0,1};
// 	if (modbus_write_registers(ctx,254,2,drven) < 0){
// 		fprintf(stdout, "Drive enable failed\n");
// 		return -1;
// 	}
// 
// 	//go home
// 	const uint16_t homeset[2]={1,1};
// 	if (modbus_write_registers(ctx,418,2,homeset) < 0){
// 		fprintf(stdout,"Cannot go home\n");
// 		return -1;
// 	}
// 	
// 	// set resolution
// 	const uint16_t enc_res[1]={1024};
// 	modbus_write_registers(ctx,984,1,enc_res);
// 	return 0;
// }
// 
// void my_handler(int s){
// 	fprintf(stdout, "Caught signal %d\n",s);
// 	sharedMemory.sdata->data_exchange = FALSE;
// 	//fclose(fp);
// 	modbus_close(ctx);
// 	modbus_free(ctx);
// 	//terminate_data_exchange(sdata);	   
// 	exit(1); 
// }

void printCharVec(std::vector<char> vec)
{
	std::copy(vec.begin(), vec.end(), std::ostream_iterator<char>(std::cout));
	std::cout << std::endl;
}

std::string charVecToStr(std::vector<char> vec)
{
	std::string convertedStr(vec.begin(), vec.end());
	return convertedStr;
}

std::vector<double> arrayToVec(double *inputArray)
{
	
	return std::vector<double>(inputArray, inputArray + 6);

}
	
	
	
	