#pragma once

#include <WinSock2.h>
#include <vector>




class socketManagerWindows
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
	socketManagerWindows(int);
	~socketManagerWindows();
	


	
	void loadIntArrayToBuf(std::vector<int>);
	void loadDubArrayToBuf(std::vector<double>);

	std::vector<char> recvData(void);
	void sendBuf();
	std::vector<char> getBuf(void);


	

};

