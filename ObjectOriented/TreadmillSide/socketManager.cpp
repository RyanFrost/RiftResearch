#include "socketManager.h"


#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <cstdio>

#include <iostream>
#include <vector>
#include <boost/lexical_cast.hpp>





socketManager::socketManager(int portNumber) : port(portNumber)
{
	initSocket();
}


socketManager::~socketManager()
{
	cleanUpSocket();
}


void socketManager::initSocket()
{
	std::cout << "Initializing Rift connection... " << std::flush;
	
	struct sockaddr_in server;
	server.sin_family = AF_INET;
	server.sin_addr.s_addr = INADDR_ANY;
	server.sin_port = htons(port);


	//Create socket
	
	//std::cout << "Creating socket..." << std::endl;
	if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
	{
		perror("cannot create socket");
		return;
	}
	//std::cout << "Socket created." << std::endl;

	

	//Bind socket
	//std::cout << "Binding socket to port...   ";
	if (bind(sockfd, (struct sockaddr *)&server, sizeof(server)) < 0)
	{
		perror("bind failed");
		return;
	}
	
	std::cout << "successful." << std::endl;
}


std::vector<char> socketManager::recvData(void)
{
	//Declare sockaddr_in struct for client
	
	socklen_t remLen = sizeof(remoteHost);

	int recv_len;
	
	// Preallocate buffer
	buf.resize(1024);
	
	if ((recv_len = recvfrom(sockfd, &buf[0], buf.size(), 0, (struct sockaddr *) &remoteHost, &remLen)) < 0)
	{
		perror("Recv Failed");
	}
	
	// Truncate buffer to length of message
	buf.resize(recv_len);
	
	return buf;

}

void socketManager::sendBuf(void)
{
	
	int remLen = sizeof(remoteHost);


	if (sendto(sockfd, &buf[0], buf.size(), 0, (sockaddr *) &remoteHost, remLen) < 0)
	{
		perror("Send failed.");
	}
}

void socketManager::loadIntArrayToBuf(std::vector<int> vec)
{
	// clear buffer
	
	buf.clear();
	
	std::string valStr;

	// Create string containing comma-delimited list of the input numbers
	for (std::vector<int>::iterator iter = vec.begin(); iter != vec.end(); iter++)
	{
		// cast the int to a string, then append to the main string
		valStr.append(boost::lexical_cast<std::string>(*iter));
		
		if (iter < vec.end() - 1) // Doesn't put a comma after the last number
		{
			valStr.append(",");
		}
	}
	
	// copy the string into the vector<char> buffer
	std::copy(valStr.begin(), valStr.end(), back_inserter(buf));
}

void socketManager::loadDubArrayToBuf(std::vector<double> vec)
{

	buf.clear();

	std::string valStr;

	// Create string containing comma-delimited list of the input numbers
	for (std::vector<double>::iterator iter = vec.begin(); iter != vec.end(); iter++)
	{
		// cast the int to a string, then append to the main string
		valStr.append(boost::lexical_cast<std::string>(*iter));

		if (iter < vec.end() - 1) // Doesn't put a comma after the last number
		{
			valStr.append(",");
		}
	}

	// copy the string into the vector<char> buffer
	std::copy(valStr.begin(), valStr.end(), back_inserter(buf));



}

void socketManager::loadIntToBuf(int integer)
{
	
	buf.clear();
	std::string intStr = std::to_string(integer);
	std::copy(intStr.begin(), intStr.end(), back_inserter(buf));
}

void socketManager::loadDubToBuf(double dub)
{
	buf.clear();
	std::string dubStr = std::to_string(dub);
	std::copy(dubStr.begin(), dubStr.end(), back_inserter(buf));
}


void socketManager::cleanUpSocket(void)
{
	close(sockfd);
	//std::cout << "Socket Destroyed." << std::endl;
}