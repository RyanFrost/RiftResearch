
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>


#define DEFAULT_BUFLEN 512
#define DEFAULT_PORT "3020"

typedef struct {
       float x;
       float y;
       float z;
       float rel;
       int inview;
       } marker_struct;
       
typedef struct {
        int size;
        int m_sock;
        marker_struct *marker;
        int frame_number;
        long long time_stamp;
        } markers_struct;

int connect_server(const char*);
int send_command(const char*,int/*socket*/);
int get_data();
markers_struct initialize_markers(const char*);
int update_markers(markers_struct *);
int vsleep(int vs_time);

int vsleep(int vs_time)
{
     int vs_clock = clock();
     int vs_test = clock();
     
     while ((vs_test - vs_clock) < vs_time){
           vs_test = clock();
           }
           
     return 0;
     
}

int connect_server(const char* cs_server_address)
{    
 //Linux Method
 
 int cs_sock;
 struct hostent *server;
 struct sockaddr_in server_addr;

 //Create Socket
 cs_sock = socket(AF_INET,SOCK_STREAM,0);
 if ((server = gethostbyname(cs_server_address)) == NULL) {
  perror("Error Resolving Hostname:");
  exit(1);
 }
 //copy the network address part of the structure to the sockaddr_in structure which is passed to connect()
 memcpy(&server_addr.sin_addr, server->h_addr_list[0], server->h_length);
 server_addr.sin_family = AF_INET;
 server_addr.sin_port = htons(3020);
 //conect to the address
 if (connect(cs_sock, (struct sockaddr *)&server_addr, sizeof(server_addr))) {
  perror("Error establishing a connection: ");
  close(cs_sock);
  exit(1);
 }
 
 return cs_sock;

}

int send_command(const char *sc_command_input,int sc_sock)
{
    
    int sc_send_error;
    char *sc_sendbuf,*sc_iter_buf;
    char sc_packet_size = 8;
    char sc_packet_type = 1;
    int sc_bufcount;
    
    /*Set determine packet size and
    compose whole packet as referenced by "sc_sendbuf"*/
    
    sc_packet_size += strlen(sc_command_input);
    sc_sendbuf = (char*)malloc(sizeof(char)*sc_packet_size);
    
    /*packet size and packet type portion of the packet header. 
    see section 4.1 of RTC3D protocol manual */
    
    for (sc_bufcount = 1; sc_bufcount <= 8; sc_bufcount++){
        
        sc_iter_buf = sc_sendbuf + (sc_bufcount - 1);
        
        if (sc_bufcount == 4)
        {
             *sc_iter_buf = sc_packet_size;
        }
        else if (sc_bufcount == 8)
        {
             *sc_iter_buf = sc_packet_type;
        }
        else
        {
            *sc_iter_buf = (char) 0;
        }
    }
    
    //add command string to the end of the packet
    sc_iter_buf++;
    strcpy(sc_iter_buf, sc_command_input);
    
    //send packet and check for errors
    
    sc_send_error = send( sc_sock, sc_sendbuf, (int)sc_packet_size, 0 );
    if (sc_send_error == -1) {
        perror("send failed with error: %d\n");
        close(sc_sock);
        return -1;
    }else{

            return 1;
    }
    
}

int get_data(markers_struct *gd_markers_ptr,int gd_socket)
{
    
    int gd_read_error = 0;
    unsigned char *gd_recvbuf;
    unsigned char *gd_buf;
    unsigned char *gd_buf_holder;
    int gd_recvbuflen = 0;
    int gd_total_bytes = 0;
    int gd_i = 0;
    unsigned int gd_int = 0;
    unsigned int *gd_intptr = (unsigned int*)malloc(sizeof(int));
    float *gd_floatptr = (float *)malloc(sizeof(float));
    
    int gd_packet_size = 0;
    int gd_packet_type = 0;
    int gd_comp_count = 0;
    int gd_comp_size = 0;
    int gd_comp_type = 0;
    int gd_frame_num = 0;
    int gd_time_stamp = 0;
    int gd_marker_count = 0;
    markers_struct gd_markers;
    
    gd_recvbuflen = sizeof(char);
    
    gd_recvbuf = (unsigned char*)malloc(sizeof(char)*36);
    gd_buf = gd_recvbuf;
    
    gd_buf_holder = (unsigned char*)malloc(sizeof(char));
    //vsleep();
    
    do {
        
        gd_read_error = recv(gd_socket,/*(const char*)*/gd_buf_holder,gd_recvbuflen,0);
        *gd_recvbuf = *gd_buf_holder;
        gd_recvbuf++;
        gd_total_bytes += gd_read_error;
        if (gd_read_error < 0){
                          
                          perror("recv failed with error: %d\n");
                          return 0;
                          
        }
        
        
        if(gd_total_bytes >= 8 && gd_packet_size == 0){
                          
                          gd_packet_size = (int)(gd_buf[0]*pow(2,24) + gd_buf[1]*pow(2,16) + gd_buf[2]*pow(2,8) + gd_buf[3]);
                          gd_packet_type = (int)(gd_buf[4]*pow(2,24) + gd_buf[5]*pow(2,16) + gd_buf[6]*pow(2,8) + gd_buf[7]);
                          
        }
        
        if (gd_packet_type == 1){
                           
                           gd_buf = (unsigned char*)realloc(gd_buf, sizeof(char)*(gd_packet_size));
                           gd_recvbuf = gd_buf + gd_total_bytes;
                           
        }

        if (gd_packet_type == 3 && gd_packet_size > 0 && gd_marker_count == 0){
                           
                           gd_marker_count = (gd_packet_size - 36)/16;
                           gd_markers.size = gd_marker_count;
                           gd_markers.marker = (marker_struct*)malloc(sizeof(marker_struct)*gd_marker_count);
                           gd_buf = (unsigned char*)realloc(gd_buf, sizeof(char)*(gd_packet_size));
                           gd_recvbuf = gd_buf + gd_total_bytes;
                           
        }
        
        if (gd_packet_type == 4){
                           
                           return 0;    
        }
        
    } while (gd_read_error > 0 && gd_total_bytes != gd_packet_size);
    
    if (gd_packet_type == 3){
                       
                       gd_markers.frame_number = gd_buf[20] << 24 | gd_buf[21] << 16 | gd_buf[22] << 8 | gd_buf[23];
                       gd_markers.time_stamp = (long long)gd_buf[24] << 56 | (long long)gd_buf[25] << 48 | (long long)gd_buf[26] << 40 | (long long)gd_buf[27] << 32 | (long long)gd_buf[28] << 24 | (long long)gd_buf[29] << 16 | (long long)gd_buf[30] << 8 | (long long)gd_buf[31];
                       
                       gd_buf += 36;
                       
                       for (gd_i = 1; gd_i <= gd_markers.size; gd_i++){
                           //Concatenate X-value bytes 
                           gd_int = (gd_buf[16*(gd_i - 1)] << 24) | (gd_buf[1 + 16*(gd_i - 1)] << 16) | (gd_buf[2 + 16*(gd_i - 1)] << 8) | gd_buf[3 + 16*(gd_i - 1)];
                           //Convert concatenated bytes to floating point number
                           *gd_intptr = gd_int;
                           gd_floatptr = (float *) gd_intptr;
                           gd_markers.marker[gd_i - 1].x = *gd_floatptr;
                           //Concatenate Y-value bytes
                           gd_int = (gd_buf[4 + 16*(gd_i - 1)] << 24) | (gd_buf[5 + 16*(gd_i - 1)] << 16) | (gd_buf[6 + 16*(gd_i - 1)] << 8) | gd_buf[7 + 16*(gd_i - 1)];
                           //convert concatenated bytes to floating point number
                           *gd_intptr = gd_int;
                           gd_floatptr = (float *) gd_intptr;
                           gd_markers.marker[gd_i - 1].y = *gd_floatptr;
                           //concatenate Z-value bytes
                           gd_int = (gd_buf[8 + 16*(gd_i - 1)] << 24) | (gd_buf[9 + 16*(gd_i - 1)] << 16) | (gd_buf[10 + 16*(gd_i - 1)] << 8) | gd_buf[11 + 16*(gd_i - 1)];

                           //convert concatenated bytes to floating point number
                           *gd_intptr = gd_int;
                           gd_floatptr = (float *) gd_intptr;
                           gd_markers.marker[gd_i - 1].z = *gd_floatptr;
                           //Check for marker visibility and store visibility indicator
                           if (~(gd_int & -1) == 0){
                                        
                                        gd_markers.marker[gd_i - 1].inview = 0;
                                        
                           } else {
                                  
                                        gd_markers.marker[gd_i - 1].inview = 1;
                                        
                           }
                           //concatenate reliability bytes
                           gd_int = (gd_buf[12 + 16*(gd_i - 1)] << 24) + (gd_buf[13 + 16*(gd_i - 1)] << 16) + (gd_buf[14 + 16*(gd_i - 1)] << 8) + gd_buf[15 + 16*(gd_i - 1)];

                           //convert concatenated bytes to floating point number
                           *gd_intptr = gd_int;
                           gd_floatptr = (float *) gd_intptr;
                           gd_markers.marker[gd_i - 1].rel = *gd_floatptr;
                           
                       }
                       
                       
    }
    /*
    if (gd_packet_type == 1){
                       
                       for (gd_i = 8; gd_i < gd_packet_size; gd_i++){
                           
                           printf("%c",gd_buf[gd_i]);
                           
                       }
    }
    */
    if (gd_packet_type != 1){
                       gd_markers.m_sock = gd_socket;
                       *gd_markers_ptr = gd_markers;
    }
    
    //free(gd_buf);
    //gd_buf = realloc(gd_buf,0);
    //free(gd_buf_holder);
    //gd_buf_holder = realloc(gd_buf_holder,0);
    //free(gd_intptr);
    //gd_intptr = realloc(gd_intptr,0);
    free(gd_floatptr);
}

markers_struct initialize_markers(const char *im_ipaddress){
    
    const char *im_command1 = "Version 1.0";
    const char *im_command2 = "SetByteOrder BigEndian";
    const char *im_command3 = "SendCurrentFrame 3d";
    markers_struct im_markers;
    //Added by Mark Ison to allocate memory for markers
    im_markers.marker = (marker_struct*)malloc(sizeof(marker_struct));
    //connect to first principles server
    im_markers.m_sock = connect_server(im_ipaddress);
    //send initializing commands and read response
    send_command(im_command1,im_markers.m_sock);
    get_data(&im_markers,im_markers.m_sock);
    send_command(im_command2,im_markers.m_sock);
    get_data(&im_markers,im_markers.m_sock);
    //populate marker structures with initial data reading
    send_command(im_command3,im_markers.m_sock);
    get_data(&im_markers,im_markers.m_sock);
    get_data(&im_markers,im_markers.m_sock);
    
    return im_markers;
    
}

int update_markers(markers_struct *um_markers_ptr){
    
    const char *um_command = "SendCurrentFrame 3d";
    markers_struct um_markers;
    um_markers = *um_markers_ptr;
    free(um_markers.marker);
    send_command(um_command,um_markers.m_sock);
    get_data(&um_markers,um_markers.m_sock);
    get_data(&um_markers,um_markers.m_sock);
    *um_markers_ptr = um_markers;
    return 0;
    
}

////////////////////////////////////////////////////////////////////////////////
/*
int main(){
    
    char *main_ip_address = "10.200.83.213";
    int main_i;
    markers_struct markers;

    markers = initialize_markers(main_ip_address);
    
    update_markers(&markers);
    
    for (main_i = 0; main_i < markers.size; main_i++){
       
        printf("FrameNum:%d\n",markers.frame_number);
        printf("Timestamp:%llu\n",markers.time_stamp);
        printf("Inview: %d\n",markers.marker[main_i].inview);
        printf("X:%f\n",markers.marker[main_i].x);
        printf("Y:%f\n",markers.marker[main_i].y);
        printf("Z:%f\n",markers.marker[main_i].z);
        printf("REL:%f\n",markers.marker[main_i].rel);
        printf("=============================\n");
        }
    getchar();
    update_markers(&markers);
    printf("+++++++++++++++++++++++++++++++++\n");
    printf("Number of Markers: %d\n",markers.size);
    for (main_i = 0; main_i < markers.size; main_i++){
        printf("FrameNum:%d\n",markers.frame_number);
        printf("Timestamp:%llu\n",markers.time_stamp);
        printf("Inview: %d\n",markers.marker[main_i].inview);
        printf("X:%f\n",markers.marker[main_i].x);
        printf("Y:%f\n",markers.marker[main_i].y);
        printf("Z:%f\n",markers.marker[main_i].z);
        printf("REL:%f\n",markers.marker[main_i].rel);
        printf("=============================\n");
        }
    
    do{
     
     update_markers(&markers);
     main_i = main_i + 1;
     printf("FN:%d\n",markers.frame_number);

    }while (main_i < 100000);
    printf("+++++++++++++++++++++++++++++++++\n");
    printf("Number of Markers: %d\n",markers.size);
    for (main_i = 0; main_i < markers.size; main_i++){
        printf("FrameNum:%d\n",markers.frame_number);
        printf("Timestamp:%llu\n",markers.time_stamp);
        printf("Inview: %d\n",markers.marker[main_i].inview);
        printf("X:%f\n",markers.marker[main_i].x);
        printf("Y:%f\n",markers.marker[main_i].y);
        printf("Z:%f\n",markers.marker[main_i].z);
        printf("REL:%f\n",markers.marker[main_i].rel);
        printf("=============================\n");
        }
    return 0;
    
}*/

    
