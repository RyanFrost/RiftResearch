OBJS = UDPSender.o socketManagerLinux.o dataGeneratorLinux.o sharedMemObject.o
CC = g++
DEBUG = -g
CXXFLAGS = -Wall -c -std=c++0x $(DEBUG)
LFLAGS = -Wall $(DEBUG)

udpSender : $(OBJS)
	$(CC) $(LFLAGS) $(OBJS) -o udpSender

UDPSender.o : UDPSender.cpp
	$(CC) $(CXXFLAGS) UDPSender.cpp

socketManagerLinux.o : socketManagerLinux.h socketManagerLinux.cpp
	$(CC) $(CXXFLAGS) socketManagerLinux.cpp

dataGenerator.o : dataGeneratorLinux.h dataGeneratorLinux.cpp
	$(CC) $(CXXFLAGS) dataGeneratorLinux.cpp

sharedMemObject.o : sharedMemObject.h sharedMemObject.cpp
	$(CC) $(CXXFLAGS) sharedMemObject.cpp

clean:
	\rm *.o *~ udpSender