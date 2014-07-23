#pragma once
#include <sys/ipc.h>
#include <sys/shm.h>
#include <cstdint>

class sharedMemObject
{

private:
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
	
	
public:
	sharedMemObject();
	~sharedMemObject();
	
	
	sensor_data *sdata;
};