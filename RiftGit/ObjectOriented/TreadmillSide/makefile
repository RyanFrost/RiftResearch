OBJS = UDPSender.o socketManager.o dataGenerator.o sharedMemJeff.o
CC = g++
DEBUG = -g
CXXFLAGS = -Wall -c -std=c++0x $(DEBUG)
LFLAGS = -Wall -lboost_thread $(DEBUG)

udpSender : $(OBJS)
	$(CC) $(OBJS) -o udpSender $(LFLAGS)

UDPSender.o : UDPSender.cpp
	$(CC) $(CXXFLAGS) UDPSender.cpp

socketManager.o : socketManager.h socketManager.cpp
	$(CC) $(CXXFLAGS) socketManager.cpp

dataGenerator.o : dataGenerator.h dataGenerator.cpp
	$(CC) $(CXXFLAGS) dataGenerator.cpp

sharedMemJeff.o : sharedMemJeff.h sharedMemJeff.cpp
	$(CC) $(CXXFLAGS) sharedMemJeff.cpp

clean:
	\rm *.o *~ udpSender