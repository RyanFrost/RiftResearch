#include "sharedMemObject.h"

#include <sys/ipc.h>
#include <sys/shm.h>
#include <cstdio>
#include <cstdlib>
#include <cstdint>

sharedMemObject::sharedMemObject()
{
	int SHM_SIZE = 1024;
	
	key_t key;
	int shmid;
	sdata = (sensor_data *) malloc(sizeof(sensor_data));	// Initialize structures
	// make the key
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
	
	
	openFile();
}


sharedMemObject::~sharedMemObject()
{
	free(sdata);
	fclose(fp);
	
}



void sharedMemObject::openFile()
{
	fp = fopen("mydata.txt", "w");
}




void sharedMemObject::save2file(double xfoot, bool movingBackward, bool movingForward, bool transitioning)
{
	// ensure proper spacing between 'fprintf' w/ a space after last %f
	fprintf(fp,"%d %f %f ",sdata->motorv_int /*1*/, sdata->lcR_lbs/*2*/, sdata->lcL_lbs/*3*/);

	fprintf(fp,"%f %f %f %f %d %f %f %f %f %f ", sdata->time /*4*/,sdata->tspeed_desired/*5*/, sdata->xd/*6*/, sdata->xact/*7*/, sdata->perturb/*8*/,sdata->angle_enc/*9*/, sdata->Kd/*10*/, sdata->Kact/*11*/, sdata->force_b/*12*/, sdata->elapsed/*13*/);

	fprintf(fp,"%d %d %f %f ", sdata->numEMG/*14*/,sdata->cycle/*15*/,sdata->time_vst_absolute/*16*/,sdata->zero_time_absolute/*17*/);
 
	for (int i = 0; i<3; i++)
	fprintf(fp,"%f ", sdata->jt_angles_l[i]); /*18-20*/ 

	fprintf(fp,"%f ", xfoot);/*21*/
	
	fprintf(fp,"%d %d %d", movingBackward/*22*/, movingForward/*23*/, transitioning/*24*/); 
	
	//fprintf(fp," %f",sdata->xf/*25*/);

	fprintf(fp,"\n");
}