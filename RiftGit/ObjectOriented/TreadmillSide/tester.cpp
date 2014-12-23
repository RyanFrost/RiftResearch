#include <fstream>
#include <vector>
#include <iostream>
#include <chrono>
#include <sstream>
#include <cmath>


int main()
{


	std::ifstream fileInput("testData.txt");
	std::size_t numLines = 0;
        std::string line;
	while ( std::getline(fileInput,line) )
	{
		numLines++;
	}
	fileInput.clear();
	fileInput.seekg(0,fileInput.beg);
        std::vector<std::vector<double> > dataVec(numLines, std::vector<double> (8, 0));
        int lineNum = 0;
	double startingTime;

        while( std::getline(fileInput, line))
        {
                std::istringstream iss(line);
                for (int i = 0; i < 8; i++)
                {
                        iss >> dataVec[lineNum][i];
                }
		if ( lineNum == 0 )
		{
			startingTime = dataVec[0][0];
		}
		dataVec[lineNum][0] -= startingTime;
                lineNum++;
        }


	double diff = (dataVec[numLines-1][0] - dataVec[0][0])/(numLines);

        typedef std::chrono::high_resolution_clock Clock;
        typedef std::chrono::duration<double> secDouble;
        
        std::chrono::high_resolution_clock timer;
        
        Clock::time_point startTime = timer.now();
        secDouble secs;
	int timeIndex = 0;
	int prevValue = 0;

	std::vector<double> angles;
	angles.resize(6);
	while( true )
	{
		secs = timer.now() - startTime;
		timeIndex =  std::round( secs.count() / diff );
		if (timeIndex != prevValue)
		{

			angles.assign(dataVec[timeIndex].begin() + 1, dataVec[timeIndex].end() - 1);
			
			std::cout << '\r';
			for ( int i = 0; i < 6; i++)
			{
				std::cout << angles[i] << ", ";
			}

			std::cout << std::flush;	
			prevValue = timeIndex;
		}

		
	}
		
		
	



	return 0;
}
