#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
	int pid,p_exec_time;
	
	if(argc<3){
		printf(2,"Usage :chexectime pid exec_time\n");
		exit();
		}
	pid = atoi(argv[1]);
	p_exec_time=atoi(argv[2]);
	if(p_exec_time<0|| p_exec_time >50){
		printf(2,"Invalid exec_time !\n");
		exit();
	}
	printf(1,"pid=%d, exec_time%d\n",pid,p_exec_time);
	exec_time(pid,p_exec_time);
	
	exit();
	
		
}
