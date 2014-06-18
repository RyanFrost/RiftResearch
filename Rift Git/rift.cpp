#include "riftHeader.h"

using namespace std;

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
double time_elapsed(struct timeval *, struct timeval *);
void foot_tracking(double, double, double, double, double, double,double, double, double, double, double, double); // foot and torso tracking
vector< vector<double> > leg_tracking(double[],double[],double[]);
void save2file(sensor_data *);
void my_handler(int);
float track_position_table(int, int);
void move_track(float);
void convert64to16(float);

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
	int random_mat[91] = {5,8,15,19,25,29,35,39,42,47,50,57,62,69,72,76,81,85,92,98,105,111,115,119,125,130,136,141,144,147,152,157,162,169,173,177,183,189,192,199,204,208,215,219,225,228,232,237,240,246,252,256,261,264,270,274,280,283,290,294,297,	304,310,313,317,323,329,334,339,346,351,358,361,366,369,374,377,384,387,394,400,406,411,416,421,428,432,436,442,447,450}; 
	// random matrix for perturbation location
	// location 1 = Loading Phase / Heal-strike
	// location 2 = Mid Stance
	// location 3 = Terminal Stance / Toe-off
	int location[91] =  {3,2,3,2,1,2,3,1,1,3,1,2,3,1,2,2,1,3,2,3,1,3,2,2,1,3,1,3,2,3,2,1,3,1,2,1,2,3,1,1,3,1,2,3,2,3,3,1,2,2,3,1,2,1,3,1,1,3,1,2,2,2,3,2,1,3,3,1,2,1,2,3,2,1,1,3,3,2,3,2,1,1,3,2,1,2,3,2,1,3,1};
	// random matrix for perturbation magnitude/1000
	double magnitude[91] = {50,50,10,100,50,10,100,10,100,50,50,100,10,10,10,50,100,100,100,100,10,50,10,50,100,10,50,100,100,50,50,100,10,50,10,10,100,50,10,100,10,50,50,100,10,100,50,10,50,100,10,	50,10,100,50,50,100,100,10,10,100,50,10,10,100,100,10,50,100,10,50,50,100,100,10,100,10,50,50,10,50,50,10,100,10,50,50,10,100,100,100};

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
	
	double distance;
	double ave_reset_val_past = 0;
	double ave_reset_val = 0;
	double avep = 0.5;
	sdata->cycle = 0;
	
	
	bool currentlyBeeping = FALSE;
	
	/*----( Create patch array to send )----*/
	
	std::srand(std::time(0));
	int numPatches = 150;
	int patchStart = 20;
	patchStart -= 500;
	int patches [numPatches];
	string patchStr;
	int pLocation = patchStart;
	
	patches[0] = pLocation;
	string locString = boost::lexical_cast<string>( pLocation );
	patchStr.append(locString);
	cout << numPatches;
	
	for (int i = 1; i<numPatches; i++)
	{
		int separation = std::rand() % 3 + 5;
		pLocation += separation;
		//cout << pLocation << " ";
		patches[i] = pLocation;
		locString = boost::lexical_cast<string>( pLocation );
		patchStr.append(",");
		patchStr.append(locString);	
	}

	cout << patchStr << " patch str\n";
	char *patchChar = new char[patchStr.size()+1];
	patchChar[patchStr.size()]=0;
	memcpy(patchChar,patchStr.c_str(),patchStr.size());
	

	
	
	int numPert = 10;
	int pertTypes [numPert];
	
	
	for (int i = 0; i<numPert; i++)
	{
		pertTypes[i] = 0;
		
		if (i >= numPert/2)
		{
			pertTypes[i] = 1;
		}	
	}
	
	random_shuffle(&pertTypes[0], &pertTypes[numPert]);
	
	int currentPatch = 0; // Used in for loop to check which patch is next
	int currentPertOne = 0;
	int currentPertZero = 0;// Used in for loop to check if current patch is perturbation
	bool typeZeroPatch = false; // Used in for loop for preventing stiffnesschange
	
	int patchBufferStart = 20; // # of patches before the first perturbation
	int patchBufferEnd = 20; // # of patches after the last perturbation
	int patchesBetween = (numPatches-(patchBufferStart+patchBufferEnd))/numPert;
	cout << "patches between = " << patchesBetween << "\n";
	int typeZero [numPert/2]; int zeroCounter = 0;
	int typeOne [numPert/2]; int oneCounter = 0;
	double typeOneMidpoint [numPert/2];
	
	
	for (int i = 0; i<numPert; i++)
	{
		/* Type 0 perturbation - Sand patch but no stiffness change */
		if (pertTypes[i] == 0)
		{	
			typeZero[zeroCounter] = patchBufferStart + i*patchesBetween + rand() % 5 - 2;
			zeroCounter++;
		}
		else if (pertTypes[i] == 1) /* Type 1 perturbation - Stiffness change with no patch */
		{
			typeOne[oneCounter] = patchBufferStart + i*patchesBetween + rand() % 5 - 2;
			int tempPatch = typeOne[oneCounter];
			typeOneMidpoint[oneCounter] = (patches[tempPatch]-patches[tempPatch-1])/2;
			oneCounter++;
		}
		
	}
	
	for (int i = 0; i < zeroCounter; i++)
	{
		cout << "zero at " << typeZero[i] << "\n";
	}
	for (int i = 0; i < oneCounter; i++)
	{
		cout << "one at " << typeOne[i] << "\n";
	}
	
	/*----( Limb Tracking )----*/
	
	string markerStrX, markerStrY;
	string currentMarkerStrX, currentMarkerStrY;
	
	
	
	
	
	
	/*----( Connect to Rift computer )----*/

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
	int bufIter;

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

	if(sendto(sockfd, patchChar, strlen(patchChar), 0, (struct sockaddr *)&remote_addr, addrlen) < 0)
	{
		perror("Send failed.");
		close(sockfd);
		return 0;
	}

	cout << "Response Received"  << endl;
	
	
	
	cout << "Type zero perturbations at: ";
			
	for (int i = 0; i < zeroCounter; i++)
	{
		cout << "  " << typeZero[i];
	}
	cout << "\n";
	cout << "Type one perturbations at: ";
	
	for (int i = 0; i < oneCounter; i++)
	{
		cout << "  " << typeOne[i];
	}
	
	cout << "\n";
	
	cout << "Next patch: " << currentPatch << "\n";
	cout << "Next perturbation: ";
	
	if ( typeZero[currentPertZero] < typeOne[currentPertOne] )
	{
		cout << "No stiffness change at patch number " << typeZero[currentPertZero];
	}
	else
	{
		cout << "Stiffness change between patches " << typeOne[currentPertOne] - 1 << " and " << typeOne[currentPertOne];
	}

	cout << "\n\n";	

	
	
//-----------------------------------------------------------
	bool runTheLoop = true;
	
	/* ----( Main loop )---- */
	
	while(runTheLoop)
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
	
		/*else // sdata->experiment = FALSE
		{
			i = length_of_for_loop;
		} */
		
		
// 		for (int marker = 0; marker<10;marker++)
// 		{
// 			if ( !isnan(sdata->x_markers[marker]) )
// 			{
// 				markerArrayX[marker] 
// 		
		
		
		/*----( Limb Tracking )----*/
	
		string markerStrX, markerStrY;
		string currentMarkerStrX, currentMarkerStrY;
		
		vector< vector<double> > markerVec = leg_tracking(sdata->x_markers, sdata->y_markers, sdata->z_markers);
// 		cout << "\n\n\n\nfootposx = "<< sdata->foot_pos_x<<endl;
// 		for (int it = 0; it<5; it++)
// 		{
// 			cout << "Marker #" << it << endl;
// 			for(int dim = 0; dim<3; dim++)
// 			{
// 				cout<< markerVec[it][dim] << endl;
// 			}
// 			cout <<endl;
// 		}
		
		
		
// 			for (int markerIter = 0; markerIter < numMarkers; markerIter++)
// 			{
// 				
// 				if ( !isnan(sdata->x_markers[markerIter]) )
// 				{
// 					markerArray[markerIter][0] = sdata->x_markers[markerIter];
// 				}
// 				else
// 				{
// 					
// 				}
// 				currentMarkerStrX = boost::lexical_cast<string>( sdata->x_markers[markerIter] );
// 				markerStrX.append(",");
// 				markerStrX.append(currentMarkerStrX);
// 				
// 			}
// 		
// 		char *markerCharX = new char[markerStrX.size()+1];
// 		char *markerCharY = new char[markerStrY.size()+1];
// 		markerCharX[markerStrX.size()] = 0;
// 		markerCharY[markerStrY.size()] = 0;
// 		memcpy(markerCharX,markerStrX.c_str(),markerStrX.size());
// 		memcpy(markerCharY,markerStrY.c_str(),markerStrY.size());
		
		try
		{
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
		
			distance = atof(stepData);
			
			if(sendto(sockfd,"running", strlen("running"), 0, (struct sockaddr *)&remote_addr, addrlen) < 0)
			{
				perror("Send failed.");
				//close(sockfd);
				return 0;
			}
			
		}
		catch (int e)
		{
			cout << "Exception caught";
		}
		
		
		temp1 += 0.1;
		
		bool typeZeroPatch = false;
		bool typeOnePatch = false;
		
		
		if ( currentPatch == typeZero[currentPertZero])
		{
			typeZeroPatch = true;
			
		}
		else if ( currentPatch == typeOne[currentPertOne])
		{
			
			
			typeOnePatch = true;
			distance -= typeOneMidpoint[currentPertOne];
			
		}
		
		
		
		
		if (!currentlyBeeping)
		{
			if (abs(distance) < 0.5)
			{
				if ( !typeZeroPatch)
				{
					sdata->beep = TRUE;
				}
				else
				{
					currentPertZero++;
					sdata->perturb = 2;
				}
				
				currentlyBeeping = TRUE;
				
				if ( typeOnePatch )
				{
					currentPertOne++;
					sdata->perturb = 3;
				}
				else
				{
					currentPatch++;
				}
				
				if( !typeZeroPatch && !typeOnePatch)
				{
					sdata->perturb = 1;
				}
				
				cout << "Type zero perturbations at: ";
		
				for (int i = 0; i < zeroCounter; i++)
				{
					cout << "  " << typeZero[i];
				}
				cout << "\n";
				cout << "Type one perturbations at: ";
				
				for (int i = 0; i < oneCounter; i++)
				{
					cout << "  " << typeOne[i];
				}
				
				cout << "\n";
				
				cout << "Next patch: " << currentPatch << "\n";
				cout << "Next perturbation: ";
				
				if ( typeZero[currentPertZero] < typeOne[currentPertOne] )
				{
					cout << "No stiffness change at patch number " << typeZero[currentPertZero];
				}
				else
				{
					cout << "Stiffness change between patches " << typeOne[currentPertOne] - 1 << " and " << typeOne[currentPertOne];
				}
		
				cout << "\n\n";	
			
			}
		
		}
	
	
	
		if (distance >= 0.5)
		{
			currentlyBeeping = FALSE;
			if (sdata->perturb == 2)
			{
				sdata->perturb = 0;
			}
		}
		
		
		
	} // close for i.. loop	
		
	/* ----( Print data to file )---- */
	save2file(sdata);// call if you want data to be saved to a file
	gettimeofday(&end, NULL);
	sdata->elapsed = time_elapsed(&start, &end);
	gettimeofday(&start, NULL);

		
		
		 
	

	// close everything
	fprintf(stdout,"Exiting...\n");
	sdata->data_exchange = FALSE;
	fclose(fp);
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

void convert64to16(float p){
	int a, b, c, d, e, f, g, h, q, i;
	q=p*(pow(2,20))*2500/2749;
	a= q/65536; http://stackoverflow.com/questions/3202136/using-g-to-compile-multiple-cpp-and-h-files
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
	
	// updated: 4/28/2014
	T[0][0] =  0.9544; //R11
	T[0][1] = -0.0246; //R12
	T[0][2] =  0.2976; //R13
	T[0][3] =  1514.3; //dx
	T[1][0] = -0.0256; //R21
	T[1][1] = -0.9997; //R22
	T[1][2] = -0.0005;  //R23
	T[1][3] = -52.084; //dy
	T[2][0] =  0.2976; //R31
	T[2][1] = -0.0072; //R32
	T[2][2] = -0.9547;  //R33
	T[2][3] = -2320.1;  //dz
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


vector< vector<double> > leg_tracking(double xMarkers[], double yMarkers[], double zMarkers[])
{
	
	// Variables
	
	// LimbTrack previous values for when nan
	
	vector< vector<double> > markerArray (5, vector<double> (4,0.0));
	vector< vector<double> > markerArrayTransf (5, vector<double> (4,0.0));
	vector<string> markerStrVec (3,"");
	
	
	for (int marker = 0; marker< 5;marker++)
	{
		markerArray[marker][0] = xMarkers[marker];
		
		markerArray[marker][1] = yMarkers[marker];
		markerArray[marker][2] = zMarkers[marker];
		markerArray[marker][3] = 1.0;
	}
	

	double z_offset = 37;
	vector< vector<double> > T (4, vector<double> (4, 0.0));
	vector<double>  Foot_t (4,0.0);
	
	double myDubs []= { xMarkers[4], yMarkers[4], zMarkers[4], 1.0};
	vector<double> Foot_c (myDubs, myDubs + sizeof(myDubs)/sizeof(double));

	// Inverse Transformation matrix from Matlab
	// Converts data from camera frame to treadmill frame
	// Data from NDI in mm
	
	// updated: 4/28/2014
	T[0][0] =  0.9544; //R11
	T[0][1] = -0.0246; //R12
	T[0][2] =  0.2976; //R13
	T[0][3] =  1514.3; //dx
	T[1][0] = -0.0256; //R21
	T[1][1] = -0.9997; //R22
	T[1][2] = -0.0005;  //R23
	T[1][3] = -52.084; //dy
	T[2][0] =  0.2976; //R31
	T[2][1] = -0.0072; //R32
	T[2][2] = -0.9547;  //R33
	T[2][3] = -2320.1;  //dz
	T[3][0] = 0; 
	T[3][1] = 0;
	T[3][2] = 0;
	T[3][3] = 1;

	// Apply coordinate transformation (NDI frame to treadmill frame)
	for (int markerNum = 0;markerNum<5;markerNum++)
	{
		for (int i = 0; i < 4; i++)
		{
			for (int j = 0; j < 4; j++)
			{
				markerArrayTransf[markerNum][i] += T[i][j] * markerArray[markerNum][j];
			}
		}
	}
	
	// Convert all positions from mm to cm, and apply the z (x) offset
	for (int markerIt = 0; markerIt<5;markerIt++)
	{
		markerArrayTransf[markerIt].pop_back(); // Removes the '1' scaler
		
		// rotates the order of the vector from z,x,y to x,y,z
		rotate(markerArrayTransf[markerIt].begin(),markerArrayTransf[markerIt].begin()+2,markerArrayTransf[markerIt].end());
		
		
		for(int dimIt = 0; dimIt<3; dimIt++)
		{
			markerArrayTransf[markerIt][dimIt] /= 10; // converts from mm to cm
			if (dimIt == 0) // applies z (x) offset if current dimension is x 
			{
				markerArrayTransf[markerIt][dimIt] -= z_offset;
			}
		}
	}
	

// 	
	return markerArrayTransf;
}

char* getJointAngles ( vector< vector<double> > markerVecs)
{
	vector<double> torsoHip = { 0.0, -1.0};
	vector<double> hipKnee = { markerVecs[2][0]-markerVecs[1][0], markerVecs[2][1]-markerVecs[1][1] };
	vector<double> kneeAnkle = { markerVecs[3][0]-markerVecs[2][0], markerVecs[3][1]-markerVecs[2][1] };
	vector<double> ankleToe = { markerVecs[4][0]-markerVecs[3][0], markerVecs[4][1]-markerVecs[3][1] };
	
	vector< vector<double> > vecs = {torsoHip, hipKnee, kneeAnkle, ankleToe};
	vector<double> angles (3, 0.0);
	
	for ( int vecIt = 0; vecIt < 3; vecIt++)
	{
		double dot = vecs[vecIt][0] * vecs[vecIt+1][0] + vecs[vecIt][1] * vecs[vecIt+1][1];
		double det = vecs[vecIt][0] * vecs[vecIt+1][1] - vecs[vecIt][1] * vecs[vecIt+1][0];
		angles[vecIt] = atan2(det, dot);
	}
	

}


	
void my_handler(int s){
        fprintf(stdout, "Caught signal %d\n",s);
	sdata->data_exchange = FALSE;
	fclose(fp);
	//terminate_data_exchange(sdata);	   
        exit(1); 
}
