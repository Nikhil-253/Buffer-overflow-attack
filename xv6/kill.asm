
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 10             	sub    $0x10,%esp
  12:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
  14:	83 3b 01             	cmpl   $0x1,(%ebx)
  17:	7f 17                	jg     30 <main+0x30>
    printf(2, "usage: kill pid...\n");
  19:	83 ec 08             	sub    $0x8,%esp
  1c:	68 1c 08 00 00       	push   $0x81c
  21:	6a 02                	push   $0x2
  23:	e8 3d 04 00 00       	call   465 <printf>
  28:	83 c4 10             	add    $0x10,%esp
    exit();
  2b:	e8 99 02 00 00       	call   2c9 <exit>
  }
  for(i=1; i<argc; i++)
  30:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  37:	eb 2d                	jmp    66 <main+0x66>
    kill(atoi(argv[i]));
  39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  43:	8b 43 04             	mov    0x4(%ebx),%eax
  46:	01 d0                	add    %edx,%eax
  48:	8b 00                	mov    (%eax),%eax
  4a:	83 ec 0c             	sub    $0xc,%esp
  4d:	50                   	push   %eax
  4e:	e8 e4 01 00 00       	call   237 <atoi>
  53:	83 c4 10             	add    $0x10,%esp
  56:	83 ec 0c             	sub    $0xc,%esp
  59:	50                   	push   %eax
  5a:	e8 9a 02 00 00       	call   2f9 <kill>
  5f:	83 c4 10             	add    $0x10,%esp
  for(i=1; i<argc; i++)
  62:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  69:	3b 03                	cmp    (%ebx),%eax
  6b:	7c cc                	jl     39 <main+0x39>
  exit();
  6d:	e8 57 02 00 00       	call   2c9 <exit>

00000072 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  72:	55                   	push   %ebp
  73:	89 e5                	mov    %esp,%ebp
  75:	57                   	push   %edi
  76:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  7a:	8b 55 10             	mov    0x10(%ebp),%edx
  7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  80:	89 cb                	mov    %ecx,%ebx
  82:	89 df                	mov    %ebx,%edi
  84:	89 d1                	mov    %edx,%ecx
  86:	fc                   	cld    
  87:	f3 aa                	rep stos %al,%es:(%edi)
  89:	89 ca                	mov    %ecx,%edx
  8b:	89 fb                	mov    %edi,%ebx
  8d:	89 5d 08             	mov    %ebx,0x8(%ebp)
  90:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  93:	90                   	nop
  94:	5b                   	pop    %ebx
  95:	5f                   	pop    %edi
  96:	5d                   	pop    %ebp
  97:	c3                   	ret    

00000098 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  98:	55                   	push   %ebp
  99:	89 e5                	mov    %esp,%ebp
  9b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  9e:	8b 45 08             	mov    0x8(%ebp),%eax
  a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  a4:	90                   	nop
  a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  a8:	8d 42 01             	lea    0x1(%edx),%eax
  ab:	89 45 0c             	mov    %eax,0xc(%ebp)
  ae:	8b 45 08             	mov    0x8(%ebp),%eax
  b1:	8d 48 01             	lea    0x1(%eax),%ecx
  b4:	89 4d 08             	mov    %ecx,0x8(%ebp)
  b7:	0f b6 12             	movzbl (%edx),%edx
  ba:	88 10                	mov    %dl,(%eax)
  bc:	0f b6 00             	movzbl (%eax),%eax
  bf:	84 c0                	test   %al,%al
  c1:	75 e2                	jne    a5 <strcpy+0xd>
    ;
  return os;
  c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c6:	c9                   	leave  
  c7:	c3                   	ret    

000000c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c8:	55                   	push   %ebp
  c9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  cb:	eb 08                	jmp    d5 <strcmp+0xd>
    p++, q++;
  cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  d5:	8b 45 08             	mov    0x8(%ebp),%eax
  d8:	0f b6 00             	movzbl (%eax),%eax
  db:	84 c0                	test   %al,%al
  dd:	74 10                	je     ef <strcmp+0x27>
  df:	8b 45 08             	mov    0x8(%ebp),%eax
  e2:	0f b6 10             	movzbl (%eax),%edx
  e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  e8:	0f b6 00             	movzbl (%eax),%eax
  eb:	38 c2                	cmp    %al,%dl
  ed:	74 de                	je     cd <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  ef:	8b 45 08             	mov    0x8(%ebp),%eax
  f2:	0f b6 00             	movzbl (%eax),%eax
  f5:	0f b6 d0             	movzbl %al,%edx
  f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  fb:	0f b6 00             	movzbl (%eax),%eax
  fe:	0f b6 c8             	movzbl %al,%ecx
 101:	89 d0                	mov    %edx,%eax
 103:	29 c8                	sub    %ecx,%eax
}
 105:	5d                   	pop    %ebp
 106:	c3                   	ret    

00000107 <strlen>:

uint
strlen(const char *s)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 10d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 114:	eb 04                	jmp    11a <strlen+0x13>
 116:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 11a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	01 d0                	add    %edx,%eax
 122:	0f b6 00             	movzbl (%eax),%eax
 125:	84 c0                	test   %al,%al
 127:	75 ed                	jne    116 <strlen+0xf>
    ;
  return n;
 129:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12c:	c9                   	leave  
 12d:	c3                   	ret    

0000012e <memset>:

void*
memset(void *dst, int c, uint n)
{
 12e:	55                   	push   %ebp
 12f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 131:	8b 45 10             	mov    0x10(%ebp),%eax
 134:	50                   	push   %eax
 135:	ff 75 0c             	push   0xc(%ebp)
 138:	ff 75 08             	push   0x8(%ebp)
 13b:	e8 32 ff ff ff       	call   72 <stosb>
 140:	83 c4 0c             	add    $0xc,%esp
  return dst;
 143:	8b 45 08             	mov    0x8(%ebp),%eax
}
 146:	c9                   	leave  
 147:	c3                   	ret    

00000148 <strchr>:

char*
strchr(const char *s, char c)
{
 148:	55                   	push   %ebp
 149:	89 e5                	mov    %esp,%ebp
 14b:	83 ec 04             	sub    $0x4,%esp
 14e:	8b 45 0c             	mov    0xc(%ebp),%eax
 151:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 154:	eb 14                	jmp    16a <strchr+0x22>
    if(*s == c)
 156:	8b 45 08             	mov    0x8(%ebp),%eax
 159:	0f b6 00             	movzbl (%eax),%eax
 15c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 15f:	75 05                	jne    166 <strchr+0x1e>
      return (char*)s;
 161:	8b 45 08             	mov    0x8(%ebp),%eax
 164:	eb 13                	jmp    179 <strchr+0x31>
  for(; *s; s++)
 166:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
 16d:	0f b6 00             	movzbl (%eax),%eax
 170:	84 c0                	test   %al,%al
 172:	75 e2                	jne    156 <strchr+0xe>
  return 0;
 174:	b8 00 00 00 00       	mov    $0x0,%eax
}
 179:	c9                   	leave  
 17a:	c3                   	ret    

0000017b <gets>:

char*
gets(char *buf, int max)
{
 17b:	55                   	push   %ebp
 17c:	89 e5                	mov    %esp,%ebp
 17e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 181:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 188:	eb 42                	jmp    1cc <gets+0x51>
    cc = read(0, &c, 1);
 18a:	83 ec 04             	sub    $0x4,%esp
 18d:	6a 01                	push   $0x1
 18f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 192:	50                   	push   %eax
 193:	6a 00                	push   $0x0
 195:	e8 47 01 00 00       	call   2e1 <read>
 19a:	83 c4 10             	add    $0x10,%esp
 19d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1a4:	7e 33                	jle    1d9 <gets+0x5e>
      break;
    buf[i++] = c;
 1a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a9:	8d 50 01             	lea    0x1(%eax),%edx
 1ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1af:	89 c2                	mov    %eax,%edx
 1b1:	8b 45 08             	mov    0x8(%ebp),%eax
 1b4:	01 c2                	add    %eax,%edx
 1b6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ba:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1bc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c0:	3c 0a                	cmp    $0xa,%al
 1c2:	74 16                	je     1da <gets+0x5f>
 1c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c8:	3c 0d                	cmp    $0xd,%al
 1ca:	74 0e                	je     1da <gets+0x5f>
  for(i=0; i+1 < max; ){
 1cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cf:	83 c0 01             	add    $0x1,%eax
 1d2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1d5:	7f b3                	jg     18a <gets+0xf>
 1d7:	eb 01                	jmp    1da <gets+0x5f>
      break;
 1d9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1da:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1dd:	8b 45 08             	mov    0x8(%ebp),%eax
 1e0:	01 d0                	add    %edx,%eax
 1e2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e8:	c9                   	leave  
 1e9:	c3                   	ret    

000001ea <stat>:

int
stat(const char *n, struct stat *st)
{
 1ea:	55                   	push   %ebp
 1eb:	89 e5                	mov    %esp,%ebp
 1ed:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f0:	83 ec 08             	sub    $0x8,%esp
 1f3:	6a 00                	push   $0x0
 1f5:	ff 75 08             	push   0x8(%ebp)
 1f8:	e8 0c 01 00 00       	call   309 <open>
 1fd:	83 c4 10             	add    $0x10,%esp
 200:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 203:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 207:	79 07                	jns    210 <stat+0x26>
    return -1;
 209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 20e:	eb 25                	jmp    235 <stat+0x4b>
  r = fstat(fd, st);
 210:	83 ec 08             	sub    $0x8,%esp
 213:	ff 75 0c             	push   0xc(%ebp)
 216:	ff 75 f4             	push   -0xc(%ebp)
 219:	e8 03 01 00 00       	call   321 <fstat>
 21e:	83 c4 10             	add    $0x10,%esp
 221:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 224:	83 ec 0c             	sub    $0xc,%esp
 227:	ff 75 f4             	push   -0xc(%ebp)
 22a:	e8 c2 00 00 00       	call   2f1 <close>
 22f:	83 c4 10             	add    $0x10,%esp
  return r;
 232:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 235:	c9                   	leave  
 236:	c3                   	ret    

00000237 <atoi>:

int
atoi(const char *s)
{
 237:	55                   	push   %ebp
 238:	89 e5                	mov    %esp,%ebp
 23a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 23d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 244:	eb 25                	jmp    26b <atoi+0x34>
    n = n*10 + *s++ - '0';
 246:	8b 55 fc             	mov    -0x4(%ebp),%edx
 249:	89 d0                	mov    %edx,%eax
 24b:	c1 e0 02             	shl    $0x2,%eax
 24e:	01 d0                	add    %edx,%eax
 250:	01 c0                	add    %eax,%eax
 252:	89 c1                	mov    %eax,%ecx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	8d 50 01             	lea    0x1(%eax),%edx
 25a:	89 55 08             	mov    %edx,0x8(%ebp)
 25d:	0f b6 00             	movzbl (%eax),%eax
 260:	0f be c0             	movsbl %al,%eax
 263:	01 c8                	add    %ecx,%eax
 265:	83 e8 30             	sub    $0x30,%eax
 268:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
 26e:	0f b6 00             	movzbl (%eax),%eax
 271:	3c 2f                	cmp    $0x2f,%al
 273:	7e 0a                	jle    27f <atoi+0x48>
 275:	8b 45 08             	mov    0x8(%ebp),%eax
 278:	0f b6 00             	movzbl (%eax),%eax
 27b:	3c 39                	cmp    $0x39,%al
 27d:	7e c7                	jle    246 <atoi+0xf>
  return n;
 27f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 282:	c9                   	leave  
 283:	c3                   	ret    

00000284 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 284:	55                   	push   %ebp
 285:	89 e5                	mov    %esp,%ebp
 287:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 290:	8b 45 0c             	mov    0xc(%ebp),%eax
 293:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 296:	eb 17                	jmp    2af <memmove+0x2b>
    *dst++ = *src++;
 298:	8b 55 f8             	mov    -0x8(%ebp),%edx
 29b:	8d 42 01             	lea    0x1(%edx),%eax
 29e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a4:	8d 48 01             	lea    0x1(%eax),%ecx
 2a7:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2aa:	0f b6 12             	movzbl (%edx),%edx
 2ad:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2af:	8b 45 10             	mov    0x10(%ebp),%eax
 2b2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2b5:	89 55 10             	mov    %edx,0x10(%ebp)
 2b8:	85 c0                	test   %eax,%eax
 2ba:	7f dc                	jg     298 <memmove+0x14>
  return vdst;
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bf:	c9                   	leave  
 2c0:	c3                   	ret    

000002c1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c1:	b8 01 00 00 00       	mov    $0x1,%eax
 2c6:	cd 40                	int    $0x40
 2c8:	c3                   	ret    

000002c9 <exit>:
SYSCALL(exit)
 2c9:	b8 02 00 00 00       	mov    $0x2,%eax
 2ce:	cd 40                	int    $0x40
 2d0:	c3                   	ret    

000002d1 <wait>:
SYSCALL(wait)
 2d1:	b8 03 00 00 00       	mov    $0x3,%eax
 2d6:	cd 40                	int    $0x40
 2d8:	c3                   	ret    

000002d9 <pipe>:
SYSCALL(pipe)
 2d9:	b8 04 00 00 00       	mov    $0x4,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret    

000002e1 <read>:
SYSCALL(read)
 2e1:	b8 05 00 00 00       	mov    $0x5,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <write>:
SYSCALL(write)
 2e9:	b8 10 00 00 00       	mov    $0x10,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <close>:
SYSCALL(close)
 2f1:	b8 15 00 00 00       	mov    $0x15,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <kill>:
SYSCALL(kill)
 2f9:	b8 06 00 00 00       	mov    $0x6,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <exec>:
SYSCALL(exec)
 301:	b8 07 00 00 00       	mov    $0x7,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <open>:
SYSCALL(open)
 309:	b8 0f 00 00 00       	mov    $0xf,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <mknod>:
SYSCALL(mknod)
 311:	b8 11 00 00 00       	mov    $0x11,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <unlink>:
SYSCALL(unlink)
 319:	b8 12 00 00 00       	mov    $0x12,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <fstat>:
SYSCALL(fstat)
 321:	b8 08 00 00 00       	mov    $0x8,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <link>:
SYSCALL(link)
 329:	b8 13 00 00 00       	mov    $0x13,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <mkdir>:
SYSCALL(mkdir)
 331:	b8 14 00 00 00       	mov    $0x14,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <chdir>:
SYSCALL(chdir)
 339:	b8 09 00 00 00       	mov    $0x9,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <dup>:
SYSCALL(dup)
 341:	b8 0a 00 00 00       	mov    $0xa,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <getpid>:
SYSCALL(getpid)
 349:	b8 0b 00 00 00       	mov    $0xb,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <sbrk>:
SYSCALL(sbrk)
 351:	b8 0c 00 00 00       	mov    $0xc,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <sleep>:
SYSCALL(sleep)
 359:	b8 0d 00 00 00       	mov    $0xd,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <uptime>:
SYSCALL(uptime)
 361:	b8 0e 00 00 00       	mov    $0xe,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <ps>:
SYSCALL(ps)
 369:	b8 16 00 00 00       	mov    $0x16,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret    

00000371 <exec_time>:
SYSCALL(exec_time)
 371:	b8 17 00 00 00       	mov    $0x17,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret    

00000379 <deadline>:
SYSCALL(deadline)
 379:	b8 18 00 00 00       	mov    $0x18,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <sched_policy>:
SYSCALL(sched_policy)
 381:	b8 19 00 00 00       	mov    $0x19,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <rate>:
SYSCALL(rate)
 389:	b8 1a 00 00 00       	mov    $0x1a,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 391:	55                   	push   %ebp
 392:	89 e5                	mov    %esp,%ebp
 394:	83 ec 18             	sub    $0x18,%esp
 397:	8b 45 0c             	mov    0xc(%ebp),%eax
 39a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 39d:	83 ec 04             	sub    $0x4,%esp
 3a0:	6a 01                	push   $0x1
 3a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3a5:	50                   	push   %eax
 3a6:	ff 75 08             	push   0x8(%ebp)
 3a9:	e8 3b ff ff ff       	call   2e9 <write>
 3ae:	83 c4 10             	add    $0x10,%esp
}
 3b1:	90                   	nop
 3b2:	c9                   	leave  
 3b3:	c3                   	ret    

000003b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b4:	55                   	push   %ebp
 3b5:	89 e5                	mov    %esp,%ebp
 3b7:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3c1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3c5:	74 17                	je     3de <printint+0x2a>
 3c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3cb:	79 11                	jns    3de <printint+0x2a>
    neg = 1;
 3cd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d7:	f7 d8                	neg    %eax
 3d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3dc:	eb 06                	jmp    3e4 <printint+0x30>
  } else {
    x = xx;
 3de:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f1:	ba 00 00 00 00       	mov    $0x0,%edx
 3f6:	f7 f1                	div    %ecx
 3f8:	89 d1                	mov    %edx,%ecx
 3fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fd:	8d 50 01             	lea    0x1(%eax),%edx
 400:	89 55 f4             	mov    %edx,-0xc(%ebp)
 403:	0f b6 91 80 0a 00 00 	movzbl 0xa80(%ecx),%edx
 40a:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 40e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 411:	8b 45 ec             	mov    -0x14(%ebp),%eax
 414:	ba 00 00 00 00       	mov    $0x0,%edx
 419:	f7 f1                	div    %ecx
 41b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 41e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 422:	75 c7                	jne    3eb <printint+0x37>
  if(neg)
 424:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 428:	74 2d                	je     457 <printint+0xa3>
    buf[i++] = '-';
 42a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42d:	8d 50 01             	lea    0x1(%eax),%edx
 430:	89 55 f4             	mov    %edx,-0xc(%ebp)
 433:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 438:	eb 1d                	jmp    457 <printint+0xa3>
    putc(fd, buf[i]);
 43a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 43d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 440:	01 d0                	add    %edx,%eax
 442:	0f b6 00             	movzbl (%eax),%eax
 445:	0f be c0             	movsbl %al,%eax
 448:	83 ec 08             	sub    $0x8,%esp
 44b:	50                   	push   %eax
 44c:	ff 75 08             	push   0x8(%ebp)
 44f:	e8 3d ff ff ff       	call   391 <putc>
 454:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 457:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 45b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 45f:	79 d9                	jns    43a <printint+0x86>
}
 461:	90                   	nop
 462:	90                   	nop
 463:	c9                   	leave  
 464:	c3                   	ret    

00000465 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 465:	55                   	push   %ebp
 466:	89 e5                	mov    %esp,%ebp
 468:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 46b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 472:	8d 45 0c             	lea    0xc(%ebp),%eax
 475:	83 c0 04             	add    $0x4,%eax
 478:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 47b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 482:	e9 59 01 00 00       	jmp    5e0 <printf+0x17b>
    c = fmt[i] & 0xff;
 487:	8b 55 0c             	mov    0xc(%ebp),%edx
 48a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 48d:	01 d0                	add    %edx,%eax
 48f:	0f b6 00             	movzbl (%eax),%eax
 492:	0f be c0             	movsbl %al,%eax
 495:	25 ff 00 00 00       	and    $0xff,%eax
 49a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 49d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a1:	75 2c                	jne    4cf <printf+0x6a>
      if(c == '%'){
 4a3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4a7:	75 0c                	jne    4b5 <printf+0x50>
        state = '%';
 4a9:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4b0:	e9 27 01 00 00       	jmp    5dc <printf+0x177>
      } else {
        putc(fd, c);
 4b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4b8:	0f be c0             	movsbl %al,%eax
 4bb:	83 ec 08             	sub    $0x8,%esp
 4be:	50                   	push   %eax
 4bf:	ff 75 08             	push   0x8(%ebp)
 4c2:	e8 ca fe ff ff       	call   391 <putc>
 4c7:	83 c4 10             	add    $0x10,%esp
 4ca:	e9 0d 01 00 00       	jmp    5dc <printf+0x177>
      }
    } else if(state == '%'){
 4cf:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4d3:	0f 85 03 01 00 00    	jne    5dc <printf+0x177>
      if(c == 'd'){
 4d9:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4dd:	75 1e                	jne    4fd <printf+0x98>
        printint(fd, *ap, 10, 1);
 4df:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e2:	8b 00                	mov    (%eax),%eax
 4e4:	6a 01                	push   $0x1
 4e6:	6a 0a                	push   $0xa
 4e8:	50                   	push   %eax
 4e9:	ff 75 08             	push   0x8(%ebp)
 4ec:	e8 c3 fe ff ff       	call   3b4 <printint>
 4f1:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f8:	e9 d8 00 00 00       	jmp    5d5 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4fd:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 501:	74 06                	je     509 <printf+0xa4>
 503:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 507:	75 1e                	jne    527 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 509:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50c:	8b 00                	mov    (%eax),%eax
 50e:	6a 00                	push   $0x0
 510:	6a 10                	push   $0x10
 512:	50                   	push   %eax
 513:	ff 75 08             	push   0x8(%ebp)
 516:	e8 99 fe ff ff       	call   3b4 <printint>
 51b:	83 c4 10             	add    $0x10,%esp
        ap++;
 51e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 522:	e9 ae 00 00 00       	jmp    5d5 <printf+0x170>
      } else if(c == 's'){
 527:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 52b:	75 43                	jne    570 <printf+0x10b>
        s = (char*)*ap;
 52d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 530:	8b 00                	mov    (%eax),%eax
 532:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 535:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 539:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53d:	75 25                	jne    564 <printf+0xff>
          s = "(null)";
 53f:	c7 45 f4 30 08 00 00 	movl   $0x830,-0xc(%ebp)
        while(*s != 0){
 546:	eb 1c                	jmp    564 <printf+0xff>
          putc(fd, *s);
 548:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54b:	0f b6 00             	movzbl (%eax),%eax
 54e:	0f be c0             	movsbl %al,%eax
 551:	83 ec 08             	sub    $0x8,%esp
 554:	50                   	push   %eax
 555:	ff 75 08             	push   0x8(%ebp)
 558:	e8 34 fe ff ff       	call   391 <putc>
 55d:	83 c4 10             	add    $0x10,%esp
          s++;
 560:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 564:	8b 45 f4             	mov    -0xc(%ebp),%eax
 567:	0f b6 00             	movzbl (%eax),%eax
 56a:	84 c0                	test   %al,%al
 56c:	75 da                	jne    548 <printf+0xe3>
 56e:	eb 65                	jmp    5d5 <printf+0x170>
        }
      } else if(c == 'c'){
 570:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 574:	75 1d                	jne    593 <printf+0x12e>
        putc(fd, *ap);
 576:	8b 45 e8             	mov    -0x18(%ebp),%eax
 579:	8b 00                	mov    (%eax),%eax
 57b:	0f be c0             	movsbl %al,%eax
 57e:	83 ec 08             	sub    $0x8,%esp
 581:	50                   	push   %eax
 582:	ff 75 08             	push   0x8(%ebp)
 585:	e8 07 fe ff ff       	call   391 <putc>
 58a:	83 c4 10             	add    $0x10,%esp
        ap++;
 58d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 591:	eb 42                	jmp    5d5 <printf+0x170>
      } else if(c == '%'){
 593:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 597:	75 17                	jne    5b0 <printf+0x14b>
        putc(fd, c);
 599:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59c:	0f be c0             	movsbl %al,%eax
 59f:	83 ec 08             	sub    $0x8,%esp
 5a2:	50                   	push   %eax
 5a3:	ff 75 08             	push   0x8(%ebp)
 5a6:	e8 e6 fd ff ff       	call   391 <putc>
 5ab:	83 c4 10             	add    $0x10,%esp
 5ae:	eb 25                	jmp    5d5 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5b0:	83 ec 08             	sub    $0x8,%esp
 5b3:	6a 25                	push   $0x25
 5b5:	ff 75 08             	push   0x8(%ebp)
 5b8:	e8 d4 fd ff ff       	call   391 <putc>
 5bd:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c3:	0f be c0             	movsbl %al,%eax
 5c6:	83 ec 08             	sub    $0x8,%esp
 5c9:	50                   	push   %eax
 5ca:	ff 75 08             	push   0x8(%ebp)
 5cd:	e8 bf fd ff ff       	call   391 <putc>
 5d2:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5d5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5dc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5e0:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e6:	01 d0                	add    %edx,%eax
 5e8:	0f b6 00             	movzbl (%eax),%eax
 5eb:	84 c0                	test   %al,%al
 5ed:	0f 85 94 fe ff ff    	jne    487 <printf+0x22>
    }
  }
}
 5f3:	90                   	nop
 5f4:	90                   	nop
 5f5:	c9                   	leave  
 5f6:	c3                   	ret    

000005f7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5f7:	55                   	push   %ebp
 5f8:	89 e5                	mov    %esp,%ebp
 5fa:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5fd:	8b 45 08             	mov    0x8(%ebp),%eax
 600:	83 e8 08             	sub    $0x8,%eax
 603:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 606:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 60b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 60e:	eb 24                	jmp    634 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 610:	8b 45 fc             	mov    -0x4(%ebp),%eax
 613:	8b 00                	mov    (%eax),%eax
 615:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 618:	72 12                	jb     62c <free+0x35>
 61a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 620:	77 24                	ja     646 <free+0x4f>
 622:	8b 45 fc             	mov    -0x4(%ebp),%eax
 625:	8b 00                	mov    (%eax),%eax
 627:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 62a:	72 1a                	jb     646 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 62c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62f:	8b 00                	mov    (%eax),%eax
 631:	89 45 fc             	mov    %eax,-0x4(%ebp)
 634:	8b 45 f8             	mov    -0x8(%ebp),%eax
 637:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 63a:	76 d4                	jbe    610 <free+0x19>
 63c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63f:	8b 00                	mov    (%eax),%eax
 641:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 644:	73 ca                	jae    610 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 646:	8b 45 f8             	mov    -0x8(%ebp),%eax
 649:	8b 40 04             	mov    0x4(%eax),%eax
 64c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 653:	8b 45 f8             	mov    -0x8(%ebp),%eax
 656:	01 c2                	add    %eax,%edx
 658:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65b:	8b 00                	mov    (%eax),%eax
 65d:	39 c2                	cmp    %eax,%edx
 65f:	75 24                	jne    685 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 661:	8b 45 f8             	mov    -0x8(%ebp),%eax
 664:	8b 50 04             	mov    0x4(%eax),%edx
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	8b 00                	mov    (%eax),%eax
 66c:	8b 40 04             	mov    0x4(%eax),%eax
 66f:	01 c2                	add    %eax,%edx
 671:	8b 45 f8             	mov    -0x8(%ebp),%eax
 674:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 677:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67a:	8b 00                	mov    (%eax),%eax
 67c:	8b 10                	mov    (%eax),%edx
 67e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 681:	89 10                	mov    %edx,(%eax)
 683:	eb 0a                	jmp    68f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 685:	8b 45 fc             	mov    -0x4(%ebp),%eax
 688:	8b 10                	mov    (%eax),%edx
 68a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 68f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 692:	8b 40 04             	mov    0x4(%eax),%eax
 695:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 69c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69f:	01 d0                	add    %edx,%eax
 6a1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6a4:	75 20                	jne    6c6 <free+0xcf>
    p->s.size += bp->s.size;
 6a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a9:	8b 50 04             	mov    0x4(%eax),%edx
 6ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6af:	8b 40 04             	mov    0x4(%eax),%eax
 6b2:	01 c2                	add    %eax,%edx
 6b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bd:	8b 10                	mov    (%eax),%edx
 6bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c2:	89 10                	mov    %edx,(%eax)
 6c4:	eb 08                	jmp    6ce <free+0xd7>
  } else
    p->s.ptr = bp;
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6cc:	89 10                	mov    %edx,(%eax)
  freep = p;
 6ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d1:	a3 9c 0a 00 00       	mov    %eax,0xa9c
}
 6d6:	90                   	nop
 6d7:	c9                   	leave  
 6d8:	c3                   	ret    

000006d9 <morecore>:

static Header*
morecore(uint nu)
{
 6d9:	55                   	push   %ebp
 6da:	89 e5                	mov    %esp,%ebp
 6dc:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6df:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6e6:	77 07                	ja     6ef <morecore+0x16>
    nu = 4096;
 6e8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6ef:	8b 45 08             	mov    0x8(%ebp),%eax
 6f2:	c1 e0 03             	shl    $0x3,%eax
 6f5:	83 ec 0c             	sub    $0xc,%esp
 6f8:	50                   	push   %eax
 6f9:	e8 53 fc ff ff       	call   351 <sbrk>
 6fe:	83 c4 10             	add    $0x10,%esp
 701:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 704:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 708:	75 07                	jne    711 <morecore+0x38>
    return 0;
 70a:	b8 00 00 00 00       	mov    $0x0,%eax
 70f:	eb 26                	jmp    737 <morecore+0x5e>
  hp = (Header*)p;
 711:	8b 45 f4             	mov    -0xc(%ebp),%eax
 714:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 717:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71a:	8b 55 08             	mov    0x8(%ebp),%edx
 71d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 720:	8b 45 f0             	mov    -0x10(%ebp),%eax
 723:	83 c0 08             	add    $0x8,%eax
 726:	83 ec 0c             	sub    $0xc,%esp
 729:	50                   	push   %eax
 72a:	e8 c8 fe ff ff       	call   5f7 <free>
 72f:	83 c4 10             	add    $0x10,%esp
  return freep;
 732:	a1 9c 0a 00 00       	mov    0xa9c,%eax
}
 737:	c9                   	leave  
 738:	c3                   	ret    

00000739 <malloc>:

void*
malloc(uint nbytes)
{
 739:	55                   	push   %ebp
 73a:	89 e5                	mov    %esp,%ebp
 73c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	83 c0 07             	add    $0x7,%eax
 745:	c1 e8 03             	shr    $0x3,%eax
 748:	83 c0 01             	add    $0x1,%eax
 74b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 74e:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 753:	89 45 f0             	mov    %eax,-0x10(%ebp)
 756:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 75a:	75 23                	jne    77f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 75c:	c7 45 f0 94 0a 00 00 	movl   $0xa94,-0x10(%ebp)
 763:	8b 45 f0             	mov    -0x10(%ebp),%eax
 766:	a3 9c 0a 00 00       	mov    %eax,0xa9c
 76b:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 770:	a3 94 0a 00 00       	mov    %eax,0xa94
    base.s.size = 0;
 775:	c7 05 98 0a 00 00 00 	movl   $0x0,0xa98
 77c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 782:	8b 00                	mov    (%eax),%eax
 784:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 787:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78a:	8b 40 04             	mov    0x4(%eax),%eax
 78d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 790:	77 4d                	ja     7df <malloc+0xa6>
      if(p->s.size == nunits)
 792:	8b 45 f4             	mov    -0xc(%ebp),%eax
 795:	8b 40 04             	mov    0x4(%eax),%eax
 798:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 79b:	75 0c                	jne    7a9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 79d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a0:	8b 10                	mov    (%eax),%edx
 7a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a5:	89 10                	mov    %edx,(%eax)
 7a7:	eb 26                	jmp    7cf <malloc+0x96>
      else {
        p->s.size -= nunits;
 7a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ac:	8b 40 04             	mov    0x4(%eax),%eax
 7af:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7b2:	89 c2                	mov    %eax,%edx
 7b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bd:	8b 40 04             	mov    0x4(%eax),%eax
 7c0:	c1 e0 03             	shl    $0x3,%eax
 7c3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7cc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d2:	a3 9c 0a 00 00       	mov    %eax,0xa9c
      return (void*)(p + 1);
 7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7da:	83 c0 08             	add    $0x8,%eax
 7dd:	eb 3b                	jmp    81a <malloc+0xe1>
    }
    if(p == freep)
 7df:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 7e4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7e7:	75 1e                	jne    807 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7e9:	83 ec 0c             	sub    $0xc,%esp
 7ec:	ff 75 ec             	push   -0x14(%ebp)
 7ef:	e8 e5 fe ff ff       	call   6d9 <morecore>
 7f4:	83 c4 10             	add    $0x10,%esp
 7f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7fe:	75 07                	jne    807 <malloc+0xce>
        return 0;
 800:	b8 00 00 00 00       	mov    $0x0,%eax
 805:	eb 13                	jmp    81a <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 807:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 815:	e9 6d ff ff ff       	jmp    787 <malloc+0x4e>
  }
}
 81a:	c9                   	leave  
 81b:	c3                   	ret    
