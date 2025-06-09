
_buffer_overflow:     file format elf32-i386


Disassembly of section .text:

00000000 <foo>:
#include "types.h"
#include "user.h"
#include "fcntl.h"

void foo () {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
	printf (1 , "SECRET_STRING" ) ;
   6:	83 ec 08             	sub    $0x8,%esp
   9:	68 2e 08 00 00       	push   $0x82e
   e:	6a 01                	push   $0x1
  10:	e8 62 04 00 00       	call   477 <printf>
  15:	83 c4 10             	add    $0x10,%esp
}
  18:	90                   	nop
  19:	c9                   	leave  
  1a:	c3                   	ret    

0000001b <vulnerable_function>:

void vulnerable_function ( char * input ) {
  1b:	55                   	push   %ebp
  1c:	89 e5                	mov    %esp,%ebp
  1e:	83 ec 18             	sub    $0x18,%esp
	char buffer [4];
	strcpy(buffer,input) ;
  21:	83 ec 08             	sub    $0x8,%esp
  24:	ff 75 08             	push   0x8(%ebp)
  27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  2a:	50                   	push   %eax
  2b:	e8 7a 00 00 00       	call   aa <strcpy>
  30:	83 c4 10             	add    $0x10,%esp
}
  33:	90                   	nop
  34:	c9                   	leave  
  35:	c3                   	ret    

00000036 <main>:

int main ( int argc , char ** argv ){
  36:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  3a:	83 e4 f0             	and    $0xfffffff0,%esp
  3d:	ff 71 fc             	push   -0x4(%ecx)
  40:	55                   	push   %ebp
  41:	89 e5                	mov    %esp,%ebp
  43:	51                   	push   %ecx
  44:	83 ec 74             	sub    $0x74,%esp
	int fd = open ("payload",O_RDWR) ;
  47:	83 ec 08             	sub    $0x8,%esp
  4a:	6a 02                	push   $0x2
  4c:	68 3c 08 00 00       	push   $0x83c
  51:	e8 c5 02 00 00       	call   31b <open>
  56:	83 c4 10             	add    $0x10,%esp
  59:	89 45 f4             	mov    %eax,-0xc(%ebp)
	char payload [100];
	read (fd , payload , 100) ;
  5c:	83 ec 04             	sub    $0x4,%esp
  5f:	6a 64                	push   $0x64
  61:	8d 45 90             	lea    -0x70(%ebp),%eax
  64:	50                   	push   %eax
  65:	ff 75 f4             	push   -0xc(%ebp)
  68:	e8 86 02 00 00       	call   2f3 <read>
  6d:	83 c4 10             	add    $0x10,%esp
	vulnerable_function (payload) ;
  70:	83 ec 0c             	sub    $0xc,%esp
  73:	8d 45 90             	lea    -0x70(%ebp),%eax
  76:	50                   	push   %eax
  77:	e8 9f ff ff ff       	call   1b <vulnerable_function>
  7c:	83 c4 10             	add    $0x10,%esp
	exit () ;
  7f:	e8 57 02 00 00       	call   2db <exit>

00000084 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  84:	55                   	push   %ebp
  85:	89 e5                	mov    %esp,%ebp
  87:	57                   	push   %edi
  88:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8c:	8b 55 10             	mov    0x10(%ebp),%edx
  8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  92:	89 cb                	mov    %ecx,%ebx
  94:	89 df                	mov    %ebx,%edi
  96:	89 d1                	mov    %edx,%ecx
  98:	fc                   	cld    
  99:	f3 aa                	rep stos %al,%es:(%edi)
  9b:	89 ca                	mov    %ecx,%edx
  9d:	89 fb                	mov    %edi,%ebx
  9f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  a2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  a5:	90                   	nop
  a6:	5b                   	pop    %ebx
  a7:	5f                   	pop    %edi
  a8:	5d                   	pop    %ebp
  a9:	c3                   	ret    

000000aa <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  aa:	55                   	push   %ebp
  ab:	89 e5                	mov    %esp,%ebp
  ad:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  b0:	8b 45 08             	mov    0x8(%ebp),%eax
  b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  b6:	90                   	nop
  b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  ba:	8d 42 01             	lea    0x1(%edx),%eax
  bd:	89 45 0c             	mov    %eax,0xc(%ebp)
  c0:	8b 45 08             	mov    0x8(%ebp),%eax
  c3:	8d 48 01             	lea    0x1(%eax),%ecx
  c6:	89 4d 08             	mov    %ecx,0x8(%ebp)
  c9:	0f b6 12             	movzbl (%edx),%edx
  cc:	88 10                	mov    %dl,(%eax)
  ce:	0f b6 00             	movzbl (%eax),%eax
  d1:	84 c0                	test   %al,%al
  d3:	75 e2                	jne    b7 <strcpy+0xd>
    ;
  return os;
  d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d8:	c9                   	leave  
  d9:	c3                   	ret    

000000da <strcmp>:

int
strcmp(const char *p, const char *q)
{
  da:	55                   	push   %ebp
  db:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  dd:	eb 08                	jmp    e7 <strcmp+0xd>
    p++, q++;
  df:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  e3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  e7:	8b 45 08             	mov    0x8(%ebp),%eax
  ea:	0f b6 00             	movzbl (%eax),%eax
  ed:	84 c0                	test   %al,%al
  ef:	74 10                	je     101 <strcmp+0x27>
  f1:	8b 45 08             	mov    0x8(%ebp),%eax
  f4:	0f b6 10             	movzbl (%eax),%edx
  f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  fa:	0f b6 00             	movzbl (%eax),%eax
  fd:	38 c2                	cmp    %al,%dl
  ff:	74 de                	je     df <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 101:	8b 45 08             	mov    0x8(%ebp),%eax
 104:	0f b6 00             	movzbl (%eax),%eax
 107:	0f b6 d0             	movzbl %al,%edx
 10a:	8b 45 0c             	mov    0xc(%ebp),%eax
 10d:	0f b6 00             	movzbl (%eax),%eax
 110:	0f b6 c8             	movzbl %al,%ecx
 113:	89 d0                	mov    %edx,%eax
 115:	29 c8                	sub    %ecx,%eax
}
 117:	5d                   	pop    %ebp
 118:	c3                   	ret    

00000119 <strlen>:

uint
strlen(const char *s)
{
 119:	55                   	push   %ebp
 11a:	89 e5                	mov    %esp,%ebp
 11c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 11f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 126:	eb 04                	jmp    12c <strlen+0x13>
 128:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 12c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 12f:	8b 45 08             	mov    0x8(%ebp),%eax
 132:	01 d0                	add    %edx,%eax
 134:	0f b6 00             	movzbl (%eax),%eax
 137:	84 c0                	test   %al,%al
 139:	75 ed                	jne    128 <strlen+0xf>
    ;
  return n;
 13b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13e:	c9                   	leave  
 13f:	c3                   	ret    

00000140 <memset>:

void*
memset(void *dst, int c, uint n)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 143:	8b 45 10             	mov    0x10(%ebp),%eax
 146:	50                   	push   %eax
 147:	ff 75 0c             	push   0xc(%ebp)
 14a:	ff 75 08             	push   0x8(%ebp)
 14d:	e8 32 ff ff ff       	call   84 <stosb>
 152:	83 c4 0c             	add    $0xc,%esp
  return dst;
 155:	8b 45 08             	mov    0x8(%ebp),%eax
}
 158:	c9                   	leave  
 159:	c3                   	ret    

0000015a <strchr>:

char*
strchr(const char *s, char c)
{
 15a:	55                   	push   %ebp
 15b:	89 e5                	mov    %esp,%ebp
 15d:	83 ec 04             	sub    $0x4,%esp
 160:	8b 45 0c             	mov    0xc(%ebp),%eax
 163:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 166:	eb 14                	jmp    17c <strchr+0x22>
    if(*s == c)
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	0f b6 00             	movzbl (%eax),%eax
 16e:	38 45 fc             	cmp    %al,-0x4(%ebp)
 171:	75 05                	jne    178 <strchr+0x1e>
      return (char*)s;
 173:	8b 45 08             	mov    0x8(%ebp),%eax
 176:	eb 13                	jmp    18b <strchr+0x31>
  for(; *s; s++)
 178:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17c:	8b 45 08             	mov    0x8(%ebp),%eax
 17f:	0f b6 00             	movzbl (%eax),%eax
 182:	84 c0                	test   %al,%al
 184:	75 e2                	jne    168 <strchr+0xe>
  return 0;
 186:	b8 00 00 00 00       	mov    $0x0,%eax
}
 18b:	c9                   	leave  
 18c:	c3                   	ret    

0000018d <gets>:

char*
gets(char *buf, int max)
{
 18d:	55                   	push   %ebp
 18e:	89 e5                	mov    %esp,%ebp
 190:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 19a:	eb 42                	jmp    1de <gets+0x51>
    cc = read(0, &c, 1);
 19c:	83 ec 04             	sub    $0x4,%esp
 19f:	6a 01                	push   $0x1
 1a1:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1a4:	50                   	push   %eax
 1a5:	6a 00                	push   $0x0
 1a7:	e8 47 01 00 00       	call   2f3 <read>
 1ac:	83 c4 10             	add    $0x10,%esp
 1af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b6:	7e 33                	jle    1eb <gets+0x5e>
      break;
    buf[i++] = c;
 1b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bb:	8d 50 01             	lea    0x1(%eax),%edx
 1be:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1c1:	89 c2                	mov    %eax,%edx
 1c3:	8b 45 08             	mov    0x8(%ebp),%eax
 1c6:	01 c2                	add    %eax,%edx
 1c8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1cc:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ce:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d2:	3c 0a                	cmp    $0xa,%al
 1d4:	74 16                	je     1ec <gets+0x5f>
 1d6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1da:	3c 0d                	cmp    $0xd,%al
 1dc:	74 0e                	je     1ec <gets+0x5f>
  for(i=0; i+1 < max; ){
 1de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e1:	83 c0 01             	add    $0x1,%eax
 1e4:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1e7:	7f b3                	jg     19c <gets+0xf>
 1e9:	eb 01                	jmp    1ec <gets+0x5f>
      break;
 1eb:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	01 d0                	add    %edx,%eax
 1f4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1fa:	c9                   	leave  
 1fb:	c3                   	ret    

000001fc <stat>:

int
stat(const char *n, struct stat *st)
{
 1fc:	55                   	push   %ebp
 1fd:	89 e5                	mov    %esp,%ebp
 1ff:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 202:	83 ec 08             	sub    $0x8,%esp
 205:	6a 00                	push   $0x0
 207:	ff 75 08             	push   0x8(%ebp)
 20a:	e8 0c 01 00 00       	call   31b <open>
 20f:	83 c4 10             	add    $0x10,%esp
 212:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 215:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 219:	79 07                	jns    222 <stat+0x26>
    return -1;
 21b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 220:	eb 25                	jmp    247 <stat+0x4b>
  r = fstat(fd, st);
 222:	83 ec 08             	sub    $0x8,%esp
 225:	ff 75 0c             	push   0xc(%ebp)
 228:	ff 75 f4             	push   -0xc(%ebp)
 22b:	e8 03 01 00 00       	call   333 <fstat>
 230:	83 c4 10             	add    $0x10,%esp
 233:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 236:	83 ec 0c             	sub    $0xc,%esp
 239:	ff 75 f4             	push   -0xc(%ebp)
 23c:	e8 c2 00 00 00       	call   303 <close>
 241:	83 c4 10             	add    $0x10,%esp
  return r;
 244:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 247:	c9                   	leave  
 248:	c3                   	ret    

00000249 <atoi>:

int
atoi(const char *s)
{
 249:	55                   	push   %ebp
 24a:	89 e5                	mov    %esp,%ebp
 24c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 24f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 256:	eb 25                	jmp    27d <atoi+0x34>
    n = n*10 + *s++ - '0';
 258:	8b 55 fc             	mov    -0x4(%ebp),%edx
 25b:	89 d0                	mov    %edx,%eax
 25d:	c1 e0 02             	shl    $0x2,%eax
 260:	01 d0                	add    %edx,%eax
 262:	01 c0                	add    %eax,%eax
 264:	89 c1                	mov    %eax,%ecx
 266:	8b 45 08             	mov    0x8(%ebp),%eax
 269:	8d 50 01             	lea    0x1(%eax),%edx
 26c:	89 55 08             	mov    %edx,0x8(%ebp)
 26f:	0f b6 00             	movzbl (%eax),%eax
 272:	0f be c0             	movsbl %al,%eax
 275:	01 c8                	add    %ecx,%eax
 277:	83 e8 30             	sub    $0x30,%eax
 27a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	0f b6 00             	movzbl (%eax),%eax
 283:	3c 2f                	cmp    $0x2f,%al
 285:	7e 0a                	jle    291 <atoi+0x48>
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	0f b6 00             	movzbl (%eax),%eax
 28d:	3c 39                	cmp    $0x39,%al
 28f:	7e c7                	jle    258 <atoi+0xf>
  return n;
 291:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 294:	c9                   	leave  
 295:	c3                   	ret    

00000296 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 296:	55                   	push   %ebp
 297:	89 e5                	mov    %esp,%ebp
 299:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2a8:	eb 17                	jmp    2c1 <memmove+0x2b>
    *dst++ = *src++;
 2aa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2ad:	8d 42 01             	lea    0x1(%edx),%eax
 2b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b6:	8d 48 01             	lea    0x1(%eax),%ecx
 2b9:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2bc:	0f b6 12             	movzbl (%edx),%edx
 2bf:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2c1:	8b 45 10             	mov    0x10(%ebp),%eax
 2c4:	8d 50 ff             	lea    -0x1(%eax),%edx
 2c7:	89 55 10             	mov    %edx,0x10(%ebp)
 2ca:	85 c0                	test   %eax,%eax
 2cc:	7f dc                	jg     2aa <memmove+0x14>
  return vdst;
 2ce:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d1:	c9                   	leave  
 2d2:	c3                   	ret    

000002d3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2d3:	b8 01 00 00 00       	mov    $0x1,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <exit>:
SYSCALL(exit)
 2db:	b8 02 00 00 00       	mov    $0x2,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <wait>:
SYSCALL(wait)
 2e3:	b8 03 00 00 00       	mov    $0x3,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <pipe>:
SYSCALL(pipe)
 2eb:	b8 04 00 00 00       	mov    $0x4,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <read>:
SYSCALL(read)
 2f3:	b8 05 00 00 00       	mov    $0x5,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <write>:
SYSCALL(write)
 2fb:	b8 10 00 00 00       	mov    $0x10,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <close>:
SYSCALL(close)
 303:	b8 15 00 00 00       	mov    $0x15,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <kill>:
SYSCALL(kill)
 30b:	b8 06 00 00 00       	mov    $0x6,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <exec>:
SYSCALL(exec)
 313:	b8 07 00 00 00       	mov    $0x7,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <open>:
SYSCALL(open)
 31b:	b8 0f 00 00 00       	mov    $0xf,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <mknod>:
SYSCALL(mknod)
 323:	b8 11 00 00 00       	mov    $0x11,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <unlink>:
SYSCALL(unlink)
 32b:	b8 12 00 00 00       	mov    $0x12,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <fstat>:
SYSCALL(fstat)
 333:	b8 08 00 00 00       	mov    $0x8,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <link>:
SYSCALL(link)
 33b:	b8 13 00 00 00       	mov    $0x13,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <mkdir>:
SYSCALL(mkdir)
 343:	b8 14 00 00 00       	mov    $0x14,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <chdir>:
SYSCALL(chdir)
 34b:	b8 09 00 00 00       	mov    $0x9,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <dup>:
SYSCALL(dup)
 353:	b8 0a 00 00 00       	mov    $0xa,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <getpid>:
SYSCALL(getpid)
 35b:	b8 0b 00 00 00       	mov    $0xb,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <sbrk>:
SYSCALL(sbrk)
 363:	b8 0c 00 00 00       	mov    $0xc,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <sleep>:
SYSCALL(sleep)
 36b:	b8 0d 00 00 00       	mov    $0xd,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <uptime>:
SYSCALL(uptime)
 373:	b8 0e 00 00 00       	mov    $0xe,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <ps>:
SYSCALL(ps)
 37b:	b8 16 00 00 00       	mov    $0x16,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <exec_time>:
SYSCALL(exec_time)
 383:	b8 17 00 00 00       	mov    $0x17,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <deadline>:
SYSCALL(deadline)
 38b:	b8 18 00 00 00       	mov    $0x18,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    

00000393 <sched_policy>:
SYSCALL(sched_policy)
 393:	b8 19 00 00 00       	mov    $0x19,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret    

0000039b <rate>:
SYSCALL(rate)
 39b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret    

000003a3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3a3:	55                   	push   %ebp
 3a4:	89 e5                	mov    %esp,%ebp
 3a6:	83 ec 18             	sub    $0x18,%esp
 3a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ac:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3af:	83 ec 04             	sub    $0x4,%esp
 3b2:	6a 01                	push   $0x1
 3b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3b7:	50                   	push   %eax
 3b8:	ff 75 08             	push   0x8(%ebp)
 3bb:	e8 3b ff ff ff       	call   2fb <write>
 3c0:	83 c4 10             	add    $0x10,%esp
}
 3c3:	90                   	nop
 3c4:	c9                   	leave  
 3c5:	c3                   	ret    

000003c6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c6:	55                   	push   %ebp
 3c7:	89 e5                	mov    %esp,%ebp
 3c9:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3d3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3d7:	74 17                	je     3f0 <printint+0x2a>
 3d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3dd:	79 11                	jns    3f0 <printint+0x2a>
    neg = 1;
 3df:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e9:	f7 d8                	neg    %eax
 3eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ee:	eb 06                	jmp    3f6 <printint+0x30>
  } else {
    x = xx;
 3f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 400:	8b 45 ec             	mov    -0x14(%ebp),%eax
 403:	ba 00 00 00 00       	mov    $0x0,%edx
 408:	f7 f1                	div    %ecx
 40a:	89 d1                	mov    %edx,%ecx
 40c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40f:	8d 50 01             	lea    0x1(%eax),%edx
 412:	89 55 f4             	mov    %edx,-0xc(%ebp)
 415:	0f b6 91 d0 0a 00 00 	movzbl 0xad0(%ecx),%edx
 41c:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 420:	8b 4d 10             	mov    0x10(%ebp),%ecx
 423:	8b 45 ec             	mov    -0x14(%ebp),%eax
 426:	ba 00 00 00 00       	mov    $0x0,%edx
 42b:	f7 f1                	div    %ecx
 42d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 430:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 434:	75 c7                	jne    3fd <printint+0x37>
  if(neg)
 436:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 43a:	74 2d                	je     469 <printint+0xa3>
    buf[i++] = '-';
 43c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43f:	8d 50 01             	lea    0x1(%eax),%edx
 442:	89 55 f4             	mov    %edx,-0xc(%ebp)
 445:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 44a:	eb 1d                	jmp    469 <printint+0xa3>
    putc(fd, buf[i]);
 44c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 44f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 452:	01 d0                	add    %edx,%eax
 454:	0f b6 00             	movzbl (%eax),%eax
 457:	0f be c0             	movsbl %al,%eax
 45a:	83 ec 08             	sub    $0x8,%esp
 45d:	50                   	push   %eax
 45e:	ff 75 08             	push   0x8(%ebp)
 461:	e8 3d ff ff ff       	call   3a3 <putc>
 466:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 469:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 46d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 471:	79 d9                	jns    44c <printint+0x86>
}
 473:	90                   	nop
 474:	90                   	nop
 475:	c9                   	leave  
 476:	c3                   	ret    

00000477 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 477:	55                   	push   %ebp
 478:	89 e5                	mov    %esp,%ebp
 47a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 47d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 484:	8d 45 0c             	lea    0xc(%ebp),%eax
 487:	83 c0 04             	add    $0x4,%eax
 48a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 48d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 494:	e9 59 01 00 00       	jmp    5f2 <printf+0x17b>
    c = fmt[i] & 0xff;
 499:	8b 55 0c             	mov    0xc(%ebp),%edx
 49c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 49f:	01 d0                	add    %edx,%eax
 4a1:	0f b6 00             	movzbl (%eax),%eax
 4a4:	0f be c0             	movsbl %al,%eax
 4a7:	25 ff 00 00 00       	and    $0xff,%eax
 4ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4b3:	75 2c                	jne    4e1 <printf+0x6a>
      if(c == '%'){
 4b5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4b9:	75 0c                	jne    4c7 <printf+0x50>
        state = '%';
 4bb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4c2:	e9 27 01 00 00       	jmp    5ee <printf+0x177>
      } else {
        putc(fd, c);
 4c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4ca:	0f be c0             	movsbl %al,%eax
 4cd:	83 ec 08             	sub    $0x8,%esp
 4d0:	50                   	push   %eax
 4d1:	ff 75 08             	push   0x8(%ebp)
 4d4:	e8 ca fe ff ff       	call   3a3 <putc>
 4d9:	83 c4 10             	add    $0x10,%esp
 4dc:	e9 0d 01 00 00       	jmp    5ee <printf+0x177>
      }
    } else if(state == '%'){
 4e1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4e5:	0f 85 03 01 00 00    	jne    5ee <printf+0x177>
      if(c == 'd'){
 4eb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4ef:	75 1e                	jne    50f <printf+0x98>
        printint(fd, *ap, 10, 1);
 4f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f4:	8b 00                	mov    (%eax),%eax
 4f6:	6a 01                	push   $0x1
 4f8:	6a 0a                	push   $0xa
 4fa:	50                   	push   %eax
 4fb:	ff 75 08             	push   0x8(%ebp)
 4fe:	e8 c3 fe ff ff       	call   3c6 <printint>
 503:	83 c4 10             	add    $0x10,%esp
        ap++;
 506:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 50a:	e9 d8 00 00 00       	jmp    5e7 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 50f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 513:	74 06                	je     51b <printf+0xa4>
 515:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 519:	75 1e                	jne    539 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 51b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 51e:	8b 00                	mov    (%eax),%eax
 520:	6a 00                	push   $0x0
 522:	6a 10                	push   $0x10
 524:	50                   	push   %eax
 525:	ff 75 08             	push   0x8(%ebp)
 528:	e8 99 fe ff ff       	call   3c6 <printint>
 52d:	83 c4 10             	add    $0x10,%esp
        ap++;
 530:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 534:	e9 ae 00 00 00       	jmp    5e7 <printf+0x170>
      } else if(c == 's'){
 539:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 53d:	75 43                	jne    582 <printf+0x10b>
        s = (char*)*ap;
 53f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 542:	8b 00                	mov    (%eax),%eax
 544:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 547:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 54b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 54f:	75 25                	jne    576 <printf+0xff>
          s = "(null)";
 551:	c7 45 f4 44 08 00 00 	movl   $0x844,-0xc(%ebp)
        while(*s != 0){
 558:	eb 1c                	jmp    576 <printf+0xff>
          putc(fd, *s);
 55a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55d:	0f b6 00             	movzbl (%eax),%eax
 560:	0f be c0             	movsbl %al,%eax
 563:	83 ec 08             	sub    $0x8,%esp
 566:	50                   	push   %eax
 567:	ff 75 08             	push   0x8(%ebp)
 56a:	e8 34 fe ff ff       	call   3a3 <putc>
 56f:	83 c4 10             	add    $0x10,%esp
          s++;
 572:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 576:	8b 45 f4             	mov    -0xc(%ebp),%eax
 579:	0f b6 00             	movzbl (%eax),%eax
 57c:	84 c0                	test   %al,%al
 57e:	75 da                	jne    55a <printf+0xe3>
 580:	eb 65                	jmp    5e7 <printf+0x170>
        }
      } else if(c == 'c'){
 582:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 586:	75 1d                	jne    5a5 <printf+0x12e>
        putc(fd, *ap);
 588:	8b 45 e8             	mov    -0x18(%ebp),%eax
 58b:	8b 00                	mov    (%eax),%eax
 58d:	0f be c0             	movsbl %al,%eax
 590:	83 ec 08             	sub    $0x8,%esp
 593:	50                   	push   %eax
 594:	ff 75 08             	push   0x8(%ebp)
 597:	e8 07 fe ff ff       	call   3a3 <putc>
 59c:	83 c4 10             	add    $0x10,%esp
        ap++;
 59f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a3:	eb 42                	jmp    5e7 <printf+0x170>
      } else if(c == '%'){
 5a5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5a9:	75 17                	jne    5c2 <printf+0x14b>
        putc(fd, c);
 5ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ae:	0f be c0             	movsbl %al,%eax
 5b1:	83 ec 08             	sub    $0x8,%esp
 5b4:	50                   	push   %eax
 5b5:	ff 75 08             	push   0x8(%ebp)
 5b8:	e8 e6 fd ff ff       	call   3a3 <putc>
 5bd:	83 c4 10             	add    $0x10,%esp
 5c0:	eb 25                	jmp    5e7 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5c2:	83 ec 08             	sub    $0x8,%esp
 5c5:	6a 25                	push   $0x25
 5c7:	ff 75 08             	push   0x8(%ebp)
 5ca:	e8 d4 fd ff ff       	call   3a3 <putc>
 5cf:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d5:	0f be c0             	movsbl %al,%eax
 5d8:	83 ec 08             	sub    $0x8,%esp
 5db:	50                   	push   %eax
 5dc:	ff 75 08             	push   0x8(%ebp)
 5df:	e8 bf fd ff ff       	call   3a3 <putc>
 5e4:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5ee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5f2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5f8:	01 d0                	add    %edx,%eax
 5fa:	0f b6 00             	movzbl (%eax),%eax
 5fd:	84 c0                	test   %al,%al
 5ff:	0f 85 94 fe ff ff    	jne    499 <printf+0x22>
    }
  }
}
 605:	90                   	nop
 606:	90                   	nop
 607:	c9                   	leave  
 608:	c3                   	ret    

00000609 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 609:	55                   	push   %ebp
 60a:	89 e5                	mov    %esp,%ebp
 60c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 60f:	8b 45 08             	mov    0x8(%ebp),%eax
 612:	83 e8 08             	sub    $0x8,%eax
 615:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 618:	a1 ec 0a 00 00       	mov    0xaec,%eax
 61d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 620:	eb 24                	jmp    646 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 622:	8b 45 fc             	mov    -0x4(%ebp),%eax
 625:	8b 00                	mov    (%eax),%eax
 627:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 62a:	72 12                	jb     63e <free+0x35>
 62c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 632:	77 24                	ja     658 <free+0x4f>
 634:	8b 45 fc             	mov    -0x4(%ebp),%eax
 637:	8b 00                	mov    (%eax),%eax
 639:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 63c:	72 1a                	jb     658 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 63e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 641:	8b 00                	mov    (%eax),%eax
 643:	89 45 fc             	mov    %eax,-0x4(%ebp)
 646:	8b 45 f8             	mov    -0x8(%ebp),%eax
 649:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 64c:	76 d4                	jbe    622 <free+0x19>
 64e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 651:	8b 00                	mov    (%eax),%eax
 653:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 656:	73 ca                	jae    622 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 658:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65b:	8b 40 04             	mov    0x4(%eax),%eax
 65e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 665:	8b 45 f8             	mov    -0x8(%ebp),%eax
 668:	01 c2                	add    %eax,%edx
 66a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66d:	8b 00                	mov    (%eax),%eax
 66f:	39 c2                	cmp    %eax,%edx
 671:	75 24                	jne    697 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 673:	8b 45 f8             	mov    -0x8(%ebp),%eax
 676:	8b 50 04             	mov    0x4(%eax),%edx
 679:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67c:	8b 00                	mov    (%eax),%eax
 67e:	8b 40 04             	mov    0x4(%eax),%eax
 681:	01 c2                	add    %eax,%edx
 683:	8b 45 f8             	mov    -0x8(%ebp),%eax
 686:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 689:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68c:	8b 00                	mov    (%eax),%eax
 68e:	8b 10                	mov    (%eax),%edx
 690:	8b 45 f8             	mov    -0x8(%ebp),%eax
 693:	89 10                	mov    %edx,(%eax)
 695:	eb 0a                	jmp    6a1 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	8b 10                	mov    (%eax),%edx
 69c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	8b 40 04             	mov    0x4(%eax),%eax
 6a7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b1:	01 d0                	add    %edx,%eax
 6b3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6b6:	75 20                	jne    6d8 <free+0xcf>
    p->s.size += bp->s.size;
 6b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bb:	8b 50 04             	mov    0x4(%eax),%edx
 6be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c1:	8b 40 04             	mov    0x4(%eax),%eax
 6c4:	01 c2                	add    %eax,%edx
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cf:	8b 10                	mov    (%eax),%edx
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	89 10                	mov    %edx,(%eax)
 6d6:	eb 08                	jmp    6e0 <free+0xd7>
  } else
    p->s.ptr = bp;
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6de:	89 10                	mov    %edx,(%eax)
  freep = p;
 6e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e3:	a3 ec 0a 00 00       	mov    %eax,0xaec
}
 6e8:	90                   	nop
 6e9:	c9                   	leave  
 6ea:	c3                   	ret    

000006eb <morecore>:

static Header*
morecore(uint nu)
{
 6eb:	55                   	push   %ebp
 6ec:	89 e5                	mov    %esp,%ebp
 6ee:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6f1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6f8:	77 07                	ja     701 <morecore+0x16>
    nu = 4096;
 6fa:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 701:	8b 45 08             	mov    0x8(%ebp),%eax
 704:	c1 e0 03             	shl    $0x3,%eax
 707:	83 ec 0c             	sub    $0xc,%esp
 70a:	50                   	push   %eax
 70b:	e8 53 fc ff ff       	call   363 <sbrk>
 710:	83 c4 10             	add    $0x10,%esp
 713:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 716:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 71a:	75 07                	jne    723 <morecore+0x38>
    return 0;
 71c:	b8 00 00 00 00       	mov    $0x0,%eax
 721:	eb 26                	jmp    749 <morecore+0x5e>
  hp = (Header*)p;
 723:	8b 45 f4             	mov    -0xc(%ebp),%eax
 726:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 729:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72c:	8b 55 08             	mov    0x8(%ebp),%edx
 72f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 732:	8b 45 f0             	mov    -0x10(%ebp),%eax
 735:	83 c0 08             	add    $0x8,%eax
 738:	83 ec 0c             	sub    $0xc,%esp
 73b:	50                   	push   %eax
 73c:	e8 c8 fe ff ff       	call   609 <free>
 741:	83 c4 10             	add    $0x10,%esp
  return freep;
 744:	a1 ec 0a 00 00       	mov    0xaec,%eax
}
 749:	c9                   	leave  
 74a:	c3                   	ret    

0000074b <malloc>:

void*
malloc(uint nbytes)
{
 74b:	55                   	push   %ebp
 74c:	89 e5                	mov    %esp,%ebp
 74e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 751:	8b 45 08             	mov    0x8(%ebp),%eax
 754:	83 c0 07             	add    $0x7,%eax
 757:	c1 e8 03             	shr    $0x3,%eax
 75a:	83 c0 01             	add    $0x1,%eax
 75d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 760:	a1 ec 0a 00 00       	mov    0xaec,%eax
 765:	89 45 f0             	mov    %eax,-0x10(%ebp)
 768:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 76c:	75 23                	jne    791 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 76e:	c7 45 f0 e4 0a 00 00 	movl   $0xae4,-0x10(%ebp)
 775:	8b 45 f0             	mov    -0x10(%ebp),%eax
 778:	a3 ec 0a 00 00       	mov    %eax,0xaec
 77d:	a1 ec 0a 00 00       	mov    0xaec,%eax
 782:	a3 e4 0a 00 00       	mov    %eax,0xae4
    base.s.size = 0;
 787:	c7 05 e8 0a 00 00 00 	movl   $0x0,0xae8
 78e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 791:	8b 45 f0             	mov    -0x10(%ebp),%eax
 794:	8b 00                	mov    (%eax),%eax
 796:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 799:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79c:	8b 40 04             	mov    0x4(%eax),%eax
 79f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7a2:	77 4d                	ja     7f1 <malloc+0xa6>
      if(p->s.size == nunits)
 7a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a7:	8b 40 04             	mov    0x4(%eax),%eax
 7aa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7ad:	75 0c                	jne    7bb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b2:	8b 10                	mov    (%eax),%edx
 7b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b7:	89 10                	mov    %edx,(%eax)
 7b9:	eb 26                	jmp    7e1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7be:	8b 40 04             	mov    0x4(%eax),%eax
 7c1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7c4:	89 c2                	mov    %eax,%edx
 7c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	8b 40 04             	mov    0x4(%eax),%eax
 7d2:	c1 e0 03             	shl    $0x3,%eax
 7d5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7db:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7de:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e4:	a3 ec 0a 00 00       	mov    %eax,0xaec
      return (void*)(p + 1);
 7e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ec:	83 c0 08             	add    $0x8,%eax
 7ef:	eb 3b                	jmp    82c <malloc+0xe1>
    }
    if(p == freep)
 7f1:	a1 ec 0a 00 00       	mov    0xaec,%eax
 7f6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7f9:	75 1e                	jne    819 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7fb:	83 ec 0c             	sub    $0xc,%esp
 7fe:	ff 75 ec             	push   -0x14(%ebp)
 801:	e8 e5 fe ff ff       	call   6eb <morecore>
 806:	83 c4 10             	add    $0x10,%esp
 809:	89 45 f4             	mov    %eax,-0xc(%ebp)
 80c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 810:	75 07                	jne    819 <malloc+0xce>
        return 0;
 812:	b8 00 00 00 00       	mov    $0x0,%eax
 817:	eb 13                	jmp    82c <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 822:	8b 00                	mov    (%eax),%eax
 824:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 827:	e9 6d ff ff ff       	jmp    799 <malloc+0x4e>
  }
}
 82c:	c9                   	leave  
 82d:	c3                   	ret    
