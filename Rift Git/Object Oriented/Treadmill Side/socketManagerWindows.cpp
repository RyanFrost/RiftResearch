#include "socketManager.h"
#include <WinSock2.h>
#include <iostream>
#include <vector>
#include <boost/lexical_cast.hpp>

#pragma comment(lib,"ws2_32.lib") //Winsock Library


#define PORT 27015

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
	std::cout << "Initializing socket." << std::endl;
	
	struct sockaddr_in server;
	WSADATA wsa;


	//Initialize winsock
	
	std::cout << "Initializing winsock..." << std::endl;
	if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
	{
		exit(EXIT_FAILURE);
	}
	std::cout << "Winsock initialized." << std::endl;
	
	//Create socket
	
	std::cout << "Creating socket..." << std::endl;
	if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == INVALID_SOCKET)
	{
		std::cout << "Could not create socket." << std::endl;
	}
	std::cout << "Socket created." << std::endl;

	//Prepare sockaddr_in struct
	
	server.sin_family = AF_INET;
	server.sin_addr.s_addr = INADDR_ANY;
	server.sin_port = htons(port);

	//Change socket options to allow dual connection on same port - for home computer only

	BOOL reuseVal = TRUE;
	int reuseLen = sizeof(BOOL);
	if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, (char*) &reuseVal, reuseLen) == SOCKET_ERROR)
	{
		std::cout << "setsockopt failed: " << WSAGetLastError() << std::endl;
	}

	//Bind socket
	std::cout << "Binding socket to port...   ";
	if (bind(sockfd, (struct sockaddr *)&server, sizeof(server)) == SOCKET_ERROR)
	{
		std::cout << "Bind failed." << std::endl;
		exit(EXIT_FAILURE);
	}
	
	std::cout << "Socket bound." << std::endl;
}


std::vector<char> socketManager::recvData(void)
{
	//Declare sockaddr_in struct for client
	
	int remLen;
	remLen = sizeof(remoteHost);

	int recv_len;
	
	// Preallocate buffer
	buf.resize(1024);
	
	if ((recv_len = recvfrom(sockfd, &buf[0], buf.size(), 0, (struct sockaddr *) &remoteHost, &remLen)) == SOCKET_ERROR)
	{
		std::cout << "recvfrom() failed with error: " << WSAGetLastError() << std::endl;
		exit(EXIT_FAILURE);
	}
	
	// Truncate buffer to length of message
	buf.resize(recv_len);
	
	return buf;

}

void socketManager::sendBuf(void)
{
	
	int remLen = sizeof(remoteHost);


	if (sendto(sockfd, &buf[0], buf.size(), 0, (sockaddr *) &remoteHost, remLen) == SOCKET_ERROR)
	{
		std::cout << "Error sending: " << WSAGetLastError() << std::endl;
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
std::vector<char> socketManager::getBuf(void)
{
	return buf;
}





void socketManager::cleanUpSocket(void)
{
	closesocket(sockfd);
	WSACleanup();
	std::cout << "Socket Destroyed." << std::endl;
}