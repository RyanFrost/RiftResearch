#pragma once
#include <sys/ipc.h>
#include <sys/shm.h>
#include <cstdint>
#include <fstream>

class sharedMemObject
{

protected:
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
		float xd_raw; // Linear track desired position wrt the home position in cm
		float xd_filt; // filtered value of xd_raw
		float xact; // Linear track actual position wrt the home position in cm
		int perturb; // (T/F) perturb this cycle?
		int perturbWarning; // Sent to rift when heelstrike before perturbation
		int cycle; // number of gait cycles
		double angle_enc; // angle from encoder (deg)
		double Kd; // Desired stiffness
		double Kact; // Actual Stiffness
		double Fb_raw; // Force at location B of kinematic analysis (raw)
		double Fb_filt; // Force at location B of kinematic analysis (filtered)
		double elapsed; // Time elapsed each iteration of VST for loop
		bool start_EMG; // Tells to start collecting EMG data
		bool get_EMG; // Tells when to get EMG
		bool experiment; // Tells whether to do experiment or stop it.
		int numEMG; // Number of EMG electrodes used in experiment
		bool beep; // Causes beep
		double time_vst_absolute; // Timestamp for each iteration of vst code in absolute computer time
		double zero_time_absolute; // Timestamp for Zero time of EMG data in absolute computer time
		double marker_x_posl[6]; // x position of left leg markers from DUO wrt camara
		double marker_y_posl[6]; // y position of left leg markers from DUO wrt camara
		double marker_x_posr[6]; // x position of right leg markers from DUO wrt camara
		double marker_y_posr[6]; // y position of right leg markers from DUO wrt camara
		double jt_angles_l[3];	// joint angles left leg
		double jt_angles_r[3];	// joint angles right leg
		double xf;	// foot position x only (average of both foot makers in x)
		double xfoot; // foot position used in control sequence (constant throughout each iteration)
		double joint_angles_rift[6];	// joint angles in vector charactor form
		bool movingBackward;  // indicates that xf is increasing over time
		bool movingForward;  // indicates that xf is decreasing over time
		bool transitioning;  // foot velocity is changing direction			
		bool smech; // stiffness mechanism at zero stiffness position to trigger linear actuator
		bool lapReturn; // vertical actuator is returning to zero position
		int lap; // linear actuator position in encoder counts (integer)
	};
	
	// File saving components
	
	
	
	FILE *fp;
		
	void openFile(const char*);
	
	
public:
	// Call constructor with desired name of file to write data to
	// (e.g. "treadmillData.txt")
	sharedMemObject(const char*);
	~sharedMemObject();
	
	void save2file(bool, bool, double, int, int);
	
	sensor_data *sdata;
};
