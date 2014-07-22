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
#include "vince_linux.h" //adds marker structure

#include "track_position_table.h"
#include <list>
#include <vector>
#include <algorithm>
#include <unistd.h>

#ifndef M_PI 
#define M_PI 3.14159
#endif

using namespace std;

#define SHM_SIZE 1024 /* make it a 1K shared memory segment */

const char filename[] = "mydata.txt";
//const char filename_emg[] = "emg_sampled_data.txt";

// updated 5/3/2014
struct sensor_data {
int motorv_int; // voltage to motor in int format
double lc1_lbs; // loadcell 1 in pounds
double lc2_lbs; // loadcell 2 in pounds
double time;	// Absolute system time (sec) the Arduino measurement was taken
uint8_t motorv_2Arduino; // Commanded motor voltage to Arduino range: [0-255] [0-5]V
double motorv_double; // Commanded motor voltage: [0-5]V
double tspeed_actual;	// Actual treadmill speed
double tspeed_desired;	// Desired treadmill speed
bool enable_treadmill;	// Enable treadmill motor
bool data_exchange;	// Bool for acknowledging data exchange with Arduino
float xd; // Linear track desired position wrt the home position in cm
float xact; // Linear track actual position wrt the home position in cm
int forcesensors_int[8]; // force sensor vector in int format
double forcesensors_lbs[8]; // force sensor vector in pounds
double foot_pos_x; // x position of foot along treadmill in cm
double foot_pos_y; // y position of foot above treadmill in cm
double mid_stance_x; // Average of torso and hip positions (x)
double x_markers[10]; // x position of markers from NDI wrt camara
double y_markers[10]; // y position of markers from NDI wrt camara
double z_markers[10]; // z position of markers from NDI wrt camara
int perturb; // (T/F) perturb this cycle?
int cycle; // number of gait cycles
double angle_enc; // angle from encoder (deg)
double Kd; // Desired stiffness
double Kact; // Actual Stiffness
double force_b; // Force at location B of kin. analysis
double elapsed; // Time elapsed each iteration of VST for loop
double* sharedData; // Pointer to emg data
bool start_EMG; // Tells to start collecting EMG data
bool get_EMG; // Tells when to get EMG
double time_emg; // Computer time that emg was sampled
bool experiment; // Tells wheather to do experiment or stop it.
int numEMG; // Number of EMG electrodes used in experiment
bool beep; // Causes beep
//
double time_vst_startEMG;
double time_vst_absolute;
double start_aq_grt;
double start_aq_gtod;
double time_emg_startEMG;
double time_emg_absolute;
};


/* ----( Function Prototypes )---- */
void foot_tracking(double, double, double, double, double, double,double, double, double, double, double, double); // foot and torso tracking
//void foot_tracking(double, double, double, double, double, double); // just foot tracking
void track_position(double, double);
void convert64to16(float);
void my_handler(int);
int initialize_modbus(void);
void move_track(float);
float read_track(void);
void get_angle_enc(void);
double time_elapsed(struct timeval *, struct timeval *);
void save2file(sensor_data *);
void save2file_emg(sensor_data *);

bool is_sorted(vector<double>);

//float track_position_table(int, int);

/* ----( Global Variables )---- */
uint16_t mtp1[4];
sensor_data *sdata;
modbus_t *ctx;
FILE *fp;
FILE *fp_emg;

/* ----( Main Function )---- */
int main (int argc, char *argv[])
{
	struct timeval start, end;
	key_t key;
    int shmid;
	int flag;
	int rc, rcb, rcw, i;
	struct sigaction sigIntHandler;
	
	// Catch Ctrl+C signal
   	sigIntHandler.sa_handler = my_handler;
   	sigemptyset(&sigIntHandler.sa_mask);
   	sigIntHandler.sa_flags = 0;
        sigaction(SIGINT, &sigIntHandler, NULL);

	fp= fopen(filename, "w");
	//fp_emg= fopen(filename_emg, "w");
	
	// Initialize structures
	sdata = (sensor_data *) malloc(sizeof(sensor_data)); 

	/* ----( Shared Memory )---- */
	/* make the key */
    if ( (key=ftok("/home/treadmill/Desktop/ArduinoCodes/shmfile",'R')) == -1 ) {
      	      perror("ftok-->");
	      exit(1);
        }
	if ((shmid = shmget(key, SHM_SIZE, 0666 | IPC_CREAT)) == -1) {
           perror("shmget");
           exit(1);
        }
	
	sdata = (sensor_data *) shmat(shmid, (void *)0, 0);
    	if (sdata == (sensor_data *) (-1)) {
      	   perror("shmat");
     	   exit(1);
    	}

	/* ----( Initialize modbus )---- */
	if (initialize_modbus() < 0)
	exit(1);

	/* ----( Connect to NDI system )---- */	
/*	char *main_ip_address = "10.200.148.198"; // VST space 
   	markers_struct markers;

	fprintf(stdout, "Trying to connect to the server %s\n", main_ip_address);
	markers = initialize_markers(main_ip_address);
 	fprintf(stdout, "Connected\n");

    	update_markers(&markers);
	printf("Number of Markers: %d\n",markers.size);*/
 	   	
	// Initialization
	int K_table, xf_table;	
	const double dK1 = 1000.0;
	const double dK2 = 100000.0;
	const double K_01 = 10000.0;
	const double K_02 = 100000.0;	
	const double xf_0 = 1.0;
	const double dxf = 0.5;
	const double theta1_0 = 0.1; // beginning value for theta1 table
	const double dtheta1 = 0.5;
	double xb = 0.33;
	double err = 0;
	double err_integrate = 0;
	double errp = 0;
	double uff = 0;
	double ufb = 0;
	//double duff = 0;
	//double dufb = 0;
	//double uffp = 0;
	double P = 0;
	double I = 0;
	double D = 0;
	double u = 0;
	double u_filt = 0;
	double Kact_p = 0;
	double Kp = 0.00000435;
	double Ki = 0.0005;
	bool control = TRUE; // to use PI feedback controller
	int delay = 0;
	double b_filt[3] = {0.0976, 0.1953, 0.0976}; // from matlab butter n = 2, wn = .01
	double a_filt[3] = {1.0000, -0.9428, 0.3333};
	double x0 = 0; 
	double x1 = 0; 
	double x2 = 0;
	double x0_filt = 0;
	double x1_filt = 0;
	double x2_filt = 0;
	sdata->xd = 0;
	sdata->elapsed = 0;
	flag = 1;
	// random 3 to 7 cycles
	
	int ind = 0;
	int range_num = 0;
	int counter1 = 0;
	int counter2 = 0;
	int counter3 = 0;
	//int cycle = 0;
	int num_cyc_inf = 10; // # cycles on infinite stiffness
	double xmid = 0;
	double xf = 0;
	double xterm = 0;
	double progress = 0;
	double prog1 = 0;
	double prog2 = 0;
	double prog3 = 0;
	double prog4 = 0;
	double prog5 = 0;
	int cont1 = 0;
	int cont2 = 0;
	int cont3 = 0;
	int length_of_for_loop = 1000000000;	
	bool hs = FALSE;

	sdata->experiment=FALSE;
	sdata->cycle = 0;
	bool end_low_stiff = FALSE;

//***************************
 	timeval a, b;
	gettimeofday(&a,0);
	double t = (double)(a.tv_usec);
	//double time_vst_startEMG = a.tv_sec + t/1000000;
	sdata->time_vst_startEMG = a.tv_sec + t/1000000; // <--------
	double past1 = 0;
	double past2 = 0;
	double past3 = 0;


	
	bool goneForward = true;
	bool goneBackward = true;

	bool swing_phase;
	bool changedStiff = false;
	bool cycled = false;
	bool movingForward = false;
	bool movingBackward = false;
	bool movingBackwardFirst = false;
	sdata->beep = FALSE;
//********************************
	while( true )
	{
		end_low_stiff = FALSE;		
		sdata->beep = FALSE;
		changedStiff = false;
		cycled = false;
		movingForward = false;
		movingBackward = false;
		movingBackwardFirst = false;
		// Normal inf stiffness
		sdata->Kd = 1e6;
		sdata->xd = 0.01;
		move_track(sdata->xd);
		cout << "Waiting\n";			
		// wait for beep	
		fprintf(stdout, "Waiting for beep\n");
		while(!sdata->beep)
		{
			
			past3 = past2;
			past2 = past1;
			past1 = xf;
			xf = sdata->foot_pos_x;
			fprintf(stdout,"Values: %f, %f, %f, %f\n",xf,past1,past2,past3);
			usleep(500000);
		}	
		cout << "Beeping\n";
		// Sand Stiffness
		 

		while(!end_low_stiff && sdata->beep)
		{	
			
			
			//fprintf(stdout, "Sand!!!!!\n");
			// Calculate xf progression
						

			
			

			fprintf(stdout,"Normal: %f, %f, %f.\nReversed: %f, %f, %f.\n",
						pastValsSmall[0],pastValsSmall[1],pastValsSmall[2],
						vecReverse[0],vecReverse[1],vecReverse[2]);

			

				
			if ( movingForward && fabs(xf-45.0)<=5)
			{
				changedStiff = true;
				sdata->Kd = 6e4;
				cout << "changed stiffness\n";
			}

			
			if (movingBackward && changedStiff)
			{
				cycled = true;
				cout << "cycled\n";
			}
			//cout << "Foot pos = " << xf << "\n";
			//cout << "Stiffness: " << sdata->Kd << "\n";
			//cout << "Cycled?: " << cycled << "\n";


			if (movingForward && cycled && fabs(xf-45.0)<=5)
			{
				end_low_stiff = TRUE;
				break;
			}
			else
				end_low_stiff = FALSE;
			past3 = past2;
			past2 = past1;
			past1 = xf;				
			
			
			if ( isnan(xf) )
			flag = 1;
			else
				flag = 0;
			
			if (flag==0) // No nan problems for xf and xmid
			{
				
				/* ----( Controller )---- */
				// Calculate actual stiffness
				sdata->Kact = (xb*sdata->force_b) / (pow( (sdata->foot_pos_x/100.0) ,2.0)*tan(sdata->angle_enc*M_PI/180.0));
		
				// Calculate error
				err = sdata->Kd - sdata->Kact;
		
				/* ----( Feedforward )---- */
				if (sdata->Kd < 100001.0)
					K_table = static_cast<int>( ( (sdata->Kd - K_01)/dK1) + 0.5); // Note: +0.5 used for rounding
				else 
					K_table = static_cast<int>( (90 + (sdata->Kd - K_02)/dK2) + 0.5);
	
				xf_table = static_cast<int>( (sdata->foot_pos_x - xf_0)/dxf + 0.5);
				uff = track_position_table(xf_table, K_table); // Updates desired track position
				//duff = uff - uffp;
				//sdata->beep = FALSE;
				/* ----( Feedback )---- */   
				if (control == TRUE)
				{	
					if (fabs(err) <= 1.0*sdata->Kd && sdata->force_b > 25 && sdata->Kd < 2e5 ) //err threshold
					{
						// PI Controller (Incremental form)
						ufb = ufb + (-1.0)*(Kp*err - Kp*errp + Ki*err*sdata->elapsed);
						//dufb = (-1.0)*(Kp*err - Kp*errp + Ki*err*sdata->elapsed);
					}
					else
					{
						ufb = 0;			
						P = 0;
						I = 0;
						D = 0;
						err_integrate = 0;
						errp = 0;
					}
				}
				else
				{
					ufb = 0;
				}
		
				/* ----( Update past values )---- */
				prog5 = prog4;
				prog4 = prog3;
				prog3 = prog2;
				prog2 = prog1;
				prog1 = xf;
				//uffp = uff;
				errp = err;

				/* ----( Filter output )---- */
				// Remove tiny adjustments
				//if (fabs(duff) < 0.05) // 0.5mm
				//duff = 0;

				if (fabs(ufb) < 0.05) // 0.5mm
				ufb = 0;

				// control input
				//u = u + dufb + duff;
				u = ufb + uff;	
				u = uff;	

				// filter
				x0 = u;
				x0_filt = b_filt[0]*x0 + b_filt[1]*x1 + b_filt[2]*x2 - a_filt[1]*x1_filt - a_filt[2]*x2_filt;	 
				u = x0_filt;

				// update filter
				x2 = x1;
				x1 = x0;
				x2_filt = x1_filt;
				x1_filt = x0_filt;
	
				// bound track movement
				if (u>38)
				u = 38;

				if(u<.01)
				u = .01;

				/* ----( Move track )---- */
				sdata->xd = u;
				move_track(sdata->xd);

			} // close of if (flag==0)
			


			
			// Actual track position		
			sdata->xact = read_track();

				
		} // end of while loop

	} // end of true loop

	sleep(.001);

	// close everything
	fprintf(stdout,"Exiting...\n");
	sdata->data_exchange = FALSE;
	fclose(fp);
	//fclose(fp_emg);
	modbus_close(ctx);
	modbus_free(ctx);
	fprintf(stdout,"\n");
	fprintf(stdout,"Done!\n");
	fprintf(stdout,"\n");
}

//---------------------------//
/* ----( Sub Functions )---- */
//---------------------------//

void positionUpdater(bool *run)
{
	vector<double> pastVals(3, 0);
	vector<double> vec(3,0);
	
	
	while(run)
	{
		xf = sdata->foot_pos_x;
		xmid = sdata->mid_stance_x;
		pastVals.erase(pastVals.begin());		// Removes first element from list
		pastVals.push_back(xf);				// Adds current foot pos to end of list
		
		
/*
		for (int iter = 0; iter < vec.size(); iter++)
		{
			vec[iter] = pastVals[iter*pastVals.size()/vec.size()];
		}
*/
		

		vec = pastVals;
		vector<double> vecReverse(pastValsSmall.rbegin(),pastValsSmall.rend());
		
		
		
		if (is_sorted(vec))
		{				
			movingForward = false;				
			movingBackward = true;
			cout << "moving backward\n";
		}
		else if (is_sorted(vecReverse))
		{	
			movingForward = true;
			movingBackward=false;
			cout << "moving forward\n";
		}
		
		
		
	}
	
}


bool is_sorted(vector<double> vec)
{
	for (int vecIter = 0; vecIter < vec.size()-1; vecIter++)
	{
		if ( vec[vecIter] > vec[vecIter+1] )
		{
			return false;
		}
	}
	return true;
}



void convert64to16(float p){
	int a, b, c, d, e, f, g, h, q, i;
	q=p*(pow(2,20))*2500/2749;
	a= q/65536; 
	b= q%65536;
	c= a/65536;
	d= a%65536;
	e= c/65536; 
	f= c%65536;
	g= e/65536; 
	h= e%65536;

	mtp1[0]=h;
	mtp1[1]=f;
	mtp1[2]=d;
	mtp1[3]=b;
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

	//sdata->xd = pos;
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
	
	//fprintf(stdout, "fb2P: %d %d j2: %d\n",tab_reg[0],tab_reg[1],rr);

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


// "#if 0" lets the preprocessor ignore this code, essentially commenting out this block without having to put "//" before each line

#if 0
void save2file(sensor_data * d) 
{
	fprintf(fp,"%d %f %f %f %f %f %f %f %f %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n", 
			d->motorv_int /*1*/, d->lc1_lbs/*2*/, d->lc2_lbs/*3*/, d->time /*4*/,d->tspeed_desired/*5*/, d->xd/*6*/,d->xact/*7*/,d->foot_pos_x/*8*/, d->mid_stance_x/*9*/, d->perturb/*10*/,
			d->angle_enc/*11*/,d->Kd/*12*/,d->Kact/*13*/,d->force_b/*14*/,d->elapsed/*15*/,d->x_markers[0]/*16*/, d->x_markers[1]/*17*/, d->x_markers[2]/*18*/, d->x_markers[3]/*19*/, 
			d->x_markers[4]/*20*/, d->y_markers[0]/*21*/, d->y_markers[1]/*22*/, d->y_markers[2]/*23*/, d->y_markers[3]/*24*/, d->y_markers[4]/*25*/, d->z_markers[0]/*26*/, 
			d->z_markers[1]/*27*/, d->z_markers[2]/*28*/, d->z_markers[3]/*29*/, d->z_markers[4]/*30*/, d->x_markers[5]/*31*/, d->x_markers[6]/*32*/, d->x_markers[7]/*33*/, 
			d->x_markers[8]/*34*/, d->x_markers[9]/*35*/, d->y_markers[5]/*36*/, d->y_markers[6]/*37*/, d->y_markers[7]/*38*/, d->y_markers[8]/*39*/, d->y_markers[9]/*40*/, 
			d->z_markers[5]/*41*/, d->z_markers[6]/*42*/, d->z_markers[7]/*43*/, d->z_markers[8]/*44*/, d->z_markers[9]/*45*/,d->numEMG/*46*/);

	, d->sharedData[0]/*47*/,d->sharedData[1]/*48*/,d->sharedData[2]/*49*/,d->sharedData[3]/*50*/,d->sharedData[4]/*51*/,d->sharedData[5]/*52*/,d->sharedData[6]/*53*/,d->sharedData[7]/*54*/,
	d->sharedData[8]/*55*/,d->sharedData[9]/*56*/,d->sharedData[10]/*57*/,d->sharedData[11]/*58*/,d->sharedData[12]/*59*/,d->sharedData[13]/*60*/);

}

#endif

void save2file(sensor_data * d) 
{
	fprintf(fp,"%d %f %f %f %f %f %f %f %f %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %d %d %d %d %d %d %d %d %d %d %d \
			%f %f %f %f %f %f %f\n", d->motorv_int /*1*/, d->lc1_lbs/*2*/, d->lc2_lbs/*3*/, d->time /*4*/,d->tspeed_desired/*5*/, d->xd/*6*/,d->xact/*7*/,d->foot_pos_x/*8*/, 
			d->mid_stance_x/*9*/, d->perturb/*10*/,d->angle_enc/*11*/,d->Kd/*12*/,d->Kact/*13*/,d->force_b/*14*/,d->elapsed/*15*/,d->x_markers[0]/*16*/, d->x_markers[1]/*17*/, 
			d->x_markers[2]/*18*/, d->x_markers[3]/*19*/, d->x_markers[4]/*20*/, d->y_markers[0]/*21*/, d->y_markers[1]/*22*/, d->y_markers[2]/*23*/, d->y_markers[3]/*24*/, 
			d->y_markers[4]/*25*/, d->z_markers[0]/*26*/, d->z_markers[1]/*27*/, d->z_markers[2]/*28*/, d->z_markers[3]/*29*/, d->z_markers[4]/*30*/, d->x_markers[5]/*31*/, 
			d->x_markers[6]/*32*/, d->x_markers[7]/*33*/, d->x_markers[8]/*34*/, d->x_markers[9]/*35*/, d->y_markers[5]/*36*/, d->y_markers[6]/*37*/, d->y_markers[7]/*38*/, 
			d->y_markers[8]/*39*/, d->y_markers[9]/*40*/, d->z_markers[5]/*41*/, d->z_markers[6]/*42*/, d->z_markers[7]/*43*/, d->z_markers[8]/*44*/, d->z_markers[9]/*45*/, 
			d->forcesensors_int[0]/*46*/,d->forcesensors_int[1]/*47*/,d->forcesensors_int[2]/*48*/,d->forcesensors_int[3]/*49*/,d->forcesensors_int[4]/*50*/,d->forcesensors_int[5]/*51*/,
			d->forcesensors_int[6]/*52*/,d->forcesensors_int[7]/*53*/,d->numEMG/*54*/,d->cycle/*55*/,d->get_EMG/*56*/,d->time_emg/*57*/,d->time_vst_startEMG/*58*/,d->time_vst_absolute/*59*/,
			d->start_aq_grt/*60*/,d->start_aq_gtod/*61*/,d->time_emg_startEMG/*62*/,d->time_emg_absolute/*63*/); 

}


void save2file_emg(sensor_data * d) 
{
	fprintf(fp_emg,"%f %f %f %f %f %f %f %f %f %f %f %f %f %f\n",d->sharedData[0]/*47*/,d->sharedData[1]/*48*/,d->sharedData[2]/*49*/,d->sharedData[3]/*50*/,d->sharedData[4]/*51*/,d->sharedData[5]/*52*/,d->sharedData[6]/*53*/,d->sharedData[7]/*54*/,d->sharedData[8]/*55*/,d->sharedData[9]/*56*/,d->sharedData[10]/*57*/,d->sharedData[11]/*58*/,d->sharedData[12]/*59*/,d->sharedData[13]/*60*/);

}

void foot_tracking(double toe_x, double toe_y, double toe_z, double ankle_x, double ankle_y, double ankle_z, double torso_x, double torso_y, double torso_z, double hip_x, double hip_y, double hip_z)
{
	
	// Variables
	double x_foot = (toe_x + ankle_x)/2.0;
	double y_foot = (toe_y + ankle_y)/2.0;
	double z_foot = (toe_z + ankle_z)/2.0;
	double x_mid  = (torso_x + hip_x)/2.0;
	double y_mid = (torso_y + hip_y)/2.0;
	double z_mid = (torso_z + hip_z)/2.0;
	double temp1, temp2;
	double z_offset = 32;
	double T[4][4];
	double Foot_t[4] = {0.0, 0.0, 0.0, 0.0};
	double Mid_t[4] = {0.0, 0.0, 0.0, 0.0};
	double Foot_c[4] = { x_foot, y_foot, z_foot, 1.0 };
	double Mid_c[4]  = { x_mid, y_mid, z_mid, 1.0 };

	// Inverse Transformation matrix from Matlab
	// Converts data from camera frame to treadmill frame
	// Data from NDI in mm
	
	// updated: 5/16/2014
	T[0][0] =  0.9422; //R11
	T[0][1] = -0.0245; //R12
	T[0][2] =  0.3342; //R13
	T[0][3] =  1602.1; //dx
	T[1][0] = -0.0247; //R21
	T[1][1] = -0.9997; //R22
	T[1][2] = -0.0037;  //R23
	T[1][3] = -53.851; //dy
	T[2][0] =  0.3342; //R31
	T[2][1] = -0.0048; //R32
	T[2][2] = -0.9425;  //R33
	T[2][3] = -2249.2;  //dz
	T[3][0] = 0; 
	T[3][1] = 0;
	T[3][2] = 0;
	T[3][3] = 1;

	// Store positions
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			temp1 = T[i][j]*Foot_c[j];
			Foot_t[i] = Foot_t[i] + temp1;
			temp2 = T[i][j]*Mid_c[j];
			Mid_t[i] = Mid_t[i] + temp2;
		}
	}

	sdata->foot_pos_x = (Foot_t[2]/10.0) - z_offset;  // Convert to cm // really it's z
	sdata->foot_pos_y = (Foot_t[0]/10.0);  // Convert to cm
	sdata->mid_stance_x = (Mid_t[2]/10.0) - z_offset;  // really it's z
		
	return;
}

void track_position(double K, double foot_pos_x) // K in N/m, x_track in cm
{
	// Best fit line from experimental data
	//sdata->xd = pow(1/((K*pow(foot_pos_x,2.0))/451717200 + 317/207400.0),(1000/1657.0));
	sdata->xd = pow(451717200.0,(1000/1657.0))/(pow((K*foot_pos_x*foot_pos_x + 690426.0),(1000/1657.0)));
	/* Note: same equation written in 2 different forms */
	return;
}


