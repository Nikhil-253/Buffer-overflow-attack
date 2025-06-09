
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
   6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
   d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  inword = 0;
  19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  20:	eb 69                	jmp    8b <wc+0x8b>
    for(i=0; i<n; i++){
  22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  29:	eb 58                	jmp    83 <wc+0x83>
      c++;
  2b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
      if(buf[i] == '\n')
  2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  32:	05 40 0c 00 00       	add    $0xc40,%eax
  37:	0f b6 00             	movzbl (%eax),%eax
  3a:	3c 0a                	cmp    $0xa,%al
  3c:	75 04                	jne    42 <wc+0x42>
        l++;
  3e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  45:	05 40 0c 00 00       	add    $0xc40,%eax
  4a:	0f b6 00             	movzbl (%eax),%eax
  4d:	0f be c0             	movsbl %al,%eax
  50:	83 ec 08             	sub    $0x8,%esp
  53:	50                   	push   %eax
  54:	68 67 09 00 00       	push   $0x967
  59:	e8 35 02 00 00       	call   293 <strchr>
  5e:	83 c4 10             	add    $0x10,%esp
  61:	85 c0                	test   %eax,%eax
  63:	74 09                	je     6e <wc+0x6e>
        inword = 0;
  65:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  6c:	eb 11                	jmp    7f <wc+0x7f>
      else if(!inword){
  6e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  72:	75 0b                	jne    7f <wc+0x7f>
        w++;
  74:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
        inword = 1;
  78:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
    for(i=0; i<n; i++){
  7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  86:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  89:	7c a0                	jl     2b <wc+0x2b>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  8b:	83 ec 04             	sub    $0x4,%esp
  8e:	68 00 02 00 00       	push   $0x200
  93:	68 40 0c 00 00       	push   $0xc40
  98:	ff 75 08             	push   0x8(%ebp)
  9b:	e8 8c 03 00 00       	call   42c <read>
  a0:	83 c4 10             	add    $0x10,%esp
  a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  aa:	0f 8f 72 ff ff ff    	jg     22 <wc+0x22>
      }
    }
  }
  if(n < 0){
  b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  b4:	79 17                	jns    cd <wc+0xcd>
    printf(1, "wc: read error\n");
  b6:	83 ec 08             	sub    $0x8,%esp
  b9:	68 6d 09 00 00       	push   $0x96d
  be:	6a 01                	push   $0x1
  c0:	e8 eb 04 00 00       	call   5b0 <printf>
  c5:	83 c4 10             	add    $0x10,%esp
    exit();
  c8:	e8 47 03 00 00       	call   414 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  cd:	83 ec 08             	sub    $0x8,%esp
  d0:	ff 75 0c             	push   0xc(%ebp)
  d3:	ff 75 e8             	push   -0x18(%ebp)
  d6:	ff 75 ec             	push   -0x14(%ebp)
  d9:	ff 75 f0             	push   -0x10(%ebp)
  dc:	68 7d 09 00 00       	push   $0x97d
  e1:	6a 01                	push   $0x1
  e3:	e8 c8 04 00 00       	call   5b0 <printf>
  e8:	83 c4 20             	add    $0x20,%esp
}
  eb:	90                   	nop
  ec:	c9                   	leave  
  ed:	c3                   	ret    

000000ee <main>:

int
main(int argc, char *argv[])
{
  ee:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  f2:	83 e4 f0             	and    $0xfffffff0,%esp
  f5:	ff 71 fc             	push   -0x4(%ecx)
  f8:	55                   	push   %ebp
  f9:	89 e5                	mov    %esp,%ebp
  fb:	53                   	push   %ebx
  fc:	51                   	push   %ecx
  fd:	83 ec 10             	sub    $0x10,%esp
 100:	89 cb                	mov    %ecx,%ebx
  int fd, i;

  if(argc <= 1){
 102:	83 3b 01             	cmpl   $0x1,(%ebx)
 105:	7f 17                	jg     11e <main+0x30>
    wc(0, "");
 107:	83 ec 08             	sub    $0x8,%esp
 10a:	68 8a 09 00 00       	push   $0x98a
 10f:	6a 00                	push   $0x0
 111:	e8 ea fe ff ff       	call   0 <wc>
 116:	83 c4 10             	add    $0x10,%esp
    exit();
 119:	e8 f6 02 00 00       	call   414 <exit>
  }

  for(i = 1; i < argc; i++){
 11e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 125:	e9 83 00 00 00       	jmp    1ad <main+0xbf>
    if((fd = open(argv[i], 0)) < 0){
 12a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 12d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 134:	8b 43 04             	mov    0x4(%ebx),%eax
 137:	01 d0                	add    %edx,%eax
 139:	8b 00                	mov    (%eax),%eax
 13b:	83 ec 08             	sub    $0x8,%esp
 13e:	6a 00                	push   $0x0
 140:	50                   	push   %eax
 141:	e8 0e 03 00 00       	call   454 <open>
 146:	83 c4 10             	add    $0x10,%esp
 149:	89 45 f0             	mov    %eax,-0x10(%ebp)
 14c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 150:	79 29                	jns    17b <main+0x8d>
      printf(1, "wc: cannot open %s\n", argv[i]);
 152:	8b 45 f4             	mov    -0xc(%ebp),%eax
 155:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 15c:	8b 43 04             	mov    0x4(%ebx),%eax
 15f:	01 d0                	add    %edx,%eax
 161:	8b 00                	mov    (%eax),%eax
 163:	83 ec 04             	sub    $0x4,%esp
 166:	50                   	push   %eax
 167:	68 8b 09 00 00       	push   $0x98b
 16c:	6a 01                	push   $0x1
 16e:	e8 3d 04 00 00       	call   5b0 <printf>
 173:	83 c4 10             	add    $0x10,%esp
      exit();
 176:	e8 99 02 00 00       	call   414 <exit>
    }
    wc(fd, argv[i]);
 17b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 185:	8b 43 04             	mov    0x4(%ebx),%eax
 188:	01 d0                	add    %edx,%eax
 18a:	8b 00                	mov    (%eax),%eax
 18c:	83 ec 08             	sub    $0x8,%esp
 18f:	50                   	push   %eax
 190:	ff 75 f0             	push   -0x10(%ebp)
 193:	e8 68 fe ff ff       	call   0 <wc>
 198:	83 c4 10             	add    $0x10,%esp
    close(fd);
 19b:	83 ec 0c             	sub    $0xc,%esp
 19e:	ff 75 f0             	push   -0x10(%ebp)
 1a1:	e8 96 02 00 00       	call   43c <close>
 1a6:	83 c4 10             	add    $0x10,%esp
  for(i = 1; i < argc; i++){
 1a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b0:	3b 03                	cmp    (%ebx),%eax
 1b2:	0f 8c 72 ff ff ff    	jl     12a <main+0x3c>
  }
  exit();
 1b8:	e8 57 02 00 00       	call   414 <exit>

000001bd <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1bd:	55                   	push   %ebp
 1be:	89 e5                	mov    %esp,%ebp
 1c0:	57                   	push   %edi
 1c1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1c5:	8b 55 10             	mov    0x10(%ebp),%edx
 1c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1cb:	89 cb                	mov    %ecx,%ebx
 1cd:	89 df                	mov    %ebx,%edi
 1cf:	89 d1                	mov    %edx,%ecx
 1d1:	fc                   	cld    
 1d2:	f3 aa                	rep stos %al,%es:(%edi)
 1d4:	89 ca                	mov    %ecx,%edx
 1d6:	89 fb                	mov    %edi,%ebx
 1d8:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1db:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1de:	90                   	nop
 1df:	5b                   	pop    %ebx
 1e0:	5f                   	pop    %edi
 1e1:	5d                   	pop    %ebp
 1e2:	c3                   	ret    

000001e3 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 1e3:	55                   	push   %ebp
 1e4:	89 e5                	mov    %esp,%ebp
 1e6:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1ef:	90                   	nop
 1f0:	8b 55 0c             	mov    0xc(%ebp),%edx
 1f3:	8d 42 01             	lea    0x1(%edx),%eax
 1f6:	89 45 0c             	mov    %eax,0xc(%ebp)
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	8d 48 01             	lea    0x1(%eax),%ecx
 1ff:	89 4d 08             	mov    %ecx,0x8(%ebp)
 202:	0f b6 12             	movzbl (%edx),%edx
 205:	88 10                	mov    %dl,(%eax)
 207:	0f b6 00             	movzbl (%eax),%eax
 20a:	84 c0                	test   %al,%al
 20c:	75 e2                	jne    1f0 <strcpy+0xd>
    ;
  return os;
 20e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 211:	c9                   	leave  
 212:	c3                   	ret    

00000213 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 213:	55                   	push   %ebp
 214:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 216:	eb 08                	jmp    220 <strcmp+0xd>
    p++, q++;
 218:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 220:	8b 45 08             	mov    0x8(%ebp),%eax
 223:	0f b6 00             	movzbl (%eax),%eax
 226:	84 c0                	test   %al,%al
 228:	74 10                	je     23a <strcmp+0x27>
 22a:	8b 45 08             	mov    0x8(%ebp),%eax
 22d:	0f b6 10             	movzbl (%eax),%edx
 230:	8b 45 0c             	mov    0xc(%ebp),%eax
 233:	0f b6 00             	movzbl (%eax),%eax
 236:	38 c2                	cmp    %al,%dl
 238:	74 de                	je     218 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 23a:	8b 45 08             	mov    0x8(%ebp),%eax
 23d:	0f b6 00             	movzbl (%eax),%eax
 240:	0f b6 d0             	movzbl %al,%edx
 243:	8b 45 0c             	mov    0xc(%ebp),%eax
 246:	0f b6 00             	movzbl (%eax),%eax
 249:	0f b6 c8             	movzbl %al,%ecx
 24c:	89 d0                	mov    %edx,%eax
 24e:	29 c8                	sub    %ecx,%eax
}
 250:	5d                   	pop    %ebp
 251:	c3                   	ret    

00000252 <strlen>:

uint
strlen(const char *s)
{
 252:	55                   	push   %ebp
 253:	89 e5                	mov    %esp,%ebp
 255:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 258:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 25f:	eb 04                	jmp    265 <strlen+0x13>
 261:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 265:	8b 55 fc             	mov    -0x4(%ebp),%edx
 268:	8b 45 08             	mov    0x8(%ebp),%eax
 26b:	01 d0                	add    %edx,%eax
 26d:	0f b6 00             	movzbl (%eax),%eax
 270:	84 c0                	test   %al,%al
 272:	75 ed                	jne    261 <strlen+0xf>
    ;
  return n;
 274:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 277:	c9                   	leave  
 278:	c3                   	ret    

00000279 <memset>:

void*
memset(void *dst, int c, uint n)
{
 279:	55                   	push   %ebp
 27a:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 27c:	8b 45 10             	mov    0x10(%ebp),%eax
 27f:	50                   	push   %eax
 280:	ff 75 0c             	push   0xc(%ebp)
 283:	ff 75 08             	push   0x8(%ebp)
 286:	e8 32 ff ff ff       	call   1bd <stosb>
 28b:	83 c4 0c             	add    $0xc,%esp
  return dst;
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 291:	c9                   	leave  
 292:	c3                   	ret    

00000293 <strchr>:

char*
strchr(const char *s, char c)
{
 293:	55                   	push   %ebp
 294:	89 e5                	mov    %esp,%ebp
 296:	83 ec 04             	sub    $0x4,%esp
 299:	8b 45 0c             	mov    0xc(%ebp),%eax
 29c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 29f:	eb 14                	jmp    2b5 <strchr+0x22>
    if(*s == c)
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	0f b6 00             	movzbl (%eax),%eax
 2a7:	38 45 fc             	cmp    %al,-0x4(%ebp)
 2aa:	75 05                	jne    2b1 <strchr+0x1e>
      return (char*)s;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
 2af:	eb 13                	jmp    2c4 <strchr+0x31>
  for(; *s; s++)
 2b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	0f b6 00             	movzbl (%eax),%eax
 2bb:	84 c0                	test   %al,%al
 2bd:	75 e2                	jne    2a1 <strchr+0xe>
  return 0;
 2bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2c4:	c9                   	leave  
 2c5:	c3                   	ret    

000002c6 <gets>:

char*
gets(char *buf, int max)
{
 2c6:	55                   	push   %ebp
 2c7:	89 e5                	mov    %esp,%ebp
 2c9:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2d3:	eb 42                	jmp    317 <gets+0x51>
    cc = read(0, &c, 1);
 2d5:	83 ec 04             	sub    $0x4,%esp
 2d8:	6a 01                	push   $0x1
 2da:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2dd:	50                   	push   %eax
 2de:	6a 00                	push   $0x0
 2e0:	e8 47 01 00 00       	call   42c <read>
 2e5:	83 c4 10             	add    $0x10,%esp
 2e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2ef:	7e 33                	jle    324 <gets+0x5e>
      break;
    buf[i++] = c;
 2f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f4:	8d 50 01             	lea    0x1(%eax),%edx
 2f7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2fa:	89 c2                	mov    %eax,%edx
 2fc:	8b 45 08             	mov    0x8(%ebp),%eax
 2ff:	01 c2                	add    %eax,%edx
 301:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 305:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 307:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 30b:	3c 0a                	cmp    $0xa,%al
 30d:	74 16                	je     325 <gets+0x5f>
 30f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 313:	3c 0d                	cmp    $0xd,%al
 315:	74 0e                	je     325 <gets+0x5f>
  for(i=0; i+1 < max; ){
 317:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31a:	83 c0 01             	add    $0x1,%eax
 31d:	39 45 0c             	cmp    %eax,0xc(%ebp)
 320:	7f b3                	jg     2d5 <gets+0xf>
 322:	eb 01                	jmp    325 <gets+0x5f>
      break;
 324:	90                   	nop
      break;
  }
  buf[i] = '\0';
 325:	8b 55 f4             	mov    -0xc(%ebp),%edx
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	01 d0                	add    %edx,%eax
 32d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 330:	8b 45 08             	mov    0x8(%ebp),%eax
}
 333:	c9                   	leave  
 334:	c3                   	ret    

00000335 <stat>:

int
stat(const char *n, struct stat *st)
{
 335:	55                   	push   %ebp
 336:	89 e5                	mov    %esp,%ebp
 338:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 33b:	83 ec 08             	sub    $0x8,%esp
 33e:	6a 00                	push   $0x0
 340:	ff 75 08             	push   0x8(%ebp)
 343:	e8 0c 01 00 00       	call   454 <open>
 348:	83 c4 10             	add    $0x10,%esp
 34b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 34e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 352:	79 07                	jns    35b <stat+0x26>
    return -1;
 354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 359:	eb 25                	jmp    380 <stat+0x4b>
  r = fstat(fd, st);
 35b:	83 ec 08             	sub    $0x8,%esp
 35e:	ff 75 0c             	push   0xc(%ebp)
 361:	ff 75 f4             	push   -0xc(%ebp)
 364:	e8 03 01 00 00       	call   46c <fstat>
 369:	83 c4 10             	add    $0x10,%esp
 36c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 36f:	83 ec 0c             	sub    $0xc,%esp
 372:	ff 75 f4             	push   -0xc(%ebp)
 375:	e8 c2 00 00 00       	call   43c <close>
 37a:	83 c4 10             	add    $0x10,%esp
  return r;
 37d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 380:	c9                   	leave  
 381:	c3                   	ret    

00000382 <atoi>:

int
atoi(const char *s)
{
 382:	55                   	push   %ebp
 383:	89 e5                	mov    %esp,%ebp
 385:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 388:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 38f:	eb 25                	jmp    3b6 <atoi+0x34>
    n = n*10 + *s++ - '0';
 391:	8b 55 fc             	mov    -0x4(%ebp),%edx
 394:	89 d0                	mov    %edx,%eax
 396:	c1 e0 02             	shl    $0x2,%eax
 399:	01 d0                	add    %edx,%eax
 39b:	01 c0                	add    %eax,%eax
 39d:	89 c1                	mov    %eax,%ecx
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	8d 50 01             	lea    0x1(%eax),%edx
 3a5:	89 55 08             	mov    %edx,0x8(%ebp)
 3a8:	0f b6 00             	movzbl (%eax),%eax
 3ab:	0f be c0             	movsbl %al,%eax
 3ae:	01 c8                	add    %ecx,%eax
 3b0:	83 e8 30             	sub    $0x30,%eax
 3b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
 3b9:	0f b6 00             	movzbl (%eax),%eax
 3bc:	3c 2f                	cmp    $0x2f,%al
 3be:	7e 0a                	jle    3ca <atoi+0x48>
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
 3c3:	0f b6 00             	movzbl (%eax),%eax
 3c6:	3c 39                	cmp    $0x39,%al
 3c8:	7e c7                	jle    391 <atoi+0xf>
  return n;
 3ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3cd:	c9                   	leave  
 3ce:	c3                   	ret    

000003cf <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3cf:	55                   	push   %ebp
 3d0:	89 e5                	mov    %esp,%ebp
 3d2:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 3d5:	8b 45 08             	mov    0x8(%ebp),%eax
 3d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3db:	8b 45 0c             	mov    0xc(%ebp),%eax
 3de:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3e1:	eb 17                	jmp    3fa <memmove+0x2b>
    *dst++ = *src++;
 3e3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3e6:	8d 42 01             	lea    0x1(%edx),%eax
 3e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
 3ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ef:	8d 48 01             	lea    0x1(%eax),%ecx
 3f2:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 3f5:	0f b6 12             	movzbl (%edx),%edx
 3f8:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 3fa:	8b 45 10             	mov    0x10(%ebp),%eax
 3fd:	8d 50 ff             	lea    -0x1(%eax),%edx
 400:	89 55 10             	mov    %edx,0x10(%ebp)
 403:	85 c0                	test   %eax,%eax
 405:	7f dc                	jg     3e3 <memmove+0x14>
  return vdst;
 407:	8b 45 08             	mov    0x8(%ebp),%eax
}
 40a:	c9                   	leave  
 40b:	c3                   	ret    

0000040c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 40c:	b8 01 00 00 00       	mov    $0x1,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <exit>:
SYSCALL(exit)
 414:	b8 02 00 00 00       	mov    $0x2,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <wait>:
SYSCALL(wait)
 41c:	b8 03 00 00 00       	mov    $0x3,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <pipe>:
SYSCALL(pipe)
 424:	b8 04 00 00 00       	mov    $0x4,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <read>:
SYSCALL(read)
 42c:	b8 05 00 00 00       	mov    $0x5,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <write>:
SYSCALL(write)
 434:	b8 10 00 00 00       	mov    $0x10,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <close>:
SYSCALL(close)
 43c:	b8 15 00 00 00       	mov    $0x15,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <kill>:
SYSCALL(kill)
 444:	b8 06 00 00 00       	mov    $0x6,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <exec>:
SYSCALL(exec)
 44c:	b8 07 00 00 00       	mov    $0x7,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <open>:
SYSCALL(open)
 454:	b8 0f 00 00 00       	mov    $0xf,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <mknod>:
SYSCALL(mknod)
 45c:	b8 11 00 00 00       	mov    $0x11,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <unlink>:
SYSCALL(unlink)
 464:	b8 12 00 00 00       	mov    $0x12,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <fstat>:
SYSCALL(fstat)
 46c:	b8 08 00 00 00       	mov    $0x8,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <link>:
SYSCALL(link)
 474:	b8 13 00 00 00       	mov    $0x13,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <mkdir>:
SYSCALL(mkdir)
 47c:	b8 14 00 00 00       	mov    $0x14,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <chdir>:
SYSCALL(chdir)
 484:	b8 09 00 00 00       	mov    $0x9,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <dup>:
SYSCALL(dup)
 48c:	b8 0a 00 00 00       	mov    $0xa,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <getpid>:
SYSCALL(getpid)
 494:	b8 0b 00 00 00       	mov    $0xb,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <sbrk>:
SYSCALL(sbrk)
 49c:	b8 0c 00 00 00       	mov    $0xc,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <sleep>:
SYSCALL(sleep)
 4a4:	b8 0d 00 00 00       	mov    $0xd,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <uptime>:
SYSCALL(uptime)
 4ac:	b8 0e 00 00 00       	mov    $0xe,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <ps>:
SYSCALL(ps)
 4b4:	b8 16 00 00 00       	mov    $0x16,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <exec_time>:
SYSCALL(exec_time)
 4bc:	b8 17 00 00 00       	mov    $0x17,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <deadline>:
SYSCALL(deadline)
 4c4:	b8 18 00 00 00       	mov    $0x18,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <sched_policy>:
SYSCALL(sched_policy)
 4cc:	b8 19 00 00 00       	mov    $0x19,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <rate>:
SYSCALL(rate)
 4d4:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4dc:	55                   	push   %ebp
 4dd:	89 e5                	mov    %esp,%ebp
 4df:	83 ec 18             	sub    $0x18,%esp
 4e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4e8:	83 ec 04             	sub    $0x4,%esp
 4eb:	6a 01                	push   $0x1
 4ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4f0:	50                   	push   %eax
 4f1:	ff 75 08             	push   0x8(%ebp)
 4f4:	e8 3b ff ff ff       	call   434 <write>
 4f9:	83 c4 10             	add    $0x10,%esp
}
 4fc:	90                   	nop
 4fd:	c9                   	leave  
 4fe:	c3                   	ret    

000004ff <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ff:	55                   	push   %ebp
 500:	89 e5                	mov    %esp,%ebp
 502:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 505:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 50c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 510:	74 17                	je     529 <printint+0x2a>
 512:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 516:	79 11                	jns    529 <printint+0x2a>
    neg = 1;
 518:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 51f:	8b 45 0c             	mov    0xc(%ebp),%eax
 522:	f7 d8                	neg    %eax
 524:	89 45 ec             	mov    %eax,-0x14(%ebp)
 527:	eb 06                	jmp    52f <printint+0x30>
  } else {
    x = xx;
 529:	8b 45 0c             	mov    0xc(%ebp),%eax
 52c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 52f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 536:	8b 4d 10             	mov    0x10(%ebp),%ecx
 539:	8b 45 ec             	mov    -0x14(%ebp),%eax
 53c:	ba 00 00 00 00       	mov    $0x0,%edx
 541:	f7 f1                	div    %ecx
 543:	89 d1                	mov    %edx,%ecx
 545:	8b 45 f4             	mov    -0xc(%ebp),%eax
 548:	8d 50 01             	lea    0x1(%eax),%edx
 54b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 54e:	0f b6 91 10 0c 00 00 	movzbl 0xc10(%ecx),%edx
 555:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 559:	8b 4d 10             	mov    0x10(%ebp),%ecx
 55c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 55f:	ba 00 00 00 00       	mov    $0x0,%edx
 564:	f7 f1                	div    %ecx
 566:	89 45 ec             	mov    %eax,-0x14(%ebp)
 569:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 56d:	75 c7                	jne    536 <printint+0x37>
  if(neg)
 56f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 573:	74 2d                	je     5a2 <printint+0xa3>
    buf[i++] = '-';
 575:	8b 45 f4             	mov    -0xc(%ebp),%eax
 578:	8d 50 01             	lea    0x1(%eax),%edx
 57b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 57e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 583:	eb 1d                	jmp    5a2 <printint+0xa3>
    putc(fd, buf[i]);
 585:	8d 55 dc             	lea    -0x24(%ebp),%edx
 588:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58b:	01 d0                	add    %edx,%eax
 58d:	0f b6 00             	movzbl (%eax),%eax
 590:	0f be c0             	movsbl %al,%eax
 593:	83 ec 08             	sub    $0x8,%esp
 596:	50                   	push   %eax
 597:	ff 75 08             	push   0x8(%ebp)
 59a:	e8 3d ff ff ff       	call   4dc <putc>
 59f:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 5a2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5aa:	79 d9                	jns    585 <printint+0x86>
}
 5ac:	90                   	nop
 5ad:	90                   	nop
 5ae:	c9                   	leave  
 5af:	c3                   	ret    

000005b0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5b0:	55                   	push   %ebp
 5b1:	89 e5                	mov    %esp,%ebp
 5b3:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5bd:	8d 45 0c             	lea    0xc(%ebp),%eax
 5c0:	83 c0 04             	add    $0x4,%eax
 5c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5cd:	e9 59 01 00 00       	jmp    72b <printf+0x17b>
    c = fmt[i] & 0xff;
 5d2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d8:	01 d0                	add    %edx,%eax
 5da:	0f b6 00             	movzbl (%eax),%eax
 5dd:	0f be c0             	movsbl %al,%eax
 5e0:	25 ff 00 00 00       	and    $0xff,%eax
 5e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5e8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5ec:	75 2c                	jne    61a <printf+0x6a>
      if(c == '%'){
 5ee:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5f2:	75 0c                	jne    600 <printf+0x50>
        state = '%';
 5f4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5fb:	e9 27 01 00 00       	jmp    727 <printf+0x177>
      } else {
        putc(fd, c);
 600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 603:	0f be c0             	movsbl %al,%eax
 606:	83 ec 08             	sub    $0x8,%esp
 609:	50                   	push   %eax
 60a:	ff 75 08             	push   0x8(%ebp)
 60d:	e8 ca fe ff ff       	call   4dc <putc>
 612:	83 c4 10             	add    $0x10,%esp
 615:	e9 0d 01 00 00       	jmp    727 <printf+0x177>
      }
    } else if(state == '%'){
 61a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 61e:	0f 85 03 01 00 00    	jne    727 <printf+0x177>
      if(c == 'd'){
 624:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 628:	75 1e                	jne    648 <printf+0x98>
        printint(fd, *ap, 10, 1);
 62a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 62d:	8b 00                	mov    (%eax),%eax
 62f:	6a 01                	push   $0x1
 631:	6a 0a                	push   $0xa
 633:	50                   	push   %eax
 634:	ff 75 08             	push   0x8(%ebp)
 637:	e8 c3 fe ff ff       	call   4ff <printint>
 63c:	83 c4 10             	add    $0x10,%esp
        ap++;
 63f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 643:	e9 d8 00 00 00       	jmp    720 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 648:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 64c:	74 06                	je     654 <printf+0xa4>
 64e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 652:	75 1e                	jne    672 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 654:	8b 45 e8             	mov    -0x18(%ebp),%eax
 657:	8b 00                	mov    (%eax),%eax
 659:	6a 00                	push   $0x0
 65b:	6a 10                	push   $0x10
 65d:	50                   	push   %eax
 65e:	ff 75 08             	push   0x8(%ebp)
 661:	e8 99 fe ff ff       	call   4ff <printint>
 666:	83 c4 10             	add    $0x10,%esp
        ap++;
 669:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 66d:	e9 ae 00 00 00       	jmp    720 <printf+0x170>
      } else if(c == 's'){
 672:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 676:	75 43                	jne    6bb <printf+0x10b>
        s = (char*)*ap;
 678:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67b:	8b 00                	mov    (%eax),%eax
 67d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 680:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 684:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 688:	75 25                	jne    6af <printf+0xff>
          s = "(null)";
 68a:	c7 45 f4 9f 09 00 00 	movl   $0x99f,-0xc(%ebp)
        while(*s != 0){
 691:	eb 1c                	jmp    6af <printf+0xff>
          putc(fd, *s);
 693:	8b 45 f4             	mov    -0xc(%ebp),%eax
 696:	0f b6 00             	movzbl (%eax),%eax
 699:	0f be c0             	movsbl %al,%eax
 69c:	83 ec 08             	sub    $0x8,%esp
 69f:	50                   	push   %eax
 6a0:	ff 75 08             	push   0x8(%ebp)
 6a3:	e8 34 fe ff ff       	call   4dc <putc>
 6a8:	83 c4 10             	add    $0x10,%esp
          s++;
 6ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 6af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b2:	0f b6 00             	movzbl (%eax),%eax
 6b5:	84 c0                	test   %al,%al
 6b7:	75 da                	jne    693 <printf+0xe3>
 6b9:	eb 65                	jmp    720 <printf+0x170>
        }
      } else if(c == 'c'){
 6bb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6bf:	75 1d                	jne    6de <printf+0x12e>
        putc(fd, *ap);
 6c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c4:	8b 00                	mov    (%eax),%eax
 6c6:	0f be c0             	movsbl %al,%eax
 6c9:	83 ec 08             	sub    $0x8,%esp
 6cc:	50                   	push   %eax
 6cd:	ff 75 08             	push   0x8(%ebp)
 6d0:	e8 07 fe ff ff       	call   4dc <putc>
 6d5:	83 c4 10             	add    $0x10,%esp
        ap++;
 6d8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6dc:	eb 42                	jmp    720 <printf+0x170>
      } else if(c == '%'){
 6de:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6e2:	75 17                	jne    6fb <printf+0x14b>
        putc(fd, c);
 6e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e7:	0f be c0             	movsbl %al,%eax
 6ea:	83 ec 08             	sub    $0x8,%esp
 6ed:	50                   	push   %eax
 6ee:	ff 75 08             	push   0x8(%ebp)
 6f1:	e8 e6 fd ff ff       	call   4dc <putc>
 6f6:	83 c4 10             	add    $0x10,%esp
 6f9:	eb 25                	jmp    720 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6fb:	83 ec 08             	sub    $0x8,%esp
 6fe:	6a 25                	push   $0x25
 700:	ff 75 08             	push   0x8(%ebp)
 703:	e8 d4 fd ff ff       	call   4dc <putc>
 708:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 70b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 70e:	0f be c0             	movsbl %al,%eax
 711:	83 ec 08             	sub    $0x8,%esp
 714:	50                   	push   %eax
 715:	ff 75 08             	push   0x8(%ebp)
 718:	e8 bf fd ff ff       	call   4dc <putc>
 71d:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 720:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 727:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 72b:	8b 55 0c             	mov    0xc(%ebp),%edx
 72e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 731:	01 d0                	add    %edx,%eax
 733:	0f b6 00             	movzbl (%eax),%eax
 736:	84 c0                	test   %al,%al
 738:	0f 85 94 fe ff ff    	jne    5d2 <printf+0x22>
    }
  }
}
 73e:	90                   	nop
 73f:	90                   	nop
 740:	c9                   	leave  
 741:	c3                   	ret    

00000742 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 742:	55                   	push   %ebp
 743:	89 e5                	mov    %esp,%ebp
 745:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 748:	8b 45 08             	mov    0x8(%ebp),%eax
 74b:	83 e8 08             	sub    $0x8,%eax
 74e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 751:	a1 48 0e 00 00       	mov    0xe48,%eax
 756:	89 45 fc             	mov    %eax,-0x4(%ebp)
 759:	eb 24                	jmp    77f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75e:	8b 00                	mov    (%eax),%eax
 760:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 763:	72 12                	jb     777 <free+0x35>
 765:	8b 45 f8             	mov    -0x8(%ebp),%eax
 768:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 76b:	77 24                	ja     791 <free+0x4f>
 76d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 770:	8b 00                	mov    (%eax),%eax
 772:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 775:	72 1a                	jb     791 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	8b 00                	mov    (%eax),%eax
 77c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 77f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 782:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 785:	76 d4                	jbe    75b <free+0x19>
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	8b 00                	mov    (%eax),%eax
 78c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 78f:	73 ca                	jae    75b <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 791:	8b 45 f8             	mov    -0x8(%ebp),%eax
 794:	8b 40 04             	mov    0x4(%eax),%eax
 797:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 79e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a1:	01 c2                	add    %eax,%edx
 7a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a6:	8b 00                	mov    (%eax),%eax
 7a8:	39 c2                	cmp    %eax,%edx
 7aa:	75 24                	jne    7d0 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7af:	8b 50 04             	mov    0x4(%eax),%edx
 7b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b5:	8b 00                	mov    (%eax),%eax
 7b7:	8b 40 04             	mov    0x4(%eax),%eax
 7ba:	01 c2                	add    %eax,%edx
 7bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bf:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c5:	8b 00                	mov    (%eax),%eax
 7c7:	8b 10                	mov    (%eax),%edx
 7c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7cc:	89 10                	mov    %edx,(%eax)
 7ce:	eb 0a                	jmp    7da <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d3:	8b 10                	mov    (%eax),%edx
 7d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d8:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dd:	8b 40 04             	mov    0x4(%eax),%eax
 7e0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ea:	01 d0                	add    %edx,%eax
 7ec:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7ef:	75 20                	jne    811 <free+0xcf>
    p->s.size += bp->s.size;
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8b 50 04             	mov    0x4(%eax),%edx
 7f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fa:	8b 40 04             	mov    0x4(%eax),%eax
 7fd:	01 c2                	add    %eax,%edx
 7ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 802:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 805:	8b 45 f8             	mov    -0x8(%ebp),%eax
 808:	8b 10                	mov    (%eax),%edx
 80a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80d:	89 10                	mov    %edx,(%eax)
 80f:	eb 08                	jmp    819 <free+0xd7>
  } else
    p->s.ptr = bp;
 811:	8b 45 fc             	mov    -0x4(%ebp),%eax
 814:	8b 55 f8             	mov    -0x8(%ebp),%edx
 817:	89 10                	mov    %edx,(%eax)
  freep = p;
 819:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81c:	a3 48 0e 00 00       	mov    %eax,0xe48
}
 821:	90                   	nop
 822:	c9                   	leave  
 823:	c3                   	ret    

00000824 <morecore>:

static Header*
morecore(uint nu)
{
 824:	55                   	push   %ebp
 825:	89 e5                	mov    %esp,%ebp
 827:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 82a:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 831:	77 07                	ja     83a <morecore+0x16>
    nu = 4096;
 833:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 83a:	8b 45 08             	mov    0x8(%ebp),%eax
 83d:	c1 e0 03             	shl    $0x3,%eax
 840:	83 ec 0c             	sub    $0xc,%esp
 843:	50                   	push   %eax
 844:	e8 53 fc ff ff       	call   49c <sbrk>
 849:	83 c4 10             	add    $0x10,%esp
 84c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 84f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 853:	75 07                	jne    85c <morecore+0x38>
    return 0;
 855:	b8 00 00 00 00       	mov    $0x0,%eax
 85a:	eb 26                	jmp    882 <morecore+0x5e>
  hp = (Header*)p;
 85c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 862:	8b 45 f0             	mov    -0x10(%ebp),%eax
 865:	8b 55 08             	mov    0x8(%ebp),%edx
 868:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 86b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86e:	83 c0 08             	add    $0x8,%eax
 871:	83 ec 0c             	sub    $0xc,%esp
 874:	50                   	push   %eax
 875:	e8 c8 fe ff ff       	call   742 <free>
 87a:	83 c4 10             	add    $0x10,%esp
  return freep;
 87d:	a1 48 0e 00 00       	mov    0xe48,%eax
}
 882:	c9                   	leave  
 883:	c3                   	ret    

00000884 <malloc>:

void*
malloc(uint nbytes)
{
 884:	55                   	push   %ebp
 885:	89 e5                	mov    %esp,%ebp
 887:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 88a:	8b 45 08             	mov    0x8(%ebp),%eax
 88d:	83 c0 07             	add    $0x7,%eax
 890:	c1 e8 03             	shr    $0x3,%eax
 893:	83 c0 01             	add    $0x1,%eax
 896:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 899:	a1 48 0e 00 00       	mov    0xe48,%eax
 89e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8a5:	75 23                	jne    8ca <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8a7:	c7 45 f0 40 0e 00 00 	movl   $0xe40,-0x10(%ebp)
 8ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b1:	a3 48 0e 00 00       	mov    %eax,0xe48
 8b6:	a1 48 0e 00 00       	mov    0xe48,%eax
 8bb:	a3 40 0e 00 00       	mov    %eax,0xe40
    base.s.size = 0;
 8c0:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
 8c7:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cd:	8b 00                	mov    (%eax),%eax
 8cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d5:	8b 40 04             	mov    0x4(%eax),%eax
 8d8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8db:	77 4d                	ja     92a <malloc+0xa6>
      if(p->s.size == nunits)
 8dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e0:	8b 40 04             	mov    0x4(%eax),%eax
 8e3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8e6:	75 0c                	jne    8f4 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8eb:	8b 10                	mov    (%eax),%edx
 8ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f0:	89 10                	mov    %edx,(%eax)
 8f2:	eb 26                	jmp    91a <malloc+0x96>
      else {
        p->s.size -= nunits;
 8f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f7:	8b 40 04             	mov    0x4(%eax),%eax
 8fa:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8fd:	89 c2                	mov    %eax,%edx
 8ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 902:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 905:	8b 45 f4             	mov    -0xc(%ebp),%eax
 908:	8b 40 04             	mov    0x4(%eax),%eax
 90b:	c1 e0 03             	shl    $0x3,%eax
 90e:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	8b 55 ec             	mov    -0x14(%ebp),%edx
 917:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 91a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91d:	a3 48 0e 00 00       	mov    %eax,0xe48
      return (void*)(p + 1);
 922:	8b 45 f4             	mov    -0xc(%ebp),%eax
 925:	83 c0 08             	add    $0x8,%eax
 928:	eb 3b                	jmp    965 <malloc+0xe1>
    }
    if(p == freep)
 92a:	a1 48 0e 00 00       	mov    0xe48,%eax
 92f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 932:	75 1e                	jne    952 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 934:	83 ec 0c             	sub    $0xc,%esp
 937:	ff 75 ec             	push   -0x14(%ebp)
 93a:	e8 e5 fe ff ff       	call   824 <morecore>
 93f:	83 c4 10             	add    $0x10,%esp
 942:	89 45 f4             	mov    %eax,-0xc(%ebp)
 945:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 949:	75 07                	jne    952 <malloc+0xce>
        return 0;
 94b:	b8 00 00 00 00       	mov    $0x0,%eax
 950:	eb 13                	jmp    965 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 952:	8b 45 f4             	mov    -0xc(%ebp),%eax
 955:	89 45 f0             	mov    %eax,-0x10(%ebp)
 958:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95b:	8b 00                	mov    (%eax),%eax
 95d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 960:	e9 6d ff ff ff       	jmp    8d2 <malloc+0x4e>
  }
}
 965:	c9                   	leave  
 966:	c3                   	ret    
