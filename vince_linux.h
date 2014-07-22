//#ifndef _vince_h
//#define _vince_h

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


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
int send_command(const char*,int);
int get_data();
markers_struct initialize_markers(const char*);
int update_markers(markers_struct *);

//#endif
