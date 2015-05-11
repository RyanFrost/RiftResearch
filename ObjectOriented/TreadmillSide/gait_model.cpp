#include <stdio.h>
#include <stdlib.h>
#include <cmath>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <math.h>
#include <limits.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/time.h>
#include <string.h>
#include <sstream>
#include <unistd.h>
#include <stdint.h>
#include <ncurses.h>
#include <signal.h>
#include "modbus/modbus.h"
#include <errno.h>
#include <sys/types.h>
#include "lookup_table.h" //adds big lookup table

#include <list>
#include <vector>
#include <algorithm>

#ifndef M_PI 
#define M_PI 3.14159
#endif

using namespace std;

#define SHM_SIZE 1024 /* make it a 1K shared memory segment */

const char filename[] = "mydata.txt";

// updated 6/30/2014
struct sensor_data {
int motorv_int; // voltage to motor in int format
double lcR_lbs; // Right loadcell [lbs] (was lc1)
double lcL_lbs; // Left loadcell [lbs] (was lc2)
double time;	// Absolute system time (sec) the Arduino measurement was taken
uint8_t motorv_2Arduino; // Commanded motor voltage to Arduino range: [0-255] [0-5]V
double motorv_double; // Commanded motor voltage: [0-5]V
double tspeed_actual;	// Actual treadmill speed
double tspeed_desired;	// Desired treadmill speed
bool enable_treadmill;	// Enable treadmill motor
bool data_exchange;	// Bool for acknowledging data exchange with Arduino
float xd; // Linear track desired position wrt the home position in cm
float xact; // Linear track actual position wrt the home position in cm
int perturb; // (T/F) perturb this cycle?
int cycle; // number of gait cycles
double angle_enc; // angle from encoder (deg)
double Kd; // Desired stiffness
double Kact; // Actual Stiffness
double force_b; // Force at location B of kin. analysis
double elapsed; // Time elapsed each iteration of VST for loop
bool start_EMG; // Tells to start collecting EMG data
bool get_EMG; // Tells when to get EMG
bool experiment; // Tells wheather to do experiment or stop it.
int numEMG; // Number of EMG electrodes used in experiment
bool beep; // Causes beep
double time_vst_absolute; // Timestamp for each iteration of vst code in absolute computer time
double zero_time_absolute; // Timestamp for Zero time of EMG data in absolute computer time
double marker_x_posl[6]; 	// x position of left leg markers from DUO wrt camara
double marker_y_posl[6]; 	// y position of left leg markers from DUO wrt camara
double jt_angles_l[3];		// joint angles left leg
double xf;					// foot position x only (average of both foot makers in x)
};

/* ----( Function Prototypes )---- */
void track_position(double, double);
void convert64to16(float);
void my_handler(int);
int initialize_modbus(void);
void move_track(float);
float read_track(void);
void get_angle_enc(void);
double time_elapsed(struct timeval *, struct timeval *);
void save2file(sensor_data *, double, bool, bool, bool);
void shareMemSetup(void);
bool is_sorted(vector<double>);
bool isToeOff(vector<double>);
bool isHeelStrike(vector<double>);
double feedForwardFunction(double);

/* ----( Global Variables )---- */
uint16_t mtp1[4];
sensor_data *sdata;
modbus_t *ctx;
FILE *fp;

/* ----( Main Function )---- */
int main (int argc, char *argv[])
{
	// Variables
	struct timeval start, end; // for calculating duration of iteration
	struct sigaction sigIntHandler; // for catch Ctrl+C
	
	// Catch Ctrl+C signal
   	sigIntHandler.sa_handler = my_handler;
   	sigemptyset(&sigIntHandler.sa_mask);
   	sigIntHandler.sa_flags = 0;
    sigaction(SIGINT, &sigIntHandler, NULL);

	// open mydata.txt
	fp = fopen(filename, "w");
	
	// Initialize structures
	sdata = (sensor_data *) malloc(sizeof(sensor_data)); 

	// Setup shared memory
	shareMemSetup();

	// Initialize modbus
	if (initialize_modbus() < 0)
	exit(1);
	
	// Vector variables
	vector<double> pastVals(5,0); // 5x1 vector of zeros
	vector<double> vec(5,0);

	// Initiation of static variables
	double xb = 0.33; // distance from treadmill rotatation point to junction point [m]
	// random 3 to 7 cycles
	int random_mat[91] = {5,8,15,19,25,29,35,39,42,47,50,57,62,69,72,76,81,85,92,98,105,111,115,119,125,130,136,141,144,147,152,157,162,169,173,177,183,189,192,199,204,208,215,219,225,228,232,237,240,246,252,256,261,264,270,274,280,283,290,294,297,	304,310,313,317,323,329,334,339,346,351,358,361,366,369,374,377,384,387,394,400,406,411,416,421,428,432,436,442,447,450}; 
	// random matrix for perturbation location
	// location 1 = Loading Phase / Heal-strike
	// location 2 = Mid Stance
	// location 3 = Terminal Stance / Toe-off
	//int location[91] =  {3,2,3,2,1,2,3,1,1,3,1,2,3,1,2,2,1,3,2,3,1,3,2,2,1,3,1,3,2,3,2,1,3,1,2,1,2,3,1,1,3,1,2,3,2,3,3,1,2,2,3,1,2,1,3,1,1,3,1,2,2,2,3,2,1,3,3,1,2,1,2,3,2,1,1,3,3,2,3,2,1,1,3,2,1,2,3,2,1,3,1};
	// right now only at HS
	int location[91] =  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};	
	// random matrix for perturbation magnitude/1000
	double magnitude[91] = {50,50,10,100,50,10,100,10,100,50,50,100,10,10,10,50,100,100,100,100,10,50,10,50,100,10,50,100,100,50,50,100,10,50,10,10,100,50,10,100,10,50,50,100,10,100,50,10,50,100,10,	50,10,100,50,50,100,100,10,10,100,50,10,10,100,100,10,50,100,10,50,50,100,100,10,100,10,50,50,10,50,50,10,100,10,50,50,10,100,100,100};
	double bFilt[3] = {0.0976, 0.1953, 0.0976}; // from matlab butter n = 2, wn = .01
	double aFilt[3] = {1.0000, -0.9428, 0.3333};
	int num_cyc_inf = 30; // # cycles on infinite stiffness
	

	// Initialization of dynamic variables
	double xfoot, xmid, xterm;
	sdata->elapsed = 0.040; // approx. time of each iteration 
	bool filterData = true;
	bool flag = FALSE;
	bool heelStrike = false;
	bool changedStiffness = false;
	bool movingForward = false;
	bool movingBackward = false;
	bool transitioning = false;
	bool continuePerturb = false;
	double err = 0;
	int ind = 0;
	int count = 0;
	int range_num = 0;
	double uff = 0;
	double u = 0;
	double x[3] = {0,0,0};
	double xFilt[3] = {0,0,0};
	
	timeval timeValue; // for timestamp
	timeval zeroTimeVal; // for zero time
	double time_us = 0; // microsecond time for timestamp
	double timeZero_us = 0; // microsecond time for zero timestamp
		
	
	
	// Initialize variables in shared memory
	sdata->experiment = FALSE; // make sure sdata->experiment is false for correct timing
	sdata->cycle = 0; // make sure number of cycles is 0 

	/* ----( Wait to start experiment )---- */
	cout << "\nWaiting to start experiment...\n";
	while (sdata->experiment == FALSE){} // waits for 'main' to change 'experiment' to true
	// Zero Time for syncronization
	gettimeofday(&zeroTimeVal,0);
	timeZero_us = (double)(zeroTimeVal.tv_usec);
	sdata->zero_time_absolute = zeroTimeVal.tv_sec + timeZero_us/1000000; // zero time for emg
 	while (sdata->start_EMG == FALSE){}  // waits for 'main' to change 'start_EMG' to true
	
	while (sdata->experiment) // continuously runs experiment unless 'main' ends the experiment
	{
		/* ----( Read in data )---- */
		// Get EMG data
		sdata->get_EMG = TRUE;
		cout << "Called 'get EMG'\n";

		// Keep constant foot positon through the loop
		xfoot = sdata->xf; // foot position of left (pertrubed) leg
		
		// Check for good foot position data
		if (xfoot < -10) // DUOs return -9999 if marker not seen
		flag = TRUE;
		else
		flag = FALSE;
		
		if (!flag) // i.e. No NAN problems for xf
		{
			// Needed to avoid negative index in lookup table
			if (xfoot < 1 && xfoot > -10) 
			xfoot = 0.26;

			if (xfoot > 100)
			xfoot = 99;

			// get current angle
			get_angle_enc(); 
			if ( sdata->angle_enc <= 0 )
			sdata->angle_enc = 0.01;

			// Default stiffness
			sdata->Kd = 1e6; // inf
		
			/* ----( Calculations for perturbations )---- */
			xmid = 45; // approx. midline of person
			xterm = xmid+15.0; // Terminal stance perturbation begins when foot crosses plane 15 cm after midline
			
			// Calculate xf progression
			pastVals.erase(pastVals.begin());  // Removes first element from list
			pastVals.push_back(xfoot);		   // Adds current foot pos to end of list
			vec = pastVals;
			vector<double> vecReverse(vec.rbegin(),vec.rend()); // Creates reverse xf vector
	
			// Find progression of foot position
			if (is_sorted(vecReverse)) // See if values of xf are decreasing
			{
				movingForward = true;
				movingBackward = false;
				transitioning = false;
				cout << "moving forward\n";
			}
			else if (is_sorted(vec)) // See if values of xf are increasing
			{				
				movingForward = false;				
				movingBackward = true;
				transitioning = false;
				cout << "moving backward\n";
			}
			else // foot changing direction
			{
				movingForward = false;
				movingBackward = false;
				transitioning = true;
				cout << "transitioning\n";
			}

			// Increment cycle number if pass midline during swing phase of left leg
			//if ( fabs(xfoot-xmid+10) <= 10.0 && movingForward ) 
			if ( movingForward ) 
			{
				range_num++;
				if (range_num == 1) // only increase cycle number for first time in the range
				sdata->cycle++;
				
			   	// end experiment when completed all cycles
				if (sdata->cycle == num_cyc_inf + random_mat[90])
				{
					cout << "Experiment will stop in 10 sec\n";
					cout << "Slow down treadmill!!!\n";
					sleep(10);
					sdata->experiment = FALSE;
				}
			}
			else if ( movingBackward )
			range_num = 0;
			
			// reset range value if outside of the range
			//if (fabs(xfoot-xmid+10) >= 10.0) 
			//range_num = 0;	
		
			/* ----( Perturbations )---- */
			if (sdata->cycle == (num_cyc_inf + random_mat[ind])) // i.e. a perturbation cycle
			{
				/* ----( Loading/Heel-Strike Perturbation )---- */
				if (location[ind] == 1)
				{
					// if ( (isHeelStrike(vec) && xfoot < 40) || movingBackward || (count>0 && count<5) ) // could try
					// if ( ~movingForward )
					if ( (isHeelStrike(vec) && xfoot < 40) || continuePerturb )
					{
						sdata->Kd = 1000.0*magnitude[ind]; // Magnitude of stiffness perturbation
						sdata->perturb = location[ind];
						changedStiffness = true;
						count++;
						
						if ( ~movingForward )
						continuePerturb = true;
						else
						continuePerturb = false;
						
					}
					else // i.e. movingForward (swing phase), can be before and after HS in this cycle 
					{
						// only increase index if a perturbation has occurred (after toe-off)
						if ( changedStiffness ) 
						ind++;
						
						// reset after perturbation
						sdata->perturb = 0;
						changedStiffness = false;
						continuePerturb = false;
						count = 0;
					}	
				}
			}
			else // i.e. not a perturbation cycle
			{
				// make sure reset to 0		
				sdata->perturb = 0;
				changedStiffness = false;
				continuePerturb = false;
				count = 0;
			}

			/* ----( Controller )---- */
			// Calculate actual stiffness
			sdata->Kact = (xb*sdata->force_b) / (pow( (sdata->xf/100.0) ,2.0)*tan(sdata->angle_enc*M_PI/180.0));
			
			// Calculate error
			err = sdata->Kd - sdata->Kact;
			
			// Feedforward
			uff = feedForwardFunction(xfoot);
			
			// control input
			u = uff;

			/* ----( Filter output )---- */
			if (filterData)
			{
				// filter				
				x[0] = u;
				xFilt[0] = bFilt[0]*x[0] + bFilt[1]*x[1] + bFilt[2]*x[2] - aFilt[1]*xFilt[1]- aFilt[2]*xFilt[2];	
				u = xFilt[0];

				// update filter
				x[2] = x[1];
				x[1] = x[0];
				xFilt[2] = xFilt[1];
				xFilt[1] = xFilt[0];
			}
			
			// Ensure infinite stiffness when desired
			if (sdata->Kd > 5e5)
			u = .01;
	
			// bound track movement for safety
			if (u>38)
			u = 38;

			if(u<.01)
			u = .01;

			/* ----( Move track )---- */
			sdata->xd = u;
			move_track(sdata->xd);

		} // close of "if (flag==0)"

		// Increase index if missed for some reason
		if( (num_cyc_inf + random_mat[ind]) < sdata->cycle)
		ind++; 

		// Actual track position		
		sdata->xact = read_track();

		/* ----( Print data to sceen and file )---- */
		cout << "\033[2J\033[1;1H"; // clears terminal screen
		fprintf(stdout, "xf: %f   xd: %f theta1: %f\nKd: %f Kact: %f\n", sdata->xf, sdata->xd, sdata->angle_enc, sdata->Kd, sdata->Kact);
		//fprintf(stdout, "perturb: %d ind %d\n",sdata->perturb, ind);
		fprintf(stdout, "location: %d next pert cycle: %d magnitude %f\n",location[ind], num_cyc_inf + random_mat[ind],magnitude[ind]);
		fprintf(stdout, "cycle %d of %d\n",sdata->cycle, num_cyc_inf + random_mat[90]);
		//printf(stdout,"Number of Markers: EMG: %d\n", sdata->numEMG);
		
		gettimeofday(&end, NULL);
		sdata->elapsed = time_elapsed(&start, &end);
		fprintf(stdout, "Time elapsed: %f s\n", sdata->elapsed);
		fprintf(stdout,"---------------------\n");
		gettimeofday(&start, NULL);
			
		gettimeofday(&timeValue,0);
		time_us = (double)(timeValue.tv_usec);
		sdata->time_vst_absolute = timeValue.tv_sec + time_us/1000000;
		save2file(sdata, xfoot, movingBackward, movingForward, transitioning);// call if you want data to be saved to a file
		
	} // sdata->experiment = FALSE
	
	// close everything
	fprintf(stdout,"Exiting...\n");	
	//sleep(8);
	sdata->data_exchange = FALSE;
	fclose(fp);
	modbus_close(ctx);
	modbus_free(ctx);
	fprintf(stdout,"\n Done!\n\n");

}

//---------------------------//
/* ----( Sub Functions )---- */
//---------------------------//
void save2file(sensor_data * d, double xfoot, bool movingBackward, bool movingForward, bool transitioning) 
{
	// ensure proper spacing between 'fprintf' w/ a space after last %f
	fprintf(fp,"%d %f %f ",d->motorv_int /*1*/, d->lcR_lbs/*2*/, d->lcL_lbs/*3*/);

	fprintf(fp,"%f %f %f %f %d %f %f %f %f %f ", d->time /*4*/,d->tspeed_desired/*5*/, d->xd/*6*/, d->xact/*7*/, d->perturb/*8*/,d->angle_enc/*9*/, d->Kd/*10*/, d->Kact/*11*/, d->force_b/*12*/, d->elapsed/*13*/);

	fprintf(fp,"%d %d %f %f ", d->numEMG/*14*/,d->cycle/*15*/,d->time_vst_absolute/*16*/,d->zero_time_absolute/*17*/);

	//Jeremy added
	//double marker_x_posl[6]; 	// x position of left leg markers from DUO wrt camara
	//double marker_y_posl[6]; 	// y position of left leg markers from DUO wrt camara
	//double jt_angles_l[3];		// joint angles left leg
	//double xf;					// foot position x only (average of both foot makers in x)
 
	for (int i = 0; i<3; i++)
	fprintf(fp,"%f ", d->jt_angles_l[i]); /*18-20*/ 

	fprintf(fp,"%f ", xfoot);/*21*/
	
	fprintf(fp,"%d %d %d", movingBackward/*22*/, movingForward/*23*/, transitioning/*24*/); 

	fprintf(fp,"\n");
}

bool is_sorted(vector<double> posVec)
{
	for (int vecIter = 0; vecIter < posVec.size()-1; vecIter++)
	{
		if ( posVec[vecIter] > posVec[vecIter+1] )
		{
			return false;
		}
	}
	return true;
}

bool isHeelStrike(vector<double> posVec)
{
	// can improve
	double prog4 = posVec[0];
	double prog3 = posVec[1];
	double prog2 = posVec[2];
	double prog1 = posVec[3];
	double prog0 = posVec[4];
						
	if( (prog4-prog3)>=0 && (prog3-prog2)>=0 && (prog2-prog1)<=0 && (prog1-prog0)<=0 )
	return true;
	else
	return false;
	
/*	Ryan's code
	int mid = posVec.size()/2;
	
	for (int vecIter = 0; vecIter < mid; vecIter++)
	{
		
		if ( posVec[mid+vecIter+1] > posVec[mid+vecIter] || posVec[mid-vecIter-1] > posVec[mid-vecIter])
		{
			return false;
		}
	}
	return true;
*/
}

bool isToeOff(vector<double> posVec)
{
	
	
	int mid = posVec.size()/2;
	
	for (int vecIter = 0; vecIter < mid; vecIter++)
	{
		
		if ( posVec[mid+vecIter+1] < posVec[mid+vecIter] || posVec[mid-vecIter-1] < posVec[mid-vecIter])
		{
			return false;
		}
	}
	return true;
}

double feedForwardFunction(double xfoot)
{

	int K_table, xf_table;	
	const double dK1 = 1000.0;
	const double dK2 = 100000.0;
	const double K_01 = 10000.0;
	const double K_02 = 100000.0;	
	const double xf_0 = 1.0;
	const double dxf = 0.5;
	const double theta1_0 = 0.1; // beginning value for theta1 table
	const double dtheta1 = 0.5;
	double uff;

	/* ----( Feedforward )---- */
	if (sdata->Kd < 100001.0)
	K_table = static_cast<int>( ( (sdata->Kd - K_01)/dK1) + 0.5); // Note: +0.5 used for rounding
	else 
	K_table = static_cast<int>( (90 + (sdata->Kd - K_02)/dK2) + 0.5);
	
	xf_table = static_cast<int>( (xfoot - xf_0)/dxf + 0.5);
	uff = track_position_table(xf_table, K_table); // Updates desired track position
	
	return uff;
}

void convert64to16(float p){
	int a, b, c, d, e, f, g, h, q, i;
	q = p*(pow(2,20))*2500/2749;
	a = q/65536; 
	b = q%65536;
	c = a/65536;
	d = a%65536;
	e = c/65536; 
	f = c%65536;
	g = e/65536; 
	h = e%65536;

	mtp1[0] = h;
	mtp1[1] = f;
	mtp1[2] = d;
	mtp1[3] = b;
}


void my_handler(int s){
    fprintf(stdout, "Caught signal %d\n",s);
	sdata->data_exchange = FALSE;
	fclose(fp);
	modbus_close(ctx);
	modbus_free(ctx);
	//terminate_data_exchange(sdata);	   
    exit(1); 
}

int initialize_modbus(void){

	//establish connection
	ctx = modbus_new_tcp("192.168.0.35", 502);
	if (modbus_connect(ctx) == -1) {
    		fprintf(stderr, "Connection failed: %s\n", modbus_strerror(errno));
    		modbus_free(ctx);
		return -1;
	}

	//enable drive
	const uint16_t drven[2]={0,1};
	if (modbus_write_registers(ctx,254,2,drven) < 0){
		fprintf(stdout, "Drive enable failed\n");
		return -1;
	}

	//go home
	const uint16_t homeset[2]={1,1};
	if (modbus_write_registers(ctx,418,2,homeset) < 0){
		fprintf(stdout,"Cannot go home\n");
		return -1;
	}
	
	// set resolution
	const uint16_t enc_res[1]={1024};
	modbus_write_registers(ctx,984,1,enc_res);
	return 0;
}

void move_track(float pos){

	convert64to16(pos); //global mtp1 changed
	//write task position
	if(modbus_write_registers(ctx,550,4,mtp1) < 0)
	fprintf(stdout, "Cannot write position\n");

	//allow for interuptions (forget last command)
	const uint16_t mtcntl[1]={768};		
	if (modbus_write_registers(ctx,532,1,mtcntl) < 0)
   	fprintf(stdout,"Cannot set control\n");

	//set motion
	const uint16_t mtset[2]={0,1};
	if (modbus_write_registers(ctx,554,2,mtset) < 0)
   	fprintf(stdout,"Cannot set motion\n");

	//start motion
	const uint16_t mtmove[2]={0,0};
	if (modbus_write_registers(ctx,544,2,mtmove) < 0)
	fprintf(stdout, "Cannot move\n");

	return;
}

float read_track(void){
	uint16_t tab_reg[64];
	int rc = modbus_read_registers(ctx, 588, 4, tab_reg);
	//convert 16 to 64
	float q=((float)tab_reg[3])/65536; 
	q=q+tab_reg[2];
	q=q*65536;
	q=q/(pow(2,20))*2749/2500;
	return q;
}

void get_angle_enc(void)
{

	uint16_t tab_reg[16];	
	//for (int i = 0; i < 16; i++)
	//	tab_reg[i] = 0;


	int rr = modbus_read_registers(ctx, 258, 2, tab_reg);
	if (rr == -1) 
    	fprintf(stderr, "%s\n", modbus_strerror(errno));
	
	//convert to deg
	float ang=((float)tab_reg[1])/65536*90;

	if (ang > 45)
	ang = 0; 
  	
	sdata->angle_enc = ang;

}

double time_elapsed(struct timeval * start, struct timeval * end)
{
    double elapsed;
    
    if (end->tv_usec < start->tv_usec)
    {
	end->tv_sec--; 	
	end->tv_usec+=1000000;
    }
     //fprintf(stdout, "%ld.%06ld\n", end->tv_sec, end->tv_usec);

    elapsed = (double) (end->tv_usec-start->tv_usec);
    elapsed = elapsed/1000000 + (end->tv_sec-start->tv_sec);

    return elapsed;
}

void shareMemSetup(void)
{
	key_t key;
    int shmid;
	/* ----( Shared Memory )---- */
	/* make the key */
    if ( (key=ftok("/home/treadmill/Desktop/ArduinoCodes/shmfile",'R')) == -1 ) 
    {
    	perror("ftok-->");
	    exit(1);
    }
	if ((shmid = shmget(key, SHM_SIZE, 0666 | IPC_CREAT)) == -1) 
	{	
    	perror("shmget");
    	exit(1);
    }
	
	sdata = (sensor_data *) shmat(shmid, (void *)0, 0);
    if (sdata == (sensor_data *) (-1)) 
    {
    	perror("shmat");
    	exit(1);
    }
}




