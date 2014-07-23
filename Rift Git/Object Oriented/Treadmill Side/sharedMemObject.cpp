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
}

sharedMemObject::~sharedMemObject()
{
	free(sdata);
}