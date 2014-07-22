

#include <iostream>
#include <cstdio>




int main()
{
	
	int numArray[14];
	char a[200];
	char *aP = a;
	for (int i = 0; i< 14; i++)
	{
		numArray[i] = i*3;
		
	}
	for (int i = 0; i< 13; i++)
	{
		aP += sprintf(aP,"%d ",numArray[i]);
	}
	
	aP += sprintf(aP,"%d",numArray[13]);
	
	printf("%s\n",aP);
	
	
	
	
	return 0;
}