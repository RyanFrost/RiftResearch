#include <stdio.h>
#include <stdlib.h>
#include <cmath>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <math.h>
#include <vector>
#include <algorithm>
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
//
#include <sys/ioctl.h>
#include <linux/kd.h>
#include <ctime>
#include <cstdio>


#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#define PORT 27015
#define STEPSIZE 512
#define PSIZE 10

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

double time_elapsed(struct timeval *, struct timeval *);
void foot_tracking(double, double, double, double, double, double,double, double, double, double, double, double); // foot and torso tracking
void save2file(sensor_data *);
void my_handler(int);
int initialize_modbus(void);

/* ----( Global Variables )---- */
uint16_t mtp1[4];
sensor_data *sdata;
modbus_t *ctx;
FILE *fp;

/* temp variables */
double temp1 = 0.1;
double temp2 = 0.5;

/* ----( Main Function )---- */
int main (int argc, char *argv[])
{
	struct timeval start, end;
	key_t key;
        int shmid;
	int flag = 0;
	int rc, rcb, rcw, i, j, k;
	struct sigaction sigIntHandler;
	
	// Catch Ctrl+C signal
   	sigIntHandler.sa_handler = my_handler;
   	sigemptyset(&sigIntHandler.sa_mask);
   	sigIntHandler.sa_flags = 0;
        sigaction(SIGINT, &sigIntHandler, NULL);

	fp= fopen(filename, "w");
	
	// Initialize structures
	sdata = (sensor_data *) malloc(sizeof(sensor_data)); 

	/* ----( Initialize modbus )---- */
	if (initialize_modbus() < 0)
	exit(1);

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

	/* ----( Connect to NDI system )----*/	
	char *main_ip_address = "10.200.148.198"; // VST space 
   	markers_struct markers;

	fprintf(stdout, "Trying to connect to the server %s\n", main_ip_address);
	markers = initialize_markers(main_ip_address);
 	fprintf(stdout, "Connected\n");

    	update_markers(&markers);
	printf("Number of Markers: %d\n",markers.size); 

	int cycle;
	int count = 0;
	int cyc_reset = 0;
	int range_num = 0;
	double ave = 0;
	double length = 0;
	double xf_min = 0;
	double xf_max = 0;
	bool heelstrike = FALSE;
	bool toeoff = FALSE;
	bool sand = FALSE;
	double progress = 0;
	double prog5 = 0;
	double prog4 = 0;
	double prog3 = 0;
	double prog2 = 0;
	double prog1 = 0;
	double xf = 0;
	double xmid = 0;
	double frac = 0;
	double aveStepLength = 0.5;
	double stepsTaken = 0; 
	char data[100];
	//vector<double> xf_vector;
	int n, w;
	int buffer_length = 20000;
	double xf_buffer[buffer_length];
	//double min, max;
	int reset_val = 0;
	string reply;

	double ave_reset_val_past = 0;
	double ave_reset_val = 0;
	double avep = 0.5;
	sdata->cycle = 0;

	struct sockaddr_in server_addr;
	struct sockaddr_in remote_addr;
	socklen_t addrlen = sizeof(remote_addr);

	int recvlen; 			/* # of bytes received */
	int sockfd;			/* local socket */
	char stepData[STEPSIZE];
	//char patch[PSIZE];

	memset((char *)&server_addr, 0, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(PORT);
	server_addr.sin_addr.s_addr = htonl(0);

	if  ((sockfd = socket(AF_INET, SOCK_DGRAM,0)) < 0)	/* Creates socket */
	{
		perror("cannot create socket");
		return 0;
	}
	cout << "Socket Created" << endl;
	
	if(bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) /* Binds socket to port */
	{
		perror("bind failed");
		return 0;
	}
	cout << "Socket Bound"  << endl;

	printf("Waiting for Unity...\n");	/* recvfrom waits for Unity connection, blocks until then */
	recvlen = recvfrom(sockfd, stepData, STEPSIZE, 0, (struct sockaddr *)&remote_addr, &addrlen);
	if (recvlen > 0)
	{
		//buf[recvlen] = 0;
		printf("%s\n", stepData);
	}

	char patch[] = 	"10,20,30,40,50,60,70,80,90,100";
	int sand_cycle[10] = {10,20,30,40,50,60,70,80,90,100};
	int ind = 0;
	//patch[0] = "10,60,100";
	//patchArrayString = "10,60,100";
	
	
	if(sendto(sockfd, patch, 100, 0, (struct sockaddr *)&remote_addr, addrlen) < 0)
	{
		perror("Send failed.");
		close(sockfd);
		return 0;
	}

	cout << "Response Received"  << endl;
	

	std::clock_t tstart;
	double t_elapsed;
	tstart = std::clock();
//-----------------------------------------------------------
	int length_of_for_loop = 1000000000;

	/* ----( Main loop )---- */
	for (i = 0; i < length_of_for_loop; i++)
	{
		if (true)
		{
			/* ----( Read in data )---- */
			// Get data from NDI		
			update_markers(&markers);
			for ( int main_i = 0; main_i < markers.size; main_i++)
			{
				sdata->x_markers[main_i] = markers.marker[main_i].x;
				sdata->y_markers[main_i] = markers.marker[main_i].y;
				sdata->z_markers[main_i] = markers.marker[main_i].z;
			}	
		
			// Calculates foot position
			foot_tracking(sdata->x_markers[4], sdata->y_markers[4], sdata->z_markers[4], sdata->x_markers[3], sdata->y_markers[3], sdata->z_markers[3],sdata->x_markers[0], sdata->y_markers[0], sdata->z_markers[0], sdata->x_markers[1], sdata->y_markers[1], sdata->z_markers[1]);
			
			// Avoid nan problems
			if ( isnan(sdata->foot_pos_x) || isnan(sdata->mid_stance_x) )
				flag = 1;
			else
				flag = 0;

			if (flag == 0) // && sdata->tspeed_desired > 300
			{

				xmid = sdata->mid_stance_x;
				xf = sdata->foot_pos_x; 
				//xf_vector.push_back(xf);
				progress = ((prog5-prog4)+(prog4-prog3)+(prog3-prog2)+(prog2-prog1))/4.0; // indicates xf increasing if negative


				heelstrike = (prog4-prog3)>=0 && (prog3-prog2)>=0 && (prog2-prog1)<=0 && (prog1-xf)<=0; // indicates heel-stike
				toeoff = (prog4-prog3)<=0 && (prog3-prog2)<=0 && (prog2-prog1)>=0 && (prog1-xf)>=0; // indicates toeoff

				if (heelstrike)
				{
					xf_min = prog2;
					frac = 0.25;
				}

				if (toeoff)
				{
					xf_max = prog2; 
					frac = 0.75;
				}

				//xmid = 50;

				xf_buffer[count] = xf;
				
				// Increment cycle number if pass midline during swing phase of left leg
				if ( fabs(xf-xmid+2) <= 5.0 && progress > 0 ) // xf decreasing (swing phase) 
				{
					range_num++;

					if (range_num == 1) // only increase cycle number for first time in the range
					{
						//xf_max = *max_element(xf_vector.begin(), xf_vector.end());
						//xf_min = *min_element(xf_vector.begin(), xf_vector.end());
												
						sdata->cycle++;

						if (sdata->cycle == sand_cycle[ind])
						{
							sdata->beep = TRUE;
							ind++;
						}
										
						reset_val = count;

						if (sdata->cycle > 10)
						{
							cyc_reset++;
							ave_reset_val = ave_reset_val_past + (reset_val-ave_reset_val_past)/(static_cast<double>(cyc_reset));
						}

						while (count < buffer_length)
						{
							xf_buffer[count] = 50;
							count++;
						}

						count = -1;

						xf_min = 50;
						xf_max = 50;

						for (k=0;k<buffer_length;k++)
						{
							if (xf_buffer[k] > xf_max)
								xf_max = xf_buffer[k];
							if (xf_buffer[k] < xf_min)
								xf_min = xf_buffer[k];
						}
			
						length = (xf_max - xf_min);
						ave = avep + (length-avep)/(static_cast<double>(sdata->cycle) + 1.0 );

						for (w=0;w<=reset_val+2;w++)
						xf_buffer[w] = 50;

						
					} // end of "if (range_num == 1)"
					// 

					
					// time for pert
					//if (sand)
					//sdata->beep = TRUE;

					//if (cycle%10 == 0)
					//sdata->beep = TRUE;

					

	
				} // end of "if ( fabs(xf-xmid) <= 5 && progress > 0 )"
				else if ( fabs(xf-xmid+2) >= 7.0)
				{
				range_num = 0;
				}


				/* ----( Update past values )---- */
				prog5 = prog4;
				prog4 = prog3;
				prog3 = prog2;
				prog2 = prog1;
				prog1 = xf;
				avep = ave;
				ave_reset_val_past = ave_reset_val;


				count++;


				//frac = 0;
				/* ----( Values to send to rift )---- */
				
				
						
				
				/*if ( aveStepLength == 0)
				{
					aveStepLength = 0.5;
					stepsTaken = 0;
				} */

				//xmid = 50;
				/*if ( fabs(xf-xmid+2) <= 5.0 && progress > 0) // xf decreasing (swing phase), don't end purterbation early, offset slightly
				{
					range_num++;

					if (range_num == 1) // only increase cycle number for first time in the range
				    	sdata->cycle++;
				}*/

				aveStepLength = ave;
				stepsTaken = sdata->cycle;	

				t_elapsed = ( std::clock() - tstart) / (double) CLOCKS_PER_SEC;
				
				cout << t_elapsed << stepData;
				n = sprintf(stepData,"%f,%f", stepsTaken,aveStepLength/100.0);
				
				for (i = n; i<STEPSIZE; i++)
				{
					stepData[i] = 0;
				}
				cout << stepData;
				cout << "\n";
				if(sendto(sockfd, stepData, STEPSIZE, 0, (struct sockaddr *)&remote_addr, addrlen) < 0)
				{
					perror("Send failed.");
					close(sockfd);
					return 0;
				}
		
				recvlen = recvfrom(sockfd, stepData, STEPSIZE, 0, (struct sockaddr *)&remote_addr, &addrlen);
				if (recvlen > 0)
				{
					stepData[recvlen] = 0;

					if (strcmp(stepData,"Exit") == 0)
					{
						printf("Connection closed.\n");
						close(sockfd);
						return(0);
					}
				}
					
				temp1 += 0.1;
				sleep(0.1);
				cout << i;
			} // end of "flag == 0"

			

			/* ----( Print data to sceen and file )---- */
			//fprintf(stdout,"StepsTaken: %f past step length: %f", stepsTaken, length);
			//save2file(sdata);// call if you want data to be saved to a file
			gettimeofday(&end, NULL);
			sdata->elapsed = time_elapsed(&start, &end);
			//fprintf(stdout, "Time elapsed: %f s\n", sdata->elapsed);
			//fprintf(stdout,"---------------------\n");
			gettimeofday(&start, NULL);

			fprintf(fp,"%f %f %d %d %f %f %f %d %f %d %f %d %f %f %f\n",stepsTaken/*1*/,aveStepLength/*2*/,sdata->cycle/*3*/,toeoff/*4*/,sdata->foot_pos_x/*5*/,length/*6*/,sdata->elapsed/*7*/, count/*8*/,frac/*9*/, reset_val/*10*/, ave_reset_val/*11*/,sdata->beep/*12*/,sdata->mid_stance_x/*13*/,xf_min/*14*/,xf_max/*15*/);
			sleep(.001); //???
		}
		else // sdata->experiment = FALSE
		{
			i = length_of_for_loop;
		}
	} // close for i.. loop

	// close everything
	fprintf(stdout,"Exiting...\n");
	sdata->data_exchange = FALSE;
	fclose(fp);
	modbus_close(ctx);
	modbus_free(ctx);
	fprintf(stdout,"\n");
	fprintf(stdout,"Done!\n");
	fprintf(stdout,"\n");
}


//---------------------------//
/* ----( Sub Functions )---- */
//---------------------------//


void save2file(sensor_data * d) 
{
	fprintf(fp,"%d %f %f %f %f %f %f %f %f %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %d %d %d %d %d %d %d %d %d\n", d->motorv_int /*1*/, d->lc1_lbs/*2*/, d->lc2_lbs/*3*/, d->time /*4*/,d->tspeed_desired/*5*/, d->xd/*6*/,d->xact/*7*/,d->foot_pos_x/*8*/, d->mid_stance_x/*9*/, d->perturb/*10*/,d->angle_enc/*11*/,d->Kd/*12*/,d->Kact/*13*/,d->force_b/*14*/,d->elapsed/*15*/,d->x_markers[0]/*16*/, d->x_markers[1]/*17*/, d->x_markers[2]/*18*/, d->x_markers[3]/*19*/, d->x_markers[4]/*20*/, d->y_markers[0]/*21*/, d->y_markers[1]/*22*/, d->y_markers[2]/*23*/, d->y_markers[3]/*24*/, d->y_markers[4]/*25*/, d->z_markers[0]/*26*/, d->z_markers[1]/*27*/, d->z_markers[2]/*28*/, d->z_markers[3]/*29*/, d->z_markers[4]/*30*/, d->x_markers[5]/*31*/, d->x_markers[6]/*32*/, d->x_markers[7]/*33*/, d->x_markers[8]/*34*/, d->x_markers[9]/*35*/, d->y_markers[5]/*36*/, d->y_markers[6]/*37*/, d->y_markers[7]/*38*/, d->y_markers[8]/*39*/, d->y_markers[9]/*40*/, d->z_markers[5]
/*41*/, d->z_markers[6]/*42*/, d->z_markers[7]/*43*/, d->z_markers[8]/*44*/, d->z_markers[9]/*45*/,d->forcesensors_int[0]/*46*/,d->forcesensors_int[1]/*47*/,d->forcesensors_int[2]/*48*/,d->forcesensors_int[3]/*49*/,d->forcesensors_int[4]/*50*/,d->forcesensors_int[5]/*51*/,d->forcesensors_int[6]/*52*/,d->forcesensors_int[7]/*53*/,d->numEMG/*54*/); 

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
	double z_offset = 37;
	double T[4][4];
	double Foot_t[4] = {0.0, 0.0, 0.0, 0.0};
	double Mid_t[4] = {0.0, 0.0, 0.0, 0.0};
	double Foot_c[4] = { x_foot, y_foot, z_foot, 1.0 };
	double Mid_c[4]  = { x_mid, y_mid, z_mid, 1.0 };

	// Inverse Transformation matrix from Matlab
	// Converts data from camera frame to treadmill frame
	// Data from NDI in mm
	T[0][0] =  0.9460; //R11
	T[0][1] = -0.0155; //R12
	T[0][2] =  0.3237; //R13
	T[0][3] =  1580.9; //dx
	T[1][0] = -0.0086; //R21
	T[1][1] = -0.9997; //R22
	T[1][2] = -0.0229;  //R23
	T[1][3] = -199.00; //dy
	T[2][0] =  0.3240; //R31
	T[2][1] =  0.0189; //R32
	T[2][2] = -0.9459;  //R33
	T[2][3] = -2311.2;  //dz
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


