OBJS = UDPSender.o socketManagerLinux.o dataGenerator.o 
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

dataGenerator.o : dataGenerator.h dataGenerator.cpp
	$(CC) $(CXXFLAGS) dataGenerator.cpp -L/usr/lib -lboost_thread

clean:
	\rm *.o *~ udpSender