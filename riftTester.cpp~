

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
#include <time.h>


#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#define PORT 27015
#define STEPSIZE 512
#define PSIZE 10

using namespace std;




int n;
double stepsTaken;
double aveStepLength;
double t_elapsed;

timespec tStart;
int temp1;
int bufferIter;









int main()
{
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
	
	char patch[] = 	"5,10,20,30,40,50,60,70,80,90,100";
	int sand_cycle[11] = {5,10,20,30,40,50,60,70,80,90,100};
	int ind = 1;
	
	//patch[0] = "10,60,100";
	//patchArrayString = "10,60,100";
	
	
	if(sendto(sockfd, patch, 100, 0, (struct sockaddr *)&remote_addr, addrlen) < 0)
	{
		perror("Send failed.");
		close(sockfd);
		return 0;
	}
	
	cout << "Response Received"  << endl;
	
	
	clock_gettime(CLOCK_MONOTONIC, &tStart);
	
	cout << "Timer started... \n";
	
	
	
	int length_of_for_loop = 1000000000;
	
	
	
	
	/* ----( Main loop )---- */
	for (int i = 0; i < length_of_for_loop; i++)
	{
		
		
		timespec tCurrent;
		
		clock_gettime(CLOCK_MONOTONIC, &tCurrent);
		t_elapsed = (tCurrent.tv_sec-tStart.tv_sec);
// 		cout << "Time elapsed since start: ";
// 		cout << t_elapsed;
// 		cout << "\n";
		stepsTaken = t_elapsed;
		n = sprintf(stepData,"%f,%f", stepsTaken*1,0.5);
		
		
		if (stepsTaken == sand_cycle[ind])
		{
			cout << "Print patch at " << sand_cycle[ind] << "\n";
			ind++;
		}
		
		
		for (bufferIter = n; bufferIter<STEPSIZE; bufferIter++)
		{
			stepData[bufferIter] = 0;
		}
		//cout << stepData;
		//cout << "\n";
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
		//cout << i;
		//cout << "\n";
		usleep(1000);
		
		
	}
	
	return 0;
}