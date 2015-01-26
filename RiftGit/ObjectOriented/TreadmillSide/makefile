OBJS = UDPSender.o socketManager.o dataGenerator.o sharedMemObject.o treadmillController.o
CC = g++
DEBUG = -g
CXXFLAGS = -Wall -Wextra -c -std=c++0x $(DEBUG)
LFLAGS = -Wall -lboost_thread -lmodbus $(DEBUG)

udpSender : $(OBJS)
	$(CC) $(OBJS) -o udpSender $(LFLAGS)

UDPSender.o : UDPSender.cpp
	$(CC) $(CXXFLAGS) UDPSender.cpp 

socketManager.o : socketManager.h socketManager.cpp
	$(CC) $(CXXFLAGS) socketManager.cpp 

dataGenerator.o : dataGenerator.h dataGenerator.cpp
	$(CC) $(CXXFLAGS) dataGenerator.cpp

sharedMemObject.o : sharedMemObject.h sharedMemObject.cpp
	$(CC) $(CXXFLAGS) sharedMemObject.cpp
	
treadmillController.o : treadmillController.h treadmillController.cpp
	$(CC) $(CXXFLAGS) treadmillController.cpp

clean:
	\rm *.o *~ udpSender
