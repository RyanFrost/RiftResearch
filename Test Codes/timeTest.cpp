
#include <ctime>
#include <cstdio>
#include <cmath>
#include <iostream>

int main()
{

	std:: clock_t start;
	start = std::clock();
	
	int x;
	
	for (int i = 0; i<1000000;i++)
	{
		x = std::pow(i,2);
	}
	
	std::cout << "Time: " << (std::clock() - start) / (double)(CLOCKS_PER_SEC / 1000) << " ms" << std::endl;	
	


	return 0;
}
