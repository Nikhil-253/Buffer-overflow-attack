#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
	int k,n,id;
	double x=0,z,d;
	    int p_deadline[3] = {7, 24, 15};
   	    int p_exectime[3] = {5, 6, 4};
   	    int parent_pid = getpid();
   	    sched_policy(parent_pid, 0);
    	    deadline(parent_pid, 11);
            exec_time(parent_pid, 4);
	
	if(argc<2)
		n=1;
	else
		n= atoi(argv[1]);
		
	if (n<0 || n>20)
		n=2;
			
	if(argc<3)
		d=1.0;
	else
		d = atoi(argv[2]);
		
	x=0;
	id=0;
	for(k=0;k<n;k++){
		id= fork();
		if(id<0)
			printf(1,"%d failed in fork!\n",getpid());
	
		else if(id>0){
			printf(1,"Parent %d creating child %d\n",getpid(),id);
			while(1){
			}
			}
		else{
			printf(1,"Child %d creating \n",getpid());
			sched_policy(getpid(), 0);
            		deadline(getpid(), p_deadline[k]);
            		exec_time(getpid(), p_exectime[k]);
			for(z=0;z<8000000;z+=d)
				x=x+3.14*89.64;
			break;
		}
		}
		exit();
		}
	
		

