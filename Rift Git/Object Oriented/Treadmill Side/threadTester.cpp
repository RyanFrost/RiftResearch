
#include <iostream>
#include <boost/thread.hpp>



void startProcess(void);

int main()
{
	
	
	boost::thread t1(startProcess);
	t1.join();
	
	
	
	
	
	
	
	return 0;
}


void startProcess()
{
	for(int i = 0; i<10000; i++)
	{
		std::cout << i << std::endl;
	}
}