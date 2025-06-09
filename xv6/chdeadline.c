#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
	int pid,p_deadline;
	
	if(argc<3){
		printf(2,"Usage :chexectime pid exec_time\n");
		exit();
		}
	pid = atoi(argv[1]);
	p_deadline=atoi(argv[2]);
	if(p_deadline<0|| p_deadline >50){
		printf(2,"Invalid exec_time !\n");
		exit();
	}
	printf(1,"pid=%d, deadline%d\n",pid,p_deadline);
	deadline(pid,p_deadline);
	
	exit();
	
		
}
