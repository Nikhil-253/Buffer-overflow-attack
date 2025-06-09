#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
	int pid,p_policy;
	
	if(argc<3){
		printf(2,"Usage :chexectime pid exec_time\n");
		exit();
		}
	pid = atoi(argv[1]);
	p_policy=atoi(argv[2]);
	if(p_policy<-1|| p_policy >1){
		printf(2,"Invalid exec_time !\n");
		exit();
	}
	printf(1,"pid=%d, Sched_policy=%d\n",pid,p_policy);
	sched_policy(pid,p_policy);
	
	exit();
	
		
}
