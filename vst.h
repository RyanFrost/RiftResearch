

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
// void foot_tracking(double, double, double, double, double, double,double, double, double, double, double, double); // foot and torso tracking
// //void foot_tracking(double, double, double, double, double, double); // just foot tracking
// void track_position(double, double);
// void convert64to16(float);
// void my_handler(int);
// int initialize_modbus(void);
// void move_track(float);
// float read_track(void);
// void get_angle_enc(void);
// double time_elapsed(struct timeval *, struct timeval *);
// void save2file(sensor_data *);
// void save2file_emg(sensor_data *);
// float track_position_table(int, int);