/* Example Connection to Wireless EMG System

  Compilation and execution instructions:
 * In a shell, navigate to the folder containing this file
 * 	[user@workstation]$ mkdir build
 *  [user@workstation]$ cd build
 * 	[user@workstation]$ cmake ..
 *  [user@workstation]$ make
 *  [user@workstation]$ ./EMGClient
 * and follow the prompts on the screen.
 *
 * **NOTE: To use threads as in Test 2, install boost library:
 *  [user@oworkstation]$ sudo apt-get install libboost-all-dev
*/

// Libraries for threads
#include <boost/thread.hpp>

// Library for collecting EMG
#include "EMG.h"

// Library for acquiring highest resolution timestamps
#include "RealTime.h"

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



// Global variable to interact with server
EMG* emgServer;
bool quitTest; // Identify if user manually quit the test with threads

// SHM 
#define SHM_SIZE 1024 /* make it a 1K shared memory segment */

// updated 8/01/2014
struct sensor_data 
	{
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

		// -------- Jeremy added --------

		double marker_x_posl[6]; 				// x position of left leg markers from DUO wrt camara
		double marker_y_posl[6]; 				// y position of left leg markers from DUO wrt camara
		double jt_angles_l[3];					// joint angles left leg
		double xf;								// foot position x only (average of both foot makers in x)
		double joint_angles_rift[6];	// joint angles in vector charactor form
	};

// Thread for acquiring EMG data independent of function acquiring it...
void* EMG_fun()
{
    // Collect data until you send a stop signal
    // 1000Hz acquisition rate
    emgServer->emgRunSignalStop(0,1000);
}

// Thread for displaying EMG data in real time
void* DATA_fun()
{
   float64* data; // Memory allocated and freed by EMG
   double lastAccess = getRealTime();

   // Wait until emgServer is collecting data
   while (!emgServer->isRunning()){}
   // Now stay in loop until it is done running
   while (emgServer->isRunning() && !quitTest)
   {
       if (getRealTime()-lastAccess > 1)
       {
           // Collect most recent sample
           data = emgServer->getEMGData();

           // Print out current time and EMG from each channel
           fprintf(stdout,"%0.3f: ",getRealTime());
           for (size_t i = 0; i < emgServer->numChannels();i++)
               fprintf(stdout,"%0.4f\t", data[i]);
           fprintf(stdout,"\n");

           // Save current time for next output in 1 second
           lastAccess = getRealTime();
       }
   }

}

/* Example features of Wireless EMG system */
int main()
{
	// Create connection with EMG/NDI Computer
	// 3 Consecutive Channels of EMG
	// Start with channel 2 (2,3,4)
	// Filter data with butterworth
	string IP = "10.200.148.198";

    emgServer = new EMG(3, 2, BUTTER,IP);

    string test = "Test1";

//-----( Indicate which EMG channels of interest )-------//
   	vector<size_t> chans;
	//chans.push_back(1);
   	chans.push_back(2);
	chans.push_back(3);
   	chans.push_back(4);
	//chans.push_back(5);
	//chans.push_back(6);
	//chans.push_back(7);
	//chans.push_back(8);
	//chans.push_back(9);
	//chans.push_back(10);
	//chans.push_back(11);
 	//chans.push_back(12);
	//chans.push_back(13);
    //chans.push_back(14);
	//chans.push_back(15);
    //chans.push_back(16);
//-------------------------------------------//

   	fprintf(stdout,"Test6\n");
   	test = "Test6";
   	// Method to start EMG collection in line with code to avoid threads
   	// Possible to use shared memory this way, but the for loop should
   	// be in its own program.  Otherwise the buffer will overflow if you don't sample
   	// faster than the sampling rate.
	
	float64* data; // Memory is allocated and freed by EMG
	
//-----( Shared Memory )-----//
	key_t key;
    int shmid;
	sensor_data * sdata;
	sdata = (sensor_data *) malloc(sizeof(sensor_data));
	
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

//-----------------
	timeval bb;
	double t2;

	sdata->experiment = FALSE;
	fprintf(stdout, "-------------------------------\n");
	fprintf(stdout, "Waiting to start experiment...\n");
	while (sdata->experiment==FALSE){}
		
	// Timing neccesary for sync
	double startTime = getRealTime(); // emg time is wrt startTime
	gettimeofday(&bb,0);
	t2 = (double)(bb.tv_usec);
	sdata->zero_time_absolute = bb.tv_sec + t2/1000000; // zero time for emg


	// Acquisition rate 2000Hz
	// Keep all samples in buffer to save after exiting for loops
	// Start acquisition (usually takes 1s to start getting data)
	emgServer->startEMG(startTime, chans, 2000); // <---- 2000 Hz
    
    // for realtime use of EMG        
	// Mimic some part of shared memory
	//size_t dataLen = sizeof(double)*emgServer->numChannels();
    //sdata->sharedData = (double*)malloc(dataLen);
    
    sdata->numEMG = emgServer->numChannels();

	fprintf(stdout,"Waiting for start EMG\n");
    while (!sdata->start_EMG)
	{
		fprintf(stdout,"sdata->start_EMG %d\n" , sdata->start_EMG);
		emgServer->syncData();
	}
	
	fprintf(stdout,"numEMG: %d\n",sdata->numEMG);
	fprintf(stdout,"Starting EMG\n");
    
	while (sdata->start_EMG) 
	{
		// Synchronize data according to acquisition frequency
		emgServer->syncData(); 

        if (sdata->get_EMG) 
		{
			//fprintf(stdout,"Getting Data..\n");
			//fprintf(stdout,"numEMG: %d\n",sdata->numEMG);
			//data = emgServer->getFeatureData(); // Get filtered data
			data = emgServer->getEMGData(); // Get UNfiltered data

			// Copy this to shared memory variable of appropriate size
            //memcpy(sdata->sharedData,data,dataLen);


			// Don't get EMG data until next iteration call from vst.cpp
	        sdata->get_EMG == FALSE;

			// Print out synced time and EMG from each channel just for testing,
			// but don't do this in real code with faster frequencies
			//fprintf(stdout,"%0.3f: ",emgServer->emgRunTime());
			//for (size_t i = 0; i < emgServer->numChannels();i++)
			//fprintf(stdout,"%0.4f\t", sdata->sharedData[i]);
			//fprintf(stdout,"\n");

		} // closes when get_EMG = FALSE;

    } // closes when start_EMG = FALSE 

	// Save complete buffer afterwards
    emgServer->saveBuffers(test.c_str());

    // Stop acquisition
    emgServer->stopEMG();

	// Close everything and exit
	emgServer->closeServer();

	return 0;
}
