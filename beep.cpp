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

#ifndef M_PI 
#define M_PI 3.14159
#endif

using namespace std;

#define SHM_SIZE 1024 /* make it a 1K shared memory segment */

const char filename[] = "mydata.txt";

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
bool experiment; // Tells wheather to do experiment or stop it.
int numEMG; // Number of EMG electrodes used in experiment
bool beep; // Causes beep
};

uint16_t mtp1[4];
sensor_data *sdata;


int main (int argc, char *argv[])
{


	key_t key;
        int shmid;
	int flag;
	int rc, rcb, rcw, i;
	int count = 0;
	
	
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


	sdata->beep = FALSE;

	fprintf(stdout, "Waiting for signal\n");
    	while(true)
   	{	
     		if(!sdata->beep){}
     	
     		else 
     		{		
      			system("audacious /home/treadmill/Desktop/ArduinoCodes/Beep/beep-1.mp3 &");
      			//system("audacious /home/treadmill/Desktop/ArduinoCodes/Beep/beep-1.mp3");
			count++;
			/*if (count > 10)
			{
      				sdata->beep = FALSE;
				count = 0;
			}*/
			sdata->beep = FALSE;
			sleep(.005);
     		}

	    	sleep (0.005);//sleep in sec
    
	
   
    		/*if (shmdt(data) == -1) {
      		perror("shmdt");
      		exit(1);}*/
    	}

    shmctl(shmid, IPC_RMID, NULL);
    fprintf(stdout, "End of beep program\n");
    return 0;
    
}




    
 
