#include "sharedMemObject.h"

#include <sys/ipc.h>
#include <sys/shm.h>
#include <cstdio>
#include <cstdlib>
#include <cstdint>

sharedMemObject::sharedMemObject(const char * fileName)
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
	
	
	openFile(fileName);
}


sharedMemObject::~sharedMemObject()
{
	fclose(fp);
}



void sharedMemObject::openFile(const char *file)
{
	fp = fopen(file, "w");
}




void sharedMemObject::save2file(bool movingBackward, bool movingForward, double distance, int currentPatch, int patchType)
{
	// ensure proper spacing between 'fprintf' w/ a space after last %f

	fprintf(fp,"%d %f %f %f %f %f %f %d %f %f %f %f %f %d %d %f %f ",
			sdata->motorv_int 		/*1*/,
		       	sdata->lcR_lbs			/*2*/,
		       	sdata->lcL_lbs			/*3*/,
		       	sdata->time	 		/*4*/,
			sdata->tspeed_desired		/*5*/,
		       	sdata->xd_raw			/*6*/,
		       	sdata->xact			/*7*/,
			sdata->perturb			/*8*/,
			sdata->angle_enc		/*9*/,
		       	sdata->Kd			/*10*/,
		       	sdata->Kact			/*11*/,
		       	sdata->Fb_raw			/*12*/,
		       	sdata->elapsed			/*13*/,
		       	sdata->numEMG			/*14*/,
			sdata->cycle			/*15*/,
			sdata->time_vst_absolute	/*16*/,
			sdata->zero_time_absolute	/*17*/);

 
	for (int i = 0; i<6; i++)
	{
		fprintf(fp,"%f ",
			sdata->joint_angles_rift[i]); /*18-23*/ 
	}

	fprintf(fp,"%f %d %d %f %d %d ",
		       	sdata->xf			/*24*/,
	       		movingBackward			/*25*/,
		       	movingForward			/*26*/,
	       		distance			/*27*/,
		       	currentPatch			/*28*/,
		       	patchType			/*29*/);
			
	for (int i = 0; i<6; i++)
	{
		fprintf(fp,"%f ",
			sdata->marker_x_posl[i]);	/*30-35*/
	}
	for (int i = 0; i<6; i++)
	{
		fprintf(fp,"%f ",
			sdata->marker_y_posl[i]);	/*36-41*/
	}
	for (int i = 0; i<6; i++)
	{
		fprintf(fp,"%f ",
			sdata->marker_x_posr[i]);	/*42-47*/
	}
	for (int i = 0; i<6; i++)
	{
		fprintf(fp,"%f ",
			sdata->marker_y_posr[i]);	/*48-53*/
	}


	
	//fprintf(fp," %f",sdata->xf/*27*/);

	fprintf(fp,"\n");
}
