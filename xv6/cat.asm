
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
   6:	eb 31                	jmp    39 <cat+0x39>
    if (write(1, buf, n) != n) {
   8:	83 ec 04             	sub    $0x4,%esp
   b:	ff 75 f4             	push   -0xc(%ebp)
   e:	68 a0 0b 00 00       	push   $0xba0
  13:	6a 01                	push   $0x1
  15:	e8 88 03 00 00       	call   3a2 <write>
  1a:	83 c4 10             	add    $0x10,%esp
  1d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  20:	74 17                	je     39 <cat+0x39>
      printf(1, "cat: write error\n");
  22:	83 ec 08             	sub    $0x8,%esp
  25:	68 d5 08 00 00       	push   $0x8d5
  2a:	6a 01                	push   $0x1
  2c:	e8 ed 04 00 00       	call   51e <printf>
  31:	83 c4 10             	add    $0x10,%esp
      exit();
  34:	e8 49 03 00 00       	call   382 <exit>
  while((n = read(fd, buf, sizeof(buf))) > 0) {
  39:	83 ec 04             	sub    $0x4,%esp
  3c:	68 00 02 00 00       	push   $0x200
  41:	68 a0 0b 00 00       	push   $0xba0
  46:	ff 75 08             	push   0x8(%ebp)
  49:	e8 4c 03 00 00       	call   39a <read>
  4e:	83 c4 10             	add    $0x10,%esp
  51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  58:	7f ae                	jg     8 <cat+0x8>
    }
  }
  if(n < 0){
  5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  5e:	79 17                	jns    77 <cat+0x77>
    printf(1, "cat: read error\n");
  60:	83 ec 08             	sub    $0x8,%esp
  63:	68 e7 08 00 00       	push   $0x8e7
  68:	6a 01                	push   $0x1
  6a:	e8 af 04 00 00       	call   51e <printf>
  6f:	83 c4 10             	add    $0x10,%esp
    exit();
  72:	e8 0b 03 00 00       	call   382 <exit>
  }
}
  77:	90                   	nop
  78:	c9                   	leave  
  79:	c3                   	ret    

0000007a <main>:

int
main(int argc, char *argv[])
{
  7a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  7e:	83 e4 f0             	and    $0xfffffff0,%esp
  81:	ff 71 fc             	push   -0x4(%ecx)
  84:	55                   	push   %ebp
  85:	89 e5                	mov    %esp,%ebp
  87:	53                   	push   %ebx
  88:	51                   	push   %ecx
  89:	83 ec 10             	sub    $0x10,%esp
  8c:	89 cb                	mov    %ecx,%ebx
  int fd, i;

  if(argc <= 1){
  8e:	83 3b 01             	cmpl   $0x1,(%ebx)
  91:	7f 12                	jg     a5 <main+0x2b>
    cat(0);
  93:	83 ec 0c             	sub    $0xc,%esp
  96:	6a 00                	push   $0x0
  98:	e8 63 ff ff ff       	call   0 <cat>
  9d:	83 c4 10             	add    $0x10,%esp
    exit();
  a0:	e8 dd 02 00 00       	call   382 <exit>
  }

  for(i = 1; i < argc; i++){
  a5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  ac:	eb 71                	jmp    11f <main+0xa5>
    if((fd = open(argv[i], 0)) < 0){
  ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  b8:	8b 43 04             	mov    0x4(%ebx),%eax
  bb:	01 d0                	add    %edx,%eax
  bd:	8b 00                	mov    (%eax),%eax
  bf:	83 ec 08             	sub    $0x8,%esp
  c2:	6a 00                	push   $0x0
  c4:	50                   	push   %eax
  c5:	e8 f8 02 00 00       	call   3c2 <open>
  ca:	83 c4 10             	add    $0x10,%esp
  cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  d4:	79 29                	jns    ff <main+0x85>
      printf(1, "cat: cannot open %s\n", argv[i]);
  d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  e0:	8b 43 04             	mov    0x4(%ebx),%eax
  e3:	01 d0                	add    %edx,%eax
  e5:	8b 00                	mov    (%eax),%eax
  e7:	83 ec 04             	sub    $0x4,%esp
  ea:	50                   	push   %eax
  eb:	68 f8 08 00 00       	push   $0x8f8
  f0:	6a 01                	push   $0x1
  f2:	e8 27 04 00 00       	call   51e <printf>
  f7:	83 c4 10             	add    $0x10,%esp
      exit();
  fa:	e8 83 02 00 00       	call   382 <exit>
    }
    cat(fd);
  ff:	83 ec 0c             	sub    $0xc,%esp
 102:	ff 75 f0             	push   -0x10(%ebp)
 105:	e8 f6 fe ff ff       	call   0 <cat>
 10a:	83 c4 10             	add    $0x10,%esp
    close(fd);
 10d:	83 ec 0c             	sub    $0xc,%esp
 110:	ff 75 f0             	push   -0x10(%ebp)
 113:	e8 92 02 00 00       	call   3aa <close>
 118:	83 c4 10             	add    $0x10,%esp
  for(i = 1; i < argc; i++){
 11b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 11f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 122:	3b 03                	cmp    (%ebx),%eax
 124:	7c 88                	jl     ae <main+0x34>
  }
  exit();
 126:	e8 57 02 00 00       	call   382 <exit>

0000012b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 12b:	55                   	push   %ebp
 12c:	89 e5                	mov    %esp,%ebp
 12e:	57                   	push   %edi
 12f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 130:	8b 4d 08             	mov    0x8(%ebp),%ecx
 133:	8b 55 10             	mov    0x10(%ebp),%edx
 136:	8b 45 0c             	mov    0xc(%ebp),%eax
 139:	89 cb                	mov    %ecx,%ebx
 13b:	89 df                	mov    %ebx,%edi
 13d:	89 d1                	mov    %edx,%ecx
 13f:	fc                   	cld    
 140:	f3 aa                	rep stos %al,%es:(%edi)
 142:	89 ca                	mov    %ecx,%edx
 144:	89 fb                	mov    %edi,%ebx
 146:	89 5d 08             	mov    %ebx,0x8(%ebp)
 149:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 14c:	90                   	nop
 14d:	5b                   	pop    %ebx
 14e:	5f                   	pop    %edi
 14f:	5d                   	pop    %ebp
 150:	c3                   	ret    

00000151 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
 154:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 157:	8b 45 08             	mov    0x8(%ebp),%eax
 15a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 15d:	90                   	nop
 15e:	8b 55 0c             	mov    0xc(%ebp),%edx
 161:	8d 42 01             	lea    0x1(%edx),%eax
 164:	89 45 0c             	mov    %eax,0xc(%ebp)
 167:	8b 45 08             	mov    0x8(%ebp),%eax
 16a:	8d 48 01             	lea    0x1(%eax),%ecx
 16d:	89 4d 08             	mov    %ecx,0x8(%ebp)
 170:	0f b6 12             	movzbl (%edx),%edx
 173:	88 10                	mov    %dl,(%eax)
 175:	0f b6 00             	movzbl (%eax),%eax
 178:	84 c0                	test   %al,%al
 17a:	75 e2                	jne    15e <strcpy+0xd>
    ;
  return os;
 17c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 17f:	c9                   	leave  
 180:	c3                   	ret    

00000181 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 181:	55                   	push   %ebp
 182:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 184:	eb 08                	jmp    18e <strcmp+0xd>
    p++, q++;
 186:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 18a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 18e:	8b 45 08             	mov    0x8(%ebp),%eax
 191:	0f b6 00             	movzbl (%eax),%eax
 194:	84 c0                	test   %al,%al
 196:	74 10                	je     1a8 <strcmp+0x27>
 198:	8b 45 08             	mov    0x8(%ebp),%eax
 19b:	0f b6 10             	movzbl (%eax),%edx
 19e:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a1:	0f b6 00             	movzbl (%eax),%eax
 1a4:	38 c2                	cmp    %al,%dl
 1a6:	74 de                	je     186 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 1a8:	8b 45 08             	mov    0x8(%ebp),%eax
 1ab:	0f b6 00             	movzbl (%eax),%eax
 1ae:	0f b6 d0             	movzbl %al,%edx
 1b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b4:	0f b6 00             	movzbl (%eax),%eax
 1b7:	0f b6 c8             	movzbl %al,%ecx
 1ba:	89 d0                	mov    %edx,%eax
 1bc:	29 c8                	sub    %ecx,%eax
}
 1be:	5d                   	pop    %ebp
 1bf:	c3                   	ret    

000001c0 <strlen>:

uint
strlen(const char *s)
{
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1cd:	eb 04                	jmp    1d3 <strlen+0x13>
 1cf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1d3:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1d6:	8b 45 08             	mov    0x8(%ebp),%eax
 1d9:	01 d0                	add    %edx,%eax
 1db:	0f b6 00             	movzbl (%eax),%eax
 1de:	84 c0                	test   %al,%al
 1e0:	75 ed                	jne    1cf <strlen+0xf>
    ;
  return n;
 1e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1e5:	c9                   	leave  
 1e6:	c3                   	ret    

000001e7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e7:	55                   	push   %ebp
 1e8:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1ea:	8b 45 10             	mov    0x10(%ebp),%eax
 1ed:	50                   	push   %eax
 1ee:	ff 75 0c             	push   0xc(%ebp)
 1f1:	ff 75 08             	push   0x8(%ebp)
 1f4:	e8 32 ff ff ff       	call   12b <stosb>
 1f9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ff:	c9                   	leave  
 200:	c3                   	ret    

00000201 <strchr>:

char*
strchr(const char *s, char c)
{
 201:	55                   	push   %ebp
 202:	89 e5                	mov    %esp,%ebp
 204:	83 ec 04             	sub    $0x4,%esp
 207:	8b 45 0c             	mov    0xc(%ebp),%eax
 20a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 20d:	eb 14                	jmp    223 <strchr+0x22>
    if(*s == c)
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	0f b6 00             	movzbl (%eax),%eax
 215:	38 45 fc             	cmp    %al,-0x4(%ebp)
 218:	75 05                	jne    21f <strchr+0x1e>
      return (char*)s;
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
 21d:	eb 13                	jmp    232 <strchr+0x31>
  for(; *s; s++)
 21f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	0f b6 00             	movzbl (%eax),%eax
 229:	84 c0                	test   %al,%al
 22b:	75 e2                	jne    20f <strchr+0xe>
  return 0;
 22d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 232:	c9                   	leave  
 233:	c3                   	ret    

00000234 <gets>:

char*
gets(char *buf, int max)
{
 234:	55                   	push   %ebp
 235:	89 e5                	mov    %esp,%ebp
 237:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 241:	eb 42                	jmp    285 <gets+0x51>
    cc = read(0, &c, 1);
 243:	83 ec 04             	sub    $0x4,%esp
 246:	6a 01                	push   $0x1
 248:	8d 45 ef             	lea    -0x11(%ebp),%eax
 24b:	50                   	push   %eax
 24c:	6a 00                	push   $0x0
 24e:	e8 47 01 00 00       	call   39a <read>
 253:	83 c4 10             	add    $0x10,%esp
 256:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 259:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 25d:	7e 33                	jle    292 <gets+0x5e>
      break;
    buf[i++] = c;
 25f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 262:	8d 50 01             	lea    0x1(%eax),%edx
 265:	89 55 f4             	mov    %edx,-0xc(%ebp)
 268:	89 c2                	mov    %eax,%edx
 26a:	8b 45 08             	mov    0x8(%ebp),%eax
 26d:	01 c2                	add    %eax,%edx
 26f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 273:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 275:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 279:	3c 0a                	cmp    $0xa,%al
 27b:	74 16                	je     293 <gets+0x5f>
 27d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 281:	3c 0d                	cmp    $0xd,%al
 283:	74 0e                	je     293 <gets+0x5f>
  for(i=0; i+1 < max; ){
 285:	8b 45 f4             	mov    -0xc(%ebp),%eax
 288:	83 c0 01             	add    $0x1,%eax
 28b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 28e:	7f b3                	jg     243 <gets+0xf>
 290:	eb 01                	jmp    293 <gets+0x5f>
      break;
 292:	90                   	nop
      break;
  }
  buf[i] = '\0';
 293:	8b 55 f4             	mov    -0xc(%ebp),%edx
 296:	8b 45 08             	mov    0x8(%ebp),%eax
 299:	01 d0                	add    %edx,%eax
 29b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a1:	c9                   	leave  
 2a2:	c3                   	ret    

000002a3 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a3:	55                   	push   %ebp
 2a4:	89 e5                	mov    %esp,%ebp
 2a6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a9:	83 ec 08             	sub    $0x8,%esp
 2ac:	6a 00                	push   $0x0
 2ae:	ff 75 08             	push   0x8(%ebp)
 2b1:	e8 0c 01 00 00       	call   3c2 <open>
 2b6:	83 c4 10             	add    $0x10,%esp
 2b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2c0:	79 07                	jns    2c9 <stat+0x26>
    return -1;
 2c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2c7:	eb 25                	jmp    2ee <stat+0x4b>
  r = fstat(fd, st);
 2c9:	83 ec 08             	sub    $0x8,%esp
 2cc:	ff 75 0c             	push   0xc(%ebp)
 2cf:	ff 75 f4             	push   -0xc(%ebp)
 2d2:	e8 03 01 00 00       	call   3da <fstat>
 2d7:	83 c4 10             	add    $0x10,%esp
 2da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2dd:	83 ec 0c             	sub    $0xc,%esp
 2e0:	ff 75 f4             	push   -0xc(%ebp)
 2e3:	e8 c2 00 00 00       	call   3aa <close>
 2e8:	83 c4 10             	add    $0x10,%esp
  return r;
 2eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2ee:	c9                   	leave  
 2ef:	c3                   	ret    

000002f0 <atoi>:

int
atoi(const char *s)
{
 2f0:	55                   	push   %ebp
 2f1:	89 e5                	mov    %esp,%ebp
 2f3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2fd:	eb 25                	jmp    324 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
 302:	89 d0                	mov    %edx,%eax
 304:	c1 e0 02             	shl    $0x2,%eax
 307:	01 d0                	add    %edx,%eax
 309:	01 c0                	add    %eax,%eax
 30b:	89 c1                	mov    %eax,%ecx
 30d:	8b 45 08             	mov    0x8(%ebp),%eax
 310:	8d 50 01             	lea    0x1(%eax),%edx
 313:	89 55 08             	mov    %edx,0x8(%ebp)
 316:	0f b6 00             	movzbl (%eax),%eax
 319:	0f be c0             	movsbl %al,%eax
 31c:	01 c8                	add    %ecx,%eax
 31e:	83 e8 30             	sub    $0x30,%eax
 321:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 324:	8b 45 08             	mov    0x8(%ebp),%eax
 327:	0f b6 00             	movzbl (%eax),%eax
 32a:	3c 2f                	cmp    $0x2f,%al
 32c:	7e 0a                	jle    338 <atoi+0x48>
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
 331:	0f b6 00             	movzbl (%eax),%eax
 334:	3c 39                	cmp    $0x39,%al
 336:	7e c7                	jle    2ff <atoi+0xf>
  return n;
 338:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33b:	c9                   	leave  
 33c:	c3                   	ret    

0000033d <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 33d:	55                   	push   %ebp
 33e:	89 e5                	mov    %esp,%ebp
 340:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 343:	8b 45 08             	mov    0x8(%ebp),%eax
 346:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 349:	8b 45 0c             	mov    0xc(%ebp),%eax
 34c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 34f:	eb 17                	jmp    368 <memmove+0x2b>
    *dst++ = *src++;
 351:	8b 55 f8             	mov    -0x8(%ebp),%edx
 354:	8d 42 01             	lea    0x1(%edx),%eax
 357:	89 45 f8             	mov    %eax,-0x8(%ebp)
 35a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 35d:	8d 48 01             	lea    0x1(%eax),%ecx
 360:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 363:	0f b6 12             	movzbl (%edx),%edx
 366:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 368:	8b 45 10             	mov    0x10(%ebp),%eax
 36b:	8d 50 ff             	lea    -0x1(%eax),%edx
 36e:	89 55 10             	mov    %edx,0x10(%ebp)
 371:	85 c0                	test   %eax,%eax
 373:	7f dc                	jg     351 <memmove+0x14>
  return vdst;
 375:	8b 45 08             	mov    0x8(%ebp),%eax
}
 378:	c9                   	leave  
 379:	c3                   	ret    

0000037a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 37a:	b8 01 00 00 00       	mov    $0x1,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <exit>:
SYSCALL(exit)
 382:	b8 02 00 00 00       	mov    $0x2,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <wait>:
SYSCALL(wait)
 38a:	b8 03 00 00 00       	mov    $0x3,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <pipe>:
SYSCALL(pipe)
 392:	b8 04 00 00 00       	mov    $0x4,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <read>:
SYSCALL(read)
 39a:	b8 05 00 00 00       	mov    $0x5,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <write>:
SYSCALL(write)
 3a2:	b8 10 00 00 00       	mov    $0x10,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <close>:
SYSCALL(close)
 3aa:	b8 15 00 00 00       	mov    $0x15,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <kill>:
SYSCALL(kill)
 3b2:	b8 06 00 00 00       	mov    $0x6,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <exec>:
SYSCALL(exec)
 3ba:	b8 07 00 00 00       	mov    $0x7,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <open>:
SYSCALL(open)
 3c2:	b8 0f 00 00 00       	mov    $0xf,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <mknod>:
SYSCALL(mknod)
 3ca:	b8 11 00 00 00       	mov    $0x11,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <unlink>:
SYSCALL(unlink)
 3d2:	b8 12 00 00 00       	mov    $0x12,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <fstat>:
SYSCALL(fstat)
 3da:	b8 08 00 00 00       	mov    $0x8,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <link>:
SYSCALL(link)
 3e2:	b8 13 00 00 00       	mov    $0x13,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <mkdir>:
SYSCALL(mkdir)
 3ea:	b8 14 00 00 00       	mov    $0x14,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <chdir>:
SYSCALL(chdir)
 3f2:	b8 09 00 00 00       	mov    $0x9,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <dup>:
SYSCALL(dup)
 3fa:	b8 0a 00 00 00       	mov    $0xa,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <getpid>:
SYSCALL(getpid)
 402:	b8 0b 00 00 00       	mov    $0xb,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <sbrk>:
SYSCALL(sbrk)
 40a:	b8 0c 00 00 00       	mov    $0xc,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <sleep>:
SYSCALL(sleep)
 412:	b8 0d 00 00 00       	mov    $0xd,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <uptime>:
SYSCALL(uptime)
 41a:	b8 0e 00 00 00       	mov    $0xe,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <ps>:
SYSCALL(ps)
 422:	b8 16 00 00 00       	mov    $0x16,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <exec_time>:
SYSCALL(exec_time)
 42a:	b8 17 00 00 00       	mov    $0x17,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <deadline>:
SYSCALL(deadline)
 432:	b8 18 00 00 00       	mov    $0x18,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <sched_policy>:
SYSCALL(sched_policy)
 43a:	b8 19 00 00 00       	mov    $0x19,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <rate>:
SYSCALL(rate)
 442:	b8 1a 00 00 00       	mov    $0x1a,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 44a:	55                   	push   %ebp
 44b:	89 e5                	mov    %esp,%ebp
 44d:	83 ec 18             	sub    $0x18,%esp
 450:	8b 45 0c             	mov    0xc(%ebp),%eax
 453:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 456:	83 ec 04             	sub    $0x4,%esp
 459:	6a 01                	push   $0x1
 45b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 45e:	50                   	push   %eax
 45f:	ff 75 08             	push   0x8(%ebp)
 462:	e8 3b ff ff ff       	call   3a2 <write>
 467:	83 c4 10             	add    $0x10,%esp
}
 46a:	90                   	nop
 46b:	c9                   	leave  
 46c:	c3                   	ret    

0000046d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46d:	55                   	push   %ebp
 46e:	89 e5                	mov    %esp,%ebp
 470:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 473:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 47a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 47e:	74 17                	je     497 <printint+0x2a>
 480:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 484:	79 11                	jns    497 <printint+0x2a>
    neg = 1;
 486:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 48d:	8b 45 0c             	mov    0xc(%ebp),%eax
 490:	f7 d8                	neg    %eax
 492:	89 45 ec             	mov    %eax,-0x14(%ebp)
 495:	eb 06                	jmp    49d <printint+0x30>
  } else {
    x = xx;
 497:	8b 45 0c             	mov    0xc(%ebp),%eax
 49a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 49d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4aa:	ba 00 00 00 00       	mov    $0x0,%edx
 4af:	f7 f1                	div    %ecx
 4b1:	89 d1                	mov    %edx,%ecx
 4b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b6:	8d 50 01             	lea    0x1(%eax),%edx
 4b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4bc:	0f b6 91 7c 0b 00 00 	movzbl 0xb7c(%ecx),%edx
 4c3:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4cd:	ba 00 00 00 00       	mov    $0x0,%edx
 4d2:	f7 f1                	div    %ecx
 4d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4db:	75 c7                	jne    4a4 <printint+0x37>
  if(neg)
 4dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4e1:	74 2d                	je     510 <printint+0xa3>
    buf[i++] = '-';
 4e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e6:	8d 50 01             	lea    0x1(%eax),%edx
 4e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4ec:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4f1:	eb 1d                	jmp    510 <printint+0xa3>
    putc(fd, buf[i]);
 4f3:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f9:	01 d0                	add    %edx,%eax
 4fb:	0f b6 00             	movzbl (%eax),%eax
 4fe:	0f be c0             	movsbl %al,%eax
 501:	83 ec 08             	sub    $0x8,%esp
 504:	50                   	push   %eax
 505:	ff 75 08             	push   0x8(%ebp)
 508:	e8 3d ff ff ff       	call   44a <putc>
 50d:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 510:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 514:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 518:	79 d9                	jns    4f3 <printint+0x86>
}
 51a:	90                   	nop
 51b:	90                   	nop
 51c:	c9                   	leave  
 51d:	c3                   	ret    

0000051e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 51e:	55                   	push   %ebp
 51f:	89 e5                	mov    %esp,%ebp
 521:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 524:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 52b:	8d 45 0c             	lea    0xc(%ebp),%eax
 52e:	83 c0 04             	add    $0x4,%eax
 531:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 534:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 53b:	e9 59 01 00 00       	jmp    699 <printf+0x17b>
    c = fmt[i] & 0xff;
 540:	8b 55 0c             	mov    0xc(%ebp),%edx
 543:	8b 45 f0             	mov    -0x10(%ebp),%eax
 546:	01 d0                	add    %edx,%eax
 548:	0f b6 00             	movzbl (%eax),%eax
 54b:	0f be c0             	movsbl %al,%eax
 54e:	25 ff 00 00 00       	and    $0xff,%eax
 553:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 556:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 55a:	75 2c                	jne    588 <printf+0x6a>
      if(c == '%'){
 55c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 560:	75 0c                	jne    56e <printf+0x50>
        state = '%';
 562:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 569:	e9 27 01 00 00       	jmp    695 <printf+0x177>
      } else {
        putc(fd, c);
 56e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 571:	0f be c0             	movsbl %al,%eax
 574:	83 ec 08             	sub    $0x8,%esp
 577:	50                   	push   %eax
 578:	ff 75 08             	push   0x8(%ebp)
 57b:	e8 ca fe ff ff       	call   44a <putc>
 580:	83 c4 10             	add    $0x10,%esp
 583:	e9 0d 01 00 00       	jmp    695 <printf+0x177>
      }
    } else if(state == '%'){
 588:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 58c:	0f 85 03 01 00 00    	jne    695 <printf+0x177>
      if(c == 'd'){
 592:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 596:	75 1e                	jne    5b6 <printf+0x98>
        printint(fd, *ap, 10, 1);
 598:	8b 45 e8             	mov    -0x18(%ebp),%eax
 59b:	8b 00                	mov    (%eax),%eax
 59d:	6a 01                	push   $0x1
 59f:	6a 0a                	push   $0xa
 5a1:	50                   	push   %eax
 5a2:	ff 75 08             	push   0x8(%ebp)
 5a5:	e8 c3 fe ff ff       	call   46d <printint>
 5aa:	83 c4 10             	add    $0x10,%esp
        ap++;
 5ad:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b1:	e9 d8 00 00 00       	jmp    68e <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5b6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5ba:	74 06                	je     5c2 <printf+0xa4>
 5bc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5c0:	75 1e                	jne    5e0 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c5:	8b 00                	mov    (%eax),%eax
 5c7:	6a 00                	push   $0x0
 5c9:	6a 10                	push   $0x10
 5cb:	50                   	push   %eax
 5cc:	ff 75 08             	push   0x8(%ebp)
 5cf:	e8 99 fe ff ff       	call   46d <printint>
 5d4:	83 c4 10             	add    $0x10,%esp
        ap++;
 5d7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5db:	e9 ae 00 00 00       	jmp    68e <printf+0x170>
      } else if(c == 's'){
 5e0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5e4:	75 43                	jne    629 <printf+0x10b>
        s = (char*)*ap;
 5e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e9:	8b 00                	mov    (%eax),%eax
 5eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5ee:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f6:	75 25                	jne    61d <printf+0xff>
          s = "(null)";
 5f8:	c7 45 f4 0d 09 00 00 	movl   $0x90d,-0xc(%ebp)
        while(*s != 0){
 5ff:	eb 1c                	jmp    61d <printf+0xff>
          putc(fd, *s);
 601:	8b 45 f4             	mov    -0xc(%ebp),%eax
 604:	0f b6 00             	movzbl (%eax),%eax
 607:	0f be c0             	movsbl %al,%eax
 60a:	83 ec 08             	sub    $0x8,%esp
 60d:	50                   	push   %eax
 60e:	ff 75 08             	push   0x8(%ebp)
 611:	e8 34 fe ff ff       	call   44a <putc>
 616:	83 c4 10             	add    $0x10,%esp
          s++;
 619:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 61d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 620:	0f b6 00             	movzbl (%eax),%eax
 623:	84 c0                	test   %al,%al
 625:	75 da                	jne    601 <printf+0xe3>
 627:	eb 65                	jmp    68e <printf+0x170>
        }
      } else if(c == 'c'){
 629:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 62d:	75 1d                	jne    64c <printf+0x12e>
        putc(fd, *ap);
 62f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 632:	8b 00                	mov    (%eax),%eax
 634:	0f be c0             	movsbl %al,%eax
 637:	83 ec 08             	sub    $0x8,%esp
 63a:	50                   	push   %eax
 63b:	ff 75 08             	push   0x8(%ebp)
 63e:	e8 07 fe ff ff       	call   44a <putc>
 643:	83 c4 10             	add    $0x10,%esp
        ap++;
 646:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 64a:	eb 42                	jmp    68e <printf+0x170>
      } else if(c == '%'){
 64c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 650:	75 17                	jne    669 <printf+0x14b>
        putc(fd, c);
 652:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 655:	0f be c0             	movsbl %al,%eax
 658:	83 ec 08             	sub    $0x8,%esp
 65b:	50                   	push   %eax
 65c:	ff 75 08             	push   0x8(%ebp)
 65f:	e8 e6 fd ff ff       	call   44a <putc>
 664:	83 c4 10             	add    $0x10,%esp
 667:	eb 25                	jmp    68e <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 669:	83 ec 08             	sub    $0x8,%esp
 66c:	6a 25                	push   $0x25
 66e:	ff 75 08             	push   0x8(%ebp)
 671:	e8 d4 fd ff ff       	call   44a <putc>
 676:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 67c:	0f be c0             	movsbl %al,%eax
 67f:	83 ec 08             	sub    $0x8,%esp
 682:	50                   	push   %eax
 683:	ff 75 08             	push   0x8(%ebp)
 686:	e8 bf fd ff ff       	call   44a <putc>
 68b:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 68e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 695:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 699:	8b 55 0c             	mov    0xc(%ebp),%edx
 69c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 69f:	01 d0                	add    %edx,%eax
 6a1:	0f b6 00             	movzbl (%eax),%eax
 6a4:	84 c0                	test   %al,%al
 6a6:	0f 85 94 fe ff ff    	jne    540 <printf+0x22>
    }
  }
}
 6ac:	90                   	nop
 6ad:	90                   	nop
 6ae:	c9                   	leave  
 6af:	c3                   	ret    

000006b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b0:	55                   	push   %ebp
 6b1:	89 e5                	mov    %esp,%ebp
 6b3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b6:	8b 45 08             	mov    0x8(%ebp),%eax
 6b9:	83 e8 08             	sub    $0x8,%eax
 6bc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6bf:	a1 a8 0d 00 00       	mov    0xda8,%eax
 6c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6c7:	eb 24                	jmp    6ed <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 00                	mov    (%eax),%eax
 6ce:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6d1:	72 12                	jb     6e5 <free+0x35>
 6d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d9:	77 24                	ja     6ff <free+0x4f>
 6db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6de:	8b 00                	mov    (%eax),%eax
 6e0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6e3:	72 1a                	jb     6ff <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 00                	mov    (%eax),%eax
 6ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f3:	76 d4                	jbe    6c9 <free+0x19>
 6f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6fd:	73 ca                	jae    6c9 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 702:	8b 40 04             	mov    0x4(%eax),%eax
 705:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 70c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70f:	01 c2                	add    %eax,%edx
 711:	8b 45 fc             	mov    -0x4(%ebp),%eax
 714:	8b 00                	mov    (%eax),%eax
 716:	39 c2                	cmp    %eax,%edx
 718:	75 24                	jne    73e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 71a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71d:	8b 50 04             	mov    0x4(%eax),%edx
 720:	8b 45 fc             	mov    -0x4(%ebp),%eax
 723:	8b 00                	mov    (%eax),%eax
 725:	8b 40 04             	mov    0x4(%eax),%eax
 728:	01 c2                	add    %eax,%edx
 72a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 730:	8b 45 fc             	mov    -0x4(%ebp),%eax
 733:	8b 00                	mov    (%eax),%eax
 735:	8b 10                	mov    (%eax),%edx
 737:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73a:	89 10                	mov    %edx,(%eax)
 73c:	eb 0a                	jmp    748 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 73e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 741:	8b 10                	mov    (%eax),%edx
 743:	8b 45 f8             	mov    -0x8(%ebp),%eax
 746:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	8b 40 04             	mov    0x4(%eax),%eax
 74e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	01 d0                	add    %edx,%eax
 75a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 75d:	75 20                	jne    77f <free+0xcf>
    p->s.size += bp->s.size;
 75f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 762:	8b 50 04             	mov    0x4(%eax),%edx
 765:	8b 45 f8             	mov    -0x8(%ebp),%eax
 768:	8b 40 04             	mov    0x4(%eax),%eax
 76b:	01 c2                	add    %eax,%edx
 76d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 770:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 773:	8b 45 f8             	mov    -0x8(%ebp),%eax
 776:	8b 10                	mov    (%eax),%edx
 778:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77b:	89 10                	mov    %edx,(%eax)
 77d:	eb 08                	jmp    787 <free+0xd7>
  } else
    p->s.ptr = bp;
 77f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 782:	8b 55 f8             	mov    -0x8(%ebp),%edx
 785:	89 10                	mov    %edx,(%eax)
  freep = p;
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	a3 a8 0d 00 00       	mov    %eax,0xda8
}
 78f:	90                   	nop
 790:	c9                   	leave  
 791:	c3                   	ret    

00000792 <morecore>:

static Header*
morecore(uint nu)
{
 792:	55                   	push   %ebp
 793:	89 e5                	mov    %esp,%ebp
 795:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 798:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 79f:	77 07                	ja     7a8 <morecore+0x16>
    nu = 4096;
 7a1:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7a8:	8b 45 08             	mov    0x8(%ebp),%eax
 7ab:	c1 e0 03             	shl    $0x3,%eax
 7ae:	83 ec 0c             	sub    $0xc,%esp
 7b1:	50                   	push   %eax
 7b2:	e8 53 fc ff ff       	call   40a <sbrk>
 7b7:	83 c4 10             	add    $0x10,%esp
 7ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7bd:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c1:	75 07                	jne    7ca <morecore+0x38>
    return 0;
 7c3:	b8 00 00 00 00       	mov    $0x0,%eax
 7c8:	eb 26                	jmp    7f0 <morecore+0x5e>
  hp = (Header*)p;
 7ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d3:	8b 55 08             	mov    0x8(%ebp),%edx
 7d6:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dc:	83 c0 08             	add    $0x8,%eax
 7df:	83 ec 0c             	sub    $0xc,%esp
 7e2:	50                   	push   %eax
 7e3:	e8 c8 fe ff ff       	call   6b0 <free>
 7e8:	83 c4 10             	add    $0x10,%esp
  return freep;
 7eb:	a1 a8 0d 00 00       	mov    0xda8,%eax
}
 7f0:	c9                   	leave  
 7f1:	c3                   	ret    

000007f2 <malloc>:

void*
malloc(uint nbytes)
{
 7f2:	55                   	push   %ebp
 7f3:	89 e5                	mov    %esp,%ebp
 7f5:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f8:	8b 45 08             	mov    0x8(%ebp),%eax
 7fb:	83 c0 07             	add    $0x7,%eax
 7fe:	c1 e8 03             	shr    $0x3,%eax
 801:	83 c0 01             	add    $0x1,%eax
 804:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 807:	a1 a8 0d 00 00       	mov    0xda8,%eax
 80c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 813:	75 23                	jne    838 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 815:	c7 45 f0 a0 0d 00 00 	movl   $0xda0,-0x10(%ebp)
 81c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81f:	a3 a8 0d 00 00       	mov    %eax,0xda8
 824:	a1 a8 0d 00 00       	mov    0xda8,%eax
 829:	a3 a0 0d 00 00       	mov    %eax,0xda0
    base.s.size = 0;
 82e:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
 835:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 838:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 840:	8b 45 f4             	mov    -0xc(%ebp),%eax
 843:	8b 40 04             	mov    0x4(%eax),%eax
 846:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 849:	77 4d                	ja     898 <malloc+0xa6>
      if(p->s.size == nunits)
 84b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84e:	8b 40 04             	mov    0x4(%eax),%eax
 851:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 854:	75 0c                	jne    862 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 856:	8b 45 f4             	mov    -0xc(%ebp),%eax
 859:	8b 10                	mov    (%eax),%edx
 85b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85e:	89 10                	mov    %edx,(%eax)
 860:	eb 26                	jmp    888 <malloc+0x96>
      else {
        p->s.size -= nunits;
 862:	8b 45 f4             	mov    -0xc(%ebp),%eax
 865:	8b 40 04             	mov    0x4(%eax),%eax
 868:	2b 45 ec             	sub    -0x14(%ebp),%eax
 86b:	89 c2                	mov    %eax,%edx
 86d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 870:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 873:	8b 45 f4             	mov    -0xc(%ebp),%eax
 876:	8b 40 04             	mov    0x4(%eax),%eax
 879:	c1 e0 03             	shl    $0x3,%eax
 87c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 87f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 882:	8b 55 ec             	mov    -0x14(%ebp),%edx
 885:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 888:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88b:	a3 a8 0d 00 00       	mov    %eax,0xda8
      return (void*)(p + 1);
 890:	8b 45 f4             	mov    -0xc(%ebp),%eax
 893:	83 c0 08             	add    $0x8,%eax
 896:	eb 3b                	jmp    8d3 <malloc+0xe1>
    }
    if(p == freep)
 898:	a1 a8 0d 00 00       	mov    0xda8,%eax
 89d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8a0:	75 1e                	jne    8c0 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8a2:	83 ec 0c             	sub    $0xc,%esp
 8a5:	ff 75 ec             	push   -0x14(%ebp)
 8a8:	e8 e5 fe ff ff       	call   792 <morecore>
 8ad:	83 c4 10             	add    $0x10,%esp
 8b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8b7:	75 07                	jne    8c0 <malloc+0xce>
        return 0;
 8b9:	b8 00 00 00 00       	mov    $0x0,%eax
 8be:	eb 13                	jmp    8d3 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c9:	8b 00                	mov    (%eax),%eax
 8cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8ce:	e9 6d ff ff ff       	jmp    840 <malloc+0x4e>
  }
}
 8d3:	c9                   	leave  
 8d4:	c3                   	ret    
