#pragma once

#include <WinSock2.h>
#include <vector>




class socketManager
{
private:
	
	//Properties
	SOCKET sockfd;
	struct sockaddr_in remoteHost;
	int port;
	
	std::vector<char> buf;
	
	//Methods
	void initSocket(void);
	
	void cleanUpSocket(void);


public:
	socketManager(int);
	~socketManager();
	


	
	void loadIntArrayToBuf(std::vector<int>);
	void loadDubArrayToBuf(std::vector<double>);
	void loadIntToBuf(int);
	std::vector<char> recvData(void);
	void sendBuf();
	std::vector<char> getBuf(void);


	

};

