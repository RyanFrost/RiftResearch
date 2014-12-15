#include <fstream>
#include <vector>
#include <iostream>
#include <chrono>
#include <sstream>
#include <cmath>

int main()
{


	std::ifstream fileInput("testData.txt");
        int numLines = 37695;
        std::vector<std::vector<double> > dataVec(numLines, std::vector<double> (7, 0));
        std::string line;
        int lineNum = 0;
        while( std::getline(fileInput, line))
        {
                std::istringstream iss(line);
                for (int i = 0; i < 7; i++)
                {
                        iss >> dataVec[lineNum][i];
                }
                lineNum++;
        }
	
	double diff = (dataVec[numLines-1][0] - dataVec[0][0]) / numLines;
	std::cout << "Total diff = " << diff << ", small diff = " << diff/numLines << std::endl;
        
        typedef std::chrono::high_resolution_clock Clock;
        typedef std::chrono::duration<double> secDouble;
        
        std::chrono::high_resolution_clock timer;
        
        Clock::time_point startTime = timer.now();
        secDouble secs;
	int timeIndex = 0;
	int prevValue = 0;
	while( true )
	{
		secs = timer.now() - startTime;
		timeIndex = (int) std::round( secs.count() / diff );
		if ( prevValue == timeIndex )
		{
			std::cout << '\r' << timeIndex;
			prevValue = timeIndex;
		}
	}
		
		
	



	return 0;
}
