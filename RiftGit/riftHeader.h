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
#include <boost/lexical_cast.hpp>
#include <iterator>

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#define PORT 27015
#define STEPSIZE 512
#define PSIZE 10

#ifndef M_PI 
#define M_PI 3.14159
#endif



#define SHM_SIZE 1024 /* make it a 1K shared memory segment */

const char filename[] = "mydata.txt";



