#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#include <iomanip>
#include <iostream>
#include <string>

int main(void){
   //Structure for address of server
   struct sockaddr_in myaddr;
   int sock;

   //Construct the server sockaddr_ structure
   memset(&myaddr, 0, sizeof(myaddr));
   myaddr.sin_family=AF_INET;
//-----------------------------------------------------------------
// This line is correct because you want to bind an address on 
// you machine
//-----------------------------------------------------------------
   myaddr.sin_addr.s_addr=htonl(INADDR_ANY);

//-----------------------------------------------------------------
// This is the port on your machine that you are going to bind.  
// This doesn't matter because the server just returns to the port
// it received the request on.  Port zero is any port.
//-----------------------------------------------------------------
   //myaddr.sin_port=htons(9045);
   myaddr.sin_port=htons(0);

   //Create the socket
   if((sock=socket(AF_INET, SOCK_DGRAM, 0))<0) {
      perror("Failed to create socket");
      exit(EXIT_FAILURE);
   }

   if(bind(sock,( struct sockaddr *) &myaddr, sizeof(myaddr))<0) {
      perror("bind failed");
      exit(EXIT_FAILURE);
   }
 
   inet_pton(AF_INET,"10.200.148.194",&myaddr.sin_addr.s_addr);
//-----------------------------------------------------------------
// Here is where the port matters, because you know the server is
// listening on that port.  So we must set the port number here 
// for the out going message.
//-----------------------------------------------------------------
   myaddr.sin_port=htons(27015);

//-----------------------------------------------------------------
// I don't know where the exact string is but this returns a message
//-----------------------------------------------------------------
   std::string s("THIS IS A WARNING");

   //send the message to server
   if(sendto(sock, s.c_str(), s.size(), 0, (struct sockaddr *)&myaddr, sizeof(myaddr))!=s.size()) {
      perror("Mismatch in number of bytes sent");
      exit(EXIT_FAILURE);
   }

   close(sock);
   return 0;

