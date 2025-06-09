#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}


// MOD-1 : System call to show running processes
void process_status(void);
int
sys_ps(void)
{
  process_status();
  return 0;
}


// System call exect time 
int change_exec_time(int,int);
int
sys_exec_time(void){

int pid,et;
if(argint(0,&pid)<0)
	return -1;

if(argint(1,&et)<0)
	return -1;
	
return change_exec_time(pid,et);

}

// System call deadline 
int change_deadline(int,int);
int
sys_deadline(void){

int pid,dl;
if(argint(0,&pid)<0)
	return -1;

if(argint(1,&dl)<0)
	return -1;
	
return change_deadline(pid,dl);

}



// System call policy 
int change_sched_policy(int,int);
int
sys_sched_policy(void){

int pid,py;
if(argint(0,&pid)<0)
	return -1;

if(argint(1,&py)<0)
	return -1;
	
return change_sched_policy(pid,py);

}

int change_rate(int,int);
int
sys_rate(void){

int pid,rt;
if(argint(0,&pid)<0)
	return -1;

if(argint(1,&rt)<0)
	return -1;

	
return change_rate(pid,rt);

}














