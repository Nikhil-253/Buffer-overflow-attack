
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 00 79 11 80       	mov    $0x80117900,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 12 3c 10 80       	mov    $0x80103c12,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 60 92 10 80       	push   $0x80109260
80100042:	68 a0 c5 10 80       	push   $0x8010c5a0
80100047:	e8 7f 5c 00 00       	call   80105ccb <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 ec 0c 11 80 9c 	movl   $0x80110c9c,0x80110cec
80100056:	0c 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 f0 0c 11 80 9c 	movl   $0x80110c9c,0x80110cf0
80100060:	0c 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 d4 c5 10 80 	movl   $0x8010c5d4,-0xc(%ebp)
8010006a:	eb 47                	jmp    801000b3 <binit+0x7f>
    b->next = bcache.head.next;
8010006c:	8b 15 f0 0c 11 80    	mov    0x80110cf0,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 50 9c 0c 11 80 	movl   $0x80110c9c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	83 c0 0c             	add    $0xc,%eax
80100088:	83 ec 08             	sub    $0x8,%esp
8010008b:	68 67 92 10 80       	push   $0x80109267
80100090:	50                   	push   %eax
80100091:	e8 b2 5a 00 00       	call   80105b48 <initsleeplock>
80100096:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
80100099:	a1 f0 0c 11 80       	mov    0x80110cf0,%eax
8010009e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	a3 f0 0c 11 80       	mov    %eax,0x80110cf0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000ac:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b3:	b8 9c 0c 11 80       	mov    $0x80110c9c,%eax
801000b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bb:	72 af                	jb     8010006c <binit+0x38>
  }
}
801000bd:	90                   	nop
801000be:	90                   	nop
801000bf:	c9                   	leave  
801000c0:	c3                   	ret    

801000c1 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c1:	55                   	push   %ebp
801000c2:	89 e5                	mov    %esp,%ebp
801000c4:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c7:	83 ec 0c             	sub    $0xc,%esp
801000ca:	68 a0 c5 10 80       	push   $0x8010c5a0
801000cf:	e8 19 5c 00 00       	call   80105ced <acquire>
801000d4:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000d7:	a1 f0 0c 11 80       	mov    0x80110cf0,%eax
801000dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000df:	eb 58                	jmp    80100139 <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
801000e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e4:	8b 40 04             	mov    0x4(%eax),%eax
801000e7:	39 45 08             	cmp    %eax,0x8(%ebp)
801000ea:	75 44                	jne    80100130 <bget+0x6f>
801000ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ef:	8b 40 08             	mov    0x8(%eax),%eax
801000f2:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000f5:	75 39                	jne    80100130 <bget+0x6f>
      b->refcnt++;
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	8b 40 4c             	mov    0x4c(%eax),%eax
801000fd:	8d 50 01             	lea    0x1(%eax),%edx
80100100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100103:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100106:	83 ec 0c             	sub    $0xc,%esp
80100109:	68 a0 c5 10 80       	push   $0x8010c5a0
8010010e:	e8 48 5c 00 00       	call   80105d5b <release>
80100113:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100119:	83 c0 0c             	add    $0xc,%eax
8010011c:	83 ec 0c             	sub    $0xc,%esp
8010011f:	50                   	push   %eax
80100120:	e8 5f 5a 00 00       	call   80105b84 <acquiresleep>
80100125:	83 c4 10             	add    $0x10,%esp
      return b;
80100128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012b:	e9 9d 00 00 00       	jmp    801001cd <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	8b 40 54             	mov    0x54(%eax),%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	81 7d f4 9c 0c 11 80 	cmpl   $0x80110c9c,-0xc(%ebp)
80100140:	75 9f                	jne    801000e1 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100142:	a1 ec 0c 11 80       	mov    0x80110cec,%eax
80100147:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014a:	eb 6b                	jmp    801001b7 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010014c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014f:	8b 40 4c             	mov    0x4c(%eax),%eax
80100152:	85 c0                	test   %eax,%eax
80100154:	75 58                	jne    801001ae <bget+0xed>
80100156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100159:	8b 00                	mov    (%eax),%eax
8010015b:	83 e0 04             	and    $0x4,%eax
8010015e:	85 c0                	test   %eax,%eax
80100160:	75 4c                	jne    801001ae <bget+0xed>
      b->dev = dev;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 55 08             	mov    0x8(%ebp),%edx
80100168:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016e:	8b 55 0c             	mov    0xc(%ebp),%edx
80100171:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100177:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010017d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100180:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100187:	83 ec 0c             	sub    $0xc,%esp
8010018a:	68 a0 c5 10 80       	push   $0x8010c5a0
8010018f:	e8 c7 5b 00 00       	call   80105d5b <release>
80100194:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019a:	83 c0 0c             	add    $0xc,%eax
8010019d:	83 ec 0c             	sub    $0xc,%esp
801001a0:	50                   	push   %eax
801001a1:	e8 de 59 00 00       	call   80105b84 <acquiresleep>
801001a6:	83 c4 10             	add    $0x10,%esp
      return b;
801001a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ac:	eb 1f                	jmp    801001cd <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b1:	8b 40 50             	mov    0x50(%eax),%eax
801001b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b7:	81 7d f4 9c 0c 11 80 	cmpl   $0x80110c9c,-0xc(%ebp)
801001be:	75 8c                	jne    8010014c <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001c0:	83 ec 0c             	sub    $0xc,%esp
801001c3:	68 6e 92 10 80       	push   $0x8010926e
801001c8:	e8 e8 03 00 00       	call   801005b5 <panic>
}
801001cd:	c9                   	leave  
801001ce:	c3                   	ret    

801001cf <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001cf:	55                   	push   %ebp
801001d0:	89 e5                	mov    %esp,%ebp
801001d2:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001d5:	83 ec 08             	sub    $0x8,%esp
801001d8:	ff 75 0c             	push   0xc(%ebp)
801001db:	ff 75 08             	push   0x8(%ebp)
801001de:	e8 de fe ff ff       	call   801000c1 <bget>
801001e3:	83 c4 10             	add    $0x10,%esp
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ec:	8b 00                	mov    (%eax),%eax
801001ee:	83 e0 02             	and    $0x2,%eax
801001f1:	85 c0                	test   %eax,%eax
801001f3:	75 0e                	jne    80100203 <bread+0x34>
    iderw(b);
801001f5:	83 ec 0c             	sub    $0xc,%esp
801001f8:	ff 75 f4             	push   -0xc(%ebp)
801001fb:	e8 12 2b 00 00       	call   80102d12 <iderw>
80100200:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100203:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100206:	c9                   	leave  
80100207:	c3                   	ret    

80100208 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100208:	55                   	push   %ebp
80100209:	89 e5                	mov    %esp,%ebp
8010020b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	83 c0 0c             	add    $0xc,%eax
80100214:	83 ec 0c             	sub    $0xc,%esp
80100217:	50                   	push   %eax
80100218:	e8 19 5a 00 00       	call   80105c36 <holdingsleep>
8010021d:	83 c4 10             	add    $0x10,%esp
80100220:	85 c0                	test   %eax,%eax
80100222:	75 0d                	jne    80100231 <bwrite+0x29>
    panic("bwrite");
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	68 7f 92 10 80       	push   $0x8010927f
8010022c:	e8 84 03 00 00       	call   801005b5 <panic>
  b->flags |= B_DIRTY;
80100231:	8b 45 08             	mov    0x8(%ebp),%eax
80100234:	8b 00                	mov    (%eax),%eax
80100236:	83 c8 04             	or     $0x4,%eax
80100239:	89 c2                	mov    %eax,%edx
8010023b:	8b 45 08             	mov    0x8(%ebp),%eax
8010023e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	ff 75 08             	push   0x8(%ebp)
80100246:	e8 c7 2a 00 00       	call   80102d12 <iderw>
8010024b:	83 c4 10             	add    $0x10,%esp
}
8010024e:	90                   	nop
8010024f:	c9                   	leave  
80100250:	c3                   	ret    

80100251 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100251:	55                   	push   %ebp
80100252:	89 e5                	mov    %esp,%ebp
80100254:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100257:	8b 45 08             	mov    0x8(%ebp),%eax
8010025a:	83 c0 0c             	add    $0xc,%eax
8010025d:	83 ec 0c             	sub    $0xc,%esp
80100260:	50                   	push   %eax
80100261:	e8 d0 59 00 00       	call   80105c36 <holdingsleep>
80100266:	83 c4 10             	add    $0x10,%esp
80100269:	85 c0                	test   %eax,%eax
8010026b:	75 0d                	jne    8010027a <brelse+0x29>
    panic("brelse");
8010026d:	83 ec 0c             	sub    $0xc,%esp
80100270:	68 86 92 10 80       	push   $0x80109286
80100275:	e8 3b 03 00 00       	call   801005b5 <panic>

  releasesleep(&b->lock);
8010027a:	8b 45 08             	mov    0x8(%ebp),%eax
8010027d:	83 c0 0c             	add    $0xc,%eax
80100280:	83 ec 0c             	sub    $0xc,%esp
80100283:	50                   	push   %eax
80100284:	e8 5f 59 00 00       	call   80105be8 <releasesleep>
80100289:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028c:	83 ec 0c             	sub    $0xc,%esp
8010028f:	68 a0 c5 10 80       	push   $0x8010c5a0
80100294:	e8 54 5a 00 00       	call   80105ced <acquire>
80100299:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	8b 40 4c             	mov    0x4c(%eax),%eax
801002a2:	8d 50 ff             	lea    -0x1(%eax),%edx
801002a5:	8b 45 08             	mov    0x8(%ebp),%eax
801002a8:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002ab:	8b 45 08             	mov    0x8(%ebp),%eax
801002ae:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b1:	85 c0                	test   %eax,%eax
801002b3:	75 47                	jne    801002fc <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002b5:	8b 45 08             	mov    0x8(%ebp),%eax
801002b8:	8b 40 54             	mov    0x54(%eax),%eax
801002bb:	8b 55 08             	mov    0x8(%ebp),%edx
801002be:	8b 52 50             	mov    0x50(%edx),%edx
801002c1:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002c4:	8b 45 08             	mov    0x8(%ebp),%eax
801002c7:	8b 40 50             	mov    0x50(%eax),%eax
801002ca:	8b 55 08             	mov    0x8(%ebp),%edx
801002cd:	8b 52 54             	mov    0x54(%edx),%edx
801002d0:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002d3:	8b 15 f0 0c 11 80    	mov    0x80110cf0,%edx
801002d9:	8b 45 08             	mov    0x8(%ebp),%eax
801002dc:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002df:	8b 45 08             	mov    0x8(%ebp),%eax
801002e2:	c7 40 50 9c 0c 11 80 	movl   $0x80110c9c,0x50(%eax)
    bcache.head.next->prev = b;
801002e9:	a1 f0 0c 11 80       	mov    0x80110cf0,%eax
801002ee:	8b 55 08             	mov    0x8(%ebp),%edx
801002f1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002f4:	8b 45 08             	mov    0x8(%ebp),%eax
801002f7:	a3 f0 0c 11 80       	mov    %eax,0x80110cf0
  }
  
  release(&bcache.lock);
801002fc:	83 ec 0c             	sub    $0xc,%esp
801002ff:	68 a0 c5 10 80       	push   $0x8010c5a0
80100304:	e8 52 5a 00 00       	call   80105d5b <release>
80100309:	83 c4 10             	add    $0x10,%esp
}
8010030c:	90                   	nop
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
80100312:	83 ec 14             	sub    $0x14,%esp
80100315:	8b 45 08             	mov    0x8(%ebp),%eax
80100318:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010031c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100320:	89 c2                	mov    %eax,%edx
80100322:	ec                   	in     (%dx),%al
80100323:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100326:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010032a:	c9                   	leave  
8010032b:	c3                   	ret    

8010032c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010032c:	55                   	push   %ebp
8010032d:	89 e5                	mov    %esp,%ebp
8010032f:	83 ec 08             	sub    $0x8,%esp
80100332:	8b 45 08             	mov    0x8(%ebp),%eax
80100335:	8b 55 0c             	mov    0xc(%ebp),%edx
80100338:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010033c:	89 d0                	mov    %edx,%eax
8010033e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100341:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100345:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100349:	ee                   	out    %al,(%dx)
}
8010034a:	90                   	nop
8010034b:	c9                   	leave  
8010034c:	c3                   	ret    

8010034d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010034d:	55                   	push   %ebp
8010034e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100350:	fa                   	cli    
}
80100351:	90                   	nop
80100352:	5d                   	pop    %ebp
80100353:	c3                   	ret    

80100354 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100354:	55                   	push   %ebp
80100355:	89 e5                	mov    %esp,%ebp
80100357:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010035a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010035e:	74 1c                	je     8010037c <printint+0x28>
80100360:	8b 45 08             	mov    0x8(%ebp),%eax
80100363:	c1 e8 1f             	shr    $0x1f,%eax
80100366:	0f b6 c0             	movzbl %al,%eax
80100369:	89 45 10             	mov    %eax,0x10(%ebp)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 0a                	je     8010037c <printint+0x28>
    x = -xx;
80100372:	8b 45 08             	mov    0x8(%ebp),%eax
80100375:	f7 d8                	neg    %eax
80100377:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037a:	eb 06                	jmp    80100382 <printint+0x2e>
  else
    x = xx;
8010037c:	8b 45 08             	mov    0x8(%ebp),%eax
8010037f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010038c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010038f:	ba 00 00 00 00       	mov    $0x0,%edx
80100394:	f7 f1                	div    %ecx
80100396:	89 d1                	mov    %edx,%ecx
80100398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010039b:	8d 50 01             	lea    0x1(%eax),%edx
8010039e:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003a1:	0f b6 91 04 a0 10 80 	movzbl -0x7fef5ffc(%ecx),%edx
801003a8:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003b2:	ba 00 00 00 00       	mov    $0x0,%edx
801003b7:	f7 f1                	div    %ecx
801003b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003c0:	75 c7                	jne    80100389 <printint+0x35>

  if(sign)
801003c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003c6:	74 2a                	je     801003f2 <printint+0x9e>
    buf[i++] = '-';
801003c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003cb:	8d 50 01             	lea    0x1(%eax),%edx
801003ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003d1:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003d6:	eb 1a                	jmp    801003f2 <printint+0x9e>
    consputc(buf[i]);
801003d8:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003de:	01 d0                	add    %edx,%eax
801003e0:	0f b6 00             	movzbl (%eax),%eax
801003e3:	0f be c0             	movsbl %al,%eax
801003e6:	83 ec 0c             	sub    $0xc,%esp
801003e9:	50                   	push   %eax
801003ea:	e8 f9 03 00 00       	call   801007e8 <consputc>
801003ef:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003f2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003fa:	79 dc                	jns    801003d8 <printint+0x84>
}
801003fc:	90                   	nop
801003fd:	90                   	nop
801003fe:	c9                   	leave  
801003ff:	c3                   	ret    

80100400 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100406:	a1 d4 0f 11 80       	mov    0x80110fd4,%eax
8010040b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010040e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100412:	74 10                	je     80100424 <cprintf+0x24>
    acquire(&cons.lock);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	68 a0 0f 11 80       	push   $0x80110fa0
8010041c:	e8 cc 58 00 00       	call   80105ced <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 8d 92 10 80       	push   $0x8010928d
80100433:	e8 7d 01 00 00       	call   801005b5 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100438:	8d 45 0c             	lea    0xc(%ebp),%eax
8010043b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010043e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100445:	e9 2f 01 00 00       	jmp    80100579 <cprintf+0x179>
    if(c != '%'){
8010044a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010044e:	74 13                	je     80100463 <cprintf+0x63>
      consputc(c);
80100450:	83 ec 0c             	sub    $0xc,%esp
80100453:	ff 75 e4             	push   -0x1c(%ebp)
80100456:	e8 8d 03 00 00       	call   801007e8 <consputc>
8010045b:	83 c4 10             	add    $0x10,%esp
      continue;
8010045e:	e9 12 01 00 00       	jmp    80100575 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100463:	8b 55 08             	mov    0x8(%ebp),%edx
80100466:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010046a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010046d:	01 d0                	add    %edx,%eax
8010046f:	0f b6 00             	movzbl (%eax),%eax
80100472:	0f be c0             	movsbl %al,%eax
80100475:	25 ff 00 00 00       	and    $0xff,%eax
8010047a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010047d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100481:	0f 84 14 01 00 00    	je     8010059b <cprintf+0x19b>
      break;
    switch(c){
80100487:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010048b:	74 5e                	je     801004eb <cprintf+0xeb>
8010048d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100491:	0f 8f c2 00 00 00    	jg     80100559 <cprintf+0x159>
80100497:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010049b:	74 6b                	je     80100508 <cprintf+0x108>
8010049d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004a1:	0f 8f b2 00 00 00    	jg     80100559 <cprintf+0x159>
801004a7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004ab:	74 3e                	je     801004eb <cprintf+0xeb>
801004ad:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004b1:	0f 8f a2 00 00 00    	jg     80100559 <cprintf+0x159>
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 89 00 00 00    	je     8010054a <cprintf+0x14a>
801004c1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004c5:	0f 85 8e 00 00 00    	jne    80100559 <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ce:	8d 50 04             	lea    0x4(%eax),%edx
801004d1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d4:	8b 00                	mov    (%eax),%eax
801004d6:	83 ec 04             	sub    $0x4,%esp
801004d9:	6a 01                	push   $0x1
801004db:	6a 0a                	push   $0xa
801004dd:	50                   	push   %eax
801004de:	e8 71 fe ff ff       	call   80100354 <printint>
801004e3:	83 c4 10             	add    $0x10,%esp
      break;
801004e6:	e9 8a 00 00 00       	jmp    80100575 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ee:	8d 50 04             	lea    0x4(%eax),%edx
801004f1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004f4:	8b 00                	mov    (%eax),%eax
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	6a 00                	push   $0x0
801004fb:	6a 10                	push   $0x10
801004fd:	50                   	push   %eax
801004fe:	e8 51 fe ff ff       	call   80100354 <printint>
80100503:	83 c4 10             	add    $0x10,%esp
      break;
80100506:	eb 6d                	jmp    80100575 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
80100508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010050b:	8d 50 04             	lea    0x4(%eax),%edx
8010050e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100511:	8b 00                	mov    (%eax),%eax
80100513:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100516:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010051a:	75 22                	jne    8010053e <cprintf+0x13e>
        s = "(null)";
8010051c:	c7 45 ec 96 92 10 80 	movl   $0x80109296,-0x14(%ebp)
      for(; *s; s++)
80100523:	eb 19                	jmp    8010053e <cprintf+0x13e>
        consputc(*s);
80100525:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100528:	0f b6 00             	movzbl (%eax),%eax
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	83 ec 0c             	sub    $0xc,%esp
80100531:	50                   	push   %eax
80100532:	e8 b1 02 00 00       	call   801007e8 <consputc>
80100537:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010053a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010053e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100541:	0f b6 00             	movzbl (%eax),%eax
80100544:	84 c0                	test   %al,%al
80100546:	75 dd                	jne    80100525 <cprintf+0x125>
      break;
80100548:	eb 2b                	jmp    80100575 <cprintf+0x175>
    case '%':
      consputc('%');
8010054a:	83 ec 0c             	sub    $0xc,%esp
8010054d:	6a 25                	push   $0x25
8010054f:	e8 94 02 00 00       	call   801007e8 <consputc>
80100554:	83 c4 10             	add    $0x10,%esp
      break;
80100557:	eb 1c                	jmp    80100575 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100559:	83 ec 0c             	sub    $0xc,%esp
8010055c:	6a 25                	push   $0x25
8010055e:	e8 85 02 00 00       	call   801007e8 <consputc>
80100563:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100566:	83 ec 0c             	sub    $0xc,%esp
80100569:	ff 75 e4             	push   -0x1c(%ebp)
8010056c:	e8 77 02 00 00       	call   801007e8 <consputc>
80100571:	83 c4 10             	add    $0x10,%esp
      break;
80100574:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100575:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100579:	8b 55 08             	mov    0x8(%ebp),%edx
8010057c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010057f:	01 d0                	add    %edx,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f be c0             	movsbl %al,%eax
80100587:	25 ff 00 00 00       	and    $0xff,%eax
8010058c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010058f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100593:	0f 85 b1 fe ff ff    	jne    8010044a <cprintf+0x4a>
80100599:	eb 01                	jmp    8010059c <cprintf+0x19c>
      break;
8010059b:	90                   	nop
    }
  }

  if(locking)
8010059c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005a0:	74 10                	je     801005b2 <cprintf+0x1b2>
    release(&cons.lock);
801005a2:	83 ec 0c             	sub    $0xc,%esp
801005a5:	68 a0 0f 11 80       	push   $0x80110fa0
801005aa:	e8 ac 57 00 00       	call   80105d5b <release>
801005af:	83 c4 10             	add    $0x10,%esp
}
801005b2:	90                   	nop
801005b3:	c9                   	leave  
801005b4:	c3                   	ret    

801005b5 <panic>:

void
panic(char *s)
{
801005b5:	55                   	push   %ebp
801005b6:	89 e5                	mov    %esp,%ebp
801005b8:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005bb:	e8 8d fd ff ff       	call   8010034d <cli>
  cons.locking = 0;
801005c0:	c7 05 d4 0f 11 80 00 	movl   $0x0,0x80110fd4
801005c7:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005ca:	e8 d8 2d 00 00       	call   801033a7 <lapicid>
801005cf:	83 ec 08             	sub    $0x8,%esp
801005d2:	50                   	push   %eax
801005d3:	68 9d 92 10 80       	push   $0x8010929d
801005d8:	e8 23 fe ff ff       	call   80100400 <cprintf>
801005dd:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005e0:	8b 45 08             	mov    0x8(%ebp),%eax
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	50                   	push   %eax
801005e7:	e8 14 fe ff ff       	call   80100400 <cprintf>
801005ec:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005ef:	83 ec 0c             	sub    $0xc,%esp
801005f2:	68 b1 92 10 80       	push   $0x801092b1
801005f7:	e8 04 fe ff ff       	call   80100400 <cprintf>
801005fc:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ff:	83 ec 08             	sub    $0x8,%esp
80100602:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100605:	50                   	push   %eax
80100606:	8d 45 08             	lea    0x8(%ebp),%eax
80100609:	50                   	push   %eax
8010060a:	e8 9e 57 00 00       	call   80105dad <getcallerpcs>
8010060f:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100612:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100619:	eb 1c                	jmp    80100637 <panic+0x82>
    cprintf(" %p", pcs[i]);
8010061b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010061e:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100622:	83 ec 08             	sub    $0x8,%esp
80100625:	50                   	push   %eax
80100626:	68 b3 92 10 80       	push   $0x801092b3
8010062b:	e8 d0 fd ff ff       	call   80100400 <cprintf>
80100630:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100633:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100637:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010063b:	7e de                	jle    8010061b <panic+0x66>
  panicked = 1; // freeze other CPU
8010063d:	c7 05 8c 0f 11 80 01 	movl   $0x1,0x80110f8c
80100644:	00 00 00 
  for(;;)
80100647:	eb fe                	jmp    80100647 <panic+0x92>

80100649 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100649:	55                   	push   %ebp
8010064a:	89 e5                	mov    %esp,%ebp
8010064c:	53                   	push   %ebx
8010064d:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100650:	6a 0e                	push   $0xe
80100652:	68 d4 03 00 00       	push   $0x3d4
80100657:	e8 d0 fc ff ff       	call   8010032c <outb>
8010065c:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010065f:	68 d5 03 00 00       	push   $0x3d5
80100664:	e8 a6 fc ff ff       	call   8010030f <inb>
80100669:	83 c4 04             	add    $0x4,%esp
8010066c:	0f b6 c0             	movzbl %al,%eax
8010066f:	c1 e0 08             	shl    $0x8,%eax
80100672:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100675:	6a 0f                	push   $0xf
80100677:	68 d4 03 00 00       	push   $0x3d4
8010067c:	e8 ab fc ff ff       	call   8010032c <outb>
80100681:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100684:	68 d5 03 00 00       	push   $0x3d5
80100689:	e8 81 fc ff ff       	call   8010030f <inb>
8010068e:	83 c4 04             	add    $0x4,%esp
80100691:	0f b6 c0             	movzbl %al,%eax
80100694:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100697:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010069b:	75 34                	jne    801006d1 <cgaputc+0x88>
    pos += 80 - pos%80;
8010069d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006a0:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006a5:	89 c8                	mov    %ecx,%eax
801006a7:	f7 ea                	imul   %edx
801006a9:	89 d0                	mov    %edx,%eax
801006ab:	c1 f8 05             	sar    $0x5,%eax
801006ae:	89 cb                	mov    %ecx,%ebx
801006b0:	c1 fb 1f             	sar    $0x1f,%ebx
801006b3:	29 d8                	sub    %ebx,%eax
801006b5:	89 c2                	mov    %eax,%edx
801006b7:	89 d0                	mov    %edx,%eax
801006b9:	c1 e0 02             	shl    $0x2,%eax
801006bc:	01 d0                	add    %edx,%eax
801006be:	c1 e0 04             	shl    $0x4,%eax
801006c1:	29 c1                	sub    %eax,%ecx
801006c3:	89 ca                	mov    %ecx,%edx
801006c5:	b8 50 00 00 00       	mov    $0x50,%eax
801006ca:	29 d0                	sub    %edx,%eax
801006cc:	01 45 f4             	add    %eax,-0xc(%ebp)
801006cf:	eb 38                	jmp    80100709 <cgaputc+0xc0>
  else if(c == BACKSPACE){
801006d1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006d8:	75 0c                	jne    801006e6 <cgaputc+0x9d>
    if(pos > 0) --pos;
801006da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006de:	7e 29                	jle    80100709 <cgaputc+0xc0>
801006e0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006e4:	eb 23                	jmp    80100709 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006e6:	8b 45 08             	mov    0x8(%ebp),%eax
801006e9:	0f b6 c0             	movzbl %al,%eax
801006ec:	80 cc 07             	or     $0x7,%ah
801006ef:	89 c1                	mov    %eax,%ecx
801006f1:	8b 1d 00 a0 10 80    	mov    0x8010a000,%ebx
801006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fa:	8d 50 01             	lea    0x1(%eax),%edx
801006fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100700:	01 c0                	add    %eax,%eax
80100702:	01 d8                	add    %ebx,%eax
80100704:	89 ca                	mov    %ecx,%edx
80100706:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100709:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010070d:	78 09                	js     80100718 <cgaputc+0xcf>
8010070f:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100716:	7e 0d                	jle    80100725 <cgaputc+0xdc>
    panic("pos under/overflow");
80100718:	83 ec 0c             	sub    $0xc,%esp
8010071b:	68 b7 92 10 80       	push   $0x801092b7
80100720:	e8 90 fe ff ff       	call   801005b5 <panic>

  if((pos/80) >= 24){  // Scroll up.
80100725:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010072c:	7e 4d                	jle    8010077b <cgaputc+0x132>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010072e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100733:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100739:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010073e:	83 ec 04             	sub    $0x4,%esp
80100741:	68 60 0e 00 00       	push   $0xe60
80100746:	52                   	push   %edx
80100747:	50                   	push   %eax
80100748:	e8 e5 58 00 00       	call   80106032 <memmove>
8010074d:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100750:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100754:	b8 80 07 00 00       	mov    $0x780,%eax
80100759:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010075c:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010075f:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
80100765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100768:	01 c0                	add    %eax,%eax
8010076a:	01 c8                	add    %ecx,%eax
8010076c:	83 ec 04             	sub    $0x4,%esp
8010076f:	52                   	push   %edx
80100770:	6a 00                	push   $0x0
80100772:	50                   	push   %eax
80100773:	e8 fb 57 00 00       	call   80105f73 <memset>
80100778:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
8010077b:	83 ec 08             	sub    $0x8,%esp
8010077e:	6a 0e                	push   $0xe
80100780:	68 d4 03 00 00       	push   $0x3d4
80100785:	e8 a2 fb ff ff       	call   8010032c <outb>
8010078a:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100790:	c1 f8 08             	sar    $0x8,%eax
80100793:	0f b6 c0             	movzbl %al,%eax
80100796:	83 ec 08             	sub    $0x8,%esp
80100799:	50                   	push   %eax
8010079a:	68 d5 03 00 00       	push   $0x3d5
8010079f:	e8 88 fb ff ff       	call   8010032c <outb>
801007a4:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007a7:	83 ec 08             	sub    $0x8,%esp
801007aa:	6a 0f                	push   $0xf
801007ac:	68 d4 03 00 00       	push   $0x3d4
801007b1:	e8 76 fb ff ff       	call   8010032c <outb>
801007b6:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
801007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007bc:	0f b6 c0             	movzbl %al,%eax
801007bf:	83 ec 08             	sub    $0x8,%esp
801007c2:	50                   	push   %eax
801007c3:	68 d5 03 00 00       	push   $0x3d5
801007c8:	e8 5f fb ff ff       	call   8010032c <outb>
801007cd:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
801007d0:	8b 15 00 a0 10 80    	mov    0x8010a000,%edx
801007d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007d9:	01 c0                	add    %eax,%eax
801007db:	01 d0                	add    %edx,%eax
801007dd:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007e2:	90                   	nop
801007e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007e6:	c9                   	leave  
801007e7:	c3                   	ret    

801007e8 <consputc>:

void
consputc(int c)
{
801007e8:	55                   	push   %ebp
801007e9:	89 e5                	mov    %esp,%ebp
801007eb:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007ee:	a1 8c 0f 11 80       	mov    0x80110f8c,%eax
801007f3:	85 c0                	test   %eax,%eax
801007f5:	74 07                	je     801007fe <consputc+0x16>
    cli();
801007f7:	e8 51 fb ff ff       	call   8010034d <cli>
    for(;;)
801007fc:	eb fe                	jmp    801007fc <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007fe:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100805:	75 29                	jne    80100830 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100807:	83 ec 0c             	sub    $0xc,%esp
8010080a:	6a 08                	push   $0x8
8010080c:	e8 01 72 00 00       	call   80107a12 <uartputc>
80100811:	83 c4 10             	add    $0x10,%esp
80100814:	83 ec 0c             	sub    $0xc,%esp
80100817:	6a 20                	push   $0x20
80100819:	e8 f4 71 00 00       	call   80107a12 <uartputc>
8010081e:	83 c4 10             	add    $0x10,%esp
80100821:	83 ec 0c             	sub    $0xc,%esp
80100824:	6a 08                	push   $0x8
80100826:	e8 e7 71 00 00       	call   80107a12 <uartputc>
8010082b:	83 c4 10             	add    $0x10,%esp
8010082e:	eb 0e                	jmp    8010083e <consputc+0x56>
  } else
    uartputc(c);
80100830:	83 ec 0c             	sub    $0xc,%esp
80100833:	ff 75 08             	push   0x8(%ebp)
80100836:	e8 d7 71 00 00       	call   80107a12 <uartputc>
8010083b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010083e:	83 ec 0c             	sub    $0xc,%esp
80100841:	ff 75 08             	push   0x8(%ebp)
80100844:	e8 00 fe ff ff       	call   80100649 <cgaputc>
80100849:	83 c4 10             	add    $0x10,%esp
}
8010084c:	90                   	nop
8010084d:	c9                   	leave  
8010084e:	c3                   	ret    

8010084f <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010084f:	55                   	push   %ebp
80100850:	89 e5                	mov    %esp,%ebp
80100852:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
8010085c:	83 ec 0c             	sub    $0xc,%esp
8010085f:	68 a0 0f 11 80       	push   $0x80110fa0
80100864:	e8 84 54 00 00       	call   80105ced <acquire>
80100869:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010086c:	e9 50 01 00 00       	jmp    801009c1 <consoleintr+0x172>
    switch(c){
80100871:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100875:	0f 84 81 00 00 00    	je     801008fc <consoleintr+0xad>
8010087b:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010087f:	0f 8f ac 00 00 00    	jg     80100931 <consoleintr+0xe2>
80100885:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100889:	74 43                	je     801008ce <consoleintr+0x7f>
8010088b:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010088f:	0f 8f 9c 00 00 00    	jg     80100931 <consoleintr+0xe2>
80100895:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100899:	74 61                	je     801008fc <consoleintr+0xad>
8010089b:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010089f:	0f 85 8c 00 00 00    	jne    80100931 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
801008a5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
801008ac:	e9 10 01 00 00       	jmp    801009c1 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008b1:	a1 88 0f 11 80       	mov    0x80110f88,%eax
801008b6:	83 e8 01             	sub    $0x1,%eax
801008b9:	a3 88 0f 11 80       	mov    %eax,0x80110f88
        consputc(BACKSPACE);
801008be:	83 ec 0c             	sub    $0xc,%esp
801008c1:	68 00 01 00 00       	push   $0x100
801008c6:	e8 1d ff ff ff       	call   801007e8 <consputc>
801008cb:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
801008ce:	8b 15 88 0f 11 80    	mov    0x80110f88,%edx
801008d4:	a1 84 0f 11 80       	mov    0x80110f84,%eax
801008d9:	39 c2                	cmp    %eax,%edx
801008db:	0f 84 e0 00 00 00    	je     801009c1 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008e1:	a1 88 0f 11 80       	mov    0x80110f88,%eax
801008e6:	83 e8 01             	sub    $0x1,%eax
801008e9:	83 e0 7f             	and    $0x7f,%eax
801008ec:	0f b6 80 00 0f 11 80 	movzbl -0x7feef100(%eax),%eax
      while(input.e != input.w &&
801008f3:	3c 0a                	cmp    $0xa,%al
801008f5:	75 ba                	jne    801008b1 <consoleintr+0x62>
      }
      break;
801008f7:	e9 c5 00 00 00       	jmp    801009c1 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008fc:	8b 15 88 0f 11 80    	mov    0x80110f88,%edx
80100902:	a1 84 0f 11 80       	mov    0x80110f84,%eax
80100907:	39 c2                	cmp    %eax,%edx
80100909:	0f 84 b2 00 00 00    	je     801009c1 <consoleintr+0x172>
        input.e--;
8010090f:	a1 88 0f 11 80       	mov    0x80110f88,%eax
80100914:	83 e8 01             	sub    $0x1,%eax
80100917:	a3 88 0f 11 80       	mov    %eax,0x80110f88
        consputc(BACKSPACE);
8010091c:	83 ec 0c             	sub    $0xc,%esp
8010091f:	68 00 01 00 00       	push   $0x100
80100924:	e8 bf fe ff ff       	call   801007e8 <consputc>
80100929:	83 c4 10             	add    $0x10,%esp
      }
      break;
8010092c:	e9 90 00 00 00       	jmp    801009c1 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100931:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100935:	0f 84 85 00 00 00    	je     801009c0 <consoleintr+0x171>
8010093b:	a1 88 0f 11 80       	mov    0x80110f88,%eax
80100940:	8b 15 80 0f 11 80    	mov    0x80110f80,%edx
80100946:	29 d0                	sub    %edx,%eax
80100948:	83 f8 7f             	cmp    $0x7f,%eax
8010094b:	77 73                	ja     801009c0 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
8010094d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100951:	74 05                	je     80100958 <consoleintr+0x109>
80100953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100956:	eb 05                	jmp    8010095d <consoleintr+0x10e>
80100958:	b8 0a 00 00 00       	mov    $0xa,%eax
8010095d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100960:	a1 88 0f 11 80       	mov    0x80110f88,%eax
80100965:	8d 50 01             	lea    0x1(%eax),%edx
80100968:	89 15 88 0f 11 80    	mov    %edx,0x80110f88
8010096e:	83 e0 7f             	and    $0x7f,%eax
80100971:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100974:	88 90 00 0f 11 80    	mov    %dl,-0x7feef100(%eax)
        consputc(c);
8010097a:	83 ec 0c             	sub    $0xc,%esp
8010097d:	ff 75 f0             	push   -0x10(%ebp)
80100980:	e8 63 fe ff ff       	call   801007e8 <consputc>
80100985:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100988:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010098c:	74 18                	je     801009a6 <consoleintr+0x157>
8010098e:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100992:	74 12                	je     801009a6 <consoleintr+0x157>
80100994:	a1 88 0f 11 80       	mov    0x80110f88,%eax
80100999:	8b 15 80 0f 11 80    	mov    0x80110f80,%edx
8010099f:	83 ea 80             	sub    $0xffffff80,%edx
801009a2:	39 d0                	cmp    %edx,%eax
801009a4:	75 1a                	jne    801009c0 <consoleintr+0x171>
          input.w = input.e;
801009a6:	a1 88 0f 11 80       	mov    0x80110f88,%eax
801009ab:	a3 84 0f 11 80       	mov    %eax,0x80110f84
          wakeup(&input.r);
801009b0:	83 ec 0c             	sub    $0xc,%esp
801009b3:	68 80 0f 11 80       	push   $0x80110f80
801009b8:	e8 02 4a 00 00       	call   801053bf <wakeup>
801009bd:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009c0:	90                   	nop
  while((c = getc()) >= 0){
801009c1:	8b 45 08             	mov    0x8(%ebp),%eax
801009c4:	ff d0                	call   *%eax
801009c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801009c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009cd:	0f 89 9e fe ff ff    	jns    80100871 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
801009d3:	83 ec 0c             	sub    $0xc,%esp
801009d6:	68 a0 0f 11 80       	push   $0x80110fa0
801009db:	e8 7b 53 00 00       	call   80105d5b <release>
801009e0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009e7:	74 05                	je     801009ee <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
801009e9:	e8 8f 4a 00 00       	call   8010547d <procdump>
  }
}
801009ee:	90                   	nop
801009ef:	c9                   	leave  
801009f0:	c3                   	ret    

801009f1 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009f1:	55                   	push   %ebp
801009f2:	89 e5                	mov    %esp,%ebp
801009f4:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	push   0x8(%ebp)
801009fd:	e8 e2 14 00 00       	call   80101ee4 <iunlock>
80100a02:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a05:	8b 45 10             	mov    0x10(%ebp),%eax
80100a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a0b:	83 ec 0c             	sub    $0xc,%esp
80100a0e:	68 a0 0f 11 80       	push   $0x80110fa0
80100a13:	e8 d5 52 00 00       	call   80105ced <acquire>
80100a18:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a1b:	e9 ab 00 00 00       	jmp    80100acb <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
80100a20:	e8 2b 3c 00 00       	call   80104650 <myproc>
80100a25:	8b 40 24             	mov    0x24(%eax),%eax
80100a28:	85 c0                	test   %eax,%eax
80100a2a:	74 28                	je     80100a54 <consoleread+0x63>
        release(&cons.lock);
80100a2c:	83 ec 0c             	sub    $0xc,%esp
80100a2f:	68 a0 0f 11 80       	push   $0x80110fa0
80100a34:	e8 22 53 00 00       	call   80105d5b <release>
80100a39:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a3c:	83 ec 0c             	sub    $0xc,%esp
80100a3f:	ff 75 08             	push   0x8(%ebp)
80100a42:	e8 8a 13 00 00       	call   80101dd1 <ilock>
80100a47:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a4f:	e9 a9 00 00 00       	jmp    80100afd <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
80100a54:	83 ec 08             	sub    $0x8,%esp
80100a57:	68 a0 0f 11 80       	push   $0x80110fa0
80100a5c:	68 80 0f 11 80       	push   $0x80110f80
80100a61:	e8 6f 48 00 00       	call   801052d5 <sleep>
80100a66:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a69:	8b 15 80 0f 11 80    	mov    0x80110f80,%edx
80100a6f:	a1 84 0f 11 80       	mov    0x80110f84,%eax
80100a74:	39 c2                	cmp    %eax,%edx
80100a76:	74 a8                	je     80100a20 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a78:	a1 80 0f 11 80       	mov    0x80110f80,%eax
80100a7d:	8d 50 01             	lea    0x1(%eax),%edx
80100a80:	89 15 80 0f 11 80    	mov    %edx,0x80110f80
80100a86:	83 e0 7f             	and    $0x7f,%eax
80100a89:	0f b6 80 00 0f 11 80 	movzbl -0x7feef100(%eax),%eax
80100a90:	0f be c0             	movsbl %al,%eax
80100a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a96:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a9a:	75 17                	jne    80100ab3 <consoleread+0xc2>
      if(n < target){
80100a9c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a9f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100aa2:	76 2f                	jbe    80100ad3 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100aa4:	a1 80 0f 11 80       	mov    0x80110f80,%eax
80100aa9:	83 e8 01             	sub    $0x1,%eax
80100aac:	a3 80 0f 11 80       	mov    %eax,0x80110f80
      }
      break;
80100ab1:	eb 20                	jmp    80100ad3 <consoleread+0xe2>
    }
    *dst++ = c;
80100ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab6:	8d 50 01             	lea    0x1(%eax),%edx
80100ab9:	89 55 0c             	mov    %edx,0xc(%ebp)
80100abc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100abf:	88 10                	mov    %dl,(%eax)
    --n;
80100ac1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100ac5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100ac9:	74 0b                	je     80100ad6 <consoleread+0xe5>
  while(n > 0){
80100acb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100acf:	7f 98                	jg     80100a69 <consoleread+0x78>
80100ad1:	eb 04                	jmp    80100ad7 <consoleread+0xe6>
      break;
80100ad3:	90                   	nop
80100ad4:	eb 01                	jmp    80100ad7 <consoleread+0xe6>
      break;
80100ad6:	90                   	nop
  }
  release(&cons.lock);
80100ad7:	83 ec 0c             	sub    $0xc,%esp
80100ada:	68 a0 0f 11 80       	push   $0x80110fa0
80100adf:	e8 77 52 00 00       	call   80105d5b <release>
80100ae4:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ae7:	83 ec 0c             	sub    $0xc,%esp
80100aea:	ff 75 08             	push   0x8(%ebp)
80100aed:	e8 df 12 00 00       	call   80101dd1 <ilock>
80100af2:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100af5:	8b 55 10             	mov    0x10(%ebp),%edx
80100af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100afb:	29 d0                	sub    %edx,%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b05:	83 ec 0c             	sub    $0xc,%esp
80100b08:	ff 75 08             	push   0x8(%ebp)
80100b0b:	e8 d4 13 00 00       	call   80101ee4 <iunlock>
80100b10:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b13:	83 ec 0c             	sub    $0xc,%esp
80100b16:	68 a0 0f 11 80       	push   $0x80110fa0
80100b1b:	e8 cd 51 00 00       	call   80105ced <acquire>
80100b20:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b2a:	eb 21                	jmp    80100b4d <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b32:	01 d0                	add    %edx,%eax
80100b34:	0f b6 00             	movzbl (%eax),%eax
80100b37:	0f be c0             	movsbl %al,%eax
80100b3a:	0f b6 c0             	movzbl %al,%eax
80100b3d:	83 ec 0c             	sub    $0xc,%esp
80100b40:	50                   	push   %eax
80100b41:	e8 a2 fc ff ff       	call   801007e8 <consputc>
80100b46:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b50:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b53:	7c d7                	jl     80100b2c <consolewrite+0x2d>
  release(&cons.lock);
80100b55:	83 ec 0c             	sub    $0xc,%esp
80100b58:	68 a0 0f 11 80       	push   $0x80110fa0
80100b5d:	e8 f9 51 00 00       	call   80105d5b <release>
80100b62:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b65:	83 ec 0c             	sub    $0xc,%esp
80100b68:	ff 75 08             	push   0x8(%ebp)
80100b6b:	e8 61 12 00 00       	call   80101dd1 <ilock>
80100b70:	83 c4 10             	add    $0x10,%esp

  return n;
80100b73:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b76:	c9                   	leave  
80100b77:	c3                   	ret    

80100b78 <consoleinit>:

void
consoleinit(void)
{
80100b78:	55                   	push   %ebp
80100b79:	89 e5                	mov    %esp,%ebp
80100b7b:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b7e:	83 ec 08             	sub    $0x8,%esp
80100b81:	68 ca 92 10 80       	push   $0x801092ca
80100b86:	68 a0 0f 11 80       	push   $0x80110fa0
80100b8b:	e8 3b 51 00 00       	call   80105ccb <initlock>
80100b90:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b93:	c7 05 ec 0f 11 80 ff 	movl   $0x80100aff,0x80110fec
80100b9a:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b9d:	c7 05 e8 0f 11 80 f1 	movl   $0x801009f1,0x80110fe8
80100ba4:	09 10 80 
  cons.locking = 1;
80100ba7:	c7 05 d4 0f 11 80 01 	movl   $0x1,0x80110fd4
80100bae:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bb1:	83 ec 08             	sub    $0x8,%esp
80100bb4:	6a 00                	push   $0x0
80100bb6:	6a 01                	push   $0x1
80100bb8:	e8 1e 23 00 00       	call   80102edb <ioapicenable>
80100bbd:	83 c4 10             	add    $0x10,%esp
}
80100bc0:	90                   	nop
80100bc1:	c9                   	leave  
80100bc2:	c3                   	ret    

80100bc3 <exec>:

int randomnumber(int, int);

int
exec(char *path, char **argv)
{
80100bc3:	55                   	push   %ebp
80100bc4:	89 e5                	mov    %esp,%ebp
80100bc6:	56                   	push   %esi
80100bc7:	53                   	push   %ebx
80100bc8:	81 ec 20 01 00 00    	sub    $0x120,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bce:	e8 7d 3a 00 00       	call   80104650 <myproc>
80100bd3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  
  begin_op();
80100bd6:	e8 0e 2d 00 00       	call   801038e9 <begin_op>
  
  int aslr_flag = 0;
80100bdb:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  char c[2] = {0};
80100be2:	66 c7 85 de fe ff ff 	movw   $0x0,-0x122(%ebp)
80100be9:	00 00 
  if ((ip = namei("aslr_flag")) == 0) {
80100beb:	83 ec 0c             	sub    $0xc,%esp
80100bee:	68 d4 92 10 80       	push   $0x801092d4
80100bf3:	e8 0c 1d 00 00       	call   80102904 <namei>
80100bf8:	83 c4 10             	add    $0x10,%esp
80100bfb:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bfe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c02:	75 12                	jne    80100c16 <exec+0x53>
    cprintf("unable to open aslr_flag file default to no randomize\n");
80100c04:	83 ec 0c             	sub    $0xc,%esp
80100c07:	68 e0 92 10 80       	push   $0x801092e0
80100c0c:	e8 ef f7 ff ff       	call   80100400 <cprintf>
80100c11:	83 c4 10             	add    $0x10,%esp
80100c14:	eb 5b                	jmp    80100c71 <exec+0xae>
  } else {
    ilock(ip);
80100c16:	83 ec 0c             	sub    $0xc,%esp
80100c19:	ff 75 d8             	push   -0x28(%ebp)
80100c1c:	e8 b0 11 00 00       	call   80101dd1 <ilock>
80100c21:	83 c4 10             	add    $0x10,%esp
    if (readi(ip,c, 0, sizeof(char)) != sizeof(char)) {
80100c24:	6a 01                	push   $0x1
80100c26:	6a 00                	push   $0x0
80100c28:	8d 85 de fe ff ff    	lea    -0x122(%ebp),%eax
80100c2e:	50                   	push   %eax
80100c2f:	ff 75 d8             	push   -0x28(%ebp)
80100c32:	e8 86 16 00 00       	call   801022bd <readi>
80100c37:	83 c4 10             	add    $0x10,%esp
80100c3a:	83 f8 01             	cmp    $0x1,%eax
80100c3d:	74 12                	je     80100c51 <exec+0x8e>
      cprintf("unable to read aslr, default to no randomize\n");
80100c3f:	83 ec 0c             	sub    $0xc,%esp
80100c42:	68 18 93 10 80       	push   $0x80109318
80100c47:	e8 b4 f7 ff ff       	call   80100400 <cprintf>
80100c4c:	83 c4 10             	add    $0x10,%esp
80100c4f:	eb 12                	jmp    80100c63 <exec+0xa0>
    } 
    else {
      	 aslr_flag = (c[0] == '1')? 1 : 0;
80100c51:	0f b6 85 de fe ff ff 	movzbl -0x122(%ebp),%eax
80100c58:	3c 31                	cmp    $0x31,%al
80100c5a:	0f 94 c0             	sete   %al
80100c5d:	0f b6 c0             	movzbl %al,%eax
80100c60:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    iunlockput(ip);
80100c63:	83 ec 0c             	sub    $0xc,%esp
80100c66:	ff 75 d8             	push   -0x28(%ebp)
80100c69:	e8 94 13 00 00       	call   80102002 <iunlockput>
80100c6e:	83 c4 10             	add    $0x10,%esp
  }

  if((ip = namei(path)) == 0){
80100c71:	83 ec 0c             	sub    $0xc,%esp
80100c74:	ff 75 08             	push   0x8(%ebp)
80100c77:	e8 88 1c 00 00       	call   80102904 <namei>
80100c7c:	83 c4 10             	add    $0x10,%esp
80100c7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c82:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c86:	75 1f                	jne    80100ca7 <exec+0xe4>
    end_op();
80100c88:	e8 e8 2c 00 00       	call   80103975 <end_op>
    cprintf("exec: fail\n");
80100c8d:	83 ec 0c             	sub    $0xc,%esp
80100c90:	68 46 93 10 80       	push   $0x80109346
80100c95:	e8 66 f7 ff ff       	call   80100400 <cprintf>
80100c9a:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ca2:	e9 f2 05 00 00       	jmp    80101299 <exec+0x6d6>
  }
  ilock(ip);
80100ca7:	83 ec 0c             	sub    $0xc,%esp
80100caa:	ff 75 d8             	push   -0x28(%ebp)
80100cad:	e8 1f 11 00 00       	call   80101dd1 <ilock>
80100cb2:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100cb5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100cbc:	6a 34                	push   $0x34
80100cbe:	6a 00                	push   $0x0
80100cc0:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
80100cc6:	50                   	push   %eax
80100cc7:	ff 75 d8             	push   -0x28(%ebp)
80100cca:	e8 ee 15 00 00       	call   801022bd <readi>
80100ccf:	83 c4 10             	add    $0x10,%esp
80100cd2:	83 f8 34             	cmp    $0x34,%eax
80100cd5:	0f 85 67 05 00 00    	jne    80101242 <exec+0x67f>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cdb:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100ce1:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100ce6:	0f 85 59 05 00 00    	jne    80101245 <exec+0x682>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cec:	e8 1d 7d 00 00       	call   80108a0e <setupkvm>
80100cf1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100cf4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cf8:	0f 84 4a 05 00 00    	je     80101248 <exec+0x685>
    goto bad;


   // RANDOMNESS IS COMING FROM HERE!
   uint ld_offset = 0;
80100cfe:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 
   if(aslr_flag){ 
80100d05:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80100d09:	74 32                	je     80100d3d <exec+0x17a>
   	ld_offset = randomnumber(1, 7) << 12;
80100d0b:	83 ec 08             	sub    $0x8,%esp
80100d0e:	6a 07                	push   $0x7
80100d10:	6a 01                	push   $0x1
80100d12:	e8 60 06 00 00       	call   80101377 <randomnumber>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	c1 e0 0c             	shl    $0xc,%eax
80100d1d:	89 45 cc             	mov    %eax,-0x34(%ebp)
   	if(curproc->pid == 1 || curproc->pid == 2) ld_offset = 0;
80100d20:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100d23:	8b 40 10             	mov    0x10(%eax),%eax
80100d26:	83 f8 01             	cmp    $0x1,%eax
80100d29:	74 0b                	je     80100d36 <exec+0x173>
80100d2b:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100d2e:	8b 40 10             	mov    0x10(%eax),%eax
80100d31:	83 f8 02             	cmp    $0x2,%eax
80100d34:	75 07                	jne    80100d3d <exec+0x17a>
80100d36:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
   }
   
   
  
  // Load program into memory.
  sz = allocuvm(pgdir, 0, ld_offset);
80100d3d:	83 ec 04             	sub    $0x4,%esp
80100d40:	ff 75 cc             	push   -0x34(%ebp)
80100d43:	6a 00                	push   $0x0
80100d45:	ff 75 d4             	push   -0x2c(%ebp)
80100d48:	e8 67 80 00 00       	call   80108db4 <allocuvm>
80100d4d:	83 c4 10             	add    $0x10,%esp
80100d50:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d53:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d5a:	8b 85 1c ff ff ff    	mov    -0xe4(%ebp),%eax
80100d60:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d63:	e9 e8 00 00 00       	jmp    80100e50 <exec+0x28d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d6b:	6a 20                	push   $0x20
80100d6d:	50                   	push   %eax
80100d6e:	8d 85 e0 fe ff ff    	lea    -0x120(%ebp),%eax
80100d74:	50                   	push   %eax
80100d75:	ff 75 d8             	push   -0x28(%ebp)
80100d78:	e8 40 15 00 00       	call   801022bd <readi>
80100d7d:	83 c4 10             	add    $0x10,%esp
80100d80:	83 f8 20             	cmp    $0x20,%eax
80100d83:	0f 85 c2 04 00 00    	jne    8010124b <exec+0x688>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d89:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
80100d8f:	83 f8 01             	cmp    $0x1,%eax
80100d92:	0f 85 aa 00 00 00    	jne    80100e42 <exec+0x27f>
      continue;
    if(ph.memsz < ph.filesz)
80100d98:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100d9e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100da4:	39 c2                	cmp    %eax,%edx
80100da6:	0f 82 a2 04 00 00    	jb     8010124e <exec+0x68b>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100dac:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100db2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100db8:	01 c2                	add    %eax,%edx
80100dba:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100dc0:	39 c2                	cmp    %eax,%edx
80100dc2:	0f 82 89 04 00 00    	jb     80101251 <exec+0x68e>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz + ld_offset)) == 0)
80100dc8:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100dce:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100dd4:	01 c2                	add    %eax,%edx
80100dd6:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100dd9:	01 d0                	add    %edx,%eax
80100ddb:	83 ec 04             	sub    $0x4,%esp
80100dde:	50                   	push   %eax
80100ddf:	ff 75 e0             	push   -0x20(%ebp)
80100de2:	ff 75 d4             	push   -0x2c(%ebp)
80100de5:	e8 ca 7f 00 00       	call   80108db4 <allocuvm>
80100dea:	83 c4 10             	add    $0x10,%esp
80100ded:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100df0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100df4:	0f 84 5a 04 00 00    	je     80101254 <exec+0x691>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100dfa:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100e00:	25 ff 0f 00 00       	and    $0xfff,%eax
80100e05:	85 c0                	test   %eax,%eax
80100e07:	0f 85 4a 04 00 00    	jne    80101257 <exec+0x694>
      goto bad;
    if(loaduvm(pgdir, (char*)(ph.vaddr + ld_offset), ip, ph.off, ph.filesz) < 0)
80100e0d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100e13:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100e19:	8b 9d e8 fe ff ff    	mov    -0x118(%ebp),%ebx
80100e1f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
80100e22:	01 d9                	add    %ebx,%ecx
80100e24:	83 ec 0c             	sub    $0xc,%esp
80100e27:	52                   	push   %edx
80100e28:	50                   	push   %eax
80100e29:	ff 75 d8             	push   -0x28(%ebp)
80100e2c:	51                   	push   %ecx
80100e2d:	ff 75 d4             	push   -0x2c(%ebp)
80100e30:	e8 b2 7e 00 00       	call   80108ce7 <loaduvm>
80100e35:	83 c4 20             	add    $0x20,%esp
80100e38:	85 c0                	test   %eax,%eax
80100e3a:	0f 88 1a 04 00 00    	js     8010125a <exec+0x697>
80100e40:	eb 01                	jmp    80100e43 <exec+0x280>
      continue;
80100e42:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e43:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100e47:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e4a:	83 c0 20             	add    $0x20,%eax
80100e4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e50:	0f b7 85 2c ff ff ff 	movzwl -0xd4(%ebp),%eax
80100e57:	0f b7 c0             	movzwl %ax,%eax
80100e5a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100e5d:	0f 8c 05 ff ff ff    	jl     80100d68 <exec+0x1a5>
      goto bad;
  }
  iunlockput(ip);
80100e63:	83 ec 0c             	sub    $0xc,%esp
80100e66:	ff 75 d8             	push   -0x28(%ebp)
80100e69:	e8 94 11 00 00       	call   80102002 <iunlockput>
80100e6e:	83 c4 10             	add    $0x10,%esp
  end_op();
80100e71:	e8 ff 2a 00 00       	call   80103975 <end_op>
  ip = 0;
80100e76:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  //int stack_offset = (aslr_flag)? randomrange(2, 1000) : 2;
  sz = PGROUNDUP(sz);
80100e7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e80:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e90:	05 00 20 00 00       	add    $0x2000,%eax
80100e95:	83 ec 04             	sub    $0x4,%esp
80100e98:	50                   	push   %eax
80100e99:	ff 75 e0             	push   -0x20(%ebp)
80100e9c:	ff 75 d4             	push   -0x2c(%ebp)
80100e9f:	e8 10 7f 00 00       	call   80108db4 <allocuvm>
80100ea4:	83 c4 10             	add    $0x10,%esp
80100ea7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100eaa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100eae:	0f 84 a9 03 00 00    	je     8010125d <exec+0x69a>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100eb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100eb7:	2d 00 20 00 00       	sub    $0x2000,%eax
80100ebc:	83 ec 08             	sub    $0x8,%esp
80100ebf:	50                   	push   %eax
80100ec0:	ff 75 d4             	push   -0x2c(%ebp)
80100ec3:	e8 4e 81 00 00       	call   80109016 <clearpteu>
80100ec8:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ece:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ed1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100ed8:	e9 96 00 00 00       	jmp    80100f73 <exec+0x3b0>
    if(argc >= MAXARG)
80100edd:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100ee1:	0f 87 79 03 00 00    	ja     80101260 <exec+0x69d>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ee7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ef4:	01 d0                	add    %edx,%eax
80100ef6:	8b 00                	mov    (%eax),%eax
80100ef8:	83 ec 0c             	sub    $0xc,%esp
80100efb:	50                   	push   %eax
80100efc:	e8 c0 52 00 00       	call   801061c1 <strlen>
80100f01:	83 c4 10             	add    $0x10,%esp
80100f04:	89 c2                	mov    %eax,%edx
80100f06:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f09:	29 d0                	sub    %edx,%eax
80100f0b:	83 e8 01             	sub    $0x1,%eax
80100f0e:	83 e0 fc             	and    $0xfffffffc,%eax
80100f11:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100f14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f17:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f21:	01 d0                	add    %edx,%eax
80100f23:	8b 00                	mov    (%eax),%eax
80100f25:	83 ec 0c             	sub    $0xc,%esp
80100f28:	50                   	push   %eax
80100f29:	e8 93 52 00 00       	call   801061c1 <strlen>
80100f2e:	83 c4 10             	add    $0x10,%esp
80100f31:	83 c0 01             	add    $0x1,%eax
80100f34:	89 c2                	mov    %eax,%edx
80100f36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f39:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100f40:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f43:	01 c8                	add    %ecx,%eax
80100f45:	8b 00                	mov    (%eax),%eax
80100f47:	52                   	push   %edx
80100f48:	50                   	push   %eax
80100f49:	ff 75 dc             	push   -0x24(%ebp)
80100f4c:	ff 75 d4             	push   -0x2c(%ebp)
80100f4f:	e8 6e 82 00 00       	call   801091c2 <copyout>
80100f54:	83 c4 10             	add    $0x10,%esp
80100f57:	85 c0                	test   %eax,%eax
80100f59:	0f 88 04 03 00 00    	js     80101263 <exec+0x6a0>
      goto bad;
    ustack[3+argc] = sp;
80100f5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f62:	8d 50 03             	lea    0x3(%eax),%edx
80100f65:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f68:	89 84 95 34 ff ff ff 	mov    %eax,-0xcc(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100f6f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f80:	01 d0                	add    %edx,%eax
80100f82:	8b 00                	mov    (%eax),%eax
80100f84:	85 c0                	test   %eax,%eax
80100f86:	0f 85 51 ff ff ff    	jne    80100edd <exec+0x31a>
  }
  ustack[3+argc] = 0;
80100f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f8f:	83 c0 03             	add    $0x3,%eax
80100f92:	c7 84 85 34 ff ff ff 	movl   $0x0,-0xcc(%ebp,%eax,4)
80100f99:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f9d:	c7 85 34 ff ff ff ff 	movl   $0xffffffff,-0xcc(%ebp)
80100fa4:	ff ff ff 
  ustack[1] = argc;
80100fa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100faa:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100fb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fb3:	83 c0 01             	add    $0x1,%eax
80100fb6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100fbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100fc0:	29 d0                	sub    %edx,%eax
80100fc2:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)

  sp -= (3+argc+1) * 4;
80100fc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fcb:	83 c0 04             	add    $0x4,%eax
80100fce:	c1 e0 02             	shl    $0x2,%eax
80100fd1:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100fd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fd7:	83 c0 04             	add    $0x4,%eax
80100fda:	c1 e0 02             	shl    $0x2,%eax
80100fdd:	50                   	push   %eax
80100fde:	8d 85 34 ff ff ff    	lea    -0xcc(%ebp),%eax
80100fe4:	50                   	push   %eax
80100fe5:	ff 75 dc             	push   -0x24(%ebp)
80100fe8:	ff 75 d4             	push   -0x2c(%ebp)
80100feb:	e8 d2 81 00 00       	call   801091c2 <copyout>
80100ff0:	83 c4 10             	add    $0x10,%esp
80100ff3:	85 c0                	test   %eax,%eax
80100ff5:	0f 88 6b 02 00 00    	js     80101266 <exec+0x6a3>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101001:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101004:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101007:	eb 17                	jmp    80101020 <exec+0x45d>
    if(*s == '/')
80101009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100c:	0f b6 00             	movzbl (%eax),%eax
8010100f:	3c 2f                	cmp    $0x2f,%al
80101011:	75 09                	jne    8010101c <exec+0x459>
      last = s+1;
80101013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101016:	83 c0 01             	add    $0x1,%eax
80101019:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
8010101c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	0f b6 00             	movzbl (%eax),%eax
80101026:	84 c0                	test   %al,%al
80101028:	75 df                	jne    80101009 <exec+0x446>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
8010102a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010102d:	83 c0 6c             	add    $0x6c,%eax
80101030:	83 ec 04             	sub    $0x4,%esp
80101033:	6a 10                	push   $0x10
80101035:	ff 75 f0             	push   -0x10(%ebp)
80101038:	50                   	push   %eax
80101039:	e8 38 51 00 00       	call   80106176 <safestrcpy>
8010103e:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80101041:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101044:	8b 40 04             	mov    0x4(%eax),%eax
80101047:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  curproc->pgdir = pgdir;
8010104a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010104d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101050:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80101053:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101056:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101059:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
8010105b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010105e:	8b 40 18             	mov    0x18(%eax),%eax
80101061:	8b 95 18 ff ff ff    	mov    -0xe8(%ebp),%edx
80101067:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp - ld_offset;  //change
8010106a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010106d:	8b 40 18             	mov    0x18(%eax),%eax
80101070:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101073:	2b 55 cc             	sub    -0x34(%ebp),%edx
80101076:	89 50 44             	mov    %edx,0x44(%eax)
  pushcli();
80101079:	e8 ea 4d 00 00       	call   80105e68 <pushcli>
  if(ld_offset != 0){
8010107e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80101082:	0f 84 92 01 00 00    	je     8010121a <exec+0x657>
  mycpu()->gdt[SEG_UCODE] = SEG(STA_X|STA_R, ld_offset, 0xffffffff, DPL_USER);
80101088:	e8 4b 35 00 00       	call   801045d8 <mycpu>
8010108d:	8b 55 cc             	mov    -0x34(%ebp),%edx
80101090:	89 d6                	mov    %edx,%esi
80101092:	8b 55 cc             	mov    -0x34(%ebp),%edx
80101095:	c1 ea 10             	shr    $0x10,%edx
80101098:	89 d3                	mov    %edx,%ebx
8010109a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010109d:	c1 ea 18             	shr    $0x18,%edx
801010a0:	89 d1                	mov    %edx,%ecx
801010a2:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801010a9:	ff ff 
801010ab:	66 89 b0 8a 00 00 00 	mov    %si,0x8a(%eax)
801010b2:	88 98 8c 00 00 00    	mov    %bl,0x8c(%eax)
801010b8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801010bf:	83 e2 f0             	and    $0xfffffff0,%edx
801010c2:	83 ca 0a             	or     $0xa,%edx
801010c5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801010cb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801010d2:	83 ca 10             	or     $0x10,%edx
801010d5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801010db:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801010e2:	83 ca 60             	or     $0x60,%edx
801010e5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801010eb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801010f2:	83 ca 80             	or     $0xffffff80,%edx
801010f5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801010fb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80101102:	83 ca 0f             	or     $0xf,%edx
80101105:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010110b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80101112:	83 e2 ef             	and    $0xffffffef,%edx
80101115:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010111b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80101122:	83 e2 df             	and    $0xffffffdf,%edx
80101125:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010112b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80101132:	83 ca 40             	or     $0x40,%edx
80101135:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010113b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80101142:	83 ca 80             	or     $0xffffff80,%edx
80101145:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010114b:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)
  mycpu()->gdt[SEG_UDATA] = SEG(STA_W, ld_offset, 0xffffffff, DPL_USER);
80101151:	e8 82 34 00 00       	call   801045d8 <mycpu>
80101156:	8b 55 cc             	mov    -0x34(%ebp),%edx
80101159:	89 d6                	mov    %edx,%esi
8010115b:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010115e:	c1 ea 10             	shr    $0x10,%edx
80101161:	89 d3                	mov    %edx,%ebx
80101163:	8b 55 cc             	mov    -0x34(%ebp),%edx
80101166:	c1 ea 18             	shr    $0x18,%edx
80101169:	89 d1                	mov    %edx,%ecx
8010116b:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80101172:	ff ff 
80101174:	66 89 b0 92 00 00 00 	mov    %si,0x92(%eax)
8010117b:	88 98 94 00 00 00    	mov    %bl,0x94(%eax)
80101181:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80101188:	83 e2 f0             	and    $0xfffffff0,%edx
8010118b:	83 ca 02             	or     $0x2,%edx
8010118e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80101194:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010119b:	83 ca 10             	or     $0x10,%edx
8010119e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801011a4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801011ab:	83 ca 60             	or     $0x60,%edx
801011ae:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801011b4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801011bb:	83 ca 80             	or     $0xffffff80,%edx
801011be:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801011c4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801011cb:	83 ca 0f             	or     $0xf,%edx
801011ce:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801011d4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801011db:	83 e2 ef             	and    $0xffffffef,%edx
801011de:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801011e4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801011eb:	83 e2 df             	and    $0xffffffdf,%edx
801011ee:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801011f4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801011fb:	83 ca 40             	or     $0x40,%edx
801011fe:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80101204:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010120b:	83 ca 80             	or     $0xffffff80,%edx
8010120e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80101214:	88 88 97 00 00 00    	mov    %cl,0x97(%eax)
  }
  popcli();
8010121a:	e8 96 4c 00 00       	call   80105eb5 <popcli>
  switchuvm(curproc);
8010121f:	83 ec 0c             	sub    $0xc,%esp
80101222:	ff 75 c8             	push   -0x38(%ebp)
80101225:	e8 ae 78 00 00       	call   80108ad8 <switchuvm>
8010122a:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
8010122d:	83 ec 0c             	sub    $0xc,%esp
80101230:	ff 75 c4             	push   -0x3c(%ebp)
80101233:	e8 45 7d 00 00       	call   80108f7d <freevm>
80101238:	83 c4 10             	add    $0x10,%esp
  
  return 0;
8010123b:	b8 00 00 00 00       	mov    $0x0,%eax
80101240:	eb 57                	jmp    80101299 <exec+0x6d6>
    goto bad;
80101242:	90                   	nop
80101243:	eb 22                	jmp    80101267 <exec+0x6a4>
    goto bad;
80101245:	90                   	nop
80101246:	eb 1f                	jmp    80101267 <exec+0x6a4>
    goto bad;
80101248:	90                   	nop
80101249:	eb 1c                	jmp    80101267 <exec+0x6a4>
      goto bad;
8010124b:	90                   	nop
8010124c:	eb 19                	jmp    80101267 <exec+0x6a4>
      goto bad;
8010124e:	90                   	nop
8010124f:	eb 16                	jmp    80101267 <exec+0x6a4>
      goto bad;
80101251:	90                   	nop
80101252:	eb 13                	jmp    80101267 <exec+0x6a4>
      goto bad;
80101254:	90                   	nop
80101255:	eb 10                	jmp    80101267 <exec+0x6a4>
      goto bad;
80101257:	90                   	nop
80101258:	eb 0d                	jmp    80101267 <exec+0x6a4>
      goto bad;
8010125a:	90                   	nop
8010125b:	eb 0a                	jmp    80101267 <exec+0x6a4>
    goto bad;
8010125d:	90                   	nop
8010125e:	eb 07                	jmp    80101267 <exec+0x6a4>
      goto bad;
80101260:	90                   	nop
80101261:	eb 04                	jmp    80101267 <exec+0x6a4>
      goto bad;
80101263:	90                   	nop
80101264:	eb 01                	jmp    80101267 <exec+0x6a4>
    goto bad;
80101266:	90                   	nop
  
 bad:
  if(pgdir)
80101267:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010126b:	74 0e                	je     8010127b <exec+0x6b8>
    freevm(pgdir);
8010126d:	83 ec 0c             	sub    $0xc,%esp
80101270:	ff 75 d4             	push   -0x2c(%ebp)
80101273:	e8 05 7d 00 00       	call   80108f7d <freevm>
80101278:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010127b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010127f:	74 13                	je     80101294 <exec+0x6d1>
    iunlockput(ip);
80101281:	83 ec 0c             	sub    $0xc,%esp
80101284:	ff 75 d8             	push   -0x28(%ebp)
80101287:	e8 76 0d 00 00       	call   80102002 <iunlockput>
8010128c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010128f:	e8 e1 26 00 00       	call   80103975 <end_op>
  }
  return -1;
80101294:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101299:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010129c:	5b                   	pop    %ebx
8010129d:	5e                   	pop    %esi
8010129e:	5d                   	pop    %ebp
8010129f:	c3                   	ret    

801012a0 <random>:

/*Random Number Generator
Genertes Random number within a range*/

uint random(void)
{
801012a0:	55                   	push   %ebp
801012a1:	89 e5                	mov    %esp,%ebp
801012a3:	83 ec 10             	sub    $0x10,%esp
  static unsigned int z1 = 12345, z2 = 12345, z3 = 12345, z4 = 12345;
  unsigned int b;
  b  = ((z1 << 6) ^ z1) >> 13;
801012a6:	a1 18 a0 10 80       	mov    0x8010a018,%eax
801012ab:	c1 e0 06             	shl    $0x6,%eax
801012ae:	89 c2                	mov    %eax,%edx
801012b0:	a1 18 a0 10 80       	mov    0x8010a018,%eax
801012b5:	31 d0                	xor    %edx,%eax
801012b7:	c1 e8 0d             	shr    $0xd,%eax
801012ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  z1 = ((z1 & 4294967294U) << 18) ^ b;
801012bd:	a1 18 a0 10 80       	mov    0x8010a018,%eax
801012c2:	c1 e0 12             	shl    $0x12,%eax
801012c5:	25 00 00 f8 ff       	and    $0xfff80000,%eax
801012ca:	33 45 fc             	xor    -0x4(%ebp),%eax
801012cd:	a3 18 a0 10 80       	mov    %eax,0x8010a018
  b  = ((z2 << 2) ^ z2) >> 27; 
801012d2:	a1 1c a0 10 80       	mov    0x8010a01c,%eax
801012d7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801012de:	a1 1c a0 10 80       	mov    0x8010a01c,%eax
801012e3:	31 d0                	xor    %edx,%eax
801012e5:	c1 e8 1b             	shr    $0x1b,%eax
801012e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  z2 = ((z2 & 4294967288U) << 2) ^ b;
801012eb:	a1 1c a0 10 80       	mov    0x8010a01c,%eax
801012f0:	c1 e0 02             	shl    $0x2,%eax
801012f3:	83 e0 e0             	and    $0xffffffe0,%eax
801012f6:	33 45 fc             	xor    -0x4(%ebp),%eax
801012f9:	a3 1c a0 10 80       	mov    %eax,0x8010a01c
  b  = ((z3 << 13) ^ z3) >> 21;
801012fe:	a1 20 a0 10 80       	mov    0x8010a020,%eax
80101303:	c1 e0 0d             	shl    $0xd,%eax
80101306:	89 c2                	mov    %eax,%edx
80101308:	a1 20 a0 10 80       	mov    0x8010a020,%eax
8010130d:	31 d0                	xor    %edx,%eax
8010130f:	c1 e8 15             	shr    $0x15,%eax
80101312:	89 45 fc             	mov    %eax,-0x4(%ebp)
  z3 = ((z3 & 4294967280U) << 7) ^ b;
80101315:	a1 20 a0 10 80       	mov    0x8010a020,%eax
8010131a:	c1 e0 07             	shl    $0x7,%eax
8010131d:	25 00 f8 ff ff       	and    $0xfffff800,%eax
80101322:	33 45 fc             	xor    -0x4(%ebp),%eax
80101325:	a3 20 a0 10 80       	mov    %eax,0x8010a020
  b  = ((z4 << 3) ^ z4) >> 12;
8010132a:	a1 24 a0 10 80       	mov    0x8010a024,%eax
8010132f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80101336:	a1 24 a0 10 80       	mov    0x8010a024,%eax
8010133b:	31 d0                	xor    %edx,%eax
8010133d:	c1 e8 0c             	shr    $0xc,%eax
80101340:	89 45 fc             	mov    %eax,-0x4(%ebp)
  z4 = ((z4 & 4294967168U) << 13) ^ b;
80101343:	a1 24 a0 10 80       	mov    0x8010a024,%eax
80101348:	c1 e0 0d             	shl    $0xd,%eax
8010134b:	25 00 00 f0 ff       	and    $0xfff00000,%eax
80101350:	33 45 fc             	xor    -0x4(%ebp),%eax
80101353:	a3 24 a0 10 80       	mov    %eax,0x8010a024

  return (z1 ^ z2 ^ z3 ^ z4) / 2;
80101358:	8b 15 18 a0 10 80    	mov    0x8010a018,%edx
8010135e:	a1 1c a0 10 80       	mov    0x8010a01c,%eax
80101363:	31 c2                	xor    %eax,%edx
80101365:	a1 20 a0 10 80       	mov    0x8010a020,%eax
8010136a:	31 c2                	xor    %eax,%edx
8010136c:	a1 24 a0 10 80       	mov    0x8010a024,%eax
80101371:	31 d0                	xor    %edx,%eax
80101373:	d1 e8                	shr    %eax
}
80101375:	c9                   	leave  
80101376:	c3                   	ret    

80101377 <randomnumber>:

// Return a random integer between a given range.
int
randomnumber(int lo, int hi)
{
80101377:	55                   	push   %ebp
80101378:	89 e5                	mov    %esp,%ebp
8010137a:	83 ec 10             	sub    $0x10,%esp
  if (hi < lo) {
8010137d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101380:	3b 45 08             	cmp    0x8(%ebp),%eax
80101383:	7d 12                	jge    80101397 <randomnumber+0x20>
    int tmp = lo;
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	89 45 fc             	mov    %eax,-0x4(%ebp)
    lo = hi;
8010138b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010138e:	89 45 08             	mov    %eax,0x8(%ebp)
    hi = tmp;
80101391:	8b 45 fc             	mov    -0x4(%ebp),%eax
80101394:	89 45 0c             	mov    %eax,0xc(%ebp)
  }
  int range = hi - lo + 1;
80101397:	8b 45 0c             	mov    0xc(%ebp),%eax
8010139a:	2b 45 08             	sub    0x8(%ebp),%eax
8010139d:	83 c0 01             	add    $0x1,%eax
801013a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  return random() % (range) + lo;
801013a3:	e8 f8 fe ff ff       	call   801012a0 <random>
801013a8:	8b 4d f8             	mov    -0x8(%ebp),%ecx
801013ab:	ba 00 00 00 00       	mov    $0x0,%edx
801013b0:	f7 f1                	div    %ecx
801013b2:	8b 45 08             	mov    0x8(%ebp),%eax
801013b5:	01 d0                	add    %edx,%eax
}
801013b7:	c9                   	leave  
801013b8:	c3                   	ret    

801013b9 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801013b9:	55                   	push   %ebp
801013ba:	89 e5                	mov    %esp,%ebp
801013bc:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801013bf:	83 ec 08             	sub    $0x8,%esp
801013c2:	68 52 93 10 80       	push   $0x80109352
801013c7:	68 40 10 11 80       	push   $0x80111040
801013cc:	e8 fa 48 00 00       	call   80105ccb <initlock>
801013d1:	83 c4 10             	add    $0x10,%esp
}
801013d4:	90                   	nop
801013d5:	c9                   	leave  
801013d6:	c3                   	ret    

801013d7 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801013d7:	55                   	push   %ebp
801013d8:	89 e5                	mov    %esp,%ebp
801013da:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801013dd:	83 ec 0c             	sub    $0xc,%esp
801013e0:	68 40 10 11 80       	push   $0x80111040
801013e5:	e8 03 49 00 00       	call   80105ced <acquire>
801013ea:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801013ed:	c7 45 f4 74 10 11 80 	movl   $0x80111074,-0xc(%ebp)
801013f4:	eb 2d                	jmp    80101423 <filealloc+0x4c>
    if(f->ref == 0){
801013f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f9:	8b 40 04             	mov    0x4(%eax),%eax
801013fc:	85 c0                	test   %eax,%eax
801013fe:	75 1f                	jne    8010141f <filealloc+0x48>
      f->ref = 1;
80101400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101403:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010140a:	83 ec 0c             	sub    $0xc,%esp
8010140d:	68 40 10 11 80       	push   $0x80111040
80101412:	e8 44 49 00 00       	call   80105d5b <release>
80101417:	83 c4 10             	add    $0x10,%esp
      return f;
8010141a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141d:	eb 23                	jmp    80101442 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010141f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101423:	b8 d4 19 11 80       	mov    $0x801119d4,%eax
80101428:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010142b:	72 c9                	jb     801013f6 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010142d:	83 ec 0c             	sub    $0xc,%esp
80101430:	68 40 10 11 80       	push   $0x80111040
80101435:	e8 21 49 00 00       	call   80105d5b <release>
8010143a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010143d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101442:	c9                   	leave  
80101443:	c3                   	ret    

80101444 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101444:	55                   	push   %ebp
80101445:	89 e5                	mov    %esp,%ebp
80101447:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010144a:	83 ec 0c             	sub    $0xc,%esp
8010144d:	68 40 10 11 80       	push   $0x80111040
80101452:	e8 96 48 00 00       	call   80105ced <acquire>
80101457:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010145a:	8b 45 08             	mov    0x8(%ebp),%eax
8010145d:	8b 40 04             	mov    0x4(%eax),%eax
80101460:	85 c0                	test   %eax,%eax
80101462:	7f 0d                	jg     80101471 <filedup+0x2d>
    panic("filedup");
80101464:	83 ec 0c             	sub    $0xc,%esp
80101467:	68 59 93 10 80       	push   $0x80109359
8010146c:	e8 44 f1 ff ff       	call   801005b5 <panic>
  f->ref++;
80101471:	8b 45 08             	mov    0x8(%ebp),%eax
80101474:	8b 40 04             	mov    0x4(%eax),%eax
80101477:	8d 50 01             	lea    0x1(%eax),%edx
8010147a:	8b 45 08             	mov    0x8(%ebp),%eax
8010147d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101480:	83 ec 0c             	sub    $0xc,%esp
80101483:	68 40 10 11 80       	push   $0x80111040
80101488:	e8 ce 48 00 00       	call   80105d5b <release>
8010148d:	83 c4 10             	add    $0x10,%esp
  return f;
80101490:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101493:	c9                   	leave  
80101494:	c3                   	ret    

80101495 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101495:	55                   	push   %ebp
80101496:	89 e5                	mov    %esp,%ebp
80101498:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010149b:	83 ec 0c             	sub    $0xc,%esp
8010149e:	68 40 10 11 80       	push   $0x80111040
801014a3:	e8 45 48 00 00       	call   80105ced <acquire>
801014a8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801014ab:	8b 45 08             	mov    0x8(%ebp),%eax
801014ae:	8b 40 04             	mov    0x4(%eax),%eax
801014b1:	85 c0                	test   %eax,%eax
801014b3:	7f 0d                	jg     801014c2 <fileclose+0x2d>
    panic("fileclose");
801014b5:	83 ec 0c             	sub    $0xc,%esp
801014b8:	68 61 93 10 80       	push   $0x80109361
801014bd:	e8 f3 f0 ff ff       	call   801005b5 <panic>
  if(--f->ref > 0){
801014c2:	8b 45 08             	mov    0x8(%ebp),%eax
801014c5:	8b 40 04             	mov    0x4(%eax),%eax
801014c8:	8d 50 ff             	lea    -0x1(%eax),%edx
801014cb:	8b 45 08             	mov    0x8(%ebp),%eax
801014ce:	89 50 04             	mov    %edx,0x4(%eax)
801014d1:	8b 45 08             	mov    0x8(%ebp),%eax
801014d4:	8b 40 04             	mov    0x4(%eax),%eax
801014d7:	85 c0                	test   %eax,%eax
801014d9:	7e 15                	jle    801014f0 <fileclose+0x5b>
    release(&ftable.lock);
801014db:	83 ec 0c             	sub    $0xc,%esp
801014de:	68 40 10 11 80       	push   $0x80111040
801014e3:	e8 73 48 00 00       	call   80105d5b <release>
801014e8:	83 c4 10             	add    $0x10,%esp
801014eb:	e9 8b 00 00 00       	jmp    8010157b <fileclose+0xe6>
    return;
  }
  ff = *f;
801014f0:	8b 45 08             	mov    0x8(%ebp),%eax
801014f3:	8b 10                	mov    (%eax),%edx
801014f5:	89 55 e0             	mov    %edx,-0x20(%ebp)
801014f8:	8b 50 04             	mov    0x4(%eax),%edx
801014fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801014fe:	8b 50 08             	mov    0x8(%eax),%edx
80101501:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101504:	8b 50 0c             	mov    0xc(%eax),%edx
80101507:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010150a:	8b 50 10             	mov    0x10(%eax),%edx
8010150d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101510:	8b 40 14             	mov    0x14(%eax),%eax
80101513:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101516:	8b 45 08             	mov    0x8(%ebp),%eax
80101519:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101520:	8b 45 08             	mov    0x8(%ebp),%eax
80101523:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101529:	83 ec 0c             	sub    $0xc,%esp
8010152c:	68 40 10 11 80       	push   $0x80111040
80101531:	e8 25 48 00 00       	call   80105d5b <release>
80101536:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101539:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010153c:	83 f8 01             	cmp    $0x1,%eax
8010153f:	75 19                	jne    8010155a <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101541:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101545:	0f be d0             	movsbl %al,%edx
80101548:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010154b:	83 ec 08             	sub    $0x8,%esp
8010154e:	52                   	push   %edx
8010154f:	50                   	push   %eax
80101550:	e8 8a 2d 00 00       	call   801042df <pipeclose>
80101555:	83 c4 10             	add    $0x10,%esp
80101558:	eb 21                	jmp    8010157b <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010155a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010155d:	83 f8 02             	cmp    $0x2,%eax
80101560:	75 19                	jne    8010157b <fileclose+0xe6>
    begin_op();
80101562:	e8 82 23 00 00       	call   801038e9 <begin_op>
    iput(ff.ip);
80101567:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156a:	83 ec 0c             	sub    $0xc,%esp
8010156d:	50                   	push   %eax
8010156e:	e8 bf 09 00 00       	call   80101f32 <iput>
80101573:	83 c4 10             	add    $0x10,%esp
    end_op();
80101576:	e8 fa 23 00 00       	call   80103975 <end_op>
  }
}
8010157b:	c9                   	leave  
8010157c:	c3                   	ret    

8010157d <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010157d:	55                   	push   %ebp
8010157e:	89 e5                	mov    %esp,%ebp
80101580:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101583:	8b 45 08             	mov    0x8(%ebp),%eax
80101586:	8b 00                	mov    (%eax),%eax
80101588:	83 f8 02             	cmp    $0x2,%eax
8010158b:	75 40                	jne    801015cd <filestat+0x50>
    ilock(f->ip);
8010158d:	8b 45 08             	mov    0x8(%ebp),%eax
80101590:	8b 40 10             	mov    0x10(%eax),%eax
80101593:	83 ec 0c             	sub    $0xc,%esp
80101596:	50                   	push   %eax
80101597:	e8 35 08 00 00       	call   80101dd1 <ilock>
8010159c:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010159f:	8b 45 08             	mov    0x8(%ebp),%eax
801015a2:	8b 40 10             	mov    0x10(%eax),%eax
801015a5:	83 ec 08             	sub    $0x8,%esp
801015a8:	ff 75 0c             	push   0xc(%ebp)
801015ab:	50                   	push   %eax
801015ac:	e8 c6 0c 00 00       	call   80102277 <stati>
801015b1:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801015b4:	8b 45 08             	mov    0x8(%ebp),%eax
801015b7:	8b 40 10             	mov    0x10(%eax),%eax
801015ba:	83 ec 0c             	sub    $0xc,%esp
801015bd:	50                   	push   %eax
801015be:	e8 21 09 00 00       	call   80101ee4 <iunlock>
801015c3:	83 c4 10             	add    $0x10,%esp
    return 0;
801015c6:	b8 00 00 00 00       	mov    $0x0,%eax
801015cb:	eb 05                	jmp    801015d2 <filestat+0x55>
  }
  return -1;
801015cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801015d2:	c9                   	leave  
801015d3:	c3                   	ret    

801015d4 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801015d4:	55                   	push   %ebp
801015d5:	89 e5                	mov    %esp,%ebp
801015d7:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801015da:	8b 45 08             	mov    0x8(%ebp),%eax
801015dd:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801015e1:	84 c0                	test   %al,%al
801015e3:	75 0a                	jne    801015ef <fileread+0x1b>
    return -1;
801015e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801015ea:	e9 9b 00 00 00       	jmp    8010168a <fileread+0xb6>
  if(f->type == FD_PIPE)
801015ef:	8b 45 08             	mov    0x8(%ebp),%eax
801015f2:	8b 00                	mov    (%eax),%eax
801015f4:	83 f8 01             	cmp    $0x1,%eax
801015f7:	75 1a                	jne    80101613 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801015f9:	8b 45 08             	mov    0x8(%ebp),%eax
801015fc:	8b 40 0c             	mov    0xc(%eax),%eax
801015ff:	83 ec 04             	sub    $0x4,%esp
80101602:	ff 75 10             	push   0x10(%ebp)
80101605:	ff 75 0c             	push   0xc(%ebp)
80101608:	50                   	push   %eax
80101609:	e8 7e 2e 00 00       	call   8010448c <piperead>
8010160e:	83 c4 10             	add    $0x10,%esp
80101611:	eb 77                	jmp    8010168a <fileread+0xb6>
  if(f->type == FD_INODE){
80101613:	8b 45 08             	mov    0x8(%ebp),%eax
80101616:	8b 00                	mov    (%eax),%eax
80101618:	83 f8 02             	cmp    $0x2,%eax
8010161b:	75 60                	jne    8010167d <fileread+0xa9>
    ilock(f->ip);
8010161d:	8b 45 08             	mov    0x8(%ebp),%eax
80101620:	8b 40 10             	mov    0x10(%eax),%eax
80101623:	83 ec 0c             	sub    $0xc,%esp
80101626:	50                   	push   %eax
80101627:	e8 a5 07 00 00       	call   80101dd1 <ilock>
8010162c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010162f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101632:	8b 45 08             	mov    0x8(%ebp),%eax
80101635:	8b 50 14             	mov    0x14(%eax),%edx
80101638:	8b 45 08             	mov    0x8(%ebp),%eax
8010163b:	8b 40 10             	mov    0x10(%eax),%eax
8010163e:	51                   	push   %ecx
8010163f:	52                   	push   %edx
80101640:	ff 75 0c             	push   0xc(%ebp)
80101643:	50                   	push   %eax
80101644:	e8 74 0c 00 00       	call   801022bd <readi>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010164f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101653:	7e 11                	jle    80101666 <fileread+0x92>
      f->off += r;
80101655:	8b 45 08             	mov    0x8(%ebp),%eax
80101658:	8b 50 14             	mov    0x14(%eax),%edx
8010165b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010165e:	01 c2                	add    %eax,%edx
80101660:	8b 45 08             	mov    0x8(%ebp),%eax
80101663:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101666:	8b 45 08             	mov    0x8(%ebp),%eax
80101669:	8b 40 10             	mov    0x10(%eax),%eax
8010166c:	83 ec 0c             	sub    $0xc,%esp
8010166f:	50                   	push   %eax
80101670:	e8 6f 08 00 00       	call   80101ee4 <iunlock>
80101675:	83 c4 10             	add    $0x10,%esp
    return r;
80101678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167b:	eb 0d                	jmp    8010168a <fileread+0xb6>
  }
  panic("fileread");
8010167d:	83 ec 0c             	sub    $0xc,%esp
80101680:	68 6b 93 10 80       	push   $0x8010936b
80101685:	e8 2b ef ff ff       	call   801005b5 <panic>
}
8010168a:	c9                   	leave  
8010168b:	c3                   	ret    

8010168c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010168c:	55                   	push   %ebp
8010168d:	89 e5                	mov    %esp,%ebp
8010168f:	53                   	push   %ebx
80101690:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101693:	8b 45 08             	mov    0x8(%ebp),%eax
80101696:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010169a:	84 c0                	test   %al,%al
8010169c:	75 0a                	jne    801016a8 <filewrite+0x1c>
    return -1;
8010169e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801016a3:	e9 1b 01 00 00       	jmp    801017c3 <filewrite+0x137>
  if(f->type == FD_PIPE)
801016a8:	8b 45 08             	mov    0x8(%ebp),%eax
801016ab:	8b 00                	mov    (%eax),%eax
801016ad:	83 f8 01             	cmp    $0x1,%eax
801016b0:	75 1d                	jne    801016cf <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801016b2:	8b 45 08             	mov    0x8(%ebp),%eax
801016b5:	8b 40 0c             	mov    0xc(%eax),%eax
801016b8:	83 ec 04             	sub    $0x4,%esp
801016bb:	ff 75 10             	push   0x10(%ebp)
801016be:	ff 75 0c             	push   0xc(%ebp)
801016c1:	50                   	push   %eax
801016c2:	e8 c3 2c 00 00       	call   8010438a <pipewrite>
801016c7:	83 c4 10             	add    $0x10,%esp
801016ca:	e9 f4 00 00 00       	jmp    801017c3 <filewrite+0x137>
  if(f->type == FD_INODE){
801016cf:	8b 45 08             	mov    0x8(%ebp),%eax
801016d2:	8b 00                	mov    (%eax),%eax
801016d4:	83 f8 02             	cmp    $0x2,%eax
801016d7:	0f 85 d9 00 00 00    	jne    801017b6 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801016dd:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801016e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801016eb:	e9 a3 00 00 00       	jmp    80101793 <filewrite+0x107>
      int n1 = n - i;
801016f0:	8b 45 10             	mov    0x10(%ebp),%eax
801016f3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801016f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016fc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801016ff:	7e 06                	jle    80101707 <filewrite+0x7b>
        n1 = max;
80101701:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101704:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101707:	e8 dd 21 00 00       	call   801038e9 <begin_op>
      ilock(f->ip);
8010170c:	8b 45 08             	mov    0x8(%ebp),%eax
8010170f:	8b 40 10             	mov    0x10(%eax),%eax
80101712:	83 ec 0c             	sub    $0xc,%esp
80101715:	50                   	push   %eax
80101716:	e8 b6 06 00 00       	call   80101dd1 <ilock>
8010171b:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010171e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101721:	8b 45 08             	mov    0x8(%ebp),%eax
80101724:	8b 50 14             	mov    0x14(%eax),%edx
80101727:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010172a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010172d:	01 c3                	add    %eax,%ebx
8010172f:	8b 45 08             	mov    0x8(%ebp),%eax
80101732:	8b 40 10             	mov    0x10(%eax),%eax
80101735:	51                   	push   %ecx
80101736:	52                   	push   %edx
80101737:	53                   	push   %ebx
80101738:	50                   	push   %eax
80101739:	e8 d4 0c 00 00       	call   80102412 <writei>
8010173e:	83 c4 10             	add    $0x10,%esp
80101741:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101744:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101748:	7e 11                	jle    8010175b <filewrite+0xcf>
        f->off += r;
8010174a:	8b 45 08             	mov    0x8(%ebp),%eax
8010174d:	8b 50 14             	mov    0x14(%eax),%edx
80101750:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101753:	01 c2                	add    %eax,%edx
80101755:	8b 45 08             	mov    0x8(%ebp),%eax
80101758:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010175b:	8b 45 08             	mov    0x8(%ebp),%eax
8010175e:	8b 40 10             	mov    0x10(%eax),%eax
80101761:	83 ec 0c             	sub    $0xc,%esp
80101764:	50                   	push   %eax
80101765:	e8 7a 07 00 00       	call   80101ee4 <iunlock>
8010176a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010176d:	e8 03 22 00 00       	call   80103975 <end_op>

      if(r < 0)
80101772:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101776:	78 29                	js     801017a1 <filewrite+0x115>
        break;
      if(r != n1)
80101778:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010177b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010177e:	74 0d                	je     8010178d <filewrite+0x101>
        panic("short filewrite");
80101780:	83 ec 0c             	sub    $0xc,%esp
80101783:	68 74 93 10 80       	push   $0x80109374
80101788:	e8 28 ee ff ff       	call   801005b5 <panic>
      i += r;
8010178d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101790:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101796:	3b 45 10             	cmp    0x10(%ebp),%eax
80101799:	0f 8c 51 ff ff ff    	jl     801016f0 <filewrite+0x64>
8010179f:	eb 01                	jmp    801017a2 <filewrite+0x116>
        break;
801017a1:	90                   	nop
    }
    return i == n ? n : -1;
801017a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801017a8:	75 05                	jne    801017af <filewrite+0x123>
801017aa:	8b 45 10             	mov    0x10(%ebp),%eax
801017ad:	eb 14                	jmp    801017c3 <filewrite+0x137>
801017af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801017b4:	eb 0d                	jmp    801017c3 <filewrite+0x137>
  }
  panic("filewrite");
801017b6:	83 ec 0c             	sub    $0xc,%esp
801017b9:	68 84 93 10 80       	push   $0x80109384
801017be:	e8 f2 ed ff ff       	call   801005b5 <panic>
}
801017c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801017c6:	c9                   	leave  
801017c7:	c3                   	ret    

801017c8 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801017c8:	55                   	push   %ebp
801017c9:	89 e5                	mov    %esp,%ebp
801017cb:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801017ce:	8b 45 08             	mov    0x8(%ebp),%eax
801017d1:	83 ec 08             	sub    $0x8,%esp
801017d4:	6a 01                	push   $0x1
801017d6:	50                   	push   %eax
801017d7:	e8 f3 e9 ff ff       	call   801001cf <bread>
801017dc:	83 c4 10             	add    $0x10,%esp
801017df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801017e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e5:	83 c0 5c             	add    $0x5c,%eax
801017e8:	83 ec 04             	sub    $0x4,%esp
801017eb:	6a 1c                	push   $0x1c
801017ed:	50                   	push   %eax
801017ee:	ff 75 0c             	push   0xc(%ebp)
801017f1:	e8 3c 48 00 00       	call   80106032 <memmove>
801017f6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017f9:	83 ec 0c             	sub    $0xc,%esp
801017fc:	ff 75 f4             	push   -0xc(%ebp)
801017ff:	e8 4d ea ff ff       	call   80100251 <brelse>
80101804:	83 c4 10             	add    $0x10,%esp
}
80101807:	90                   	nop
80101808:	c9                   	leave  
80101809:	c3                   	ret    

8010180a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010180a:	55                   	push   %ebp
8010180b:	89 e5                	mov    %esp,%ebp
8010180d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101810:	8b 55 0c             	mov    0xc(%ebp),%edx
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	83 ec 08             	sub    $0x8,%esp
80101819:	52                   	push   %edx
8010181a:	50                   	push   %eax
8010181b:	e8 af e9 ff ff       	call   801001cf <bread>
80101820:	83 c4 10             	add    $0x10,%esp
80101823:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101829:	83 c0 5c             	add    $0x5c,%eax
8010182c:	83 ec 04             	sub    $0x4,%esp
8010182f:	68 00 02 00 00       	push   $0x200
80101834:	6a 00                	push   $0x0
80101836:	50                   	push   %eax
80101837:	e8 37 47 00 00       	call   80105f73 <memset>
8010183c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010183f:	83 ec 0c             	sub    $0xc,%esp
80101842:	ff 75 f4             	push   -0xc(%ebp)
80101845:	e8 d8 22 00 00       	call   80103b22 <log_write>
8010184a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010184d:	83 ec 0c             	sub    $0xc,%esp
80101850:	ff 75 f4             	push   -0xc(%ebp)
80101853:	e8 f9 e9 ff ff       	call   80100251 <brelse>
80101858:	83 c4 10             	add    $0x10,%esp
}
8010185b:	90                   	nop
8010185c:	c9                   	leave  
8010185d:	c3                   	ret    

8010185e <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010185e:	55                   	push   %ebp
8010185f:	89 e5                	mov    %esp,%ebp
80101861:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101864:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010186b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101872:	e9 0b 01 00 00       	jmp    80101982 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101880:	85 c0                	test   %eax,%eax
80101882:	0f 48 c2             	cmovs  %edx,%eax
80101885:	c1 f8 0c             	sar    $0xc,%eax
80101888:	89 c2                	mov    %eax,%edx
8010188a:	a1 f8 19 11 80       	mov    0x801119f8,%eax
8010188f:	01 d0                	add    %edx,%eax
80101891:	83 ec 08             	sub    $0x8,%esp
80101894:	50                   	push   %eax
80101895:	ff 75 08             	push   0x8(%ebp)
80101898:	e8 32 e9 ff ff       	call   801001cf <bread>
8010189d:	83 c4 10             	add    $0x10,%esp
801018a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801018a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801018aa:	e9 9e 00 00 00       	jmp    8010194d <balloc+0xef>
      m = 1 << (bi % 8);
801018af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b2:	83 e0 07             	and    $0x7,%eax
801018b5:	ba 01 00 00 00       	mov    $0x1,%edx
801018ba:	89 c1                	mov    %eax,%ecx
801018bc:	d3 e2                	shl    %cl,%edx
801018be:	89 d0                	mov    %edx,%eax
801018c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801018c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c6:	8d 50 07             	lea    0x7(%eax),%edx
801018c9:	85 c0                	test   %eax,%eax
801018cb:	0f 48 c2             	cmovs  %edx,%eax
801018ce:	c1 f8 03             	sar    $0x3,%eax
801018d1:	89 c2                	mov    %eax,%edx
801018d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018d6:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801018db:	0f b6 c0             	movzbl %al,%eax
801018de:	23 45 e8             	and    -0x18(%ebp),%eax
801018e1:	85 c0                	test   %eax,%eax
801018e3:	75 64                	jne    80101949 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801018e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e8:	8d 50 07             	lea    0x7(%eax),%edx
801018eb:	85 c0                	test   %eax,%eax
801018ed:	0f 48 c2             	cmovs  %edx,%eax
801018f0:	c1 f8 03             	sar    $0x3,%eax
801018f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801018f6:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801018fb:	89 d1                	mov    %edx,%ecx
801018fd:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101900:	09 ca                	or     %ecx,%edx
80101902:	89 d1                	mov    %edx,%ecx
80101904:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101907:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010190b:	83 ec 0c             	sub    $0xc,%esp
8010190e:	ff 75 ec             	push   -0x14(%ebp)
80101911:	e8 0c 22 00 00       	call   80103b22 <log_write>
80101916:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101919:	83 ec 0c             	sub    $0xc,%esp
8010191c:	ff 75 ec             	push   -0x14(%ebp)
8010191f:	e8 2d e9 ff ff       	call   80100251 <brelse>
80101924:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101927:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010192a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192d:	01 c2                	add    %eax,%edx
8010192f:	8b 45 08             	mov    0x8(%ebp),%eax
80101932:	83 ec 08             	sub    $0x8,%esp
80101935:	52                   	push   %edx
80101936:	50                   	push   %eax
80101937:	e8 ce fe ff ff       	call   8010180a <bzero>
8010193c:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010193f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101942:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101945:	01 d0                	add    %edx,%eax
80101947:	eb 57                	jmp    801019a0 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101949:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010194d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101954:	7f 17                	jg     8010196d <balloc+0x10f>
80101956:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101959:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195c:	01 d0                	add    %edx,%eax
8010195e:	89 c2                	mov    %eax,%edx
80101960:	a1 e0 19 11 80       	mov    0x801119e0,%eax
80101965:	39 c2                	cmp    %eax,%edx
80101967:	0f 82 42 ff ff ff    	jb     801018af <balloc+0x51>
      }
    }
    brelse(bp);
8010196d:	83 ec 0c             	sub    $0xc,%esp
80101970:	ff 75 ec             	push   -0x14(%ebp)
80101973:	e8 d9 e8 ff ff       	call   80100251 <brelse>
80101978:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010197b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101982:	8b 15 e0 19 11 80    	mov    0x801119e0,%edx
80101988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198b:	39 c2                	cmp    %eax,%edx
8010198d:	0f 87 e4 fe ff ff    	ja     80101877 <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101993:	83 ec 0c             	sub    $0xc,%esp
80101996:	68 90 93 10 80       	push   $0x80109390
8010199b:	e8 15 ec ff ff       	call   801005b5 <panic>
}
801019a0:	c9                   	leave  
801019a1:	c3                   	ret    

801019a2 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801019a2:	55                   	push   %ebp
801019a3:	89 e5                	mov    %esp,%ebp
801019a5:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801019a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801019ab:	c1 e8 0c             	shr    $0xc,%eax
801019ae:	89 c2                	mov    %eax,%edx
801019b0:	a1 f8 19 11 80       	mov    0x801119f8,%eax
801019b5:	01 c2                	add    %eax,%edx
801019b7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ba:	83 ec 08             	sub    $0x8,%esp
801019bd:	52                   	push   %edx
801019be:	50                   	push   %eax
801019bf:	e8 0b e8 ff ff       	call   801001cf <bread>
801019c4:	83 c4 10             	add    $0x10,%esp
801019c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801019ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801019cd:	25 ff 0f 00 00       	and    $0xfff,%eax
801019d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801019d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d8:	83 e0 07             	and    $0x7,%eax
801019db:	ba 01 00 00 00       	mov    $0x1,%edx
801019e0:	89 c1                	mov    %eax,%ecx
801019e2:	d3 e2                	shl    %cl,%edx
801019e4:	89 d0                	mov    %edx,%eax
801019e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801019e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ec:	8d 50 07             	lea    0x7(%eax),%edx
801019ef:	85 c0                	test   %eax,%eax
801019f1:	0f 48 c2             	cmovs  %edx,%eax
801019f4:	c1 f8 03             	sar    $0x3,%eax
801019f7:	89 c2                	mov    %eax,%edx
801019f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101a01:	0f b6 c0             	movzbl %al,%eax
80101a04:	23 45 ec             	and    -0x14(%ebp),%eax
80101a07:	85 c0                	test   %eax,%eax
80101a09:	75 0d                	jne    80101a18 <bfree+0x76>
    panic("freeing free block");
80101a0b:	83 ec 0c             	sub    $0xc,%esp
80101a0e:	68 a6 93 10 80       	push   $0x801093a6
80101a13:	e8 9d eb ff ff       	call   801005b5 <panic>
  bp->data[bi/8] &= ~m;
80101a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a1b:	8d 50 07             	lea    0x7(%eax),%edx
80101a1e:	85 c0                	test   %eax,%eax
80101a20:	0f 48 c2             	cmovs  %edx,%eax
80101a23:	c1 f8 03             	sar    $0x3,%eax
80101a26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101a29:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101a2e:	89 d1                	mov    %edx,%ecx
80101a30:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101a33:	f7 d2                	not    %edx
80101a35:	21 ca                	and    %ecx,%edx
80101a37:	89 d1                	mov    %edx,%ecx
80101a39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101a3c:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101a40:	83 ec 0c             	sub    $0xc,%esp
80101a43:	ff 75 f4             	push   -0xc(%ebp)
80101a46:	e8 d7 20 00 00       	call   80103b22 <log_write>
80101a4b:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101a4e:	83 ec 0c             	sub    $0xc,%esp
80101a51:	ff 75 f4             	push   -0xc(%ebp)
80101a54:	e8 f8 e7 ff ff       	call   80100251 <brelse>
80101a59:	83 c4 10             	add    $0x10,%esp
}
80101a5c:	90                   	nop
80101a5d:	c9                   	leave  
80101a5e:	c3                   	ret    

80101a5f <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101a5f:	55                   	push   %ebp
80101a60:	89 e5                	mov    %esp,%ebp
80101a62:	57                   	push   %edi
80101a63:	56                   	push   %esi
80101a64:	53                   	push   %ebx
80101a65:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101a68:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101a6f:	83 ec 08             	sub    $0x8,%esp
80101a72:	68 b9 93 10 80       	push   $0x801093b9
80101a77:	68 00 1a 11 80       	push   $0x80111a00
80101a7c:	e8 4a 42 00 00       	call   80105ccb <initlock>
80101a81:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101a84:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101a8b:	eb 2d                	jmp    80101aba <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
80101a8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101a90:	89 d0                	mov    %edx,%eax
80101a92:	c1 e0 03             	shl    $0x3,%eax
80101a95:	01 d0                	add    %edx,%eax
80101a97:	c1 e0 04             	shl    $0x4,%eax
80101a9a:	83 c0 30             	add    $0x30,%eax
80101a9d:	05 00 1a 11 80       	add    $0x80111a00,%eax
80101aa2:	83 c0 10             	add    $0x10,%eax
80101aa5:	83 ec 08             	sub    $0x8,%esp
80101aa8:	68 c0 93 10 80       	push   $0x801093c0
80101aad:	50                   	push   %eax
80101aae:	e8 95 40 00 00       	call   80105b48 <initsleeplock>
80101ab3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101ab6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101aba:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101abe:	7e cd                	jle    80101a8d <iinit+0x2e>
  }

  readsb(dev, &sb);
80101ac0:	83 ec 08             	sub    $0x8,%esp
80101ac3:	68 e0 19 11 80       	push   $0x801119e0
80101ac8:	ff 75 08             	push   0x8(%ebp)
80101acb:	e8 f8 fc ff ff       	call   801017c8 <readsb>
80101ad0:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101ad3:	a1 f8 19 11 80       	mov    0x801119f8,%eax
80101ad8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101adb:	8b 3d f4 19 11 80    	mov    0x801119f4,%edi
80101ae1:	8b 35 f0 19 11 80    	mov    0x801119f0,%esi
80101ae7:	8b 1d ec 19 11 80    	mov    0x801119ec,%ebx
80101aed:	8b 0d e8 19 11 80    	mov    0x801119e8,%ecx
80101af3:	8b 15 e4 19 11 80    	mov    0x801119e4,%edx
80101af9:	a1 e0 19 11 80       	mov    0x801119e0,%eax
80101afe:	ff 75 d4             	push   -0x2c(%ebp)
80101b01:	57                   	push   %edi
80101b02:	56                   	push   %esi
80101b03:	53                   	push   %ebx
80101b04:	51                   	push   %ecx
80101b05:	52                   	push   %edx
80101b06:	50                   	push   %eax
80101b07:	68 c8 93 10 80       	push   $0x801093c8
80101b0c:	e8 ef e8 ff ff       	call   80100400 <cprintf>
80101b11:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101b14:	90                   	nop
80101b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b18:	5b                   	pop    %ebx
80101b19:	5e                   	pop    %esi
80101b1a:	5f                   	pop    %edi
80101b1b:	5d                   	pop    %ebp
80101b1c:	c3                   	ret    

80101b1d <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101b1d:	55                   	push   %ebp
80101b1e:	89 e5                	mov    %esp,%ebp
80101b20:	83 ec 28             	sub    $0x28,%esp
80101b23:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b26:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101b2a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101b31:	e9 9e 00 00 00       	jmp    80101bd4 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b39:	c1 e8 03             	shr    $0x3,%eax
80101b3c:	89 c2                	mov    %eax,%edx
80101b3e:	a1 f4 19 11 80       	mov    0x801119f4,%eax
80101b43:	01 d0                	add    %edx,%eax
80101b45:	83 ec 08             	sub    $0x8,%esp
80101b48:	50                   	push   %eax
80101b49:	ff 75 08             	push   0x8(%ebp)
80101b4c:	e8 7e e6 ff ff       	call   801001cf <bread>
80101b51:	83 c4 10             	add    $0x10,%esp
80101b54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b5a:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b60:	83 e0 07             	and    $0x7,%eax
80101b63:	c1 e0 06             	shl    $0x6,%eax
80101b66:	01 d0                	add    %edx,%eax
80101b68:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101b6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b6e:	0f b7 00             	movzwl (%eax),%eax
80101b71:	66 85 c0             	test   %ax,%ax
80101b74:	75 4c                	jne    80101bc2 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101b76:	83 ec 04             	sub    $0x4,%esp
80101b79:	6a 40                	push   $0x40
80101b7b:	6a 00                	push   $0x0
80101b7d:	ff 75 ec             	push   -0x14(%ebp)
80101b80:	e8 ee 43 00 00       	call   80105f73 <memset>
80101b85:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101b88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b8b:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101b8f:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	ff 75 f0             	push   -0x10(%ebp)
80101b98:	e8 85 1f 00 00       	call   80103b22 <log_write>
80101b9d:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101ba0:	83 ec 0c             	sub    $0xc,%esp
80101ba3:	ff 75 f0             	push   -0x10(%ebp)
80101ba6:	e8 a6 e6 ff ff       	call   80100251 <brelse>
80101bab:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bb1:	83 ec 08             	sub    $0x8,%esp
80101bb4:	50                   	push   %eax
80101bb5:	ff 75 08             	push   0x8(%ebp)
80101bb8:	e8 f8 00 00 00       	call   80101cb5 <iget>
80101bbd:	83 c4 10             	add    $0x10,%esp
80101bc0:	eb 30                	jmp    80101bf2 <ialloc+0xd5>
    }
    brelse(bp);
80101bc2:	83 ec 0c             	sub    $0xc,%esp
80101bc5:	ff 75 f0             	push   -0x10(%ebp)
80101bc8:	e8 84 e6 ff ff       	call   80100251 <brelse>
80101bcd:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101bd0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101bd4:	8b 15 e8 19 11 80    	mov    0x801119e8,%edx
80101bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bdd:	39 c2                	cmp    %eax,%edx
80101bdf:	0f 87 51 ff ff ff    	ja     80101b36 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
80101be5:	83 ec 0c             	sub    $0xc,%esp
80101be8:	68 1b 94 10 80       	push   $0x8010941b
80101bed:	e8 c3 e9 ff ff       	call   801005b5 <panic>
}
80101bf2:	c9                   	leave  
80101bf3:	c3                   	ret    

80101bf4 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101bf4:	55                   	push   %ebp
80101bf5:	89 e5                	mov    %esp,%ebp
80101bf7:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	8b 40 04             	mov    0x4(%eax),%eax
80101c00:	c1 e8 03             	shr    $0x3,%eax
80101c03:	89 c2                	mov    %eax,%edx
80101c05:	a1 f4 19 11 80       	mov    0x801119f4,%eax
80101c0a:	01 c2                	add    %eax,%edx
80101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0f:	8b 00                	mov    (%eax),%eax
80101c11:	83 ec 08             	sub    $0x8,%esp
80101c14:	52                   	push   %edx
80101c15:	50                   	push   %eax
80101c16:	e8 b4 e5 ff ff       	call   801001cf <bread>
80101c1b:	83 c4 10             	add    $0x10,%esp
80101c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c24:	8d 50 5c             	lea    0x5c(%eax),%edx
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 04             	mov    0x4(%eax),%eax
80101c2d:	83 e0 07             	and    $0x7,%eax
80101c30:	c1 e0 06             	shl    $0x6,%eax
80101c33:	01 d0                	add    %edx,%eax
80101c35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101c38:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3b:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c42:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101c45:	8b 45 08             	mov    0x8(%ebp),%eax
80101c48:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c4f:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101c53:	8b 45 08             	mov    0x8(%ebp),%eax
80101c56:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c5d:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101c61:	8b 45 08             	mov    0x8(%ebp),%eax
80101c64:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c6b:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101c6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c72:	8b 50 58             	mov    0x58(%eax),%edx
80101c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c78:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c84:	83 c0 0c             	add    $0xc,%eax
80101c87:	83 ec 04             	sub    $0x4,%esp
80101c8a:	6a 34                	push   $0x34
80101c8c:	52                   	push   %edx
80101c8d:	50                   	push   %eax
80101c8e:	e8 9f 43 00 00       	call   80106032 <memmove>
80101c93:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101c96:	83 ec 0c             	sub    $0xc,%esp
80101c99:	ff 75 f4             	push   -0xc(%ebp)
80101c9c:	e8 81 1e 00 00       	call   80103b22 <log_write>
80101ca1:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101ca4:	83 ec 0c             	sub    $0xc,%esp
80101ca7:	ff 75 f4             	push   -0xc(%ebp)
80101caa:	e8 a2 e5 ff ff       	call   80100251 <brelse>
80101caf:	83 c4 10             	add    $0x10,%esp
}
80101cb2:	90                   	nop
80101cb3:	c9                   	leave  
80101cb4:	c3                   	ret    

80101cb5 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101cb5:	55                   	push   %ebp
80101cb6:	89 e5                	mov    %esp,%ebp
80101cb8:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101cbb:	83 ec 0c             	sub    $0xc,%esp
80101cbe:	68 00 1a 11 80       	push   $0x80111a00
80101cc3:	e8 25 40 00 00       	call   80105ced <acquire>
80101cc8:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101ccb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101cd2:	c7 45 f4 34 1a 11 80 	movl   $0x80111a34,-0xc(%ebp)
80101cd9:	eb 60                	jmp    80101d3b <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cde:	8b 40 08             	mov    0x8(%eax),%eax
80101ce1:	85 c0                	test   %eax,%eax
80101ce3:	7e 39                	jle    80101d1e <iget+0x69>
80101ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ce8:	8b 00                	mov    (%eax),%eax
80101cea:	39 45 08             	cmp    %eax,0x8(%ebp)
80101ced:	75 2f                	jne    80101d1e <iget+0x69>
80101cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cf2:	8b 40 04             	mov    0x4(%eax),%eax
80101cf5:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101cf8:	75 24                	jne    80101d1e <iget+0x69>
      ip->ref++;
80101cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cfd:	8b 40 08             	mov    0x8(%eax),%eax
80101d00:	8d 50 01             	lea    0x1(%eax),%edx
80101d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d06:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101d09:	83 ec 0c             	sub    $0xc,%esp
80101d0c:	68 00 1a 11 80       	push   $0x80111a00
80101d11:	e8 45 40 00 00       	call   80105d5b <release>
80101d16:	83 c4 10             	add    $0x10,%esp
      return ip;
80101d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d1c:	eb 77                	jmp    80101d95 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101d1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101d22:	75 10                	jne    80101d34 <iget+0x7f>
80101d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d27:	8b 40 08             	mov    0x8(%eax),%eax
80101d2a:	85 c0                	test   %eax,%eax
80101d2c:	75 06                	jne    80101d34 <iget+0x7f>
      empty = ip;
80101d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101d34:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101d3b:	81 7d f4 54 36 11 80 	cmpl   $0x80113654,-0xc(%ebp)
80101d42:	72 97                	jb     80101cdb <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101d44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101d48:	75 0d                	jne    80101d57 <iget+0xa2>
    panic("iget: no inodes");
80101d4a:	83 ec 0c             	sub    $0xc,%esp
80101d4d:	68 2d 94 10 80       	push   $0x8010942d
80101d52:	e8 5e e8 ff ff       	call   801005b5 <panic>

  ip = empty;
80101d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d60:	8b 55 08             	mov    0x8(%ebp),%edx
80101d63:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d68:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d6b:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d71:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d7b:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101d82:	83 ec 0c             	sub    $0xc,%esp
80101d85:	68 00 1a 11 80       	push   $0x80111a00
80101d8a:	e8 cc 3f 00 00       	call   80105d5b <release>
80101d8f:	83 c4 10             	add    $0x10,%esp

  return ip;
80101d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101d95:	c9                   	leave  
80101d96:	c3                   	ret    

80101d97 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101d97:	55                   	push   %ebp
80101d98:	89 e5                	mov    %esp,%ebp
80101d9a:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101d9d:	83 ec 0c             	sub    $0xc,%esp
80101da0:	68 00 1a 11 80       	push   $0x80111a00
80101da5:	e8 43 3f 00 00       	call   80105ced <acquire>
80101daa:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 40 08             	mov    0x8(%eax),%eax
80101db3:	8d 50 01             	lea    0x1(%eax),%edx
80101db6:	8b 45 08             	mov    0x8(%ebp),%eax
80101db9:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101dbc:	83 ec 0c             	sub    $0xc,%esp
80101dbf:	68 00 1a 11 80       	push   $0x80111a00
80101dc4:	e8 92 3f 00 00       	call   80105d5b <release>
80101dc9:	83 c4 10             	add    $0x10,%esp
  return ip;
80101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101dcf:	c9                   	leave  
80101dd0:	c3                   	ret    

80101dd1 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101dd1:	55                   	push   %ebp
80101dd2:	89 e5                	mov    %esp,%ebp
80101dd4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101dd7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ddb:	74 0a                	je     80101de7 <ilock+0x16>
80101ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80101de0:	8b 40 08             	mov    0x8(%eax),%eax
80101de3:	85 c0                	test   %eax,%eax
80101de5:	7f 0d                	jg     80101df4 <ilock+0x23>
    panic("ilock");
80101de7:	83 ec 0c             	sub    $0xc,%esp
80101dea:	68 3d 94 10 80       	push   $0x8010943d
80101def:	e8 c1 e7 ff ff       	call   801005b5 <panic>

  acquiresleep(&ip->lock);
80101df4:	8b 45 08             	mov    0x8(%ebp),%eax
80101df7:	83 c0 0c             	add    $0xc,%eax
80101dfa:	83 ec 0c             	sub    $0xc,%esp
80101dfd:	50                   	push   %eax
80101dfe:	e8 81 3d 00 00       	call   80105b84 <acquiresleep>
80101e03:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101e06:	8b 45 08             	mov    0x8(%ebp),%eax
80101e09:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	0f 85 cd 00 00 00    	jne    80101ee1 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101e14:	8b 45 08             	mov    0x8(%ebp),%eax
80101e17:	8b 40 04             	mov    0x4(%eax),%eax
80101e1a:	c1 e8 03             	shr    $0x3,%eax
80101e1d:	89 c2                	mov    %eax,%edx
80101e1f:	a1 f4 19 11 80       	mov    0x801119f4,%eax
80101e24:	01 c2                	add    %eax,%edx
80101e26:	8b 45 08             	mov    0x8(%ebp),%eax
80101e29:	8b 00                	mov    (%eax),%eax
80101e2b:	83 ec 08             	sub    $0x8,%esp
80101e2e:	52                   	push   %edx
80101e2f:	50                   	push   %eax
80101e30:	e8 9a e3 ff ff       	call   801001cf <bread>
80101e35:	83 c4 10             	add    $0x10,%esp
80101e38:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e3e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101e41:	8b 45 08             	mov    0x8(%ebp),%eax
80101e44:	8b 40 04             	mov    0x4(%eax),%eax
80101e47:	83 e0 07             	and    $0x7,%eax
80101e4a:	c1 e0 06             	shl    $0x6,%eax
80101e4d:	01 d0                	add    %edx,%eax
80101e4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e55:	0f b7 10             	movzwl (%eax),%edx
80101e58:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5b:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e62:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101e66:	8b 45 08             	mov    0x8(%ebp),%eax
80101e69:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e70:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101e74:	8b 45 08             	mov    0x8(%ebp),%eax
80101e77:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e7e:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101e82:	8b 45 08             	mov    0x8(%ebp),%eax
80101e85:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e8c:	8b 50 08             	mov    0x8(%eax),%edx
80101e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e92:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e98:	8d 50 0c             	lea    0xc(%eax),%edx
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	83 c0 5c             	add    $0x5c,%eax
80101ea1:	83 ec 04             	sub    $0x4,%esp
80101ea4:	6a 34                	push   $0x34
80101ea6:	52                   	push   %edx
80101ea7:	50                   	push   %eax
80101ea8:	e8 85 41 00 00       	call   80106032 <memmove>
80101ead:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101eb0:	83 ec 0c             	sub    $0xc,%esp
80101eb3:	ff 75 f4             	push   -0xc(%ebp)
80101eb6:	e8 96 e3 ff ff       	call   80100251 <brelse>
80101ebb:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec1:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ecf:	66 85 c0             	test   %ax,%ax
80101ed2:	75 0d                	jne    80101ee1 <ilock+0x110>
      panic("ilock: no type");
80101ed4:	83 ec 0c             	sub    $0xc,%esp
80101ed7:	68 43 94 10 80       	push   $0x80109443
80101edc:	e8 d4 e6 ff ff       	call   801005b5 <panic>
  }
}
80101ee1:	90                   	nop
80101ee2:	c9                   	leave  
80101ee3:	c3                   	ret    

80101ee4 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ee4:	55                   	push   %ebp
80101ee5:	89 e5                	mov    %esp,%ebp
80101ee7:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101eea:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101eee:	74 20                	je     80101f10 <iunlock+0x2c>
80101ef0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef3:	83 c0 0c             	add    $0xc,%eax
80101ef6:	83 ec 0c             	sub    $0xc,%esp
80101ef9:	50                   	push   %eax
80101efa:	e8 37 3d 00 00       	call   80105c36 <holdingsleep>
80101eff:	83 c4 10             	add    $0x10,%esp
80101f02:	85 c0                	test   %eax,%eax
80101f04:	74 0a                	je     80101f10 <iunlock+0x2c>
80101f06:	8b 45 08             	mov    0x8(%ebp),%eax
80101f09:	8b 40 08             	mov    0x8(%eax),%eax
80101f0c:	85 c0                	test   %eax,%eax
80101f0e:	7f 0d                	jg     80101f1d <iunlock+0x39>
    panic("iunlock");
80101f10:	83 ec 0c             	sub    $0xc,%esp
80101f13:	68 52 94 10 80       	push   $0x80109452
80101f18:	e8 98 e6 ff ff       	call   801005b5 <panic>

  releasesleep(&ip->lock);
80101f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f20:	83 c0 0c             	add    $0xc,%eax
80101f23:	83 ec 0c             	sub    $0xc,%esp
80101f26:	50                   	push   %eax
80101f27:	e8 bc 3c 00 00       	call   80105be8 <releasesleep>
80101f2c:	83 c4 10             	add    $0x10,%esp
}
80101f2f:	90                   	nop
80101f30:	c9                   	leave  
80101f31:	c3                   	ret    

80101f32 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101f32:	55                   	push   %ebp
80101f33:	89 e5                	mov    %esp,%ebp
80101f35:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101f38:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3b:	83 c0 0c             	add    $0xc,%eax
80101f3e:	83 ec 0c             	sub    $0xc,%esp
80101f41:	50                   	push   %eax
80101f42:	e8 3d 3c 00 00       	call   80105b84 <acquiresleep>
80101f47:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4d:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f50:	85 c0                	test   %eax,%eax
80101f52:	74 6a                	je     80101fbe <iput+0x8c>
80101f54:	8b 45 08             	mov    0x8(%ebp),%eax
80101f57:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101f5b:	66 85 c0             	test   %ax,%ax
80101f5e:	75 5e                	jne    80101fbe <iput+0x8c>
    acquire(&icache.lock);
80101f60:	83 ec 0c             	sub    $0xc,%esp
80101f63:	68 00 1a 11 80       	push   $0x80111a00
80101f68:	e8 80 3d 00 00       	call   80105ced <acquire>
80101f6d:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101f70:	8b 45 08             	mov    0x8(%ebp),%eax
80101f73:	8b 40 08             	mov    0x8(%eax),%eax
80101f76:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101f79:	83 ec 0c             	sub    $0xc,%esp
80101f7c:	68 00 1a 11 80       	push   $0x80111a00
80101f81:	e8 d5 3d 00 00       	call   80105d5b <release>
80101f86:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101f89:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101f8d:	75 2f                	jne    80101fbe <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101f8f:	83 ec 0c             	sub    $0xc,%esp
80101f92:	ff 75 08             	push   0x8(%ebp)
80101f95:	e8 ad 01 00 00       	call   80102147 <itrunc>
80101f9a:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa0:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101fa6:	83 ec 0c             	sub    $0xc,%esp
80101fa9:	ff 75 08             	push   0x8(%ebp)
80101fac:	e8 43 fc ff ff       	call   80101bf4 <iupdate>
80101fb1:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc1:	83 c0 0c             	add    $0xc,%eax
80101fc4:	83 ec 0c             	sub    $0xc,%esp
80101fc7:	50                   	push   %eax
80101fc8:	e8 1b 3c 00 00       	call   80105be8 <releasesleep>
80101fcd:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101fd0:	83 ec 0c             	sub    $0xc,%esp
80101fd3:	68 00 1a 11 80       	push   $0x80111a00
80101fd8:	e8 10 3d 00 00       	call   80105ced <acquire>
80101fdd:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe3:	8b 40 08             	mov    0x8(%eax),%eax
80101fe6:	8d 50 ff             	lea    -0x1(%eax),%edx
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101fef:	83 ec 0c             	sub    $0xc,%esp
80101ff2:	68 00 1a 11 80       	push   $0x80111a00
80101ff7:	e8 5f 3d 00 00       	call   80105d5b <release>
80101ffc:	83 c4 10             	add    $0x10,%esp
}
80101fff:	90                   	nop
80102000:	c9                   	leave  
80102001:	c3                   	ret    

80102002 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80102002:	55                   	push   %ebp
80102003:	89 e5                	mov    %esp,%ebp
80102005:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80102008:	83 ec 0c             	sub    $0xc,%esp
8010200b:	ff 75 08             	push   0x8(%ebp)
8010200e:	e8 d1 fe ff ff       	call   80101ee4 <iunlock>
80102013:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80102016:	83 ec 0c             	sub    $0xc,%esp
80102019:	ff 75 08             	push   0x8(%ebp)
8010201c:	e8 11 ff ff ff       	call   80101f32 <iput>
80102021:	83 c4 10             	add    $0x10,%esp
}
80102024:	90                   	nop
80102025:	c9                   	leave  
80102026:	c3                   	ret    

80102027 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80102027:	55                   	push   %ebp
80102028:	89 e5                	mov    %esp,%ebp
8010202a:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010202d:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80102031:	77 42                	ja     80102075 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	8b 55 0c             	mov    0xc(%ebp),%edx
80102039:	83 c2 14             	add    $0x14,%edx
8010203c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102040:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102043:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102047:	75 24                	jne    8010206d <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80102049:	8b 45 08             	mov    0x8(%ebp),%eax
8010204c:	8b 00                	mov    (%eax),%eax
8010204e:	83 ec 0c             	sub    $0xc,%esp
80102051:	50                   	push   %eax
80102052:	e8 07 f8 ff ff       	call   8010185e <balloc>
80102057:	83 c4 10             	add    $0x10,%esp
8010205a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010205d:	8b 45 08             	mov    0x8(%ebp),%eax
80102060:	8b 55 0c             	mov    0xc(%ebp),%edx
80102063:	8d 4a 14             	lea    0x14(%edx),%ecx
80102066:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102069:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
8010206d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102070:	e9 d0 00 00 00       	jmp    80102145 <bmap+0x11e>
  }
  bn -= NDIRECT;
80102075:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80102079:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
8010207d:	0f 87 b5 00 00 00    	ja     80102138 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010208c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010208f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102093:	75 20                	jne    801020b5 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80102095:	8b 45 08             	mov    0x8(%ebp),%eax
80102098:	8b 00                	mov    (%eax),%eax
8010209a:	83 ec 0c             	sub    $0xc,%esp
8010209d:	50                   	push   %eax
8010209e:	e8 bb f7 ff ff       	call   8010185e <balloc>
801020a3:	83 c4 10             	add    $0x10,%esp
801020a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801020a9:	8b 45 08             	mov    0x8(%ebp),%eax
801020ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020af:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
801020b5:	8b 45 08             	mov    0x8(%ebp),%eax
801020b8:	8b 00                	mov    (%eax),%eax
801020ba:	83 ec 08             	sub    $0x8,%esp
801020bd:	ff 75 f4             	push   -0xc(%ebp)
801020c0:	50                   	push   %eax
801020c1:	e8 09 e1 ff ff       	call   801001cf <bread>
801020c6:	83 c4 10             	add    $0x10,%esp
801020c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
801020cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020cf:	83 c0 5c             	add    $0x5c,%eax
801020d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
801020d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801020d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801020df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020e2:	01 d0                	add    %edx,%eax
801020e4:	8b 00                	mov    (%eax),%eax
801020e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801020e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801020ed:	75 36                	jne    80102125 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	8b 00                	mov    (%eax),%eax
801020f4:	83 ec 0c             	sub    $0xc,%esp
801020f7:	50                   	push   %eax
801020f8:	e8 61 f7 ff ff       	call   8010185e <balloc>
801020fd:	83 c4 10             	add    $0x10,%esp
80102100:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102103:	8b 45 0c             	mov    0xc(%ebp),%eax
80102106:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010210d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102110:	01 c2                	add    %eax,%edx
80102112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102115:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80102117:	83 ec 0c             	sub    $0xc,%esp
8010211a:	ff 75 f0             	push   -0x10(%ebp)
8010211d:	e8 00 1a 00 00       	call   80103b22 <log_write>
80102122:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80102125:	83 ec 0c             	sub    $0xc,%esp
80102128:	ff 75 f0             	push   -0x10(%ebp)
8010212b:	e8 21 e1 ff ff       	call   80100251 <brelse>
80102130:	83 c4 10             	add    $0x10,%esp
    return addr;
80102133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102136:	eb 0d                	jmp    80102145 <bmap+0x11e>
  }

  panic("bmap: out of range");
80102138:	83 ec 0c             	sub    $0xc,%esp
8010213b:	68 5a 94 10 80       	push   $0x8010945a
80102140:	e8 70 e4 ff ff       	call   801005b5 <panic>
}
80102145:	c9                   	leave  
80102146:	c3                   	ret    

80102147 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80102147:	55                   	push   %ebp
80102148:	89 e5                	mov    %esp,%ebp
8010214a:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
8010214d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102154:	eb 45                	jmp    8010219b <itrunc+0x54>
    if(ip->addrs[i]){
80102156:	8b 45 08             	mov    0x8(%ebp),%eax
80102159:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010215c:	83 c2 14             	add    $0x14,%edx
8010215f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102163:	85 c0                	test   %eax,%eax
80102165:	74 30                	je     80102197 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80102167:	8b 45 08             	mov    0x8(%ebp),%eax
8010216a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010216d:	83 c2 14             	add    $0x14,%edx
80102170:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102174:	8b 55 08             	mov    0x8(%ebp),%edx
80102177:	8b 12                	mov    (%edx),%edx
80102179:	83 ec 08             	sub    $0x8,%esp
8010217c:	50                   	push   %eax
8010217d:	52                   	push   %edx
8010217e:	e8 1f f8 ff ff       	call   801019a2 <bfree>
80102183:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80102186:	8b 45 08             	mov    0x8(%ebp),%eax
80102189:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010218c:	83 c2 14             	add    $0x14,%edx
8010218f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80102196:	00 
  for(i = 0; i < NDIRECT; i++){
80102197:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010219b:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
8010219f:	7e b5                	jle    80102156 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
801021a1:	8b 45 08             	mov    0x8(%ebp),%eax
801021a4:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801021aa:	85 c0                	test   %eax,%eax
801021ac:	0f 84 aa 00 00 00    	je     8010225c <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801021b2:	8b 45 08             	mov    0x8(%ebp),%eax
801021b5:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801021bb:	8b 45 08             	mov    0x8(%ebp),%eax
801021be:	8b 00                	mov    (%eax),%eax
801021c0:	83 ec 08             	sub    $0x8,%esp
801021c3:	52                   	push   %edx
801021c4:	50                   	push   %eax
801021c5:	e8 05 e0 ff ff       	call   801001cf <bread>
801021ca:	83 c4 10             	add    $0x10,%esp
801021cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
801021d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d3:	83 c0 5c             	add    $0x5c,%eax
801021d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
801021d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801021e0:	eb 3c                	jmp    8010221e <itrunc+0xd7>
      if(a[j])
801021e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801021ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801021ef:	01 d0                	add    %edx,%eax
801021f1:	8b 00                	mov    (%eax),%eax
801021f3:	85 c0                	test   %eax,%eax
801021f5:	74 23                	je     8010221a <itrunc+0xd3>
        bfree(ip->dev, a[j]);
801021f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102201:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102204:	01 d0                	add    %edx,%eax
80102206:	8b 00                	mov    (%eax),%eax
80102208:	8b 55 08             	mov    0x8(%ebp),%edx
8010220b:	8b 12                	mov    (%edx),%edx
8010220d:	83 ec 08             	sub    $0x8,%esp
80102210:	50                   	push   %eax
80102211:	52                   	push   %edx
80102212:	e8 8b f7 ff ff       	call   801019a2 <bfree>
80102217:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
8010221a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010221e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102221:	83 f8 7f             	cmp    $0x7f,%eax
80102224:	76 bc                	jbe    801021e2 <itrunc+0x9b>
    }
    brelse(bp);
80102226:	83 ec 0c             	sub    $0xc,%esp
80102229:	ff 75 ec             	push   -0x14(%ebp)
8010222c:	e8 20 e0 ff ff       	call   80100251 <brelse>
80102231:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102234:	8b 45 08             	mov    0x8(%ebp),%eax
80102237:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010223d:	8b 55 08             	mov    0x8(%ebp),%edx
80102240:	8b 12                	mov    (%edx),%edx
80102242:	83 ec 08             	sub    $0x8,%esp
80102245:	50                   	push   %eax
80102246:	52                   	push   %edx
80102247:	e8 56 f7 ff ff       	call   801019a2 <bfree>
8010224c:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
8010224f:	8b 45 08             	mov    0x8(%ebp),%eax
80102252:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80102259:	00 00 00 
  }

  ip->size = 0;
8010225c:	8b 45 08             	mov    0x8(%ebp),%eax
8010225f:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80102266:	83 ec 0c             	sub    $0xc,%esp
80102269:	ff 75 08             	push   0x8(%ebp)
8010226c:	e8 83 f9 ff ff       	call   80101bf4 <iupdate>
80102271:	83 c4 10             	add    $0x10,%esp
}
80102274:	90                   	nop
80102275:	c9                   	leave  
80102276:	c3                   	ret    

80102277 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80102277:	55                   	push   %ebp
80102278:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
8010227a:	8b 45 08             	mov    0x8(%ebp),%eax
8010227d:	8b 00                	mov    (%eax),%eax
8010227f:	89 c2                	mov    %eax,%edx
80102281:	8b 45 0c             	mov    0xc(%ebp),%eax
80102284:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102287:	8b 45 08             	mov    0x8(%ebp),%eax
8010228a:	8b 50 04             	mov    0x4(%eax),%edx
8010228d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102290:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102293:	8b 45 08             	mov    0x8(%ebp),%eax
80102296:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010229a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010229d:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
801022a0:	8b 45 08             	mov    0x8(%ebp),%eax
801022a3:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801022a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801022aa:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801022ae:	8b 45 08             	mov    0x8(%ebp),%eax
801022b1:	8b 50 58             	mov    0x58(%eax),%edx
801022b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801022b7:	89 50 10             	mov    %edx,0x10(%eax)
}
801022ba:	90                   	nop
801022bb:	5d                   	pop    %ebp
801022bc:	c3                   	ret    

801022bd <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801022bd:	55                   	push   %ebp
801022be:	89 e5                	mov    %esp,%ebp
801022c0:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801022c3:	8b 45 08             	mov    0x8(%ebp),%eax
801022c6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801022ca:	66 83 f8 03          	cmp    $0x3,%ax
801022ce:	75 5c                	jne    8010232c <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801022d0:	8b 45 08             	mov    0x8(%ebp),%eax
801022d3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801022d7:	66 85 c0             	test   %ax,%ax
801022da:	78 20                	js     801022fc <readi+0x3f>
801022dc:	8b 45 08             	mov    0x8(%ebp),%eax
801022df:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801022e3:	66 83 f8 09          	cmp    $0x9,%ax
801022e7:	7f 13                	jg     801022fc <readi+0x3f>
801022e9:	8b 45 08             	mov    0x8(%ebp),%eax
801022ec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801022f0:	98                   	cwtl   
801022f1:	8b 04 c5 e0 0f 11 80 	mov    -0x7feef020(,%eax,8),%eax
801022f8:	85 c0                	test   %eax,%eax
801022fa:	75 0a                	jne    80102306 <readi+0x49>
      return -1;
801022fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102301:	e9 0a 01 00 00       	jmp    80102410 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80102306:	8b 45 08             	mov    0x8(%ebp),%eax
80102309:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010230d:	98                   	cwtl   
8010230e:	8b 04 c5 e0 0f 11 80 	mov    -0x7feef020(,%eax,8),%eax
80102315:	8b 55 14             	mov    0x14(%ebp),%edx
80102318:	83 ec 04             	sub    $0x4,%esp
8010231b:	52                   	push   %edx
8010231c:	ff 75 0c             	push   0xc(%ebp)
8010231f:	ff 75 08             	push   0x8(%ebp)
80102322:	ff d0                	call   *%eax
80102324:	83 c4 10             	add    $0x10,%esp
80102327:	e9 e4 00 00 00       	jmp    80102410 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
8010232c:	8b 45 08             	mov    0x8(%ebp),%eax
8010232f:	8b 40 58             	mov    0x58(%eax),%eax
80102332:	39 45 10             	cmp    %eax,0x10(%ebp)
80102335:	77 0d                	ja     80102344 <readi+0x87>
80102337:	8b 55 10             	mov    0x10(%ebp),%edx
8010233a:	8b 45 14             	mov    0x14(%ebp),%eax
8010233d:	01 d0                	add    %edx,%eax
8010233f:	39 45 10             	cmp    %eax,0x10(%ebp)
80102342:	76 0a                	jbe    8010234e <readi+0x91>
    return -1;
80102344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102349:	e9 c2 00 00 00       	jmp    80102410 <readi+0x153>
  if(off + n > ip->size)
8010234e:	8b 55 10             	mov    0x10(%ebp),%edx
80102351:	8b 45 14             	mov    0x14(%ebp),%eax
80102354:	01 c2                	add    %eax,%edx
80102356:	8b 45 08             	mov    0x8(%ebp),%eax
80102359:	8b 40 58             	mov    0x58(%eax),%eax
8010235c:	39 c2                	cmp    %eax,%edx
8010235e:	76 0c                	jbe    8010236c <readi+0xaf>
    n = ip->size - off;
80102360:	8b 45 08             	mov    0x8(%ebp),%eax
80102363:	8b 40 58             	mov    0x58(%eax),%eax
80102366:	2b 45 10             	sub    0x10(%ebp),%eax
80102369:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010236c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102373:	e9 89 00 00 00       	jmp    80102401 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102378:	8b 45 10             	mov    0x10(%ebp),%eax
8010237b:	c1 e8 09             	shr    $0x9,%eax
8010237e:	83 ec 08             	sub    $0x8,%esp
80102381:	50                   	push   %eax
80102382:	ff 75 08             	push   0x8(%ebp)
80102385:	e8 9d fc ff ff       	call   80102027 <bmap>
8010238a:	83 c4 10             	add    $0x10,%esp
8010238d:	8b 55 08             	mov    0x8(%ebp),%edx
80102390:	8b 12                	mov    (%edx),%edx
80102392:	83 ec 08             	sub    $0x8,%esp
80102395:	50                   	push   %eax
80102396:	52                   	push   %edx
80102397:	e8 33 de ff ff       	call   801001cf <bread>
8010239c:	83 c4 10             	add    $0x10,%esp
8010239f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801023a2:	8b 45 10             	mov    0x10(%ebp),%eax
801023a5:	25 ff 01 00 00       	and    $0x1ff,%eax
801023aa:	ba 00 02 00 00       	mov    $0x200,%edx
801023af:	29 c2                	sub    %eax,%edx
801023b1:	8b 45 14             	mov    0x14(%ebp),%eax
801023b4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023b7:	39 c2                	cmp    %eax,%edx
801023b9:	0f 46 c2             	cmovbe %edx,%eax
801023bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801023bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c2:	8d 50 5c             	lea    0x5c(%eax),%edx
801023c5:	8b 45 10             	mov    0x10(%ebp),%eax
801023c8:	25 ff 01 00 00       	and    $0x1ff,%eax
801023cd:	01 d0                	add    %edx,%eax
801023cf:	83 ec 04             	sub    $0x4,%esp
801023d2:	ff 75 ec             	push   -0x14(%ebp)
801023d5:	50                   	push   %eax
801023d6:	ff 75 0c             	push   0xc(%ebp)
801023d9:	e8 54 3c 00 00       	call   80106032 <memmove>
801023de:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801023e1:	83 ec 0c             	sub    $0xc,%esp
801023e4:	ff 75 f0             	push   -0x10(%ebp)
801023e7:	e8 65 de ff ff       	call   80100251 <brelse>
801023ec:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801023ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023f2:	01 45 f4             	add    %eax,-0xc(%ebp)
801023f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023f8:	01 45 10             	add    %eax,0x10(%ebp)
801023fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023fe:	01 45 0c             	add    %eax,0xc(%ebp)
80102401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102404:	3b 45 14             	cmp    0x14(%ebp),%eax
80102407:	0f 82 6b ff ff ff    	jb     80102378 <readi+0xbb>
  }
  return n;
8010240d:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102410:	c9                   	leave  
80102411:	c3                   	ret    

80102412 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102412:	55                   	push   %ebp
80102413:	89 e5                	mov    %esp,%ebp
80102415:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102418:	8b 45 08             	mov    0x8(%ebp),%eax
8010241b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010241f:	66 83 f8 03          	cmp    $0x3,%ax
80102423:	75 5c                	jne    80102481 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102425:	8b 45 08             	mov    0x8(%ebp),%eax
80102428:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010242c:	66 85 c0             	test   %ax,%ax
8010242f:	78 20                	js     80102451 <writei+0x3f>
80102431:	8b 45 08             	mov    0x8(%ebp),%eax
80102434:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102438:	66 83 f8 09          	cmp    $0x9,%ax
8010243c:	7f 13                	jg     80102451 <writei+0x3f>
8010243e:	8b 45 08             	mov    0x8(%ebp),%eax
80102441:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102445:	98                   	cwtl   
80102446:	8b 04 c5 e4 0f 11 80 	mov    -0x7feef01c(,%eax,8),%eax
8010244d:	85 c0                	test   %eax,%eax
8010244f:	75 0a                	jne    8010245b <writei+0x49>
      return -1;
80102451:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102456:	e9 3b 01 00 00       	jmp    80102596 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010245b:	8b 45 08             	mov    0x8(%ebp),%eax
8010245e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102462:	98                   	cwtl   
80102463:	8b 04 c5 e4 0f 11 80 	mov    -0x7feef01c(,%eax,8),%eax
8010246a:	8b 55 14             	mov    0x14(%ebp),%edx
8010246d:	83 ec 04             	sub    $0x4,%esp
80102470:	52                   	push   %edx
80102471:	ff 75 0c             	push   0xc(%ebp)
80102474:	ff 75 08             	push   0x8(%ebp)
80102477:	ff d0                	call   *%eax
80102479:	83 c4 10             	add    $0x10,%esp
8010247c:	e9 15 01 00 00       	jmp    80102596 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
80102481:	8b 45 08             	mov    0x8(%ebp),%eax
80102484:	8b 40 58             	mov    0x58(%eax),%eax
80102487:	39 45 10             	cmp    %eax,0x10(%ebp)
8010248a:	77 0d                	ja     80102499 <writei+0x87>
8010248c:	8b 55 10             	mov    0x10(%ebp),%edx
8010248f:	8b 45 14             	mov    0x14(%ebp),%eax
80102492:	01 d0                	add    %edx,%eax
80102494:	39 45 10             	cmp    %eax,0x10(%ebp)
80102497:	76 0a                	jbe    801024a3 <writei+0x91>
    return -1;
80102499:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010249e:	e9 f3 00 00 00       	jmp    80102596 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801024a3:	8b 55 10             	mov    0x10(%ebp),%edx
801024a6:	8b 45 14             	mov    0x14(%ebp),%eax
801024a9:	01 d0                	add    %edx,%eax
801024ab:	3d 00 18 01 00       	cmp    $0x11800,%eax
801024b0:	76 0a                	jbe    801024bc <writei+0xaa>
    return -1;
801024b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024b7:	e9 da 00 00 00       	jmp    80102596 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801024bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024c3:	e9 97 00 00 00       	jmp    8010255f <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801024c8:	8b 45 10             	mov    0x10(%ebp),%eax
801024cb:	c1 e8 09             	shr    $0x9,%eax
801024ce:	83 ec 08             	sub    $0x8,%esp
801024d1:	50                   	push   %eax
801024d2:	ff 75 08             	push   0x8(%ebp)
801024d5:	e8 4d fb ff ff       	call   80102027 <bmap>
801024da:	83 c4 10             	add    $0x10,%esp
801024dd:	8b 55 08             	mov    0x8(%ebp),%edx
801024e0:	8b 12                	mov    (%edx),%edx
801024e2:	83 ec 08             	sub    $0x8,%esp
801024e5:	50                   	push   %eax
801024e6:	52                   	push   %edx
801024e7:	e8 e3 dc ff ff       	call   801001cf <bread>
801024ec:	83 c4 10             	add    $0x10,%esp
801024ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801024f2:	8b 45 10             	mov    0x10(%ebp),%eax
801024f5:	25 ff 01 00 00       	and    $0x1ff,%eax
801024fa:	ba 00 02 00 00       	mov    $0x200,%edx
801024ff:	29 c2                	sub    %eax,%edx
80102501:	8b 45 14             	mov    0x14(%ebp),%eax
80102504:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102507:	39 c2                	cmp    %eax,%edx
80102509:	0f 46 c2             	cmovbe %edx,%eax
8010250c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010250f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102512:	8d 50 5c             	lea    0x5c(%eax),%edx
80102515:	8b 45 10             	mov    0x10(%ebp),%eax
80102518:	25 ff 01 00 00       	and    $0x1ff,%eax
8010251d:	01 d0                	add    %edx,%eax
8010251f:	83 ec 04             	sub    $0x4,%esp
80102522:	ff 75 ec             	push   -0x14(%ebp)
80102525:	ff 75 0c             	push   0xc(%ebp)
80102528:	50                   	push   %eax
80102529:	e8 04 3b 00 00       	call   80106032 <memmove>
8010252e:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102531:	83 ec 0c             	sub    $0xc,%esp
80102534:	ff 75 f0             	push   -0x10(%ebp)
80102537:	e8 e6 15 00 00       	call   80103b22 <log_write>
8010253c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010253f:	83 ec 0c             	sub    $0xc,%esp
80102542:	ff 75 f0             	push   -0x10(%ebp)
80102545:	e8 07 dd ff ff       	call   80100251 <brelse>
8010254a:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010254d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102550:	01 45 f4             	add    %eax,-0xc(%ebp)
80102553:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102556:	01 45 10             	add    %eax,0x10(%ebp)
80102559:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010255c:	01 45 0c             	add    %eax,0xc(%ebp)
8010255f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102562:	3b 45 14             	cmp    0x14(%ebp),%eax
80102565:	0f 82 5d ff ff ff    	jb     801024c8 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010256b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010256f:	74 22                	je     80102593 <writei+0x181>
80102571:	8b 45 08             	mov    0x8(%ebp),%eax
80102574:	8b 40 58             	mov    0x58(%eax),%eax
80102577:	39 45 10             	cmp    %eax,0x10(%ebp)
8010257a:	76 17                	jbe    80102593 <writei+0x181>
    ip->size = off;
8010257c:	8b 45 08             	mov    0x8(%ebp),%eax
8010257f:	8b 55 10             	mov    0x10(%ebp),%edx
80102582:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102585:	83 ec 0c             	sub    $0xc,%esp
80102588:	ff 75 08             	push   0x8(%ebp)
8010258b:	e8 64 f6 ff ff       	call   80101bf4 <iupdate>
80102590:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102593:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102596:	c9                   	leave  
80102597:	c3                   	ret    

80102598 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102598:	55                   	push   %ebp
80102599:	89 e5                	mov    %esp,%ebp
8010259b:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010259e:	83 ec 04             	sub    $0x4,%esp
801025a1:	6a 0e                	push   $0xe
801025a3:	ff 75 0c             	push   0xc(%ebp)
801025a6:	ff 75 08             	push   0x8(%ebp)
801025a9:	e8 1a 3b 00 00       	call   801060c8 <strncmp>
801025ae:	83 c4 10             	add    $0x10,%esp
}
801025b1:	c9                   	leave  
801025b2:	c3                   	ret    

801025b3 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801025b3:	55                   	push   %ebp
801025b4:	89 e5                	mov    %esp,%ebp
801025b6:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801025b9:	8b 45 08             	mov    0x8(%ebp),%eax
801025bc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025c0:	66 83 f8 01          	cmp    $0x1,%ax
801025c4:	74 0d                	je     801025d3 <dirlookup+0x20>
    panic("dirlookup not DIR");
801025c6:	83 ec 0c             	sub    $0xc,%esp
801025c9:	68 6d 94 10 80       	push   $0x8010946d
801025ce:	e8 e2 df ff ff       	call   801005b5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801025d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025da:	eb 7b                	jmp    80102657 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801025dc:	6a 10                	push   $0x10
801025de:	ff 75 f4             	push   -0xc(%ebp)
801025e1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801025e4:	50                   	push   %eax
801025e5:	ff 75 08             	push   0x8(%ebp)
801025e8:	e8 d0 fc ff ff       	call   801022bd <readi>
801025ed:	83 c4 10             	add    $0x10,%esp
801025f0:	83 f8 10             	cmp    $0x10,%eax
801025f3:	74 0d                	je     80102602 <dirlookup+0x4f>
      panic("dirlookup read");
801025f5:	83 ec 0c             	sub    $0xc,%esp
801025f8:	68 7f 94 10 80       	push   $0x8010947f
801025fd:	e8 b3 df ff ff       	call   801005b5 <panic>
    if(de.inum == 0)
80102602:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102606:	66 85 c0             	test   %ax,%ax
80102609:	74 47                	je     80102652 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010260b:	83 ec 08             	sub    $0x8,%esp
8010260e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102611:	83 c0 02             	add    $0x2,%eax
80102614:	50                   	push   %eax
80102615:	ff 75 0c             	push   0xc(%ebp)
80102618:	e8 7b ff ff ff       	call   80102598 <namecmp>
8010261d:	83 c4 10             	add    $0x10,%esp
80102620:	85 c0                	test   %eax,%eax
80102622:	75 2f                	jne    80102653 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102624:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102628:	74 08                	je     80102632 <dirlookup+0x7f>
        *poff = off;
8010262a:	8b 45 10             	mov    0x10(%ebp),%eax
8010262d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102630:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102632:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102636:	0f b7 c0             	movzwl %ax,%eax
80102639:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010263c:	8b 45 08             	mov    0x8(%ebp),%eax
8010263f:	8b 00                	mov    (%eax),%eax
80102641:	83 ec 08             	sub    $0x8,%esp
80102644:	ff 75 f0             	push   -0x10(%ebp)
80102647:	50                   	push   %eax
80102648:	e8 68 f6 ff ff       	call   80101cb5 <iget>
8010264d:	83 c4 10             	add    $0x10,%esp
80102650:	eb 19                	jmp    8010266b <dirlookup+0xb8>
      continue;
80102652:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102653:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102657:	8b 45 08             	mov    0x8(%ebp),%eax
8010265a:	8b 40 58             	mov    0x58(%eax),%eax
8010265d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102660:	0f 82 76 ff ff ff    	jb     801025dc <dirlookup+0x29>
    }
  }

  return 0;
80102666:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010266b:	c9                   	leave  
8010266c:	c3                   	ret    

8010266d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010266d:	55                   	push   %ebp
8010266e:	89 e5                	mov    %esp,%ebp
80102670:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102673:	83 ec 04             	sub    $0x4,%esp
80102676:	6a 00                	push   $0x0
80102678:	ff 75 0c             	push   0xc(%ebp)
8010267b:	ff 75 08             	push   0x8(%ebp)
8010267e:	e8 30 ff ff ff       	call   801025b3 <dirlookup>
80102683:	83 c4 10             	add    $0x10,%esp
80102686:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102689:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010268d:	74 18                	je     801026a7 <dirlink+0x3a>
    iput(ip);
8010268f:	83 ec 0c             	sub    $0xc,%esp
80102692:	ff 75 f0             	push   -0x10(%ebp)
80102695:	e8 98 f8 ff ff       	call   80101f32 <iput>
8010269a:	83 c4 10             	add    $0x10,%esp
    return -1;
8010269d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026a2:	e9 9c 00 00 00       	jmp    80102743 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801026a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026ae:	eb 39                	jmp    801026e9 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801026b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026b3:	6a 10                	push   $0x10
801026b5:	50                   	push   %eax
801026b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801026b9:	50                   	push   %eax
801026ba:	ff 75 08             	push   0x8(%ebp)
801026bd:	e8 fb fb ff ff       	call   801022bd <readi>
801026c2:	83 c4 10             	add    $0x10,%esp
801026c5:	83 f8 10             	cmp    $0x10,%eax
801026c8:	74 0d                	je     801026d7 <dirlink+0x6a>
      panic("dirlink read");
801026ca:	83 ec 0c             	sub    $0xc,%esp
801026cd:	68 8e 94 10 80       	push   $0x8010948e
801026d2:	e8 de de ff ff       	call   801005b5 <panic>
    if(de.inum == 0)
801026d7:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801026db:	66 85 c0             	test   %ax,%ax
801026de:	74 18                	je     801026f8 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801026e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e3:	83 c0 10             	add    $0x10,%eax
801026e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026e9:	8b 45 08             	mov    0x8(%ebp),%eax
801026ec:	8b 50 58             	mov    0x58(%eax),%edx
801026ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f2:	39 c2                	cmp    %eax,%edx
801026f4:	77 ba                	ja     801026b0 <dirlink+0x43>
801026f6:	eb 01                	jmp    801026f9 <dirlink+0x8c>
      break;
801026f8:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801026f9:	83 ec 04             	sub    $0x4,%esp
801026fc:	6a 0e                	push   $0xe
801026fe:	ff 75 0c             	push   0xc(%ebp)
80102701:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102704:	83 c0 02             	add    $0x2,%eax
80102707:	50                   	push   %eax
80102708:	e8 11 3a 00 00       	call   8010611e <strncpy>
8010270d:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102710:	8b 45 10             	mov    0x10(%ebp),%eax
80102713:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271a:	6a 10                	push   $0x10
8010271c:	50                   	push   %eax
8010271d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102720:	50                   	push   %eax
80102721:	ff 75 08             	push   0x8(%ebp)
80102724:	e8 e9 fc ff ff       	call   80102412 <writei>
80102729:	83 c4 10             	add    $0x10,%esp
8010272c:	83 f8 10             	cmp    $0x10,%eax
8010272f:	74 0d                	je     8010273e <dirlink+0xd1>
    panic("dirlink");
80102731:	83 ec 0c             	sub    $0xc,%esp
80102734:	68 9b 94 10 80       	push   $0x8010949b
80102739:	e8 77 de ff ff       	call   801005b5 <panic>

  return 0;
8010273e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102743:	c9                   	leave  
80102744:	c3                   	ret    

80102745 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102745:	55                   	push   %ebp
80102746:	89 e5                	mov    %esp,%ebp
80102748:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010274b:	eb 04                	jmp    80102751 <skipelem+0xc>
    path++;
8010274d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102751:	8b 45 08             	mov    0x8(%ebp),%eax
80102754:	0f b6 00             	movzbl (%eax),%eax
80102757:	3c 2f                	cmp    $0x2f,%al
80102759:	74 f2                	je     8010274d <skipelem+0x8>
  if(*path == 0)
8010275b:	8b 45 08             	mov    0x8(%ebp),%eax
8010275e:	0f b6 00             	movzbl (%eax),%eax
80102761:	84 c0                	test   %al,%al
80102763:	75 07                	jne    8010276c <skipelem+0x27>
    return 0;
80102765:	b8 00 00 00 00       	mov    $0x0,%eax
8010276a:	eb 77                	jmp    801027e3 <skipelem+0x9e>
  s = path;
8010276c:	8b 45 08             	mov    0x8(%ebp),%eax
8010276f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102772:	eb 04                	jmp    80102778 <skipelem+0x33>
    path++;
80102774:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102778:	8b 45 08             	mov    0x8(%ebp),%eax
8010277b:	0f b6 00             	movzbl (%eax),%eax
8010277e:	3c 2f                	cmp    $0x2f,%al
80102780:	74 0a                	je     8010278c <skipelem+0x47>
80102782:	8b 45 08             	mov    0x8(%ebp),%eax
80102785:	0f b6 00             	movzbl (%eax),%eax
80102788:	84 c0                	test   %al,%al
8010278a:	75 e8                	jne    80102774 <skipelem+0x2f>
  len = path - s;
8010278c:	8b 45 08             	mov    0x8(%ebp),%eax
8010278f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102792:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102795:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102799:	7e 15                	jle    801027b0 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
8010279b:	83 ec 04             	sub    $0x4,%esp
8010279e:	6a 0e                	push   $0xe
801027a0:	ff 75 f4             	push   -0xc(%ebp)
801027a3:	ff 75 0c             	push   0xc(%ebp)
801027a6:	e8 87 38 00 00       	call   80106032 <memmove>
801027ab:	83 c4 10             	add    $0x10,%esp
801027ae:	eb 26                	jmp    801027d6 <skipelem+0x91>
  else {
    memmove(name, s, len);
801027b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b3:	83 ec 04             	sub    $0x4,%esp
801027b6:	50                   	push   %eax
801027b7:	ff 75 f4             	push   -0xc(%ebp)
801027ba:	ff 75 0c             	push   0xc(%ebp)
801027bd:	e8 70 38 00 00       	call   80106032 <memmove>
801027c2:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801027c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801027c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801027cb:	01 d0                	add    %edx,%eax
801027cd:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801027d0:	eb 04                	jmp    801027d6 <skipelem+0x91>
    path++;
801027d2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801027d6:	8b 45 08             	mov    0x8(%ebp),%eax
801027d9:	0f b6 00             	movzbl (%eax),%eax
801027dc:	3c 2f                	cmp    $0x2f,%al
801027de:	74 f2                	je     801027d2 <skipelem+0x8d>
  return path;
801027e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801027e3:	c9                   	leave  
801027e4:	c3                   	ret    

801027e5 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801027e5:	55                   	push   %ebp
801027e6:	89 e5                	mov    %esp,%ebp
801027e8:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801027eb:	8b 45 08             	mov    0x8(%ebp),%eax
801027ee:	0f b6 00             	movzbl (%eax),%eax
801027f1:	3c 2f                	cmp    $0x2f,%al
801027f3:	75 17                	jne    8010280c <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801027f5:	83 ec 08             	sub    $0x8,%esp
801027f8:	6a 01                	push   $0x1
801027fa:	6a 01                	push   $0x1
801027fc:	e8 b4 f4 ff ff       	call   80101cb5 <iget>
80102801:	83 c4 10             	add    $0x10,%esp
80102804:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102807:	e9 ba 00 00 00       	jmp    801028c6 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010280c:	e8 3f 1e 00 00       	call   80104650 <myproc>
80102811:	8b 40 68             	mov    0x68(%eax),%eax
80102814:	83 ec 0c             	sub    $0xc,%esp
80102817:	50                   	push   %eax
80102818:	e8 7a f5 ff ff       	call   80101d97 <idup>
8010281d:	83 c4 10             	add    $0x10,%esp
80102820:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102823:	e9 9e 00 00 00       	jmp    801028c6 <namex+0xe1>
    ilock(ip);
80102828:	83 ec 0c             	sub    $0xc,%esp
8010282b:	ff 75 f4             	push   -0xc(%ebp)
8010282e:	e8 9e f5 ff ff       	call   80101dd1 <ilock>
80102833:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102839:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010283d:	66 83 f8 01          	cmp    $0x1,%ax
80102841:	74 18                	je     8010285b <namex+0x76>
      iunlockput(ip);
80102843:	83 ec 0c             	sub    $0xc,%esp
80102846:	ff 75 f4             	push   -0xc(%ebp)
80102849:	e8 b4 f7 ff ff       	call   80102002 <iunlockput>
8010284e:	83 c4 10             	add    $0x10,%esp
      return 0;
80102851:	b8 00 00 00 00       	mov    $0x0,%eax
80102856:	e9 a7 00 00 00       	jmp    80102902 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010285b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010285f:	74 20                	je     80102881 <namex+0x9c>
80102861:	8b 45 08             	mov    0x8(%ebp),%eax
80102864:	0f b6 00             	movzbl (%eax),%eax
80102867:	84 c0                	test   %al,%al
80102869:	75 16                	jne    80102881 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010286b:	83 ec 0c             	sub    $0xc,%esp
8010286e:	ff 75 f4             	push   -0xc(%ebp)
80102871:	e8 6e f6 ff ff       	call   80101ee4 <iunlock>
80102876:	83 c4 10             	add    $0x10,%esp
      return ip;
80102879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287c:	e9 81 00 00 00       	jmp    80102902 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102881:	83 ec 04             	sub    $0x4,%esp
80102884:	6a 00                	push   $0x0
80102886:	ff 75 10             	push   0x10(%ebp)
80102889:	ff 75 f4             	push   -0xc(%ebp)
8010288c:	e8 22 fd ff ff       	call   801025b3 <dirlookup>
80102891:	83 c4 10             	add    $0x10,%esp
80102894:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102897:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010289b:	75 15                	jne    801028b2 <namex+0xcd>
      iunlockput(ip);
8010289d:	83 ec 0c             	sub    $0xc,%esp
801028a0:	ff 75 f4             	push   -0xc(%ebp)
801028a3:	e8 5a f7 ff ff       	call   80102002 <iunlockput>
801028a8:	83 c4 10             	add    $0x10,%esp
      return 0;
801028ab:	b8 00 00 00 00       	mov    $0x0,%eax
801028b0:	eb 50                	jmp    80102902 <namex+0x11d>
    }
    iunlockput(ip);
801028b2:	83 ec 0c             	sub    $0xc,%esp
801028b5:	ff 75 f4             	push   -0xc(%ebp)
801028b8:	e8 45 f7 ff ff       	call   80102002 <iunlockput>
801028bd:	83 c4 10             	add    $0x10,%esp
    ip = next;
801028c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801028c6:	83 ec 08             	sub    $0x8,%esp
801028c9:	ff 75 10             	push   0x10(%ebp)
801028cc:	ff 75 08             	push   0x8(%ebp)
801028cf:	e8 71 fe ff ff       	call   80102745 <skipelem>
801028d4:	83 c4 10             	add    $0x10,%esp
801028d7:	89 45 08             	mov    %eax,0x8(%ebp)
801028da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028de:	0f 85 44 ff ff ff    	jne    80102828 <namex+0x43>
  }
  if(nameiparent){
801028e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801028e8:	74 15                	je     801028ff <namex+0x11a>
    iput(ip);
801028ea:	83 ec 0c             	sub    $0xc,%esp
801028ed:	ff 75 f4             	push   -0xc(%ebp)
801028f0:	e8 3d f6 ff ff       	call   80101f32 <iput>
801028f5:	83 c4 10             	add    $0x10,%esp
    return 0;
801028f8:	b8 00 00 00 00       	mov    $0x0,%eax
801028fd:	eb 03                	jmp    80102902 <namex+0x11d>
  }
  return ip;
801028ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102902:	c9                   	leave  
80102903:	c3                   	ret    

80102904 <namei>:

struct inode*
namei(char *path)
{
80102904:	55                   	push   %ebp
80102905:	89 e5                	mov    %esp,%ebp
80102907:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010290a:	83 ec 04             	sub    $0x4,%esp
8010290d:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102910:	50                   	push   %eax
80102911:	6a 00                	push   $0x0
80102913:	ff 75 08             	push   0x8(%ebp)
80102916:	e8 ca fe ff ff       	call   801027e5 <namex>
8010291b:	83 c4 10             	add    $0x10,%esp
}
8010291e:	c9                   	leave  
8010291f:	c3                   	ret    

80102920 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102920:	55                   	push   %ebp
80102921:	89 e5                	mov    %esp,%ebp
80102923:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102926:	83 ec 04             	sub    $0x4,%esp
80102929:	ff 75 0c             	push   0xc(%ebp)
8010292c:	6a 01                	push   $0x1
8010292e:	ff 75 08             	push   0x8(%ebp)
80102931:	e8 af fe ff ff       	call   801027e5 <namex>
80102936:	83 c4 10             	add    $0x10,%esp
}
80102939:	c9                   	leave  
8010293a:	c3                   	ret    

8010293b <inb>:
{
8010293b:	55                   	push   %ebp
8010293c:	89 e5                	mov    %esp,%ebp
8010293e:	83 ec 14             	sub    $0x14,%esp
80102941:	8b 45 08             	mov    0x8(%ebp),%eax
80102944:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102948:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010294c:	89 c2                	mov    %eax,%edx
8010294e:	ec                   	in     (%dx),%al
8010294f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102952:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102956:	c9                   	leave  
80102957:	c3                   	ret    

80102958 <insl>:
{
80102958:	55                   	push   %ebp
80102959:	89 e5                	mov    %esp,%ebp
8010295b:	57                   	push   %edi
8010295c:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010295d:	8b 55 08             	mov    0x8(%ebp),%edx
80102960:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102963:	8b 45 10             	mov    0x10(%ebp),%eax
80102966:	89 cb                	mov    %ecx,%ebx
80102968:	89 df                	mov    %ebx,%edi
8010296a:	89 c1                	mov    %eax,%ecx
8010296c:	fc                   	cld    
8010296d:	f3 6d                	rep insl (%dx),%es:(%edi)
8010296f:	89 c8                	mov    %ecx,%eax
80102971:	89 fb                	mov    %edi,%ebx
80102973:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102976:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102979:	90                   	nop
8010297a:	5b                   	pop    %ebx
8010297b:	5f                   	pop    %edi
8010297c:	5d                   	pop    %ebp
8010297d:	c3                   	ret    

8010297e <outb>:
{
8010297e:	55                   	push   %ebp
8010297f:	89 e5                	mov    %esp,%ebp
80102981:	83 ec 08             	sub    $0x8,%esp
80102984:	8b 45 08             	mov    0x8(%ebp),%eax
80102987:	8b 55 0c             	mov    0xc(%ebp),%edx
8010298a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010298e:	89 d0                	mov    %edx,%eax
80102990:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102993:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102997:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010299b:	ee                   	out    %al,(%dx)
}
8010299c:	90                   	nop
8010299d:	c9                   	leave  
8010299e:	c3                   	ret    

8010299f <outsl>:
{
8010299f:	55                   	push   %ebp
801029a0:	89 e5                	mov    %esp,%ebp
801029a2:	56                   	push   %esi
801029a3:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801029a4:	8b 55 08             	mov    0x8(%ebp),%edx
801029a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801029aa:	8b 45 10             	mov    0x10(%ebp),%eax
801029ad:	89 cb                	mov    %ecx,%ebx
801029af:	89 de                	mov    %ebx,%esi
801029b1:	89 c1                	mov    %eax,%ecx
801029b3:	fc                   	cld    
801029b4:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801029b6:	89 c8                	mov    %ecx,%eax
801029b8:	89 f3                	mov    %esi,%ebx
801029ba:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801029bd:	89 45 10             	mov    %eax,0x10(%ebp)
}
801029c0:	90                   	nop
801029c1:	5b                   	pop    %ebx
801029c2:	5e                   	pop    %esi
801029c3:	5d                   	pop    %ebp
801029c4:	c3                   	ret    

801029c5 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801029c5:	55                   	push   %ebp
801029c6:	89 e5                	mov    %esp,%ebp
801029c8:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801029cb:	90                   	nop
801029cc:	68 f7 01 00 00       	push   $0x1f7
801029d1:	e8 65 ff ff ff       	call   8010293b <inb>
801029d6:	83 c4 04             	add    $0x4,%esp
801029d9:	0f b6 c0             	movzbl %al,%eax
801029dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
801029df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029e2:	25 c0 00 00 00       	and    $0xc0,%eax
801029e7:	83 f8 40             	cmp    $0x40,%eax
801029ea:	75 e0                	jne    801029cc <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801029ec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801029f0:	74 11                	je     80102a03 <idewait+0x3e>
801029f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029f5:	83 e0 21             	and    $0x21,%eax
801029f8:	85 c0                	test   %eax,%eax
801029fa:	74 07                	je     80102a03 <idewait+0x3e>
    return -1;
801029fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102a01:	eb 05                	jmp    80102a08 <idewait+0x43>
  return 0;
80102a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102a08:	c9                   	leave  
80102a09:	c3                   	ret    

80102a0a <ideinit>:

void
ideinit(void)
{
80102a0a:	55                   	push   %ebp
80102a0b:	89 e5                	mov    %esp,%ebp
80102a0d:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102a10:	83 ec 08             	sub    $0x8,%esp
80102a13:	68 a3 94 10 80       	push   $0x801094a3
80102a18:	68 60 36 11 80       	push   $0x80113660
80102a1d:	e8 a9 32 00 00       	call   80105ccb <initlock>
80102a22:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102a25:	a1 40 39 11 80       	mov    0x80113940,%eax
80102a2a:	83 e8 01             	sub    $0x1,%eax
80102a2d:	83 ec 08             	sub    $0x8,%esp
80102a30:	50                   	push   %eax
80102a31:	6a 0e                	push   $0xe
80102a33:	e8 a3 04 00 00       	call   80102edb <ioapicenable>
80102a38:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102a3b:	83 ec 0c             	sub    $0xc,%esp
80102a3e:	6a 00                	push   $0x0
80102a40:	e8 80 ff ff ff       	call   801029c5 <idewait>
80102a45:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102a48:	83 ec 08             	sub    $0x8,%esp
80102a4b:	68 f0 00 00 00       	push   $0xf0
80102a50:	68 f6 01 00 00       	push   $0x1f6
80102a55:	e8 24 ff ff ff       	call   8010297e <outb>
80102a5a:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102a5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a64:	eb 24                	jmp    80102a8a <ideinit+0x80>
    if(inb(0x1f7) != 0){
80102a66:	83 ec 0c             	sub    $0xc,%esp
80102a69:	68 f7 01 00 00       	push   $0x1f7
80102a6e:	e8 c8 fe ff ff       	call   8010293b <inb>
80102a73:	83 c4 10             	add    $0x10,%esp
80102a76:	84 c0                	test   %al,%al
80102a78:	74 0c                	je     80102a86 <ideinit+0x7c>
      havedisk1 = 1;
80102a7a:	c7 05 98 36 11 80 01 	movl   $0x1,0x80113698
80102a81:	00 00 00 
      break;
80102a84:	eb 0d                	jmp    80102a93 <ideinit+0x89>
  for(i=0; i<1000; i++){
80102a86:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a8a:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102a91:	7e d3                	jle    80102a66 <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102a93:	83 ec 08             	sub    $0x8,%esp
80102a96:	68 e0 00 00 00       	push   $0xe0
80102a9b:	68 f6 01 00 00       	push   $0x1f6
80102aa0:	e8 d9 fe ff ff       	call   8010297e <outb>
80102aa5:	83 c4 10             	add    $0x10,%esp
}
80102aa8:	90                   	nop
80102aa9:	c9                   	leave  
80102aaa:	c3                   	ret    

80102aab <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102aab:	55                   	push   %ebp
80102aac:	89 e5                	mov    %esp,%ebp
80102aae:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102ab1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102ab5:	75 0d                	jne    80102ac4 <idestart+0x19>
    panic("idestart");
80102ab7:	83 ec 0c             	sub    $0xc,%esp
80102aba:	68 a7 94 10 80       	push   $0x801094a7
80102abf:	e8 f1 da ff ff       	call   801005b5 <panic>
  if(b->blockno >= FSSIZE)
80102ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac7:	8b 40 08             	mov    0x8(%eax),%eax
80102aca:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102acf:	76 0d                	jbe    80102ade <idestart+0x33>
    panic("incorrect blockno");
80102ad1:	83 ec 0c             	sub    $0xc,%esp
80102ad4:	68 b0 94 10 80       	push   $0x801094b0
80102ad9:	e8 d7 da ff ff       	call   801005b5 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102ade:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae8:	8b 50 08             	mov    0x8(%eax),%edx
80102aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aee:	0f af c2             	imul   %edx,%eax
80102af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102af4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102af8:	75 07                	jne    80102b01 <idestart+0x56>
80102afa:	b8 20 00 00 00       	mov    $0x20,%eax
80102aff:	eb 05                	jmp    80102b06 <idestart+0x5b>
80102b01:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102b06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102b09:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102b0d:	75 07                	jne    80102b16 <idestart+0x6b>
80102b0f:	b8 30 00 00 00       	mov    $0x30,%eax
80102b14:	eb 05                	jmp    80102b1b <idestart+0x70>
80102b16:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102b1b:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102b1e:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102b22:	7e 0d                	jle    80102b31 <idestart+0x86>
80102b24:	83 ec 0c             	sub    $0xc,%esp
80102b27:	68 a7 94 10 80       	push   $0x801094a7
80102b2c:	e8 84 da ff ff       	call   801005b5 <panic>

  idewait(0);
80102b31:	83 ec 0c             	sub    $0xc,%esp
80102b34:	6a 00                	push   $0x0
80102b36:	e8 8a fe ff ff       	call   801029c5 <idewait>
80102b3b:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102b3e:	83 ec 08             	sub    $0x8,%esp
80102b41:	6a 00                	push   $0x0
80102b43:	68 f6 03 00 00       	push   $0x3f6
80102b48:	e8 31 fe ff ff       	call   8010297e <outb>
80102b4d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b53:	0f b6 c0             	movzbl %al,%eax
80102b56:	83 ec 08             	sub    $0x8,%esp
80102b59:	50                   	push   %eax
80102b5a:	68 f2 01 00 00       	push   $0x1f2
80102b5f:	e8 1a fe ff ff       	call   8010297e <outb>
80102b64:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b6a:	0f b6 c0             	movzbl %al,%eax
80102b6d:	83 ec 08             	sub    $0x8,%esp
80102b70:	50                   	push   %eax
80102b71:	68 f3 01 00 00       	push   $0x1f3
80102b76:	e8 03 fe ff ff       	call   8010297e <outb>
80102b7b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b81:	c1 f8 08             	sar    $0x8,%eax
80102b84:	0f b6 c0             	movzbl %al,%eax
80102b87:	83 ec 08             	sub    $0x8,%esp
80102b8a:	50                   	push   %eax
80102b8b:	68 f4 01 00 00       	push   $0x1f4
80102b90:	e8 e9 fd ff ff       	call   8010297e <outb>
80102b95:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b9b:	c1 f8 10             	sar    $0x10,%eax
80102b9e:	0f b6 c0             	movzbl %al,%eax
80102ba1:	83 ec 08             	sub    $0x8,%esp
80102ba4:	50                   	push   %eax
80102ba5:	68 f5 01 00 00       	push   $0x1f5
80102baa:	e8 cf fd ff ff       	call   8010297e <outb>
80102baf:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb5:	8b 40 04             	mov    0x4(%eax),%eax
80102bb8:	c1 e0 04             	shl    $0x4,%eax
80102bbb:	83 e0 10             	and    $0x10,%eax
80102bbe:	89 c2                	mov    %eax,%edx
80102bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bc3:	c1 f8 18             	sar    $0x18,%eax
80102bc6:	83 e0 0f             	and    $0xf,%eax
80102bc9:	09 d0                	or     %edx,%eax
80102bcb:	83 c8 e0             	or     $0xffffffe0,%eax
80102bce:	0f b6 c0             	movzbl %al,%eax
80102bd1:	83 ec 08             	sub    $0x8,%esp
80102bd4:	50                   	push   %eax
80102bd5:	68 f6 01 00 00       	push   $0x1f6
80102bda:	e8 9f fd ff ff       	call   8010297e <outb>
80102bdf:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102be2:	8b 45 08             	mov    0x8(%ebp),%eax
80102be5:	8b 00                	mov    (%eax),%eax
80102be7:	83 e0 04             	and    $0x4,%eax
80102bea:	85 c0                	test   %eax,%eax
80102bec:	74 35                	je     80102c23 <idestart+0x178>
    outb(0x1f7, write_cmd);
80102bee:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102bf1:	0f b6 c0             	movzbl %al,%eax
80102bf4:	83 ec 08             	sub    $0x8,%esp
80102bf7:	50                   	push   %eax
80102bf8:	68 f7 01 00 00       	push   $0x1f7
80102bfd:	e8 7c fd ff ff       	call   8010297e <outb>
80102c02:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102c05:	8b 45 08             	mov    0x8(%ebp),%eax
80102c08:	83 c0 5c             	add    $0x5c,%eax
80102c0b:	83 ec 04             	sub    $0x4,%esp
80102c0e:	68 80 00 00 00       	push   $0x80
80102c13:	50                   	push   %eax
80102c14:	68 f0 01 00 00       	push   $0x1f0
80102c19:	e8 81 fd ff ff       	call   8010299f <outsl>
80102c1e:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102c21:	eb 17                	jmp    80102c3a <idestart+0x18f>
    outb(0x1f7, read_cmd);
80102c23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102c26:	0f b6 c0             	movzbl %al,%eax
80102c29:	83 ec 08             	sub    $0x8,%esp
80102c2c:	50                   	push   %eax
80102c2d:	68 f7 01 00 00       	push   $0x1f7
80102c32:	e8 47 fd ff ff       	call   8010297e <outb>
80102c37:	83 c4 10             	add    $0x10,%esp
}
80102c3a:	90                   	nop
80102c3b:	c9                   	leave  
80102c3c:	c3                   	ret    

80102c3d <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102c3d:	55                   	push   %ebp
80102c3e:	89 e5                	mov    %esp,%ebp
80102c40:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102c43:	83 ec 0c             	sub    $0xc,%esp
80102c46:	68 60 36 11 80       	push   $0x80113660
80102c4b:	e8 9d 30 00 00       	call   80105ced <acquire>
80102c50:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102c53:	a1 94 36 11 80       	mov    0x80113694,%eax
80102c58:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102c5b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c5f:	75 15                	jne    80102c76 <ideintr+0x39>
    release(&idelock);
80102c61:	83 ec 0c             	sub    $0xc,%esp
80102c64:	68 60 36 11 80       	push   $0x80113660
80102c69:	e8 ed 30 00 00       	call   80105d5b <release>
80102c6e:	83 c4 10             	add    $0x10,%esp
    return;
80102c71:	e9 9a 00 00 00       	jmp    80102d10 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c79:	8b 40 58             	mov    0x58(%eax),%eax
80102c7c:	a3 94 36 11 80       	mov    %eax,0x80113694

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c84:	8b 00                	mov    (%eax),%eax
80102c86:	83 e0 04             	and    $0x4,%eax
80102c89:	85 c0                	test   %eax,%eax
80102c8b:	75 2d                	jne    80102cba <ideintr+0x7d>
80102c8d:	83 ec 0c             	sub    $0xc,%esp
80102c90:	6a 01                	push   $0x1
80102c92:	e8 2e fd ff ff       	call   801029c5 <idewait>
80102c97:	83 c4 10             	add    $0x10,%esp
80102c9a:	85 c0                	test   %eax,%eax
80102c9c:	78 1c                	js     80102cba <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca1:	83 c0 5c             	add    $0x5c,%eax
80102ca4:	83 ec 04             	sub    $0x4,%esp
80102ca7:	68 80 00 00 00       	push   $0x80
80102cac:	50                   	push   %eax
80102cad:	68 f0 01 00 00       	push   $0x1f0
80102cb2:	e8 a1 fc ff ff       	call   80102958 <insl>
80102cb7:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cbd:	8b 00                	mov    (%eax),%eax
80102cbf:	83 c8 02             	or     $0x2,%eax
80102cc2:	89 c2                	mov    %eax,%edx
80102cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc7:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccc:	8b 00                	mov    (%eax),%eax
80102cce:	83 e0 fb             	and    $0xfffffffb,%eax
80102cd1:	89 c2                	mov    %eax,%edx
80102cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd6:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102cd8:	83 ec 0c             	sub    $0xc,%esp
80102cdb:	ff 75 f4             	push   -0xc(%ebp)
80102cde:	e8 dc 26 00 00       	call   801053bf <wakeup>
80102ce3:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ce6:	a1 94 36 11 80       	mov    0x80113694,%eax
80102ceb:	85 c0                	test   %eax,%eax
80102ced:	74 11                	je     80102d00 <ideintr+0xc3>
    idestart(idequeue);
80102cef:	a1 94 36 11 80       	mov    0x80113694,%eax
80102cf4:	83 ec 0c             	sub    $0xc,%esp
80102cf7:	50                   	push   %eax
80102cf8:	e8 ae fd ff ff       	call   80102aab <idestart>
80102cfd:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102d00:	83 ec 0c             	sub    $0xc,%esp
80102d03:	68 60 36 11 80       	push   $0x80113660
80102d08:	e8 4e 30 00 00       	call   80105d5b <release>
80102d0d:	83 c4 10             	add    $0x10,%esp
}
80102d10:	c9                   	leave  
80102d11:	c3                   	ret    

80102d12 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102d12:	55                   	push   %ebp
80102d13:	89 e5                	mov    %esp,%ebp
80102d15:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102d18:	8b 45 08             	mov    0x8(%ebp),%eax
80102d1b:	83 c0 0c             	add    $0xc,%eax
80102d1e:	83 ec 0c             	sub    $0xc,%esp
80102d21:	50                   	push   %eax
80102d22:	e8 0f 2f 00 00       	call   80105c36 <holdingsleep>
80102d27:	83 c4 10             	add    $0x10,%esp
80102d2a:	85 c0                	test   %eax,%eax
80102d2c:	75 0d                	jne    80102d3b <iderw+0x29>
    panic("iderw: buf not locked");
80102d2e:	83 ec 0c             	sub    $0xc,%esp
80102d31:	68 c2 94 10 80       	push   $0x801094c2
80102d36:	e8 7a d8 ff ff       	call   801005b5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3e:	8b 00                	mov    (%eax),%eax
80102d40:	83 e0 06             	and    $0x6,%eax
80102d43:	83 f8 02             	cmp    $0x2,%eax
80102d46:	75 0d                	jne    80102d55 <iderw+0x43>
    panic("iderw: nothing to do");
80102d48:	83 ec 0c             	sub    $0xc,%esp
80102d4b:	68 d8 94 10 80       	push   $0x801094d8
80102d50:	e8 60 d8 ff ff       	call   801005b5 <panic>
  if(b->dev != 0 && !havedisk1)
80102d55:	8b 45 08             	mov    0x8(%ebp),%eax
80102d58:	8b 40 04             	mov    0x4(%eax),%eax
80102d5b:	85 c0                	test   %eax,%eax
80102d5d:	74 16                	je     80102d75 <iderw+0x63>
80102d5f:	a1 98 36 11 80       	mov    0x80113698,%eax
80102d64:	85 c0                	test   %eax,%eax
80102d66:	75 0d                	jne    80102d75 <iderw+0x63>
    panic("iderw: ide disk 1 not present");
80102d68:	83 ec 0c             	sub    $0xc,%esp
80102d6b:	68 ed 94 10 80       	push   $0x801094ed
80102d70:	e8 40 d8 ff ff       	call   801005b5 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102d75:	83 ec 0c             	sub    $0xc,%esp
80102d78:	68 60 36 11 80       	push   $0x80113660
80102d7d:	e8 6b 2f 00 00       	call   80105ced <acquire>
80102d82:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102d85:	8b 45 08             	mov    0x8(%ebp),%eax
80102d88:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102d8f:	c7 45 f4 94 36 11 80 	movl   $0x80113694,-0xc(%ebp)
80102d96:	eb 0b                	jmp    80102da3 <iderw+0x91>
80102d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d9b:	8b 00                	mov    (%eax),%eax
80102d9d:	83 c0 58             	add    $0x58,%eax
80102da0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102da6:	8b 00                	mov    (%eax),%eax
80102da8:	85 c0                	test   %eax,%eax
80102daa:	75 ec                	jne    80102d98 <iderw+0x86>
    ;
  *pp = b;
80102dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102daf:	8b 55 08             	mov    0x8(%ebp),%edx
80102db2:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102db4:	a1 94 36 11 80       	mov    0x80113694,%eax
80102db9:	39 45 08             	cmp    %eax,0x8(%ebp)
80102dbc:	75 23                	jne    80102de1 <iderw+0xcf>
    idestart(b);
80102dbe:	83 ec 0c             	sub    $0xc,%esp
80102dc1:	ff 75 08             	push   0x8(%ebp)
80102dc4:	e8 e2 fc ff ff       	call   80102aab <idestart>
80102dc9:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102dcc:	eb 13                	jmp    80102de1 <iderw+0xcf>
    sleep(b, &idelock);
80102dce:	83 ec 08             	sub    $0x8,%esp
80102dd1:	68 60 36 11 80       	push   $0x80113660
80102dd6:	ff 75 08             	push   0x8(%ebp)
80102dd9:	e8 f7 24 00 00       	call   801052d5 <sleep>
80102dde:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102de1:	8b 45 08             	mov    0x8(%ebp),%eax
80102de4:	8b 00                	mov    (%eax),%eax
80102de6:	83 e0 06             	and    $0x6,%eax
80102de9:	83 f8 02             	cmp    $0x2,%eax
80102dec:	75 e0                	jne    80102dce <iderw+0xbc>
  }


  release(&idelock);
80102dee:	83 ec 0c             	sub    $0xc,%esp
80102df1:	68 60 36 11 80       	push   $0x80113660
80102df6:	e8 60 2f 00 00       	call   80105d5b <release>
80102dfb:	83 c4 10             	add    $0x10,%esp
}
80102dfe:	90                   	nop
80102dff:	c9                   	leave  
80102e00:	c3                   	ret    

80102e01 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102e01:	55                   	push   %ebp
80102e02:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102e04:	a1 9c 36 11 80       	mov    0x8011369c,%eax
80102e09:	8b 55 08             	mov    0x8(%ebp),%edx
80102e0c:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102e0e:	a1 9c 36 11 80       	mov    0x8011369c,%eax
80102e13:	8b 40 10             	mov    0x10(%eax),%eax
}
80102e16:	5d                   	pop    %ebp
80102e17:	c3                   	ret    

80102e18 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102e18:	55                   	push   %ebp
80102e19:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102e1b:	a1 9c 36 11 80       	mov    0x8011369c,%eax
80102e20:	8b 55 08             	mov    0x8(%ebp),%edx
80102e23:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102e25:	a1 9c 36 11 80       	mov    0x8011369c,%eax
80102e2a:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e2d:	89 50 10             	mov    %edx,0x10(%eax)
}
80102e30:	90                   	nop
80102e31:	5d                   	pop    %ebp
80102e32:	c3                   	ret    

80102e33 <ioapicinit>:

void
ioapicinit(void)
{
80102e33:	55                   	push   %ebp
80102e34:	89 e5                	mov    %esp,%ebp
80102e36:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102e39:	c7 05 9c 36 11 80 00 	movl   $0xfec00000,0x8011369c
80102e40:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102e43:	6a 01                	push   $0x1
80102e45:	e8 b7 ff ff ff       	call   80102e01 <ioapicread>
80102e4a:	83 c4 04             	add    $0x4,%esp
80102e4d:	c1 e8 10             	shr    $0x10,%eax
80102e50:	25 ff 00 00 00       	and    $0xff,%eax
80102e55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102e58:	6a 00                	push   $0x0
80102e5a:	e8 a2 ff ff ff       	call   80102e01 <ioapicread>
80102e5f:	83 c4 04             	add    $0x4,%esp
80102e62:	c1 e8 18             	shr    $0x18,%eax
80102e65:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102e68:	0f b6 05 44 39 11 80 	movzbl 0x80113944,%eax
80102e6f:	0f b6 c0             	movzbl %al,%eax
80102e72:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102e75:	74 10                	je     80102e87 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102e77:	83 ec 0c             	sub    $0xc,%esp
80102e7a:	68 0c 95 10 80       	push   $0x8010950c
80102e7f:	e8 7c d5 ff ff       	call   80100400 <cprintf>
80102e84:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102e87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e8e:	eb 3f                	jmp    80102ecf <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e93:	83 c0 20             	add    $0x20,%eax
80102e96:	0d 00 00 01 00       	or     $0x10000,%eax
80102e9b:	89 c2                	mov    %eax,%edx
80102e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea0:	83 c0 08             	add    $0x8,%eax
80102ea3:	01 c0                	add    %eax,%eax
80102ea5:	83 ec 08             	sub    $0x8,%esp
80102ea8:	52                   	push   %edx
80102ea9:	50                   	push   %eax
80102eaa:	e8 69 ff ff ff       	call   80102e18 <ioapicwrite>
80102eaf:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eb5:	83 c0 08             	add    $0x8,%eax
80102eb8:	01 c0                	add    %eax,%eax
80102eba:	83 c0 01             	add    $0x1,%eax
80102ebd:	83 ec 08             	sub    $0x8,%esp
80102ec0:	6a 00                	push   $0x0
80102ec2:	50                   	push   %eax
80102ec3:	e8 50 ff ff ff       	call   80102e18 <ioapicwrite>
80102ec8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102ecb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ed2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ed5:	7e b9                	jle    80102e90 <ioapicinit+0x5d>
  }
}
80102ed7:	90                   	nop
80102ed8:	90                   	nop
80102ed9:	c9                   	leave  
80102eda:	c3                   	ret    

80102edb <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102edb:	55                   	push   %ebp
80102edc:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ede:	8b 45 08             	mov    0x8(%ebp),%eax
80102ee1:	83 c0 20             	add    $0x20,%eax
80102ee4:	89 c2                	mov    %eax,%edx
80102ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ee9:	83 c0 08             	add    $0x8,%eax
80102eec:	01 c0                	add    %eax,%eax
80102eee:	52                   	push   %edx
80102eef:	50                   	push   %eax
80102ef0:	e8 23 ff ff ff       	call   80102e18 <ioapicwrite>
80102ef5:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102efb:	c1 e0 18             	shl    $0x18,%eax
80102efe:	89 c2                	mov    %eax,%edx
80102f00:	8b 45 08             	mov    0x8(%ebp),%eax
80102f03:	83 c0 08             	add    $0x8,%eax
80102f06:	01 c0                	add    %eax,%eax
80102f08:	83 c0 01             	add    $0x1,%eax
80102f0b:	52                   	push   %edx
80102f0c:	50                   	push   %eax
80102f0d:	e8 06 ff ff ff       	call   80102e18 <ioapicwrite>
80102f12:	83 c4 08             	add    $0x8,%esp
}
80102f15:	90                   	nop
80102f16:	c9                   	leave  
80102f17:	c3                   	ret    

80102f18 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102f18:	55                   	push   %ebp
80102f19:	89 e5                	mov    %esp,%ebp
80102f1b:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102f1e:	83 ec 08             	sub    $0x8,%esp
80102f21:	68 3e 95 10 80       	push   $0x8010953e
80102f26:	68 a0 36 11 80       	push   $0x801136a0
80102f2b:	e8 9b 2d 00 00       	call   80105ccb <initlock>
80102f30:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102f33:	c7 05 d4 36 11 80 00 	movl   $0x0,0x801136d4
80102f3a:	00 00 00 
  freerange(vstart, vend);
80102f3d:	83 ec 08             	sub    $0x8,%esp
80102f40:	ff 75 0c             	push   0xc(%ebp)
80102f43:	ff 75 08             	push   0x8(%ebp)
80102f46:	e8 2a 00 00 00       	call   80102f75 <freerange>
80102f4b:	83 c4 10             	add    $0x10,%esp
}
80102f4e:	90                   	nop
80102f4f:	c9                   	leave  
80102f50:	c3                   	ret    

80102f51 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102f51:	55                   	push   %ebp
80102f52:	89 e5                	mov    %esp,%ebp
80102f54:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102f57:	83 ec 08             	sub    $0x8,%esp
80102f5a:	ff 75 0c             	push   0xc(%ebp)
80102f5d:	ff 75 08             	push   0x8(%ebp)
80102f60:	e8 10 00 00 00       	call   80102f75 <freerange>
80102f65:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102f68:	c7 05 d4 36 11 80 01 	movl   $0x1,0x801136d4
80102f6f:	00 00 00 
}
80102f72:	90                   	nop
80102f73:	c9                   	leave  
80102f74:	c3                   	ret    

80102f75 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102f75:	55                   	push   %ebp
80102f76:	89 e5                	mov    %esp,%ebp
80102f78:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80102f7e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102f83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102f88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102f8b:	eb 15                	jmp    80102fa2 <freerange+0x2d>
    kfree(p);
80102f8d:	83 ec 0c             	sub    $0xc,%esp
80102f90:	ff 75 f4             	push   -0xc(%ebp)
80102f93:	e8 1b 00 00 00       	call   80102fb3 <kfree>
80102f98:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102f9b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fa5:	05 00 10 00 00       	add    $0x1000,%eax
80102faa:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102fad:	73 de                	jae    80102f8d <freerange+0x18>
}
80102faf:	90                   	nop
80102fb0:	90                   	nop
80102fb1:	c9                   	leave  
80102fb2:	c3                   	ret    

80102fb3 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102fb3:	55                   	push   %ebp
80102fb4:	89 e5                	mov    %esp,%ebp
80102fb6:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80102fbc:	25 ff 0f 00 00       	and    $0xfff,%eax
80102fc1:	85 c0                	test   %eax,%eax
80102fc3:	75 18                	jne    80102fdd <kfree+0x2a>
80102fc5:	81 7d 08 00 79 11 80 	cmpl   $0x80117900,0x8(%ebp)
80102fcc:	72 0f                	jb     80102fdd <kfree+0x2a>
80102fce:	8b 45 08             	mov    0x8(%ebp),%eax
80102fd1:	05 00 00 00 80       	add    $0x80000000,%eax
80102fd6:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102fdb:	76 0d                	jbe    80102fea <kfree+0x37>
    panic("kfree");
80102fdd:	83 ec 0c             	sub    $0xc,%esp
80102fe0:	68 43 95 10 80       	push   $0x80109543
80102fe5:	e8 cb d5 ff ff       	call   801005b5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102fea:	83 ec 04             	sub    $0x4,%esp
80102fed:	68 00 10 00 00       	push   $0x1000
80102ff2:	6a 01                	push   $0x1
80102ff4:	ff 75 08             	push   0x8(%ebp)
80102ff7:	e8 77 2f 00 00       	call   80105f73 <memset>
80102ffc:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102fff:	a1 d4 36 11 80       	mov    0x801136d4,%eax
80103004:	85 c0                	test   %eax,%eax
80103006:	74 10                	je     80103018 <kfree+0x65>
    acquire(&kmem.lock);
80103008:	83 ec 0c             	sub    $0xc,%esp
8010300b:	68 a0 36 11 80       	push   $0x801136a0
80103010:	e8 d8 2c 00 00       	call   80105ced <acquire>
80103015:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80103018:	8b 45 08             	mov    0x8(%ebp),%eax
8010301b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010301e:	8b 15 d8 36 11 80    	mov    0x801136d8,%edx
80103024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103027:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80103029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010302c:	a3 d8 36 11 80       	mov    %eax,0x801136d8
  if(kmem.use_lock)
80103031:	a1 d4 36 11 80       	mov    0x801136d4,%eax
80103036:	85 c0                	test   %eax,%eax
80103038:	74 10                	je     8010304a <kfree+0x97>
    release(&kmem.lock);
8010303a:	83 ec 0c             	sub    $0xc,%esp
8010303d:	68 a0 36 11 80       	push   $0x801136a0
80103042:	e8 14 2d 00 00       	call   80105d5b <release>
80103047:	83 c4 10             	add    $0x10,%esp
}
8010304a:	90                   	nop
8010304b:	c9                   	leave  
8010304c:	c3                   	ret    

8010304d <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010304d:	55                   	push   %ebp
8010304e:	89 e5                	mov    %esp,%ebp
80103050:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103053:	a1 d4 36 11 80       	mov    0x801136d4,%eax
80103058:	85 c0                	test   %eax,%eax
8010305a:	74 10                	je     8010306c <kalloc+0x1f>
    acquire(&kmem.lock);
8010305c:	83 ec 0c             	sub    $0xc,%esp
8010305f:	68 a0 36 11 80       	push   $0x801136a0
80103064:	e8 84 2c 00 00       	call   80105ced <acquire>
80103069:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
8010306c:	a1 d8 36 11 80       	mov    0x801136d8,%eax
80103071:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103074:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103078:	74 0a                	je     80103084 <kalloc+0x37>
    kmem.freelist = r->next;
8010307a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010307d:	8b 00                	mov    (%eax),%eax
8010307f:	a3 d8 36 11 80       	mov    %eax,0x801136d8
  if(kmem.use_lock)
80103084:	a1 d4 36 11 80       	mov    0x801136d4,%eax
80103089:	85 c0                	test   %eax,%eax
8010308b:	74 10                	je     8010309d <kalloc+0x50>
    release(&kmem.lock);
8010308d:	83 ec 0c             	sub    $0xc,%esp
80103090:	68 a0 36 11 80       	push   $0x801136a0
80103095:	e8 c1 2c 00 00       	call   80105d5b <release>
8010309a:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010309d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801030a0:	c9                   	leave  
801030a1:	c3                   	ret    

801030a2 <inb>:
{
801030a2:	55                   	push   %ebp
801030a3:	89 e5                	mov    %esp,%ebp
801030a5:	83 ec 14             	sub    $0x14,%esp
801030a8:	8b 45 08             	mov    0x8(%ebp),%eax
801030ab:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801030af:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801030b3:	89 c2                	mov    %eax,%edx
801030b5:	ec                   	in     (%dx),%al
801030b6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801030b9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801030bd:	c9                   	leave  
801030be:	c3                   	ret    

801030bf <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801030bf:	55                   	push   %ebp
801030c0:	89 e5                	mov    %esp,%ebp
801030c2:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801030c5:	6a 64                	push   $0x64
801030c7:	e8 d6 ff ff ff       	call   801030a2 <inb>
801030cc:	83 c4 04             	add    $0x4,%esp
801030cf:	0f b6 c0             	movzbl %al,%eax
801030d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801030d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030d8:	83 e0 01             	and    $0x1,%eax
801030db:	85 c0                	test   %eax,%eax
801030dd:	75 0a                	jne    801030e9 <kbdgetc+0x2a>
    return -1;
801030df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801030e4:	e9 23 01 00 00       	jmp    8010320c <kbdgetc+0x14d>
  data = inb(KBDATAP);
801030e9:	6a 60                	push   $0x60
801030eb:	e8 b2 ff ff ff       	call   801030a2 <inb>
801030f0:	83 c4 04             	add    $0x4,%esp
801030f3:	0f b6 c0             	movzbl %al,%eax
801030f6:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801030f9:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103100:	75 17                	jne    80103119 <kbdgetc+0x5a>
    shift |= E0ESC;
80103102:	a1 dc 36 11 80       	mov    0x801136dc,%eax
80103107:	83 c8 40             	or     $0x40,%eax
8010310a:	a3 dc 36 11 80       	mov    %eax,0x801136dc
    return 0;
8010310f:	b8 00 00 00 00       	mov    $0x0,%eax
80103114:	e9 f3 00 00 00       	jmp    8010320c <kbdgetc+0x14d>
  } else if(data & 0x80){
80103119:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010311c:	25 80 00 00 00       	and    $0x80,%eax
80103121:	85 c0                	test   %eax,%eax
80103123:	74 45                	je     8010316a <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103125:	a1 dc 36 11 80       	mov    0x801136dc,%eax
8010312a:	83 e0 40             	and    $0x40,%eax
8010312d:	85 c0                	test   %eax,%eax
8010312f:	75 08                	jne    80103139 <kbdgetc+0x7a>
80103131:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103134:	83 e0 7f             	and    $0x7f,%eax
80103137:	eb 03                	jmp    8010313c <kbdgetc+0x7d>
80103139:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010313c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010313f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103142:	05 40 a0 10 80       	add    $0x8010a040,%eax
80103147:	0f b6 00             	movzbl (%eax),%eax
8010314a:	83 c8 40             	or     $0x40,%eax
8010314d:	0f b6 c0             	movzbl %al,%eax
80103150:	f7 d0                	not    %eax
80103152:	89 c2                	mov    %eax,%edx
80103154:	a1 dc 36 11 80       	mov    0x801136dc,%eax
80103159:	21 d0                	and    %edx,%eax
8010315b:	a3 dc 36 11 80       	mov    %eax,0x801136dc
    return 0;
80103160:	b8 00 00 00 00       	mov    $0x0,%eax
80103165:	e9 a2 00 00 00       	jmp    8010320c <kbdgetc+0x14d>
  } else if(shift & E0ESC){
8010316a:	a1 dc 36 11 80       	mov    0x801136dc,%eax
8010316f:	83 e0 40             	and    $0x40,%eax
80103172:	85 c0                	test   %eax,%eax
80103174:	74 14                	je     8010318a <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103176:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010317d:	a1 dc 36 11 80       	mov    0x801136dc,%eax
80103182:	83 e0 bf             	and    $0xffffffbf,%eax
80103185:	a3 dc 36 11 80       	mov    %eax,0x801136dc
  }

  shift |= shiftcode[data];
8010318a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010318d:	05 40 a0 10 80       	add    $0x8010a040,%eax
80103192:	0f b6 00             	movzbl (%eax),%eax
80103195:	0f b6 d0             	movzbl %al,%edx
80103198:	a1 dc 36 11 80       	mov    0x801136dc,%eax
8010319d:	09 d0                	or     %edx,%eax
8010319f:	a3 dc 36 11 80       	mov    %eax,0x801136dc
  shift ^= togglecode[data];
801031a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801031a7:	05 40 a1 10 80       	add    $0x8010a140,%eax
801031ac:	0f b6 00             	movzbl (%eax),%eax
801031af:	0f b6 d0             	movzbl %al,%edx
801031b2:	a1 dc 36 11 80       	mov    0x801136dc,%eax
801031b7:	31 d0                	xor    %edx,%eax
801031b9:	a3 dc 36 11 80       	mov    %eax,0x801136dc
  c = charcode[shift & (CTL | SHIFT)][data];
801031be:	a1 dc 36 11 80       	mov    0x801136dc,%eax
801031c3:	83 e0 03             	and    $0x3,%eax
801031c6:	8b 14 85 40 a5 10 80 	mov    -0x7fef5ac0(,%eax,4),%edx
801031cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801031d0:	01 d0                	add    %edx,%eax
801031d2:	0f b6 00             	movzbl (%eax),%eax
801031d5:	0f b6 c0             	movzbl %al,%eax
801031d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801031db:	a1 dc 36 11 80       	mov    0x801136dc,%eax
801031e0:	83 e0 08             	and    $0x8,%eax
801031e3:	85 c0                	test   %eax,%eax
801031e5:	74 22                	je     80103209 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
801031e7:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801031eb:	76 0c                	jbe    801031f9 <kbdgetc+0x13a>
801031ed:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801031f1:	77 06                	ja     801031f9 <kbdgetc+0x13a>
      c += 'A' - 'a';
801031f3:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801031f7:	eb 10                	jmp    80103209 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
801031f9:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801031fd:	76 0a                	jbe    80103209 <kbdgetc+0x14a>
801031ff:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103203:	77 04                	ja     80103209 <kbdgetc+0x14a>
      c += 'a' - 'A';
80103205:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103209:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010320c:	c9                   	leave  
8010320d:	c3                   	ret    

8010320e <kbdintr>:

void
kbdintr(void)
{
8010320e:	55                   	push   %ebp
8010320f:	89 e5                	mov    %esp,%ebp
80103211:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103214:	83 ec 0c             	sub    $0xc,%esp
80103217:	68 bf 30 10 80       	push   $0x801030bf
8010321c:	e8 2e d6 ff ff       	call   8010084f <consoleintr>
80103221:	83 c4 10             	add    $0x10,%esp
}
80103224:	90                   	nop
80103225:	c9                   	leave  
80103226:	c3                   	ret    

80103227 <inb>:
{
80103227:	55                   	push   %ebp
80103228:	89 e5                	mov    %esp,%ebp
8010322a:	83 ec 14             	sub    $0x14,%esp
8010322d:	8b 45 08             	mov    0x8(%ebp),%eax
80103230:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103234:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103238:	89 c2                	mov    %eax,%edx
8010323a:	ec                   	in     (%dx),%al
8010323b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010323e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103242:	c9                   	leave  
80103243:	c3                   	ret    

80103244 <outb>:
{
80103244:	55                   	push   %ebp
80103245:	89 e5                	mov    %esp,%ebp
80103247:	83 ec 08             	sub    $0x8,%esp
8010324a:	8b 45 08             	mov    0x8(%ebp),%eax
8010324d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103250:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103254:	89 d0                	mov    %edx,%eax
80103256:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103259:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010325d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103261:	ee                   	out    %al,(%dx)
}
80103262:	90                   	nop
80103263:	c9                   	leave  
80103264:	c3                   	ret    

80103265 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80103265:	55                   	push   %ebp
80103266:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103268:	8b 15 e0 36 11 80    	mov    0x801136e0,%edx
8010326e:	8b 45 08             	mov    0x8(%ebp),%eax
80103271:	c1 e0 02             	shl    $0x2,%eax
80103274:	01 c2                	add    %eax,%edx
80103276:	8b 45 0c             	mov    0xc(%ebp),%eax
80103279:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010327b:	a1 e0 36 11 80       	mov    0x801136e0,%eax
80103280:	83 c0 20             	add    $0x20,%eax
80103283:	8b 00                	mov    (%eax),%eax
}
80103285:	90                   	nop
80103286:	5d                   	pop    %ebp
80103287:	c3                   	ret    

80103288 <lapicinit>:

void
lapicinit(void)
{
80103288:	55                   	push   %ebp
80103289:	89 e5                	mov    %esp,%ebp
  if(!lapic)
8010328b:	a1 e0 36 11 80       	mov    0x801136e0,%eax
80103290:	85 c0                	test   %eax,%eax
80103292:	0f 84 0c 01 00 00    	je     801033a4 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103298:	68 3f 01 00 00       	push   $0x13f
8010329d:	6a 3c                	push   $0x3c
8010329f:	e8 c1 ff ff ff       	call   80103265 <lapicw>
801032a4:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801032a7:	6a 0b                	push   $0xb
801032a9:	68 f8 00 00 00       	push   $0xf8
801032ae:	e8 b2 ff ff ff       	call   80103265 <lapicw>
801032b3:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801032b6:	68 20 00 02 00       	push   $0x20020
801032bb:	68 c8 00 00 00       	push   $0xc8
801032c0:	e8 a0 ff ff ff       	call   80103265 <lapicw>
801032c5:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
801032c8:	68 80 96 98 00       	push   $0x989680
801032cd:	68 e0 00 00 00       	push   $0xe0
801032d2:	e8 8e ff ff ff       	call   80103265 <lapicw>
801032d7:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801032da:	68 00 00 01 00       	push   $0x10000
801032df:	68 d4 00 00 00       	push   $0xd4
801032e4:	e8 7c ff ff ff       	call   80103265 <lapicw>
801032e9:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801032ec:	68 00 00 01 00       	push   $0x10000
801032f1:	68 d8 00 00 00       	push   $0xd8
801032f6:	e8 6a ff ff ff       	call   80103265 <lapicw>
801032fb:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801032fe:	a1 e0 36 11 80       	mov    0x801136e0,%eax
80103303:	83 c0 30             	add    $0x30,%eax
80103306:	8b 00                	mov    (%eax),%eax
80103308:	c1 e8 10             	shr    $0x10,%eax
8010330b:	25 fc 00 00 00       	and    $0xfc,%eax
80103310:	85 c0                	test   %eax,%eax
80103312:	74 12                	je     80103326 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80103314:	68 00 00 01 00       	push   $0x10000
80103319:	68 d0 00 00 00       	push   $0xd0
8010331e:	e8 42 ff ff ff       	call   80103265 <lapicw>
80103323:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103326:	6a 33                	push   $0x33
80103328:	68 dc 00 00 00       	push   $0xdc
8010332d:	e8 33 ff ff ff       	call   80103265 <lapicw>
80103332:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103335:	6a 00                	push   $0x0
80103337:	68 a0 00 00 00       	push   $0xa0
8010333c:	e8 24 ff ff ff       	call   80103265 <lapicw>
80103341:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103344:	6a 00                	push   $0x0
80103346:	68 a0 00 00 00       	push   $0xa0
8010334b:	e8 15 ff ff ff       	call   80103265 <lapicw>
80103350:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103353:	6a 00                	push   $0x0
80103355:	6a 2c                	push   $0x2c
80103357:	e8 09 ff ff ff       	call   80103265 <lapicw>
8010335c:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010335f:	6a 00                	push   $0x0
80103361:	68 c4 00 00 00       	push   $0xc4
80103366:	e8 fa fe ff ff       	call   80103265 <lapicw>
8010336b:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010336e:	68 00 85 08 00       	push   $0x88500
80103373:	68 c0 00 00 00       	push   $0xc0
80103378:	e8 e8 fe ff ff       	call   80103265 <lapicw>
8010337d:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103380:	90                   	nop
80103381:	a1 e0 36 11 80       	mov    0x801136e0,%eax
80103386:	05 00 03 00 00       	add    $0x300,%eax
8010338b:	8b 00                	mov    (%eax),%eax
8010338d:	25 00 10 00 00       	and    $0x1000,%eax
80103392:	85 c0                	test   %eax,%eax
80103394:	75 eb                	jne    80103381 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103396:	6a 00                	push   $0x0
80103398:	6a 20                	push   $0x20
8010339a:	e8 c6 fe ff ff       	call   80103265 <lapicw>
8010339f:	83 c4 08             	add    $0x8,%esp
801033a2:	eb 01                	jmp    801033a5 <lapicinit+0x11d>
    return;
801033a4:	90                   	nop
}
801033a5:	c9                   	leave  
801033a6:	c3                   	ret    

801033a7 <lapicid>:

int
lapicid(void)
{
801033a7:	55                   	push   %ebp
801033a8:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801033aa:	a1 e0 36 11 80       	mov    0x801136e0,%eax
801033af:	85 c0                	test   %eax,%eax
801033b1:	75 07                	jne    801033ba <lapicid+0x13>
    return 0;
801033b3:	b8 00 00 00 00       	mov    $0x0,%eax
801033b8:	eb 0d                	jmp    801033c7 <lapicid+0x20>
  return lapic[ID] >> 24;
801033ba:	a1 e0 36 11 80       	mov    0x801136e0,%eax
801033bf:	83 c0 20             	add    $0x20,%eax
801033c2:	8b 00                	mov    (%eax),%eax
801033c4:	c1 e8 18             	shr    $0x18,%eax
}
801033c7:	5d                   	pop    %ebp
801033c8:	c3                   	ret    

801033c9 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801033c9:	55                   	push   %ebp
801033ca:	89 e5                	mov    %esp,%ebp
  if(lapic)
801033cc:	a1 e0 36 11 80       	mov    0x801136e0,%eax
801033d1:	85 c0                	test   %eax,%eax
801033d3:	74 0c                	je     801033e1 <lapiceoi+0x18>
    lapicw(EOI, 0);
801033d5:	6a 00                	push   $0x0
801033d7:	6a 2c                	push   $0x2c
801033d9:	e8 87 fe ff ff       	call   80103265 <lapicw>
801033de:	83 c4 08             	add    $0x8,%esp
}
801033e1:	90                   	nop
801033e2:	c9                   	leave  
801033e3:	c3                   	ret    

801033e4 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801033e4:	55                   	push   %ebp
801033e5:	89 e5                	mov    %esp,%ebp
}
801033e7:	90                   	nop
801033e8:	5d                   	pop    %ebp
801033e9:	c3                   	ret    

801033ea <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801033ea:	55                   	push   %ebp
801033eb:	89 e5                	mov    %esp,%ebp
801033ed:	83 ec 14             	sub    $0x14,%esp
801033f0:	8b 45 08             	mov    0x8(%ebp),%eax
801033f3:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801033f6:	6a 0f                	push   $0xf
801033f8:	6a 70                	push   $0x70
801033fa:	e8 45 fe ff ff       	call   80103244 <outb>
801033ff:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103402:	6a 0a                	push   $0xa
80103404:	6a 71                	push   $0x71
80103406:	e8 39 fe ff ff       	call   80103244 <outb>
8010340b:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010340e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103415:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103418:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010341d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103420:	c1 e8 04             	shr    $0x4,%eax
80103423:	89 c2                	mov    %eax,%edx
80103425:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103428:	83 c0 02             	add    $0x2,%eax
8010342b:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010342e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103432:	c1 e0 18             	shl    $0x18,%eax
80103435:	50                   	push   %eax
80103436:	68 c4 00 00 00       	push   $0xc4
8010343b:	e8 25 fe ff ff       	call   80103265 <lapicw>
80103440:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103443:	68 00 c5 00 00       	push   $0xc500
80103448:	68 c0 00 00 00       	push   $0xc0
8010344d:	e8 13 fe ff ff       	call   80103265 <lapicw>
80103452:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103455:	68 c8 00 00 00       	push   $0xc8
8010345a:	e8 85 ff ff ff       	call   801033e4 <microdelay>
8010345f:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103462:	68 00 85 00 00       	push   $0x8500
80103467:	68 c0 00 00 00       	push   $0xc0
8010346c:	e8 f4 fd ff ff       	call   80103265 <lapicw>
80103471:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103474:	6a 64                	push   $0x64
80103476:	e8 69 ff ff ff       	call   801033e4 <microdelay>
8010347b:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010347e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103485:	eb 3d                	jmp    801034c4 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80103487:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010348b:	c1 e0 18             	shl    $0x18,%eax
8010348e:	50                   	push   %eax
8010348f:	68 c4 00 00 00       	push   $0xc4
80103494:	e8 cc fd ff ff       	call   80103265 <lapicw>
80103499:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010349c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010349f:	c1 e8 0c             	shr    $0xc,%eax
801034a2:	80 cc 06             	or     $0x6,%ah
801034a5:	50                   	push   %eax
801034a6:	68 c0 00 00 00       	push   $0xc0
801034ab:	e8 b5 fd ff ff       	call   80103265 <lapicw>
801034b0:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801034b3:	68 c8 00 00 00       	push   $0xc8
801034b8:	e8 27 ff ff ff       	call   801033e4 <microdelay>
801034bd:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801034c0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801034c4:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801034c8:	7e bd                	jle    80103487 <lapicstartap+0x9d>
  }
}
801034ca:	90                   	nop
801034cb:	90                   	nop
801034cc:	c9                   	leave  
801034cd:	c3                   	ret    

801034ce <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801034ce:	55                   	push   %ebp
801034cf:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801034d1:	8b 45 08             	mov    0x8(%ebp),%eax
801034d4:	0f b6 c0             	movzbl %al,%eax
801034d7:	50                   	push   %eax
801034d8:	6a 70                	push   $0x70
801034da:	e8 65 fd ff ff       	call   80103244 <outb>
801034df:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801034e2:	68 c8 00 00 00       	push   $0xc8
801034e7:	e8 f8 fe ff ff       	call   801033e4 <microdelay>
801034ec:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801034ef:	6a 71                	push   $0x71
801034f1:	e8 31 fd ff ff       	call   80103227 <inb>
801034f6:	83 c4 04             	add    $0x4,%esp
801034f9:	0f b6 c0             	movzbl %al,%eax
}
801034fc:	c9                   	leave  
801034fd:	c3                   	ret    

801034fe <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801034fe:	55                   	push   %ebp
801034ff:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103501:	6a 00                	push   $0x0
80103503:	e8 c6 ff ff ff       	call   801034ce <cmos_read>
80103508:	83 c4 04             	add    $0x4,%esp
8010350b:	8b 55 08             	mov    0x8(%ebp),%edx
8010350e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103510:	6a 02                	push   $0x2
80103512:	e8 b7 ff ff ff       	call   801034ce <cmos_read>
80103517:	83 c4 04             	add    $0x4,%esp
8010351a:	8b 55 08             	mov    0x8(%ebp),%edx
8010351d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103520:	6a 04                	push   $0x4
80103522:	e8 a7 ff ff ff       	call   801034ce <cmos_read>
80103527:	83 c4 04             	add    $0x4,%esp
8010352a:	8b 55 08             	mov    0x8(%ebp),%edx
8010352d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103530:	6a 07                	push   $0x7
80103532:	e8 97 ff ff ff       	call   801034ce <cmos_read>
80103537:	83 c4 04             	add    $0x4,%esp
8010353a:	8b 55 08             	mov    0x8(%ebp),%edx
8010353d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103540:	6a 08                	push   $0x8
80103542:	e8 87 ff ff ff       	call   801034ce <cmos_read>
80103547:	83 c4 04             	add    $0x4,%esp
8010354a:	8b 55 08             	mov    0x8(%ebp),%edx
8010354d:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103550:	6a 09                	push   $0x9
80103552:	e8 77 ff ff ff       	call   801034ce <cmos_read>
80103557:	83 c4 04             	add    $0x4,%esp
8010355a:	8b 55 08             	mov    0x8(%ebp),%edx
8010355d:	89 42 14             	mov    %eax,0x14(%edx)
}
80103560:	90                   	nop
80103561:	c9                   	leave  
80103562:	c3                   	ret    

80103563 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80103563:	55                   	push   %ebp
80103564:	89 e5                	mov    %esp,%ebp
80103566:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103569:	6a 0b                	push   $0xb
8010356b:	e8 5e ff ff ff       	call   801034ce <cmos_read>
80103570:	83 c4 04             	add    $0x4,%esp
80103573:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103579:	83 e0 04             	and    $0x4,%eax
8010357c:	85 c0                	test   %eax,%eax
8010357e:	0f 94 c0             	sete   %al
80103581:	0f b6 c0             	movzbl %al,%eax
80103584:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103587:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010358a:	50                   	push   %eax
8010358b:	e8 6e ff ff ff       	call   801034fe <fill_rtcdate>
80103590:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103593:	6a 0a                	push   $0xa
80103595:	e8 34 ff ff ff       	call   801034ce <cmos_read>
8010359a:	83 c4 04             	add    $0x4,%esp
8010359d:	25 80 00 00 00       	and    $0x80,%eax
801035a2:	85 c0                	test   %eax,%eax
801035a4:	75 27                	jne    801035cd <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801035a6:	8d 45 c0             	lea    -0x40(%ebp),%eax
801035a9:	50                   	push   %eax
801035aa:	e8 4f ff ff ff       	call   801034fe <fill_rtcdate>
801035af:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801035b2:	83 ec 04             	sub    $0x4,%esp
801035b5:	6a 18                	push   $0x18
801035b7:	8d 45 c0             	lea    -0x40(%ebp),%eax
801035ba:	50                   	push   %eax
801035bb:	8d 45 d8             	lea    -0x28(%ebp),%eax
801035be:	50                   	push   %eax
801035bf:	e8 16 2a 00 00       	call   80105fda <memcmp>
801035c4:	83 c4 10             	add    $0x10,%esp
801035c7:	85 c0                	test   %eax,%eax
801035c9:	74 05                	je     801035d0 <cmostime+0x6d>
801035cb:	eb ba                	jmp    80103587 <cmostime+0x24>
        continue;
801035cd:	90                   	nop
    fill_rtcdate(&t1);
801035ce:	eb b7                	jmp    80103587 <cmostime+0x24>
      break;
801035d0:	90                   	nop
  }

  // convert
  if(bcd) {
801035d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801035d5:	0f 84 b4 00 00 00    	je     8010368f <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801035db:	8b 45 d8             	mov    -0x28(%ebp),%eax
801035de:	c1 e8 04             	shr    $0x4,%eax
801035e1:	89 c2                	mov    %eax,%edx
801035e3:	89 d0                	mov    %edx,%eax
801035e5:	c1 e0 02             	shl    $0x2,%eax
801035e8:	01 d0                	add    %edx,%eax
801035ea:	01 c0                	add    %eax,%eax
801035ec:	89 c2                	mov    %eax,%edx
801035ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
801035f1:	83 e0 0f             	and    $0xf,%eax
801035f4:	01 d0                	add    %edx,%eax
801035f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801035f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801035fc:	c1 e8 04             	shr    $0x4,%eax
801035ff:	89 c2                	mov    %eax,%edx
80103601:	89 d0                	mov    %edx,%eax
80103603:	c1 e0 02             	shl    $0x2,%eax
80103606:	01 d0                	add    %edx,%eax
80103608:	01 c0                	add    %eax,%eax
8010360a:	89 c2                	mov    %eax,%edx
8010360c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010360f:	83 e0 0f             	and    $0xf,%eax
80103612:	01 d0                	add    %edx,%eax
80103614:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103617:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010361a:	c1 e8 04             	shr    $0x4,%eax
8010361d:	89 c2                	mov    %eax,%edx
8010361f:	89 d0                	mov    %edx,%eax
80103621:	c1 e0 02             	shl    $0x2,%eax
80103624:	01 d0                	add    %edx,%eax
80103626:	01 c0                	add    %eax,%eax
80103628:	89 c2                	mov    %eax,%edx
8010362a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010362d:	83 e0 0f             	and    $0xf,%eax
80103630:	01 d0                	add    %edx,%eax
80103632:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103638:	c1 e8 04             	shr    $0x4,%eax
8010363b:	89 c2                	mov    %eax,%edx
8010363d:	89 d0                	mov    %edx,%eax
8010363f:	c1 e0 02             	shl    $0x2,%eax
80103642:	01 d0                	add    %edx,%eax
80103644:	01 c0                	add    %eax,%eax
80103646:	89 c2                	mov    %eax,%edx
80103648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010364b:	83 e0 0f             	and    $0xf,%eax
8010364e:	01 d0                	add    %edx,%eax
80103650:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103653:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103656:	c1 e8 04             	shr    $0x4,%eax
80103659:	89 c2                	mov    %eax,%edx
8010365b:	89 d0                	mov    %edx,%eax
8010365d:	c1 e0 02             	shl    $0x2,%eax
80103660:	01 d0                	add    %edx,%eax
80103662:	01 c0                	add    %eax,%eax
80103664:	89 c2                	mov    %eax,%edx
80103666:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103669:	83 e0 0f             	and    $0xf,%eax
8010366c:	01 d0                	add    %edx,%eax
8010366e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103671:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103674:	c1 e8 04             	shr    $0x4,%eax
80103677:	89 c2                	mov    %eax,%edx
80103679:	89 d0                	mov    %edx,%eax
8010367b:	c1 e0 02             	shl    $0x2,%eax
8010367e:	01 d0                	add    %edx,%eax
80103680:	01 c0                	add    %eax,%eax
80103682:	89 c2                	mov    %eax,%edx
80103684:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103687:	83 e0 0f             	and    $0xf,%eax
8010368a:	01 d0                	add    %edx,%eax
8010368c:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010368f:	8b 45 08             	mov    0x8(%ebp),%eax
80103692:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103695:	89 10                	mov    %edx,(%eax)
80103697:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010369a:	89 50 04             	mov    %edx,0x4(%eax)
8010369d:	8b 55 e0             	mov    -0x20(%ebp),%edx
801036a0:	89 50 08             	mov    %edx,0x8(%eax)
801036a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801036a6:	89 50 0c             	mov    %edx,0xc(%eax)
801036a9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801036ac:	89 50 10             	mov    %edx,0x10(%eax)
801036af:	8b 55 ec             	mov    -0x14(%ebp),%edx
801036b2:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801036b5:	8b 45 08             	mov    0x8(%ebp),%eax
801036b8:	8b 40 14             	mov    0x14(%eax),%eax
801036bb:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801036c1:	8b 45 08             	mov    0x8(%ebp),%eax
801036c4:	89 50 14             	mov    %edx,0x14(%eax)
}
801036c7:	90                   	nop
801036c8:	c9                   	leave  
801036c9:	c3                   	ret    

801036ca <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801036ca:	55                   	push   %ebp
801036cb:	89 e5                	mov    %esp,%ebp
801036cd:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801036d0:	83 ec 08             	sub    $0x8,%esp
801036d3:	68 49 95 10 80       	push   $0x80109549
801036d8:	68 00 37 11 80       	push   $0x80113700
801036dd:	e8 e9 25 00 00       	call   80105ccb <initlock>
801036e2:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801036e5:	83 ec 08             	sub    $0x8,%esp
801036e8:	8d 45 dc             	lea    -0x24(%ebp),%eax
801036eb:	50                   	push   %eax
801036ec:	ff 75 08             	push   0x8(%ebp)
801036ef:	e8 d4 e0 ff ff       	call   801017c8 <readsb>
801036f4:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801036f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036fa:	a3 34 37 11 80       	mov    %eax,0x80113734
  log.size = sb.nlog;
801036ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103702:	a3 38 37 11 80       	mov    %eax,0x80113738
  log.dev = dev;
80103707:	8b 45 08             	mov    0x8(%ebp),%eax
8010370a:	a3 44 37 11 80       	mov    %eax,0x80113744
  recover_from_log();
8010370f:	e8 b3 01 00 00       	call   801038c7 <recover_from_log>
}
80103714:	90                   	nop
80103715:	c9                   	leave  
80103716:	c3                   	ret    

80103717 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103717:	55                   	push   %ebp
80103718:	89 e5                	mov    %esp,%ebp
8010371a:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010371d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103724:	e9 95 00 00 00       	jmp    801037be <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103729:	8b 15 34 37 11 80    	mov    0x80113734,%edx
8010372f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103732:	01 d0                	add    %edx,%eax
80103734:	83 c0 01             	add    $0x1,%eax
80103737:	89 c2                	mov    %eax,%edx
80103739:	a1 44 37 11 80       	mov    0x80113744,%eax
8010373e:	83 ec 08             	sub    $0x8,%esp
80103741:	52                   	push   %edx
80103742:	50                   	push   %eax
80103743:	e8 87 ca ff ff       	call   801001cf <bread>
80103748:	83 c4 10             	add    $0x10,%esp
8010374b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010374e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103751:	83 c0 10             	add    $0x10,%eax
80103754:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
8010375b:	89 c2                	mov    %eax,%edx
8010375d:	a1 44 37 11 80       	mov    0x80113744,%eax
80103762:	83 ec 08             	sub    $0x8,%esp
80103765:	52                   	push   %edx
80103766:	50                   	push   %eax
80103767:	e8 63 ca ff ff       	call   801001cf <bread>
8010376c:	83 c4 10             	add    $0x10,%esp
8010376f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103772:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103775:	8d 50 5c             	lea    0x5c(%eax),%edx
80103778:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010377b:	83 c0 5c             	add    $0x5c,%eax
8010377e:	83 ec 04             	sub    $0x4,%esp
80103781:	68 00 02 00 00       	push   $0x200
80103786:	52                   	push   %edx
80103787:	50                   	push   %eax
80103788:	e8 a5 28 00 00       	call   80106032 <memmove>
8010378d:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103790:	83 ec 0c             	sub    $0xc,%esp
80103793:	ff 75 ec             	push   -0x14(%ebp)
80103796:	e8 6d ca ff ff       	call   80100208 <bwrite>
8010379b:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	ff 75 f0             	push   -0x10(%ebp)
801037a4:	e8 a8 ca ff ff       	call   80100251 <brelse>
801037a9:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801037ac:	83 ec 0c             	sub    $0xc,%esp
801037af:	ff 75 ec             	push   -0x14(%ebp)
801037b2:	e8 9a ca ff ff       	call   80100251 <brelse>
801037b7:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801037ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037be:	a1 48 37 11 80       	mov    0x80113748,%eax
801037c3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037c6:	0f 8c 5d ff ff ff    	jl     80103729 <install_trans+0x12>
  }
}
801037cc:	90                   	nop
801037cd:	90                   	nop
801037ce:	c9                   	leave  
801037cf:	c3                   	ret    

801037d0 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801037d0:	55                   	push   %ebp
801037d1:	89 e5                	mov    %esp,%ebp
801037d3:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801037d6:	a1 34 37 11 80       	mov    0x80113734,%eax
801037db:	89 c2                	mov    %eax,%edx
801037dd:	a1 44 37 11 80       	mov    0x80113744,%eax
801037e2:	83 ec 08             	sub    $0x8,%esp
801037e5:	52                   	push   %edx
801037e6:	50                   	push   %eax
801037e7:	e8 e3 c9 ff ff       	call   801001cf <bread>
801037ec:	83 c4 10             	add    $0x10,%esp
801037ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801037f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037f5:	83 c0 5c             	add    $0x5c,%eax
801037f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801037fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037fe:	8b 00                	mov    (%eax),%eax
80103800:	a3 48 37 11 80       	mov    %eax,0x80113748
  for (i = 0; i < log.lh.n; i++) {
80103805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010380c:	eb 1b                	jmp    80103829 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010380e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103811:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103814:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103818:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010381b:	83 c2 10             	add    $0x10,%edx
8010381e:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103825:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103829:	a1 48 37 11 80       	mov    0x80113748,%eax
8010382e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103831:	7c db                	jl     8010380e <read_head+0x3e>
  }
  brelse(buf);
80103833:	83 ec 0c             	sub    $0xc,%esp
80103836:	ff 75 f0             	push   -0x10(%ebp)
80103839:	e8 13 ca ff ff       	call   80100251 <brelse>
8010383e:	83 c4 10             	add    $0x10,%esp
}
80103841:	90                   	nop
80103842:	c9                   	leave  
80103843:	c3                   	ret    

80103844 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103844:	55                   	push   %ebp
80103845:	89 e5                	mov    %esp,%ebp
80103847:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010384a:	a1 34 37 11 80       	mov    0x80113734,%eax
8010384f:	89 c2                	mov    %eax,%edx
80103851:	a1 44 37 11 80       	mov    0x80113744,%eax
80103856:	83 ec 08             	sub    $0x8,%esp
80103859:	52                   	push   %edx
8010385a:	50                   	push   %eax
8010385b:	e8 6f c9 ff ff       	call   801001cf <bread>
80103860:	83 c4 10             	add    $0x10,%esp
80103863:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103869:	83 c0 5c             	add    $0x5c,%eax
8010386c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010386f:	8b 15 48 37 11 80    	mov    0x80113748,%edx
80103875:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103878:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010387a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103881:	eb 1b                	jmp    8010389e <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103886:	83 c0 10             	add    $0x10,%eax
80103889:	8b 0c 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%ecx
80103890:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103893:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103896:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010389a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010389e:	a1 48 37 11 80       	mov    0x80113748,%eax
801038a3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801038a6:	7c db                	jl     80103883 <write_head+0x3f>
  }
  bwrite(buf);
801038a8:	83 ec 0c             	sub    $0xc,%esp
801038ab:	ff 75 f0             	push   -0x10(%ebp)
801038ae:	e8 55 c9 ff ff       	call   80100208 <bwrite>
801038b3:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801038b6:	83 ec 0c             	sub    $0xc,%esp
801038b9:	ff 75 f0             	push   -0x10(%ebp)
801038bc:	e8 90 c9 ff ff       	call   80100251 <brelse>
801038c1:	83 c4 10             	add    $0x10,%esp
}
801038c4:	90                   	nop
801038c5:	c9                   	leave  
801038c6:	c3                   	ret    

801038c7 <recover_from_log>:

static void
recover_from_log(void)
{
801038c7:	55                   	push   %ebp
801038c8:	89 e5                	mov    %esp,%ebp
801038ca:	83 ec 08             	sub    $0x8,%esp
  read_head();
801038cd:	e8 fe fe ff ff       	call   801037d0 <read_head>
  install_trans(); // if committed, copy from log to disk
801038d2:	e8 40 fe ff ff       	call   80103717 <install_trans>
  log.lh.n = 0;
801038d7:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
801038de:	00 00 00 
  write_head(); // clear the log
801038e1:	e8 5e ff ff ff       	call   80103844 <write_head>
}
801038e6:	90                   	nop
801038e7:	c9                   	leave  
801038e8:	c3                   	ret    

801038e9 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801038e9:	55                   	push   %ebp
801038ea:	89 e5                	mov    %esp,%ebp
801038ec:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801038ef:	83 ec 0c             	sub    $0xc,%esp
801038f2:	68 00 37 11 80       	push   $0x80113700
801038f7:	e8 f1 23 00 00       	call   80105ced <acquire>
801038fc:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801038ff:	a1 40 37 11 80       	mov    0x80113740,%eax
80103904:	85 c0                	test   %eax,%eax
80103906:	74 17                	je     8010391f <begin_op+0x36>
      sleep(&log, &log.lock);
80103908:	83 ec 08             	sub    $0x8,%esp
8010390b:	68 00 37 11 80       	push   $0x80113700
80103910:	68 00 37 11 80       	push   $0x80113700
80103915:	e8 bb 19 00 00       	call   801052d5 <sleep>
8010391a:	83 c4 10             	add    $0x10,%esp
8010391d:	eb e0                	jmp    801038ff <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010391f:	8b 0d 48 37 11 80    	mov    0x80113748,%ecx
80103925:	a1 3c 37 11 80       	mov    0x8011373c,%eax
8010392a:	8d 50 01             	lea    0x1(%eax),%edx
8010392d:	89 d0                	mov    %edx,%eax
8010392f:	c1 e0 02             	shl    $0x2,%eax
80103932:	01 d0                	add    %edx,%eax
80103934:	01 c0                	add    %eax,%eax
80103936:	01 c8                	add    %ecx,%eax
80103938:	83 f8 1e             	cmp    $0x1e,%eax
8010393b:	7e 17                	jle    80103954 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010393d:	83 ec 08             	sub    $0x8,%esp
80103940:	68 00 37 11 80       	push   $0x80113700
80103945:	68 00 37 11 80       	push   $0x80113700
8010394a:	e8 86 19 00 00       	call   801052d5 <sleep>
8010394f:	83 c4 10             	add    $0x10,%esp
80103952:	eb ab                	jmp    801038ff <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103954:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103959:	83 c0 01             	add    $0x1,%eax
8010395c:	a3 3c 37 11 80       	mov    %eax,0x8011373c
      release(&log.lock);
80103961:	83 ec 0c             	sub    $0xc,%esp
80103964:	68 00 37 11 80       	push   $0x80113700
80103969:	e8 ed 23 00 00       	call   80105d5b <release>
8010396e:	83 c4 10             	add    $0x10,%esp
      break;
80103971:	90                   	nop
    }
  }
}
80103972:	90                   	nop
80103973:	c9                   	leave  
80103974:	c3                   	ret    

80103975 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103975:	55                   	push   %ebp
80103976:	89 e5                	mov    %esp,%ebp
80103978:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010397b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103982:	83 ec 0c             	sub    $0xc,%esp
80103985:	68 00 37 11 80       	push   $0x80113700
8010398a:	e8 5e 23 00 00       	call   80105ced <acquire>
8010398f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103992:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103997:	83 e8 01             	sub    $0x1,%eax
8010399a:	a3 3c 37 11 80       	mov    %eax,0x8011373c
  if(log.committing)
8010399f:	a1 40 37 11 80       	mov    0x80113740,%eax
801039a4:	85 c0                	test   %eax,%eax
801039a6:	74 0d                	je     801039b5 <end_op+0x40>
    panic("log.committing");
801039a8:	83 ec 0c             	sub    $0xc,%esp
801039ab:	68 4d 95 10 80       	push   $0x8010954d
801039b0:	e8 00 cc ff ff       	call   801005b5 <panic>
  if(log.outstanding == 0){
801039b5:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801039ba:	85 c0                	test   %eax,%eax
801039bc:	75 13                	jne    801039d1 <end_op+0x5c>
    do_commit = 1;
801039be:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801039c5:	c7 05 40 37 11 80 01 	movl   $0x1,0x80113740
801039cc:	00 00 00 
801039cf:	eb 10                	jmp    801039e1 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801039d1:	83 ec 0c             	sub    $0xc,%esp
801039d4:	68 00 37 11 80       	push   $0x80113700
801039d9:	e8 e1 19 00 00       	call   801053bf <wakeup>
801039de:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801039e1:	83 ec 0c             	sub    $0xc,%esp
801039e4:	68 00 37 11 80       	push   $0x80113700
801039e9:	e8 6d 23 00 00       	call   80105d5b <release>
801039ee:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801039f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801039f5:	74 3f                	je     80103a36 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801039f7:	e8 f6 00 00 00       	call   80103af2 <commit>
    acquire(&log.lock);
801039fc:	83 ec 0c             	sub    $0xc,%esp
801039ff:	68 00 37 11 80       	push   $0x80113700
80103a04:	e8 e4 22 00 00       	call   80105ced <acquire>
80103a09:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103a0c:	c7 05 40 37 11 80 00 	movl   $0x0,0x80113740
80103a13:	00 00 00 
    wakeup(&log);
80103a16:	83 ec 0c             	sub    $0xc,%esp
80103a19:	68 00 37 11 80       	push   $0x80113700
80103a1e:	e8 9c 19 00 00       	call   801053bf <wakeup>
80103a23:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103a26:	83 ec 0c             	sub    $0xc,%esp
80103a29:	68 00 37 11 80       	push   $0x80113700
80103a2e:	e8 28 23 00 00       	call   80105d5b <release>
80103a33:	83 c4 10             	add    $0x10,%esp
  }
}
80103a36:	90                   	nop
80103a37:	c9                   	leave  
80103a38:	c3                   	ret    

80103a39 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103a39:	55                   	push   %ebp
80103a3a:	89 e5                	mov    %esp,%ebp
80103a3c:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a3f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a46:	e9 95 00 00 00       	jmp    80103ae0 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103a4b:	8b 15 34 37 11 80    	mov    0x80113734,%edx
80103a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a54:	01 d0                	add    %edx,%eax
80103a56:	83 c0 01             	add    $0x1,%eax
80103a59:	89 c2                	mov    %eax,%edx
80103a5b:	a1 44 37 11 80       	mov    0x80113744,%eax
80103a60:	83 ec 08             	sub    $0x8,%esp
80103a63:	52                   	push   %edx
80103a64:	50                   	push   %eax
80103a65:	e8 65 c7 ff ff       	call   801001cf <bread>
80103a6a:	83 c4 10             	add    $0x10,%esp
80103a6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a73:	83 c0 10             	add    $0x10,%eax
80103a76:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
80103a7d:	89 c2                	mov    %eax,%edx
80103a7f:	a1 44 37 11 80       	mov    0x80113744,%eax
80103a84:	83 ec 08             	sub    $0x8,%esp
80103a87:	52                   	push   %edx
80103a88:	50                   	push   %eax
80103a89:	e8 41 c7 ff ff       	call   801001cf <bread>
80103a8e:	83 c4 10             	add    $0x10,%esp
80103a91:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103a94:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a97:	8d 50 5c             	lea    0x5c(%eax),%edx
80103a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a9d:	83 c0 5c             	add    $0x5c,%eax
80103aa0:	83 ec 04             	sub    $0x4,%esp
80103aa3:	68 00 02 00 00       	push   $0x200
80103aa8:	52                   	push   %edx
80103aa9:	50                   	push   %eax
80103aaa:	e8 83 25 00 00       	call   80106032 <memmove>
80103aaf:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103ab2:	83 ec 0c             	sub    $0xc,%esp
80103ab5:	ff 75 f0             	push   -0x10(%ebp)
80103ab8:	e8 4b c7 ff ff       	call   80100208 <bwrite>
80103abd:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103ac0:	83 ec 0c             	sub    $0xc,%esp
80103ac3:	ff 75 ec             	push   -0x14(%ebp)
80103ac6:	e8 86 c7 ff ff       	call   80100251 <brelse>
80103acb:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103ace:	83 ec 0c             	sub    $0xc,%esp
80103ad1:	ff 75 f0             	push   -0x10(%ebp)
80103ad4:	e8 78 c7 ff ff       	call   80100251 <brelse>
80103ad9:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103adc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ae0:	a1 48 37 11 80       	mov    0x80113748,%eax
80103ae5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103ae8:	0f 8c 5d ff ff ff    	jl     80103a4b <write_log+0x12>
  }
}
80103aee:	90                   	nop
80103aef:	90                   	nop
80103af0:	c9                   	leave  
80103af1:	c3                   	ret    

80103af2 <commit>:

static void
commit()
{
80103af2:	55                   	push   %ebp
80103af3:	89 e5                	mov    %esp,%ebp
80103af5:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103af8:	a1 48 37 11 80       	mov    0x80113748,%eax
80103afd:	85 c0                	test   %eax,%eax
80103aff:	7e 1e                	jle    80103b1f <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103b01:	e8 33 ff ff ff       	call   80103a39 <write_log>
    write_head();    // Write header to disk -- the real commit
80103b06:	e8 39 fd ff ff       	call   80103844 <write_head>
    install_trans(); // Now install writes to home locations
80103b0b:	e8 07 fc ff ff       	call   80103717 <install_trans>
    log.lh.n = 0;
80103b10:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
80103b17:	00 00 00 
    write_head();    // Erase the transaction from the log
80103b1a:	e8 25 fd ff ff       	call   80103844 <write_head>
  }
}
80103b1f:	90                   	nop
80103b20:	c9                   	leave  
80103b21:	c3                   	ret    

80103b22 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103b22:	55                   	push   %ebp
80103b23:	89 e5                	mov    %esp,%ebp
80103b25:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103b28:	a1 48 37 11 80       	mov    0x80113748,%eax
80103b2d:	83 f8 1d             	cmp    $0x1d,%eax
80103b30:	7f 12                	jg     80103b44 <log_write+0x22>
80103b32:	a1 48 37 11 80       	mov    0x80113748,%eax
80103b37:	8b 15 38 37 11 80    	mov    0x80113738,%edx
80103b3d:	83 ea 01             	sub    $0x1,%edx
80103b40:	39 d0                	cmp    %edx,%eax
80103b42:	7c 0d                	jl     80103b51 <log_write+0x2f>
    panic("too big a transaction");
80103b44:	83 ec 0c             	sub    $0xc,%esp
80103b47:	68 5c 95 10 80       	push   $0x8010955c
80103b4c:	e8 64 ca ff ff       	call   801005b5 <panic>
  if (log.outstanding < 1)
80103b51:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103b56:	85 c0                	test   %eax,%eax
80103b58:	7f 0d                	jg     80103b67 <log_write+0x45>
    panic("log_write outside of trans");
80103b5a:	83 ec 0c             	sub    $0xc,%esp
80103b5d:	68 72 95 10 80       	push   $0x80109572
80103b62:	e8 4e ca ff ff       	call   801005b5 <panic>

  acquire(&log.lock);
80103b67:	83 ec 0c             	sub    $0xc,%esp
80103b6a:	68 00 37 11 80       	push   $0x80113700
80103b6f:	e8 79 21 00 00       	call   80105ced <acquire>
80103b74:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103b77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b7e:	eb 1d                	jmp    80103b9d <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b83:	83 c0 10             	add    $0x10,%eax
80103b86:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
80103b8d:	89 c2                	mov    %eax,%edx
80103b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b92:	8b 40 08             	mov    0x8(%eax),%eax
80103b95:	39 c2                	cmp    %eax,%edx
80103b97:	74 10                	je     80103ba9 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
80103b99:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b9d:	a1 48 37 11 80       	mov    0x80113748,%eax
80103ba2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103ba5:	7c d9                	jl     80103b80 <log_write+0x5e>
80103ba7:	eb 01                	jmp    80103baa <log_write+0x88>
      break;
80103ba9:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103baa:	8b 45 08             	mov    0x8(%ebp),%eax
80103bad:	8b 40 08             	mov    0x8(%eax),%eax
80103bb0:	89 c2                	mov    %eax,%edx
80103bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb5:	83 c0 10             	add    $0x10,%eax
80103bb8:	89 14 85 0c 37 11 80 	mov    %edx,-0x7feec8f4(,%eax,4)
  if (i == log.lh.n)
80103bbf:	a1 48 37 11 80       	mov    0x80113748,%eax
80103bc4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bc7:	75 0d                	jne    80103bd6 <log_write+0xb4>
    log.lh.n++;
80103bc9:	a1 48 37 11 80       	mov    0x80113748,%eax
80103bce:	83 c0 01             	add    $0x1,%eax
80103bd1:	a3 48 37 11 80       	mov    %eax,0x80113748
  b->flags |= B_DIRTY; // prevent eviction
80103bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103bd9:	8b 00                	mov    (%eax),%eax
80103bdb:	83 c8 04             	or     $0x4,%eax
80103bde:	89 c2                	mov    %eax,%edx
80103be0:	8b 45 08             	mov    0x8(%ebp),%eax
80103be3:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103be5:	83 ec 0c             	sub    $0xc,%esp
80103be8:	68 00 37 11 80       	push   $0x80113700
80103bed:	e8 69 21 00 00       	call   80105d5b <release>
80103bf2:	83 c4 10             	add    $0x10,%esp
}
80103bf5:	90                   	nop
80103bf6:	c9                   	leave  
80103bf7:	c3                   	ret    

80103bf8 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103bf8:	55                   	push   %ebp
80103bf9:	89 e5                	mov    %esp,%ebp
80103bfb:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103bfe:	8b 55 08             	mov    0x8(%ebp),%edx
80103c01:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c04:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103c07:	f0 87 02             	lock xchg %eax,(%edx)
80103c0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103c0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103c10:	c9                   	leave  
80103c11:	c3                   	ret    

80103c12 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103c12:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103c16:	83 e4 f0             	and    $0xfffffff0,%esp
80103c19:	ff 71 fc             	push   -0x4(%ecx)
80103c1c:	55                   	push   %ebp
80103c1d:	89 e5                	mov    %esp,%ebp
80103c1f:	51                   	push   %ecx
80103c20:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103c23:	83 ec 08             	sub    $0x8,%esp
80103c26:	68 00 00 40 80       	push   $0x80400000
80103c2b:	68 00 79 11 80       	push   $0x80117900
80103c30:	e8 e3 f2 ff ff       	call   80102f18 <kinit1>
80103c35:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103c38:	e8 6a 4e 00 00       	call   80108aa7 <kvmalloc>
  mpinit();        // detect other processors
80103c3d:	e8 bd 03 00 00       	call   80103fff <mpinit>
  lapicinit();     // interrupt controller
80103c42:	e8 41 f6 ff ff       	call   80103288 <lapicinit>
  seginit();       // segment descriptors
80103c47:	e8 46 49 00 00       	call   80108592 <seginit>
  picinit();       // disable pic
80103c4c:	e8 15 05 00 00       	call   80104166 <picinit>
  ioapicinit();    // another interrupt controller
80103c51:	e8 dd f1 ff ff       	call   80102e33 <ioapicinit>
  consoleinit();   // console hardware
80103c56:	e8 1d cf ff ff       	call   80100b78 <consoleinit>
  uartinit();      // serial port
80103c5b:	e8 cb 3c 00 00       	call   8010792b <uartinit>
  pinit();         // process table
80103c60:	e8 3a 09 00 00       	call   8010459f <pinit>
  tvinit();        // trap vectors
80103c65:	e8 34 38 00 00       	call   8010749e <tvinit>
  binit();         // buffer cache
80103c6a:	e8 c5 c3 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103c6f:	e8 45 d7 ff ff       	call   801013b9 <fileinit>
  ideinit();       // disk 
80103c74:	e8 91 ed ff ff       	call   80102a0a <ideinit>
  startothers();   // start other processors
80103c79:	e8 80 00 00 00       	call   80103cfe <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103c7e:	83 ec 08             	sub    $0x8,%esp
80103c81:	68 00 00 00 8e       	push   $0x8e000000
80103c86:	68 00 00 40 80       	push   $0x80400000
80103c8b:	e8 c1 f2 ff ff       	call   80102f51 <kinit2>
80103c90:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103c93:	e8 33 0b 00 00       	call   801047cb <userinit>
  mpmain();        // finish this processor's setup
80103c98:	e8 1a 00 00 00       	call   80103cb7 <mpmain>

80103c9d <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103c9d:	55                   	push   %ebp
80103c9e:	89 e5                	mov    %esp,%ebp
80103ca0:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103ca3:	e8 17 4e 00 00       	call   80108abf <switchkvm>
  seginit();
80103ca8:	e8 e5 48 00 00       	call   80108592 <seginit>
  lapicinit();
80103cad:	e8 d6 f5 ff ff       	call   80103288 <lapicinit>
  mpmain();
80103cb2:	e8 00 00 00 00       	call   80103cb7 <mpmain>

80103cb7 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103cb7:	55                   	push   %ebp
80103cb8:	89 e5                	mov    %esp,%ebp
80103cba:	53                   	push   %ebx
80103cbb:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103cbe:	e8 fa 08 00 00       	call   801045bd <cpuid>
80103cc3:	89 c3                	mov    %eax,%ebx
80103cc5:	e8 f3 08 00 00       	call   801045bd <cpuid>
80103cca:	83 ec 04             	sub    $0x4,%esp
80103ccd:	53                   	push   %ebx
80103cce:	50                   	push   %eax
80103ccf:	68 8d 95 10 80       	push   $0x8010958d
80103cd4:	e8 27 c7 ff ff       	call   80100400 <cprintf>
80103cd9:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103cdc:	e8 33 39 00 00       	call   80107614 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103ce1:	e8 f2 08 00 00       	call   801045d8 <mycpu>
80103ce6:	05 a0 00 00 00       	add    $0xa0,%eax
80103ceb:	83 ec 08             	sub    $0x8,%esp
80103cee:	6a 01                	push   $0x1
80103cf0:	50                   	push   %eax
80103cf1:	e8 02 ff ff ff       	call   80103bf8 <xchg>
80103cf6:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103cf9:	e8 d8 11 00 00       	call   80104ed6 <scheduler>

80103cfe <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103cfe:	55                   	push   %ebp
80103cff:	89 e5                	mov    %esp,%ebp
80103d01:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103d04:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103d0b:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103d10:	83 ec 04             	sub    $0x4,%esp
80103d13:	50                   	push   %eax
80103d14:	68 0c c5 10 80       	push   $0x8010c50c
80103d19:	ff 75 f0             	push   -0x10(%ebp)
80103d1c:	e8 11 23 00 00       	call   80106032 <memmove>
80103d21:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103d24:	c7 45 f4 e0 37 11 80 	movl   $0x801137e0,-0xc(%ebp)
80103d2b:	eb 79                	jmp    80103da6 <startothers+0xa8>
    if(c == mycpu())  // We've started already.
80103d2d:	e8 a6 08 00 00       	call   801045d8 <mycpu>
80103d32:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103d35:	74 67                	je     80103d9e <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103d37:	e8 11 f3 ff ff       	call   8010304d <kalloc>
80103d3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d42:	83 e8 04             	sub    $0x4,%eax
80103d45:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103d48:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103d4e:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d53:	83 e8 08             	sub    $0x8,%eax
80103d56:	c7 00 9d 3c 10 80    	movl   $0x80103c9d,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103d5c:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103d61:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d6a:	83 e8 0c             	sub    $0xc,%eax
80103d6d:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d72:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7b:	0f b6 00             	movzbl (%eax),%eax
80103d7e:	0f b6 c0             	movzbl %al,%eax
80103d81:	83 ec 08             	sub    $0x8,%esp
80103d84:	52                   	push   %edx
80103d85:	50                   	push   %eax
80103d86:	e8 5f f6 ff ff       	call   801033ea <lapicstartap>
80103d8b:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103d8e:	90                   	nop
80103d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d92:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103d98:	85 c0                	test   %eax,%eax
80103d9a:	74 f3                	je     80103d8f <startothers+0x91>
80103d9c:	eb 01                	jmp    80103d9f <startothers+0xa1>
      continue;
80103d9e:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103d9f:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103da6:	a1 40 39 11 80       	mov    0x80113940,%eax
80103dab:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103db1:	05 e0 37 11 80       	add    $0x801137e0,%eax
80103db6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103db9:	0f 82 6e ff ff ff    	jb     80103d2d <startothers+0x2f>
      ;
  }
}
80103dbf:	90                   	nop
80103dc0:	90                   	nop
80103dc1:	c9                   	leave  
80103dc2:	c3                   	ret    

80103dc3 <inb>:
{
80103dc3:	55                   	push   %ebp
80103dc4:	89 e5                	mov    %esp,%ebp
80103dc6:	83 ec 14             	sub    $0x14,%esp
80103dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dcc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103dd0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103dd4:	89 c2                	mov    %eax,%edx
80103dd6:	ec                   	in     (%dx),%al
80103dd7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103dda:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103dde:	c9                   	leave  
80103ddf:	c3                   	ret    

80103de0 <outb>:
{
80103de0:	55                   	push   %ebp
80103de1:	89 e5                	mov    %esp,%ebp
80103de3:	83 ec 08             	sub    $0x8,%esp
80103de6:	8b 45 08             	mov    0x8(%ebp),%eax
80103de9:	8b 55 0c             	mov    0xc(%ebp),%edx
80103dec:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103df0:	89 d0                	mov    %edx,%eax
80103df2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103df5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103df9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dfd:	ee                   	out    %al,(%dx)
}
80103dfe:	90                   	nop
80103dff:	c9                   	leave  
80103e00:	c3                   	ret    

80103e01 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103e01:	55                   	push   %ebp
80103e02:	89 e5                	mov    %esp,%ebp
80103e04:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103e07:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103e0e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103e15:	eb 15                	jmp    80103e2c <sum+0x2b>
    sum += addr[i];
80103e17:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1d:	01 d0                	add    %edx,%eax
80103e1f:	0f b6 00             	movzbl (%eax),%eax
80103e22:	0f b6 c0             	movzbl %al,%eax
80103e25:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103e28:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103e2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103e2f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103e32:	7c e3                	jl     80103e17 <sum+0x16>
  return sum;
80103e34:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103e37:	c9                   	leave  
80103e38:	c3                   	ret    

80103e39 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103e39:	55                   	push   %ebp
80103e3a:	89 e5                	mov    %esp,%ebp
80103e3c:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e42:	05 00 00 00 80       	add    $0x80000000,%eax
80103e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103e4a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e50:	01 d0                	add    %edx,%eax
80103e52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e5b:	eb 36                	jmp    80103e93 <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103e5d:	83 ec 04             	sub    $0x4,%esp
80103e60:	6a 04                	push   $0x4
80103e62:	68 a4 95 10 80       	push   $0x801095a4
80103e67:	ff 75 f4             	push   -0xc(%ebp)
80103e6a:	e8 6b 21 00 00       	call   80105fda <memcmp>
80103e6f:	83 c4 10             	add    $0x10,%esp
80103e72:	85 c0                	test   %eax,%eax
80103e74:	75 19                	jne    80103e8f <mpsearch1+0x56>
80103e76:	83 ec 08             	sub    $0x8,%esp
80103e79:	6a 10                	push   $0x10
80103e7b:	ff 75 f4             	push   -0xc(%ebp)
80103e7e:	e8 7e ff ff ff       	call   80103e01 <sum>
80103e83:	83 c4 10             	add    $0x10,%esp
80103e86:	84 c0                	test   %al,%al
80103e88:	75 05                	jne    80103e8f <mpsearch1+0x56>
      return (struct mp*)p;
80103e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e8d:	eb 11                	jmp    80103ea0 <mpsearch1+0x67>
  for(p = addr; p < e; p += sizeof(struct mp))
80103e8f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e96:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e99:	72 c2                	jb     80103e5d <mpsearch1+0x24>
  return 0;
80103e9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ea0:	c9                   	leave  
80103ea1:	c3                   	ret    

80103ea2 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ea2:	55                   	push   %ebp
80103ea3:	89 e5                	mov    %esp,%ebp
80103ea5:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ea8:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb2:	83 c0 0f             	add    $0xf,%eax
80103eb5:	0f b6 00             	movzbl (%eax),%eax
80103eb8:	0f b6 c0             	movzbl %al,%eax
80103ebb:	c1 e0 08             	shl    $0x8,%eax
80103ebe:	89 c2                	mov    %eax,%edx
80103ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec3:	83 c0 0e             	add    $0xe,%eax
80103ec6:	0f b6 00             	movzbl (%eax),%eax
80103ec9:	0f b6 c0             	movzbl %al,%eax
80103ecc:	09 d0                	or     %edx,%eax
80103ece:	c1 e0 04             	shl    $0x4,%eax
80103ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ed4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ed8:	74 21                	je     80103efb <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103eda:	83 ec 08             	sub    $0x8,%esp
80103edd:	68 00 04 00 00       	push   $0x400
80103ee2:	ff 75 f0             	push   -0x10(%ebp)
80103ee5:	e8 4f ff ff ff       	call   80103e39 <mpsearch1>
80103eea:	83 c4 10             	add    $0x10,%esp
80103eed:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ef0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ef4:	74 51                	je     80103f47 <mpsearch+0xa5>
      return mp;
80103ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef9:	eb 61                	jmp    80103f5c <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103efe:	83 c0 14             	add    $0x14,%eax
80103f01:	0f b6 00             	movzbl (%eax),%eax
80103f04:	0f b6 c0             	movzbl %al,%eax
80103f07:	c1 e0 08             	shl    $0x8,%eax
80103f0a:	89 c2                	mov    %eax,%edx
80103f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f0f:	83 c0 13             	add    $0x13,%eax
80103f12:	0f b6 00             	movzbl (%eax),%eax
80103f15:	0f b6 c0             	movzbl %al,%eax
80103f18:	09 d0                	or     %edx,%eax
80103f1a:	c1 e0 0a             	shl    $0xa,%eax
80103f1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f23:	2d 00 04 00 00       	sub    $0x400,%eax
80103f28:	83 ec 08             	sub    $0x8,%esp
80103f2b:	68 00 04 00 00       	push   $0x400
80103f30:	50                   	push   %eax
80103f31:	e8 03 ff ff ff       	call   80103e39 <mpsearch1>
80103f36:	83 c4 10             	add    $0x10,%esp
80103f39:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103f3c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103f40:	74 05                	je     80103f47 <mpsearch+0xa5>
      return mp;
80103f42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f45:	eb 15                	jmp    80103f5c <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103f47:	83 ec 08             	sub    $0x8,%esp
80103f4a:	68 00 00 01 00       	push   $0x10000
80103f4f:	68 00 00 0f 00       	push   $0xf0000
80103f54:	e8 e0 fe ff ff       	call   80103e39 <mpsearch1>
80103f59:	83 c4 10             	add    $0x10,%esp
}
80103f5c:	c9                   	leave  
80103f5d:	c3                   	ret    

80103f5e <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103f5e:	55                   	push   %ebp
80103f5f:	89 e5                	mov    %esp,%ebp
80103f61:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103f64:	e8 39 ff ff ff       	call   80103ea2 <mpsearch>
80103f69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f70:	74 0a                	je     80103f7c <mpconfig+0x1e>
80103f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f75:	8b 40 04             	mov    0x4(%eax),%eax
80103f78:	85 c0                	test   %eax,%eax
80103f7a:	75 07                	jne    80103f83 <mpconfig+0x25>
    return 0;
80103f7c:	b8 00 00 00 00       	mov    $0x0,%eax
80103f81:	eb 7a                	jmp    80103ffd <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f86:	8b 40 04             	mov    0x4(%eax),%eax
80103f89:	05 00 00 00 80       	add    $0x80000000,%eax
80103f8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103f91:	83 ec 04             	sub    $0x4,%esp
80103f94:	6a 04                	push   $0x4
80103f96:	68 a9 95 10 80       	push   $0x801095a9
80103f9b:	ff 75 f0             	push   -0x10(%ebp)
80103f9e:	e8 37 20 00 00       	call   80105fda <memcmp>
80103fa3:	83 c4 10             	add    $0x10,%esp
80103fa6:	85 c0                	test   %eax,%eax
80103fa8:	74 07                	je     80103fb1 <mpconfig+0x53>
    return 0;
80103faa:	b8 00 00 00 00       	mov    $0x0,%eax
80103faf:	eb 4c                	jmp    80103ffd <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103fb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fb4:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103fb8:	3c 01                	cmp    $0x1,%al
80103fba:	74 12                	je     80103fce <mpconfig+0x70>
80103fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fbf:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103fc3:	3c 04                	cmp    $0x4,%al
80103fc5:	74 07                	je     80103fce <mpconfig+0x70>
    return 0;
80103fc7:	b8 00 00 00 00       	mov    $0x0,%eax
80103fcc:	eb 2f                	jmp    80103ffd <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fd1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103fd5:	0f b7 c0             	movzwl %ax,%eax
80103fd8:	83 ec 08             	sub    $0x8,%esp
80103fdb:	50                   	push   %eax
80103fdc:	ff 75 f0             	push   -0x10(%ebp)
80103fdf:	e8 1d fe ff ff       	call   80103e01 <sum>
80103fe4:	83 c4 10             	add    $0x10,%esp
80103fe7:	84 c0                	test   %al,%al
80103fe9:	74 07                	je     80103ff2 <mpconfig+0x94>
    return 0;
80103feb:	b8 00 00 00 00       	mov    $0x0,%eax
80103ff0:	eb 0b                	jmp    80103ffd <mpconfig+0x9f>
  *pmp = mp;
80103ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ff8:	89 10                	mov    %edx,(%eax)
  return conf;
80103ffa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103ffd:	c9                   	leave  
80103ffe:	c3                   	ret    

80103fff <mpinit>:

void
mpinit(void)
{
80103fff:	55                   	push   %ebp
80104000:	89 e5                	mov    %esp,%ebp
80104002:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80104005:	83 ec 0c             	sub    $0xc,%esp
80104008:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010400b:	50                   	push   %eax
8010400c:	e8 4d ff ff ff       	call   80103f5e <mpconfig>
80104011:	83 c4 10             	add    $0x10,%esp
80104014:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104017:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010401b:	75 0d                	jne    8010402a <mpinit+0x2b>
    panic("Expect to run on an SMP");
8010401d:	83 ec 0c             	sub    $0xc,%esp
80104020:	68 ae 95 10 80       	push   $0x801095ae
80104025:	e8 8b c5 ff ff       	call   801005b5 <panic>
  ismp = 1;
8010402a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80104031:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104034:	8b 40 24             	mov    0x24(%eax),%eax
80104037:	a3 e0 36 11 80       	mov    %eax,0x801136e0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010403c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010403f:	83 c0 2c             	add    $0x2c,%eax
80104042:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104045:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104048:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010404c:	0f b7 d0             	movzwl %ax,%edx
8010404f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104052:	01 d0                	add    %edx,%eax
80104054:	89 45 e8             	mov    %eax,-0x18(%ebp)
80104057:	e9 8c 00 00 00       	jmp    801040e8 <mpinit+0xe9>
    switch(*p){
8010405c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405f:	0f b6 00             	movzbl (%eax),%eax
80104062:	0f b6 c0             	movzbl %al,%eax
80104065:	83 f8 04             	cmp    $0x4,%eax
80104068:	7f 76                	jg     801040e0 <mpinit+0xe1>
8010406a:	83 f8 03             	cmp    $0x3,%eax
8010406d:	7d 6b                	jge    801040da <mpinit+0xdb>
8010406f:	83 f8 02             	cmp    $0x2,%eax
80104072:	74 4e                	je     801040c2 <mpinit+0xc3>
80104074:	83 f8 02             	cmp    $0x2,%eax
80104077:	7f 67                	jg     801040e0 <mpinit+0xe1>
80104079:	85 c0                	test   %eax,%eax
8010407b:	74 07                	je     80104084 <mpinit+0x85>
8010407d:	83 f8 01             	cmp    $0x1,%eax
80104080:	74 58                	je     801040da <mpinit+0xdb>
80104082:	eb 5c                	jmp    801040e0 <mpinit+0xe1>
    case MPPROC:
      proc = (struct mpproc*)p;
80104084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104087:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
8010408a:	a1 40 39 11 80       	mov    0x80113940,%eax
8010408f:	83 f8 01             	cmp    $0x1,%eax
80104092:	7f 28                	jg     801040bc <mpinit+0xbd>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80104094:	8b 15 40 39 11 80    	mov    0x80113940,%edx
8010409a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010409d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801040a1:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
801040a7:	81 c2 e0 37 11 80    	add    $0x801137e0,%edx
801040ad:	88 02                	mov    %al,(%edx)
        ncpu++;
801040af:	a1 40 39 11 80       	mov    0x80113940,%eax
801040b4:	83 c0 01             	add    $0x1,%eax
801040b7:	a3 40 39 11 80       	mov    %eax,0x80113940
      }
      p += sizeof(struct mpproc);
801040bc:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801040c0:	eb 26                	jmp    801040e8 <mpinit+0xe9>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801040c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801040c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801040cb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801040cf:	a2 44 39 11 80       	mov    %al,0x80113944
      p += sizeof(struct mpioapic);
801040d4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801040d8:	eb 0e                	jmp    801040e8 <mpinit+0xe9>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801040da:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801040de:	eb 08                	jmp    801040e8 <mpinit+0xe9>
    default:
      ismp = 0;
801040e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
801040e7:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801040e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040eb:	3b 45 e8             	cmp    -0x18(%ebp),%eax
801040ee:	0f 82 68 ff ff ff    	jb     8010405c <mpinit+0x5d>
    }
  }
  if(!ismp)
801040f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040f8:	75 0d                	jne    80104107 <mpinit+0x108>
    panic("Didn't find a suitable machine");
801040fa:	83 ec 0c             	sub    $0xc,%esp
801040fd:	68 c8 95 10 80       	push   $0x801095c8
80104102:	e8 ae c4 ff ff       	call   801005b5 <panic>

  if(mp->imcrp){
80104107:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010410a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010410e:	84 c0                	test   %al,%al
80104110:	74 30                	je     80104142 <mpinit+0x143>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104112:	83 ec 08             	sub    $0x8,%esp
80104115:	6a 70                	push   $0x70
80104117:	6a 22                	push   $0x22
80104119:	e8 c2 fc ff ff       	call   80103de0 <outb>
8010411e:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104121:	83 ec 0c             	sub    $0xc,%esp
80104124:	6a 23                	push   $0x23
80104126:	e8 98 fc ff ff       	call   80103dc3 <inb>
8010412b:	83 c4 10             	add    $0x10,%esp
8010412e:	83 c8 01             	or     $0x1,%eax
80104131:	0f b6 c0             	movzbl %al,%eax
80104134:	83 ec 08             	sub    $0x8,%esp
80104137:	50                   	push   %eax
80104138:	6a 23                	push   $0x23
8010413a:	e8 a1 fc ff ff       	call   80103de0 <outb>
8010413f:	83 c4 10             	add    $0x10,%esp
  }
}
80104142:	90                   	nop
80104143:	c9                   	leave  
80104144:	c3                   	ret    

80104145 <outb>:
{
80104145:	55                   	push   %ebp
80104146:	89 e5                	mov    %esp,%ebp
80104148:	83 ec 08             	sub    $0x8,%esp
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104151:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80104155:	89 d0                	mov    %edx,%eax
80104157:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010415a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010415e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104162:	ee                   	out    %al,(%dx)
}
80104163:	90                   	nop
80104164:	c9                   	leave  
80104165:	c3                   	ret    

80104166 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80104166:	55                   	push   %ebp
80104167:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104169:	68 ff 00 00 00       	push   $0xff
8010416e:	6a 21                	push   $0x21
80104170:	e8 d0 ff ff ff       	call   80104145 <outb>
80104175:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104178:	68 ff 00 00 00       	push   $0xff
8010417d:	68 a1 00 00 00       	push   $0xa1
80104182:	e8 be ff ff ff       	call   80104145 <outb>
80104187:	83 c4 08             	add    $0x8,%esp
}
8010418a:	90                   	nop
8010418b:	c9                   	leave  
8010418c:	c3                   	ret    

8010418d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010418d:	55                   	push   %ebp
8010418e:	89 e5                	mov    %esp,%ebp
80104190:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010419a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010419d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801041a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801041a6:	8b 10                	mov    (%eax),%edx
801041a8:	8b 45 08             	mov    0x8(%ebp),%eax
801041ab:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801041ad:	e8 25 d2 ff ff       	call   801013d7 <filealloc>
801041b2:	8b 55 08             	mov    0x8(%ebp),%edx
801041b5:	89 02                	mov    %eax,(%edx)
801041b7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ba:	8b 00                	mov    (%eax),%eax
801041bc:	85 c0                	test   %eax,%eax
801041be:	0f 84 c8 00 00 00    	je     8010428c <pipealloc+0xff>
801041c4:	e8 0e d2 ff ff       	call   801013d7 <filealloc>
801041c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801041cc:	89 02                	mov    %eax,(%edx)
801041ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801041d1:	8b 00                	mov    (%eax),%eax
801041d3:	85 c0                	test   %eax,%eax
801041d5:	0f 84 b1 00 00 00    	je     8010428c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801041db:	e8 6d ee ff ff       	call   8010304d <kalloc>
801041e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041e7:	0f 84 a2 00 00 00    	je     8010428f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801041ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801041f7:	00 00 00 
  p->writeopen = 1;
801041fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104204:	00 00 00 
  p->nwrite = 0;
80104207:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420a:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104211:	00 00 00 
  p->nread = 0;
80104214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104217:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010421e:	00 00 00 
  initlock(&p->lock, "pipe");
80104221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104224:	83 ec 08             	sub    $0x8,%esp
80104227:	68 e7 95 10 80       	push   $0x801095e7
8010422c:	50                   	push   %eax
8010422d:	e8 99 1a 00 00       	call   80105ccb <initlock>
80104232:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104235:	8b 45 08             	mov    0x8(%ebp),%eax
80104238:	8b 00                	mov    (%eax),%eax
8010423a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104240:	8b 45 08             	mov    0x8(%ebp),%eax
80104243:	8b 00                	mov    (%eax),%eax
80104245:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104249:	8b 45 08             	mov    0x8(%ebp),%eax
8010424c:	8b 00                	mov    (%eax),%eax
8010424e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104252:	8b 45 08             	mov    0x8(%ebp),%eax
80104255:	8b 00                	mov    (%eax),%eax
80104257:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010425a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010425d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104260:	8b 00                	mov    (%eax),%eax
80104262:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104268:	8b 45 0c             	mov    0xc(%ebp),%eax
8010426b:	8b 00                	mov    (%eax),%eax
8010426d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104271:	8b 45 0c             	mov    0xc(%ebp),%eax
80104274:	8b 00                	mov    (%eax),%eax
80104276:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010427a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010427d:	8b 00                	mov    (%eax),%eax
8010427f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104282:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104285:	b8 00 00 00 00       	mov    $0x0,%eax
8010428a:	eb 51                	jmp    801042dd <pipealloc+0x150>
    goto bad;
8010428c:	90                   	nop
8010428d:	eb 01                	jmp    80104290 <pipealloc+0x103>
    goto bad;
8010428f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104290:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104294:	74 0e                	je     801042a4 <pipealloc+0x117>
    kfree((char*)p);
80104296:	83 ec 0c             	sub    $0xc,%esp
80104299:	ff 75 f4             	push   -0xc(%ebp)
8010429c:	e8 12 ed ff ff       	call   80102fb3 <kfree>
801042a1:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801042a4:	8b 45 08             	mov    0x8(%ebp),%eax
801042a7:	8b 00                	mov    (%eax),%eax
801042a9:	85 c0                	test   %eax,%eax
801042ab:	74 11                	je     801042be <pipealloc+0x131>
    fileclose(*f0);
801042ad:	8b 45 08             	mov    0x8(%ebp),%eax
801042b0:	8b 00                	mov    (%eax),%eax
801042b2:	83 ec 0c             	sub    $0xc,%esp
801042b5:	50                   	push   %eax
801042b6:	e8 da d1 ff ff       	call   80101495 <fileclose>
801042bb:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801042be:	8b 45 0c             	mov    0xc(%ebp),%eax
801042c1:	8b 00                	mov    (%eax),%eax
801042c3:	85 c0                	test   %eax,%eax
801042c5:	74 11                	je     801042d8 <pipealloc+0x14b>
    fileclose(*f1);
801042c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801042ca:	8b 00                	mov    (%eax),%eax
801042cc:	83 ec 0c             	sub    $0xc,%esp
801042cf:	50                   	push   %eax
801042d0:	e8 c0 d1 ff ff       	call   80101495 <fileclose>
801042d5:	83 c4 10             	add    $0x10,%esp
  return -1;
801042d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801042dd:	c9                   	leave  
801042de:	c3                   	ret    

801042df <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801042df:	55                   	push   %ebp
801042e0:	89 e5                	mov    %esp,%ebp
801042e2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801042e5:	8b 45 08             	mov    0x8(%ebp),%eax
801042e8:	83 ec 0c             	sub    $0xc,%esp
801042eb:	50                   	push   %eax
801042ec:	e8 fc 19 00 00       	call   80105ced <acquire>
801042f1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801042f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042f8:	74 23                	je     8010431d <pipeclose+0x3e>
    p->writeopen = 0;
801042fa:	8b 45 08             	mov    0x8(%ebp),%eax
801042fd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104304:	00 00 00 
    wakeup(&p->nread);
80104307:	8b 45 08             	mov    0x8(%ebp),%eax
8010430a:	05 34 02 00 00       	add    $0x234,%eax
8010430f:	83 ec 0c             	sub    $0xc,%esp
80104312:	50                   	push   %eax
80104313:	e8 a7 10 00 00       	call   801053bf <wakeup>
80104318:	83 c4 10             	add    $0x10,%esp
8010431b:	eb 21                	jmp    8010433e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010431d:	8b 45 08             	mov    0x8(%ebp),%eax
80104320:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104327:	00 00 00 
    wakeup(&p->nwrite);
8010432a:	8b 45 08             	mov    0x8(%ebp),%eax
8010432d:	05 38 02 00 00       	add    $0x238,%eax
80104332:	83 ec 0c             	sub    $0xc,%esp
80104335:	50                   	push   %eax
80104336:	e8 84 10 00 00       	call   801053bf <wakeup>
8010433b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010433e:	8b 45 08             	mov    0x8(%ebp),%eax
80104341:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104347:	85 c0                	test   %eax,%eax
80104349:	75 2c                	jne    80104377 <pipeclose+0x98>
8010434b:	8b 45 08             	mov    0x8(%ebp),%eax
8010434e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104354:	85 c0                	test   %eax,%eax
80104356:	75 1f                	jne    80104377 <pipeclose+0x98>
    release(&p->lock);
80104358:	8b 45 08             	mov    0x8(%ebp),%eax
8010435b:	83 ec 0c             	sub    $0xc,%esp
8010435e:	50                   	push   %eax
8010435f:	e8 f7 19 00 00       	call   80105d5b <release>
80104364:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104367:	83 ec 0c             	sub    $0xc,%esp
8010436a:	ff 75 08             	push   0x8(%ebp)
8010436d:	e8 41 ec ff ff       	call   80102fb3 <kfree>
80104372:	83 c4 10             	add    $0x10,%esp
80104375:	eb 10                	jmp    80104387 <pipeclose+0xa8>
  } else
    release(&p->lock);
80104377:	8b 45 08             	mov    0x8(%ebp),%eax
8010437a:	83 ec 0c             	sub    $0xc,%esp
8010437d:	50                   	push   %eax
8010437e:	e8 d8 19 00 00       	call   80105d5b <release>
80104383:	83 c4 10             	add    $0x10,%esp
}
80104386:	90                   	nop
80104387:	90                   	nop
80104388:	c9                   	leave  
80104389:	c3                   	ret    

8010438a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010438a:	55                   	push   %ebp
8010438b:	89 e5                	mov    %esp,%ebp
8010438d:	53                   	push   %ebx
8010438e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104391:	8b 45 08             	mov    0x8(%ebp),%eax
80104394:	83 ec 0c             	sub    $0xc,%esp
80104397:	50                   	push   %eax
80104398:	e8 50 19 00 00       	call   80105ced <acquire>
8010439d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801043a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043a7:	e9 ad 00 00 00       	jmp    80104459 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801043ac:	8b 45 08             	mov    0x8(%ebp),%eax
801043af:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801043b5:	85 c0                	test   %eax,%eax
801043b7:	74 0c                	je     801043c5 <pipewrite+0x3b>
801043b9:	e8 92 02 00 00       	call   80104650 <myproc>
801043be:	8b 40 24             	mov    0x24(%eax),%eax
801043c1:	85 c0                	test   %eax,%eax
801043c3:	74 19                	je     801043de <pipewrite+0x54>
        release(&p->lock);
801043c5:	8b 45 08             	mov    0x8(%ebp),%eax
801043c8:	83 ec 0c             	sub    $0xc,%esp
801043cb:	50                   	push   %eax
801043cc:	e8 8a 19 00 00       	call   80105d5b <release>
801043d1:	83 c4 10             	add    $0x10,%esp
        return -1;
801043d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043d9:	e9 a9 00 00 00       	jmp    80104487 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801043de:	8b 45 08             	mov    0x8(%ebp),%eax
801043e1:	05 34 02 00 00       	add    $0x234,%eax
801043e6:	83 ec 0c             	sub    $0xc,%esp
801043e9:	50                   	push   %eax
801043ea:	e8 d0 0f 00 00       	call   801053bf <wakeup>
801043ef:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801043f2:	8b 45 08             	mov    0x8(%ebp),%eax
801043f5:	8b 55 08             	mov    0x8(%ebp),%edx
801043f8:	81 c2 38 02 00 00    	add    $0x238,%edx
801043fe:	83 ec 08             	sub    $0x8,%esp
80104401:	50                   	push   %eax
80104402:	52                   	push   %edx
80104403:	e8 cd 0e 00 00       	call   801052d5 <sleep>
80104408:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010440b:	8b 45 08             	mov    0x8(%ebp),%eax
8010440e:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104414:	8b 45 08             	mov    0x8(%ebp),%eax
80104417:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010441d:	05 00 02 00 00       	add    $0x200,%eax
80104422:	39 c2                	cmp    %eax,%edx
80104424:	74 86                	je     801043ac <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104426:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104429:	8b 45 0c             	mov    0xc(%ebp),%eax
8010442c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010442f:	8b 45 08             	mov    0x8(%ebp),%eax
80104432:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104438:	8d 48 01             	lea    0x1(%eax),%ecx
8010443b:	8b 55 08             	mov    0x8(%ebp),%edx
8010443e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104444:	25 ff 01 00 00       	and    $0x1ff,%eax
80104449:	89 c1                	mov    %eax,%ecx
8010444b:	0f b6 13             	movzbl (%ebx),%edx
8010444e:	8b 45 08             	mov    0x8(%ebp),%eax
80104451:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104455:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010445f:	7c aa                	jl     8010440b <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104461:	8b 45 08             	mov    0x8(%ebp),%eax
80104464:	05 34 02 00 00       	add    $0x234,%eax
80104469:	83 ec 0c             	sub    $0xc,%esp
8010446c:	50                   	push   %eax
8010446d:	e8 4d 0f 00 00       	call   801053bf <wakeup>
80104472:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104475:	8b 45 08             	mov    0x8(%ebp),%eax
80104478:	83 ec 0c             	sub    $0xc,%esp
8010447b:	50                   	push   %eax
8010447c:	e8 da 18 00 00       	call   80105d5b <release>
80104481:	83 c4 10             	add    $0x10,%esp
  return n;
80104484:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104487:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010448a:	c9                   	leave  
8010448b:	c3                   	ret    

8010448c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010448c:	55                   	push   %ebp
8010448d:	89 e5                	mov    %esp,%ebp
8010448f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104492:	8b 45 08             	mov    0x8(%ebp),%eax
80104495:	83 ec 0c             	sub    $0xc,%esp
80104498:	50                   	push   %eax
80104499:	e8 4f 18 00 00       	call   80105ced <acquire>
8010449e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801044a1:	eb 3e                	jmp    801044e1 <piperead+0x55>
    if(myproc()->killed){
801044a3:	e8 a8 01 00 00       	call   80104650 <myproc>
801044a8:	8b 40 24             	mov    0x24(%eax),%eax
801044ab:	85 c0                	test   %eax,%eax
801044ad:	74 19                	je     801044c8 <piperead+0x3c>
      release(&p->lock);
801044af:	8b 45 08             	mov    0x8(%ebp),%eax
801044b2:	83 ec 0c             	sub    $0xc,%esp
801044b5:	50                   	push   %eax
801044b6:	e8 a0 18 00 00       	call   80105d5b <release>
801044bb:	83 c4 10             	add    $0x10,%esp
      return -1;
801044be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044c3:	e9 be 00 00 00       	jmp    80104586 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801044c8:	8b 45 08             	mov    0x8(%ebp),%eax
801044cb:	8b 55 08             	mov    0x8(%ebp),%edx
801044ce:	81 c2 34 02 00 00    	add    $0x234,%edx
801044d4:	83 ec 08             	sub    $0x8,%esp
801044d7:	50                   	push   %eax
801044d8:	52                   	push   %edx
801044d9:	e8 f7 0d 00 00       	call   801052d5 <sleep>
801044de:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801044e1:	8b 45 08             	mov    0x8(%ebp),%eax
801044e4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801044ea:	8b 45 08             	mov    0x8(%ebp),%eax
801044ed:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801044f3:	39 c2                	cmp    %eax,%edx
801044f5:	75 0d                	jne    80104504 <piperead+0x78>
801044f7:	8b 45 08             	mov    0x8(%ebp),%eax
801044fa:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104500:	85 c0                	test   %eax,%eax
80104502:	75 9f                	jne    801044a3 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104504:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010450b:	eb 48                	jmp    80104555 <piperead+0xc9>
    if(p->nread == p->nwrite)
8010450d:	8b 45 08             	mov    0x8(%ebp),%eax
80104510:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104516:	8b 45 08             	mov    0x8(%ebp),%eax
80104519:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010451f:	39 c2                	cmp    %eax,%edx
80104521:	74 3c                	je     8010455f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104523:	8b 45 08             	mov    0x8(%ebp),%eax
80104526:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010452c:	8d 48 01             	lea    0x1(%eax),%ecx
8010452f:	8b 55 08             	mov    0x8(%ebp),%edx
80104532:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104538:	25 ff 01 00 00       	and    $0x1ff,%eax
8010453d:	89 c1                	mov    %eax,%ecx
8010453f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104542:	8b 45 0c             	mov    0xc(%ebp),%eax
80104545:	01 c2                	add    %eax,%edx
80104547:	8b 45 08             	mov    0x8(%ebp),%eax
8010454a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010454f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104551:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104558:	3b 45 10             	cmp    0x10(%ebp),%eax
8010455b:	7c b0                	jl     8010450d <piperead+0x81>
8010455d:	eb 01                	jmp    80104560 <piperead+0xd4>
      break;
8010455f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104560:	8b 45 08             	mov    0x8(%ebp),%eax
80104563:	05 38 02 00 00       	add    $0x238,%eax
80104568:	83 ec 0c             	sub    $0xc,%esp
8010456b:	50                   	push   %eax
8010456c:	e8 4e 0e 00 00       	call   801053bf <wakeup>
80104571:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104574:	8b 45 08             	mov    0x8(%ebp),%eax
80104577:	83 ec 0c             	sub    $0xc,%esp
8010457a:	50                   	push   %eax
8010457b:	e8 db 17 00 00       	call   80105d5b <release>
80104580:	83 c4 10             	add    $0x10,%esp
  return i;
80104583:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104586:	c9                   	leave  
80104587:	c3                   	ret    

80104588 <readeflags>:
{
80104588:	55                   	push   %ebp
80104589:	89 e5                	mov    %esp,%ebp
8010458b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010458e:	9c                   	pushf  
8010458f:	58                   	pop    %eax
80104590:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104593:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104596:	c9                   	leave  
80104597:	c3                   	ret    

80104598 <sti>:
{
80104598:	55                   	push   %ebp
80104599:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010459b:	fb                   	sti    
}
8010459c:	90                   	nop
8010459d:	5d                   	pop    %ebp
8010459e:	c3                   	ret    

8010459f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010459f:	55                   	push   %ebp
801045a0:	89 e5                	mov    %esp,%ebp
801045a2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801045a5:	83 ec 08             	sub    $0x8,%esp
801045a8:	68 ec 95 10 80       	push   $0x801095ec
801045ad:	68 80 39 11 80       	push   $0x80113980
801045b2:	e8 14 17 00 00       	call   80105ccb <initlock>
801045b7:	83 c4 10             	add    $0x10,%esp
}
801045ba:	90                   	nop
801045bb:	c9                   	leave  
801045bc:	c3                   	ret    

801045bd <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801045bd:	55                   	push   %ebp
801045be:	89 e5                	mov    %esp,%ebp
801045c0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801045c3:	e8 10 00 00 00       	call   801045d8 <mycpu>
801045c8:	2d e0 37 11 80       	sub    $0x801137e0,%eax
801045cd:	c1 f8 04             	sar    $0x4,%eax
801045d0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801045d6:	c9                   	leave  
801045d7:	c3                   	ret    

801045d8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801045d8:	55                   	push   %ebp
801045d9:	89 e5                	mov    %esp,%ebp
801045db:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801045de:	e8 a5 ff ff ff       	call   80104588 <readeflags>
801045e3:	25 00 02 00 00       	and    $0x200,%eax
801045e8:	85 c0                	test   %eax,%eax
801045ea:	74 0d                	je     801045f9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801045ec:	83 ec 0c             	sub    $0xc,%esp
801045ef:	68 f4 95 10 80       	push   $0x801095f4
801045f4:	e8 bc bf ff ff       	call   801005b5 <panic>
  
  apicid = lapicid();
801045f9:	e8 a9 ed ff ff       	call   801033a7 <lapicid>
801045fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104601:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104608:	eb 2d                	jmp    80104637 <mycpu+0x5f>
    if (cpus[i].apicid == apicid)
8010460a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104613:	05 e0 37 11 80       	add    $0x801137e0,%eax
80104618:	0f b6 00             	movzbl (%eax),%eax
8010461b:	0f b6 c0             	movzbl %al,%eax
8010461e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104621:	75 10                	jne    80104633 <mycpu+0x5b>
      return &cpus[i];
80104623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104626:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010462c:	05 e0 37 11 80       	add    $0x801137e0,%eax
80104631:	eb 1b                	jmp    8010464e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80104633:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104637:	a1 40 39 11 80       	mov    0x80113940,%eax
8010463c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010463f:	7c c9                	jl     8010460a <mycpu+0x32>
  }
  panic("unknown apicid\n");
80104641:	83 ec 0c             	sub    $0xc,%esp
80104644:	68 1a 96 10 80       	push   $0x8010961a
80104649:	e8 67 bf ff ff       	call   801005b5 <panic>
}
8010464e:	c9                   	leave  
8010464f:	c3                   	ret    

80104650 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104650:	55                   	push   %ebp
80104651:	89 e5                	mov    %esp,%ebp
80104653:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104656:	e8 0d 18 00 00       	call   80105e68 <pushcli>
  c = mycpu();
8010465b:	e8 78 ff ff ff       	call   801045d8 <mycpu>
80104660:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104666:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010466c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010466f:	e8 41 18 00 00       	call   80105eb5 <popcli>
  return p;
80104674:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104677:	c9                   	leave  
80104678:	c3                   	ret    

80104679 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104679:	55                   	push   %ebp
8010467a:	89 e5                	mov    %esp,%ebp
8010467c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010467f:	83 ec 0c             	sub    $0xc,%esp
80104682:	68 80 39 11 80       	push   $0x80113980
80104687:	e8 61 16 00 00       	call   80105ced <acquire>
8010468c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010468f:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104696:	eb 11                	jmp    801046a9 <allocproc+0x30>
    if(p->state == UNUSED)
80104698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469b:	8b 40 0c             	mov    0xc(%eax),%eax
8010469e:	85 c0                	test   %eax,%eax
801046a0:	74 2a                	je     801046cc <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801046a2:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
801046a9:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
801046b0:	72 e6                	jb     80104698 <allocproc+0x1f>
      goto found;

  release(&ptable.lock);
801046b2:	83 ec 0c             	sub    $0xc,%esp
801046b5:	68 80 39 11 80       	push   $0x80113980
801046ba:	e8 9c 16 00 00       	call   80105d5b <release>
801046bf:	83 c4 10             	add    $0x10,%esp
  return 0;
801046c2:	b8 00 00 00 00       	mov    $0x0,%eax
801046c7:	e9 fd 00 00 00       	jmp    801047c9 <allocproc+0x150>
      goto found;
801046cc:	90                   	nop

found:
  p->state = EMBRYO;
801046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801046d7:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801046dc:	8d 50 01             	lea    0x1(%eax),%edx
801046df:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
801046e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046e8:	89 42 10             	mov    %eax,0x10(%edx)
  p->deadline= 10;
801046eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ee:	c7 40 7c 0a 00 00 00 	movl   $0xa,0x7c(%eax)
  p->exec_time = 5;
801046f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f8:	c7 80 80 00 00 00 05 	movl   $0x5,0x80(%eax)
801046ff:	00 00 00 
  p->policy = -1;
80104702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104705:	c7 80 8c 00 00 00 ff 	movl   $0xffffffff,0x8c(%eax)
8010470c:	ff ff ff 
  p->elapsed_time = 0;
8010470f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104712:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104719:	00 00 00 
  p->arrival_elapsed_time = 0;
8010471c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471f:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104726:	00 00 00 
  p->arrival_time=-1;
80104729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472c:	c7 80 90 00 00 00 ff 	movl   $0xffffffff,0x90(%eax)
80104733:	ff ff ff 

  release(&ptable.lock);
80104736:	83 ec 0c             	sub    $0xc,%esp
80104739:	68 80 39 11 80       	push   $0x80113980
8010473e:	e8 18 16 00 00       	call   80105d5b <release>
80104743:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104746:	e8 02 e9 ff ff       	call   8010304d <kalloc>
8010474b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010474e:	89 42 08             	mov    %eax,0x8(%edx)
80104751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104754:	8b 40 08             	mov    0x8(%eax),%eax
80104757:	85 c0                	test   %eax,%eax
80104759:	75 11                	jne    8010476c <allocproc+0xf3>
    p->state = UNUSED;
8010475b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104765:	b8 00 00 00 00       	mov    $0x0,%eax
8010476a:	eb 5d                	jmp    801047c9 <allocproc+0x150>
  }
  sp = p->kstack + KSTACKSIZE;
8010476c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476f:	8b 40 08             	mov    0x8(%eax),%eax
80104772:	05 00 10 00 00       	add    $0x1000,%eax
80104777:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010477a:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010477e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104781:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104784:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104787:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010478b:	ba 58 74 10 80       	mov    $0x80107458,%edx
80104790:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104793:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104795:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010479f:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801047a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a5:	8b 40 1c             	mov    0x1c(%eax),%eax
801047a8:	83 ec 04             	sub    $0x4,%esp
801047ab:	6a 14                	push   $0x14
801047ad:	6a 00                	push   $0x0
801047af:	50                   	push   %eax
801047b0:	e8 be 17 00 00       	call   80105f73 <memset>
801047b5:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801047b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047bb:	8b 40 1c             	mov    0x1c(%eax),%eax
801047be:	ba 8f 52 10 80       	mov    $0x8010528f,%edx
801047c3:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801047c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801047c9:	c9                   	leave  
801047ca:	c3                   	ret    

801047cb <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801047cb:	55                   	push   %ebp
801047cc:	89 e5                	mov    %esp,%ebp
801047ce:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801047d1:	e8 a3 fe ff ff       	call   80104679 <allocproc>
801047d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801047d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047dc:	a3 b4 60 11 80       	mov    %eax,0x801160b4
  if((p->pgdir = setupkvm()) == 0)
801047e1:	e8 28 42 00 00       	call   80108a0e <setupkvm>
801047e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047e9:	89 42 04             	mov    %eax,0x4(%edx)
801047ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ef:	8b 40 04             	mov    0x4(%eax),%eax
801047f2:	85 c0                	test   %eax,%eax
801047f4:	75 0d                	jne    80104803 <userinit+0x38>
    panic("userinit: out of memory?");
801047f6:	83 ec 0c             	sub    $0xc,%esp
801047f9:	68 2a 96 10 80       	push   $0x8010962a
801047fe:	e8 b2 bd ff ff       	call   801005b5 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104803:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480b:	8b 40 04             	mov    0x4(%eax),%eax
8010480e:	83 ec 04             	sub    $0x4,%esp
80104811:	52                   	push   %edx
80104812:	68 e0 c4 10 80       	push   $0x8010c4e0
80104817:	50                   	push   %eax
80104818:	e8 5a 44 00 00       	call   80108c77 <inituvm>
8010481d:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104823:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482c:	8b 40 18             	mov    0x18(%eax),%eax
8010482f:	83 ec 04             	sub    $0x4,%esp
80104832:	6a 4c                	push   $0x4c
80104834:	6a 00                	push   $0x0
80104836:	50                   	push   %eax
80104837:	e8 37 17 00 00       	call   80105f73 <memset>
8010483c:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010483f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104842:	8b 40 18             	mov    0x18(%eax),%eax
80104845:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010484b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010484e:	8b 40 18             	mov    0x18(%eax),%eax
80104851:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485a:	8b 50 18             	mov    0x18(%eax),%edx
8010485d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104860:	8b 40 18             	mov    0x18(%eax),%eax
80104863:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104867:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010486b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010486e:	8b 50 18             	mov    0x18(%eax),%edx
80104871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104874:	8b 40 18             	mov    0x18(%eax),%eax
80104877:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010487b:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010487f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104882:	8b 40 18             	mov    0x18(%eax),%eax
80104885:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010488c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488f:	8b 40 18             	mov    0x18(%eax),%eax
80104892:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489c:	8b 40 18             	mov    0x18(%eax),%eax
8010489f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801048a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a9:	83 c0 6c             	add    $0x6c,%eax
801048ac:	83 ec 04             	sub    $0x4,%esp
801048af:	6a 10                	push   $0x10
801048b1:	68 43 96 10 80       	push   $0x80109643
801048b6:	50                   	push   %eax
801048b7:	e8 ba 18 00 00       	call   80106176 <safestrcpy>
801048bc:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801048bf:	83 ec 0c             	sub    $0xc,%esp
801048c2:	68 4c 96 10 80       	push   $0x8010964c
801048c7:	e8 38 e0 ff ff       	call   80102904 <namei>
801048cc:	83 c4 10             	add    $0x10,%esp
801048cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048d2:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801048d5:	83 ec 0c             	sub    $0xc,%esp
801048d8:	68 80 39 11 80       	push   $0x80113980
801048dd:	e8 0b 14 00 00       	call   80105ced <acquire>
801048e2:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801048e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801048ef:	83 ec 0c             	sub    $0xc,%esp
801048f2:	68 80 39 11 80       	push   $0x80113980
801048f7:	e8 5f 14 00 00       	call   80105d5b <release>
801048fc:	83 c4 10             	add    $0x10,%esp
}
801048ff:	90                   	nop
80104900:	c9                   	leave  
80104901:	c3                   	ret    

80104902 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104902:	55                   	push   %ebp
80104903:	89 e5                	mov    %esp,%ebp
80104905:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104908:	e8 43 fd ff ff       	call   80104650 <myproc>
8010490d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104913:	8b 00                	mov    (%eax),%eax
80104915:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104918:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010491c:	7e 2e                	jle    8010494c <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010491e:	8b 55 08             	mov    0x8(%ebp),%edx
80104921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104924:	01 c2                	add    %eax,%edx
80104926:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104929:	8b 40 04             	mov    0x4(%eax),%eax
8010492c:	83 ec 04             	sub    $0x4,%esp
8010492f:	52                   	push   %edx
80104930:	ff 75 f4             	push   -0xc(%ebp)
80104933:	50                   	push   %eax
80104934:	e8 7b 44 00 00       	call   80108db4 <allocuvm>
80104939:	83 c4 10             	add    $0x10,%esp
8010493c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010493f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104943:	75 3b                	jne    80104980 <growproc+0x7e>
      return -1;
80104945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010494a:	eb 4f                	jmp    8010499b <growproc+0x99>
  } else if(n < 0){
8010494c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104950:	79 2e                	jns    80104980 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104952:	8b 55 08             	mov    0x8(%ebp),%edx
80104955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104958:	01 c2                	add    %eax,%edx
8010495a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010495d:	8b 40 04             	mov    0x4(%eax),%eax
80104960:	83 ec 04             	sub    $0x4,%esp
80104963:	52                   	push   %edx
80104964:	ff 75 f4             	push   -0xc(%ebp)
80104967:	50                   	push   %eax
80104968:	e8 4c 45 00 00       	call   80108eb9 <deallocuvm>
8010496d:	83 c4 10             	add    $0x10,%esp
80104970:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104973:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104977:	75 07                	jne    80104980 <growproc+0x7e>
      return -1;
80104979:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010497e:	eb 1b                	jmp    8010499b <growproc+0x99>
  }
  curproc->sz = sz;
80104980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104983:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104986:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104988:	83 ec 0c             	sub    $0xc,%esp
8010498b:	ff 75 f0             	push   -0x10(%ebp)
8010498e:	e8 45 41 00 00       	call   80108ad8 <switchuvm>
80104993:	83 c4 10             	add    $0x10,%esp
  return 0;
80104996:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010499b:	c9                   	leave  
8010499c:	c3                   	ret    

8010499d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010499d:	55                   	push   %ebp
8010499e:	89 e5                	mov    %esp,%ebp
801049a0:	57                   	push   %edi
801049a1:	56                   	push   %esi
801049a2:	53                   	push   %ebx
801049a3:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801049a6:	e8 a5 fc ff ff       	call   80104650 <myproc>
801049ab:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801049ae:	e8 c6 fc ff ff       	call   80104679 <allocproc>
801049b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
801049b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801049ba:	75 0a                	jne    801049c6 <fork+0x29>
    return -1;
801049bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049c1:	e9 48 01 00 00       	jmp    80104b0e <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801049c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049c9:	8b 10                	mov    (%eax),%edx
801049cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ce:	8b 40 04             	mov    0x4(%eax),%eax
801049d1:	83 ec 08             	sub    $0x8,%esp
801049d4:	52                   	push   %edx
801049d5:	50                   	push   %eax
801049d6:	e8 7c 46 00 00       	call   80109057 <copyuvm>
801049db:	83 c4 10             	add    $0x10,%esp
801049de:	8b 55 dc             	mov    -0x24(%ebp),%edx
801049e1:	89 42 04             	mov    %eax,0x4(%edx)
801049e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049e7:	8b 40 04             	mov    0x4(%eax),%eax
801049ea:	85 c0                	test   %eax,%eax
801049ec:	75 30                	jne    80104a1e <fork+0x81>
    kfree(np->kstack);
801049ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049f1:	8b 40 08             	mov    0x8(%eax),%eax
801049f4:	83 ec 0c             	sub    $0xc,%esp
801049f7:	50                   	push   %eax
801049f8:	e8 b6 e5 ff ff       	call   80102fb3 <kfree>
801049fd:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104a00:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a03:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104a0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a0d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104a14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a19:	e9 f0 00 00 00       	jmp    80104b0e <fork+0x171>
  }
  np->sz = curproc->sz;
80104a1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a21:	8b 10                	mov    (%eax),%edx
80104a23:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a26:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104a28:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a2b:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104a2e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104a31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a34:	8b 48 18             	mov    0x18(%eax),%ecx
80104a37:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a3a:	8b 40 18             	mov    0x18(%eax),%eax
80104a3d:	89 c2                	mov    %eax,%edx
80104a3f:	89 cb                	mov    %ecx,%ebx
80104a41:	b8 13 00 00 00       	mov    $0x13,%eax
80104a46:	89 d7                	mov    %edx,%edi
80104a48:	89 de                	mov    %ebx,%esi
80104a4a:	89 c1                	mov    %eax,%ecx
80104a4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104a4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a51:	8b 40 18             	mov    0x18(%eax),%eax
80104a54:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104a5b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104a62:	eb 3b                	jmp    80104a9f <fork+0x102>
    if(curproc->ofile[i])
80104a64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a67:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a6a:	83 c2 08             	add    $0x8,%edx
80104a6d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a71:	85 c0                	test   %eax,%eax
80104a73:	74 26                	je     80104a9b <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104a75:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a78:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a7b:	83 c2 08             	add    $0x8,%edx
80104a7e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a82:	83 ec 0c             	sub    $0xc,%esp
80104a85:	50                   	push   %eax
80104a86:	e8 b9 c9 ff ff       	call   80101444 <filedup>
80104a8b:	83 c4 10             	add    $0x10,%esp
80104a8e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104a91:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104a94:	83 c1 08             	add    $0x8,%ecx
80104a97:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104a9b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104a9f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104aa3:	7e bf                	jle    80104a64 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80104aa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aa8:	8b 40 68             	mov    0x68(%eax),%eax
80104aab:	83 ec 0c             	sub    $0xc,%esp
80104aae:	50                   	push   %eax
80104aaf:	e8 e3 d2 ff ff       	call   80101d97 <idup>
80104ab4:	83 c4 10             	add    $0x10,%esp
80104ab7:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104aba:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104abd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ac0:	8d 50 6c             	lea    0x6c(%eax),%edx
80104ac3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104ac6:	83 c0 6c             	add    $0x6c,%eax
80104ac9:	83 ec 04             	sub    $0x4,%esp
80104acc:	6a 10                	push   $0x10
80104ace:	52                   	push   %edx
80104acf:	50                   	push   %eax
80104ad0:	e8 a1 16 00 00       	call   80106176 <safestrcpy>
80104ad5:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104ad8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104adb:	8b 40 10             	mov    0x10(%eax),%eax
80104ade:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104ae1:	83 ec 0c             	sub    $0xc,%esp
80104ae4:	68 80 39 11 80       	push   $0x80113980
80104ae9:	e8 ff 11 00 00       	call   80105ced <acquire>
80104aee:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104af1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104af4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104afb:	83 ec 0c             	sub    $0xc,%esp
80104afe:	68 80 39 11 80       	push   $0x80113980
80104b03:	e8 53 12 00 00       	call   80105d5b <release>
80104b08:	83 c4 10             	add    $0x10,%esp

  return pid;
80104b0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104b11:	5b                   	pop    %ebx
80104b12:	5e                   	pop    %esi
80104b13:	5f                   	pop    %edi
80104b14:	5d                   	pop    %ebp
80104b15:	c3                   	ret    

80104b16 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104b16:	55                   	push   %ebp
80104b17:	89 e5                	mov    %esp,%ebp
80104b19:	83 ec 18             	sub    $0x18,%esp

  pushcli();
80104b1c:	e8 47 13 00 00       	call   80105e68 <pushcli>
  mycpu()->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80104b21:	e8 b2 fa ff ff       	call   801045d8 <mycpu>
80104b26:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80104b2d:	ff ff 
80104b2f:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80104b36:	00 00 
80104b38:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80104b3f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80104b46:	83 e2 f0             	and    $0xfffffff0,%edx
80104b49:	83 ca 0a             	or     $0xa,%edx
80104b4c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80104b52:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80104b59:	83 ca 10             	or     $0x10,%edx
80104b5c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80104b62:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80104b69:	83 ca 60             	or     $0x60,%edx
80104b6c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80104b72:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80104b79:	83 ca 80             	or     $0xffffff80,%edx
80104b7c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80104b82:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80104b89:	83 ca 0f             	or     $0xf,%edx
80104b8c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80104b92:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80104b99:	83 e2 ef             	and    $0xffffffef,%edx
80104b9c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80104ba2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80104ba9:	83 e2 df             	and    $0xffffffdf,%edx
80104bac:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80104bb2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80104bb9:	83 ca 40             	or     $0x40,%edx
80104bbc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80104bc2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80104bc9:	83 ca 80             	or     $0xffffff80,%edx
80104bcc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80104bd2:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  mycpu()->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80104bd9:	e8 fa f9 ff ff       	call   801045d8 <mycpu>
80104bde:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80104be5:	ff ff 
80104be7:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80104bee:	00 00 
80104bf0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80104bf7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80104bfe:	83 e2 f0             	and    $0xfffffff0,%edx
80104c01:	83 ca 02             	or     $0x2,%edx
80104c04:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80104c0a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80104c11:	83 ca 10             	or     $0x10,%edx
80104c14:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80104c1a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80104c21:	83 ca 60             	or     $0x60,%edx
80104c24:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80104c2a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80104c31:	83 ca 80             	or     $0xffffff80,%edx
80104c34:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80104c3a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80104c41:	83 ca 0f             	or     $0xf,%edx
80104c44:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80104c4a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80104c51:	83 e2 ef             	and    $0xffffffef,%edx
80104c54:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80104c5a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80104c61:	83 e2 df             	and    $0xffffffdf,%edx
80104c64:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80104c6a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80104c71:	83 ca 40             	or     $0x40,%edx
80104c74:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80104c7a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80104c81:	83 ca 80             	or     $0xffffff80,%edx
80104c84:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80104c8a:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  popcli();
80104c91:	e8 1f 12 00 00       	call   80105eb5 <popcli>
  struct proc *curproc = myproc();
80104c96:	e8 b5 f9 ff ff       	call   80104650 <myproc>
80104c9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104c9e:	a1 b4 60 11 80       	mov    0x801160b4,%eax
80104ca3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104ca6:	75 0d                	jne    80104cb5 <exit+0x19f>
    panic("init exiting");
80104ca8:	83 ec 0c             	sub    $0xc,%esp
80104cab:	68 4e 96 10 80       	push   $0x8010964e
80104cb0:	e8 00 b9 ff ff       	call   801005b5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104cb5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104cbc:	eb 3f                	jmp    80104cfd <exit+0x1e7>
    if(curproc->ofile[fd]){
80104cbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cc1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cc4:	83 c2 08             	add    $0x8,%edx
80104cc7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ccb:	85 c0                	test   %eax,%eax
80104ccd:	74 2a                	je     80104cf9 <exit+0x1e3>
      fileclose(curproc->ofile[fd]);
80104ccf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cd2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cd5:	83 c2 08             	add    $0x8,%edx
80104cd8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104cdc:	83 ec 0c             	sub    $0xc,%esp
80104cdf:	50                   	push   %eax
80104ce0:	e8 b0 c7 ff ff       	call   80101495 <fileclose>
80104ce5:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104ce8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ceb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cee:	83 c2 08             	add    $0x8,%edx
80104cf1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104cf8:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104cf9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104cfd:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104d01:	7e bb                	jle    80104cbe <exit+0x1a8>
    }
  }

  begin_op();
80104d03:	e8 e1 eb ff ff       	call   801038e9 <begin_op>
  iput(curproc->cwd);
80104d08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d0b:	8b 40 68             	mov    0x68(%eax),%eax
80104d0e:	83 ec 0c             	sub    $0xc,%esp
80104d11:	50                   	push   %eax
80104d12:	e8 1b d2 ff ff       	call   80101f32 <iput>
80104d17:	83 c4 10             	add    $0x10,%esp
  end_op();
80104d1a:	e8 56 ec ff ff       	call   80103975 <end_op>
  curproc->cwd = 0;
80104d1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d22:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104d29:	83 ec 0c             	sub    $0xc,%esp
80104d2c:	68 80 39 11 80       	push   $0x80113980
80104d31:	e8 b7 0f 00 00       	call   80105ced <acquire>
80104d36:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104d39:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d3c:	8b 40 14             	mov    0x14(%eax),%eax
80104d3f:	83 ec 0c             	sub    $0xc,%esp
80104d42:	50                   	push   %eax
80104d43:	e8 34 06 00 00       	call   8010537c <wakeup1>
80104d48:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d4b:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104d52:	eb 3a                	jmp    80104d8e <exit+0x278>
    if(p->parent == curproc){
80104d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d57:	8b 40 14             	mov    0x14(%eax),%eax
80104d5a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104d5d:	75 28                	jne    80104d87 <exit+0x271>
      p->parent = initproc;
80104d5f:	8b 15 b4 60 11 80    	mov    0x801160b4,%edx
80104d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d68:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d71:	83 f8 05             	cmp    $0x5,%eax
80104d74:	75 11                	jne    80104d87 <exit+0x271>
        wakeup1(initproc);
80104d76:	a1 b4 60 11 80       	mov    0x801160b4,%eax
80104d7b:	83 ec 0c             	sub    $0xc,%esp
80104d7e:	50                   	push   %eax
80104d7f:	e8 f8 05 00 00       	call   8010537c <wakeup1>
80104d84:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d87:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80104d8e:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
80104d95:	72 bd                	jb     80104d54 <exit+0x23e>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104d97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d9a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104da1:	e8 f6 03 00 00       	call   8010519c <sched>
  panic("zombie exit");
80104da6:	83 ec 0c             	sub    $0xc,%esp
80104da9:	68 5b 96 10 80       	push   $0x8010965b
80104dae:	e8 02 b8 ff ff       	call   801005b5 <panic>

80104db3 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104db3:	55                   	push   %ebp
80104db4:	89 e5                	mov    %esp,%ebp
80104db6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104db9:	e8 92 f8 ff ff       	call   80104650 <myproc>
80104dbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104dc1:	83 ec 0c             	sub    $0xc,%esp
80104dc4:	68 80 39 11 80       	push   $0x80113980
80104dc9:	e8 1f 0f 00 00       	call   80105ced <acquire>
80104dce:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104dd1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dd8:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104ddf:	e9 a4 00 00 00       	jmp    80104e88 <wait+0xd5>
      if(p->parent != curproc)
80104de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de7:	8b 40 14             	mov    0x14(%eax),%eax
80104dea:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104ded:	0f 85 8d 00 00 00    	jne    80104e80 <wait+0xcd>
        continue;
      havekids = 1;
80104df3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfd:	8b 40 0c             	mov    0xc(%eax),%eax
80104e00:	83 f8 05             	cmp    $0x5,%eax
80104e03:	75 7c                	jne    80104e81 <wait+0xce>
        // Found one.
        pid = p->pid;
80104e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e08:	8b 40 10             	mov    0x10(%eax),%eax
80104e0b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e11:	8b 40 08             	mov    0x8(%eax),%eax
80104e14:	83 ec 0c             	sub    $0xc,%esp
80104e17:	50                   	push   %eax
80104e18:	e8 96 e1 ff ff       	call   80102fb3 <kfree>
80104e1d:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e23:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2d:	8b 40 04             	mov    0x4(%eax),%eax
80104e30:	83 ec 0c             	sub    $0xc,%esp
80104e33:	50                   	push   %eax
80104e34:	e8 44 41 00 00       	call   80108f7d <freevm>
80104e39:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e49:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e53:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5a:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e64:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104e6b:	83 ec 0c             	sub    $0xc,%esp
80104e6e:	68 80 39 11 80       	push   $0x80113980
80104e73:	e8 e3 0e 00 00       	call   80105d5b <release>
80104e78:	83 c4 10             	add    $0x10,%esp
        return pid;
80104e7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104e7e:	eb 54                	jmp    80104ed4 <wait+0x121>
        continue;
80104e80:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e81:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80104e88:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
80104e8f:	0f 82 4f ff ff ff    	jb     80104de4 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104e95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e99:	74 0a                	je     80104ea5 <wait+0xf2>
80104e9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e9e:	8b 40 24             	mov    0x24(%eax),%eax
80104ea1:	85 c0                	test   %eax,%eax
80104ea3:	74 17                	je     80104ebc <wait+0x109>
      release(&ptable.lock);
80104ea5:	83 ec 0c             	sub    $0xc,%esp
80104ea8:	68 80 39 11 80       	push   $0x80113980
80104ead:	e8 a9 0e 00 00       	call   80105d5b <release>
80104eb2:	83 c4 10             	add    $0x10,%esp
      return -1;
80104eb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eba:	eb 18                	jmp    80104ed4 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104ebc:	83 ec 08             	sub    $0x8,%esp
80104ebf:	68 80 39 11 80       	push   $0x80113980
80104ec4:	ff 75 ec             	push   -0x14(%ebp)
80104ec7:	e8 09 04 00 00       	call   801052d5 <sleep>
80104ecc:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104ecf:	e9 fd fe ff ff       	jmp    80104dd1 <wait+0x1e>
  }
}
80104ed4:	c9                   	leave  
80104ed5:	c3                   	ret    

80104ed6 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104ed6:	55                   	push   %ebp
80104ed7:	89 e5                	mov    %esp,%ebp
80104ed9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104edc:	e8 f7 f6 ff ff       	call   801045d8 <mycpu>
80104ee1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  c->proc = 0;
80104ee4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ee7:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104eee:	00 00 00 
  

    struct proc *p1;
    for(;;){
    // Enable interrupts on this processor.
    sti();
80104ef1:	e8 a2 f6 ff ff       	call   80104598 <sti>
    struct proc *highp = 0;
80104ef6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    struct proc *lowestdl = NULL;
80104efd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104f04:	83 ec 0c             	sub    $0xc,%esp
80104f07:	68 80 39 11 80       	push   $0x80113980
80104f0c:	e8 dc 0d 00 00       	call   80105ced <acquire>
80104f11:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f14:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104f1b:	eb 2a                	jmp    80104f47 <scheduler+0x71>
    	if(p->state != RUNNABLE)
80104f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f20:	8b 40 0c             	mov    0xc(%eax),%eax
80104f23:	83 f8 03             	cmp    $0x3,%eax
80104f26:	75 17                	jne    80104f3f <scheduler+0x69>
    		continue;
    	
    	p->arrival_elapsed_time++;
80104f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2b:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80104f31:	8d 50 01             	lea    0x1(%eax),%edx
80104f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f37:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
80104f3d:	eb 01                	jmp    80104f40 <scheduler+0x6a>
    		continue;
80104f3f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f40:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80104f47:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
80104f4e:	72 cd                	jb     80104f1d <scheduler+0x47>
    		}
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f50:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104f57:	e9 1e 02 00 00       	jmp    8010517a <scheduler+0x2a4>
      if(p->state != RUNNABLE)
80104f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f5f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f62:	83 f8 03             	cmp    $0x3,%eax
80104f65:	0f 85 07 02 00 00    	jne    80105172 <scheduler+0x29c>
        continue;
      
      if(p->policy==0){  	// EDF scheduling
80104f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6e:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104f74:	85 c0                	test   %eax,%eax
80104f76:	0f 85 c5 00 00 00    	jne    80105041 <scheduler+0x16b>
     
     		lowestdl= p;
80104f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      		for(p1 = ptable.proc; p1 < &ptable.proc[NPROC]; p1++){
80104f82:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
80104f89:	eb 53                	jmp    80104fde <scheduler+0x108>
      		if(p1->state != RUNNABLE)
80104f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f8e:	8b 40 0c             	mov    0xc(%eax),%eax
80104f91:	83 f8 03             	cmp    $0x3,%eax
80104f94:	75 40                	jne    80104fd6 <scheduler+0x100>
        		continue;
        	
        	if (lowestdl->deadline >= p1->deadline){
80104f96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f99:	8b 50 7c             	mov    0x7c(%eax),%edx
80104f9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f9f:	8b 40 7c             	mov    0x7c(%eax),%eax
80104fa2:	39 c2                	cmp    %eax,%edx
80104fa4:	7c 31                	jl     80104fd7 <scheduler+0x101>
        		if(lowestdl->deadline == p1->deadline){
80104fa6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fa9:	8b 50 7c             	mov    0x7c(%eax),%edx
80104fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104faf:	8b 40 7c             	mov    0x7c(%eax),%eax
80104fb2:	39 c2                	cmp    %eax,%edx
80104fb4:	75 18                	jne    80104fce <scheduler+0xf8>
        			if(lowestdl->pid > p1->pid){
80104fb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fb9:	8b 50 10             	mov    0x10(%eax),%edx
80104fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fbf:	8b 40 10             	mov    0x10(%eax),%eax
80104fc2:	39 c2                	cmp    %eax,%edx
80104fc4:	7e 11                	jle    80104fd7 <scheduler+0x101>
        	lowestdl= p1;
80104fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc9:	89 45 e8             	mov    %eax,-0x18(%ebp)
80104fcc:	eb 09                	jmp    80104fd7 <scheduler+0x101>
        	}
        	}
        	else{
        		lowestdl= p1;
80104fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd1:	89 45 e8             	mov    %eax,-0x18(%ebp)
80104fd4:	eb 01                	jmp    80104fd7 <scheduler+0x101>
        		continue;
80104fd6:	90                   	nop
      		for(p1 = ptable.proc; p1 < &ptable.proc[NPROC]; p1++){
80104fd7:	81 45 f0 9c 00 00 00 	addl   $0x9c,-0x10(%ebp)
80104fde:	81 7d f0 b4 60 11 80 	cmpl   $0x801160b4,-0x10(%ebp)
80104fe5:	72 a4                	jb     80104f8b <scheduler+0xb5>
        		}
        		}
        		}
        		
        	p= lowestdl;
80104fe7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fea:	89 45 f4             	mov    %eax,-0xc(%ebp)
        	c->proc =p;
80104fed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ff0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ff3:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        	switchuvm(p);
80104ff9:	83 ec 0c             	sub    $0xc,%esp
80104ffc:	ff 75 f4             	push   -0xc(%ebp)
80104fff:	e8 d4 3a 00 00       	call   80108ad8 <switchuvm>
80105004:	83 c4 10             	add    $0x10,%esp
      		p->state = RUNNING;
80105007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500a:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      		swtch(&(c->scheduler), p->context);
80105011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105014:	8b 40 1c             	mov    0x1c(%eax),%eax
80105017:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010501a:	83 c2 04             	add    $0x4,%edx
8010501d:	83 ec 08             	sub    $0x8,%esp
80105020:	50                   	push   %eax
80105021:	52                   	push   %edx
80105022:	e8 c1 11 00 00       	call   801061e8 <swtch>
80105027:	83 c4 10             	add    $0x10,%esp
      		switchkvm();
8010502a:	e8 90 3a 00 00       	call   80108abf <switchkvm>

      		// Process is done running for now.
      		// It should have changed its p->state before coming back.
      		c->proc = 0;
8010502f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105032:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80105039:	00 00 00 
8010503c:	e9 32 01 00 00       	jmp    80105173 <scheduler+0x29d>
        	}
        	
        	///////////////////////
        	else if(p->policy==1){  	// RMA scheduling
80105041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105044:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010504a:	83 f8 01             	cmp    $0x1,%eax
8010504d:	0f 85 ce 00 00 00    	jne    80105121 <scheduler+0x24b>
     
     		highp = p;
80105053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105056:	89 45 ec             	mov    %eax,-0x14(%ebp)
        	for(p1 = ptable.proc; p1 < &ptable.proc[NPROC]; p1++){
80105059:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
80105060:	eb 5f                	jmp    801050c1 <scheduler+0x1eb>
        		if(p1->state != RUNNABLE)
80105062:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105065:	8b 40 0c             	mov    0xc(%eax),%eax
80105068:	83 f8 03             	cmp    $0x3,%eax
8010506b:	75 4c                	jne    801050b9 <scheduler+0x1e3>
        			continue;
        	
        	if (highp->priority >= p1->priority){
8010506d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105070:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
80105076:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105079:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010507f:	39 c2                	cmp    %eax,%edx
80105081:	7c 37                	jl     801050ba <scheduler+0x1e4>
        		if(highp->priority == p1->priority){
80105083:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105086:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
8010508c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010508f:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105095:	39 c2                	cmp    %eax,%edx
80105097:	75 18                	jne    801050b1 <scheduler+0x1db>
        			if(highp->pid > p1->pid){
80105099:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010509c:	8b 50 10             	mov    0x10(%eax),%edx
8010509f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a2:	8b 40 10             	mov    0x10(%eax),%eax
801050a5:	39 c2                	cmp    %eax,%edx
801050a7:	7e 11                	jle    801050ba <scheduler+0x1e4>
        	highp= p1;
801050a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
801050af:	eb 09                	jmp    801050ba <scheduler+0x1e4>
        	}
        	}
        	else{
        		highp= p1;
801050b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801050b7:	eb 01                	jmp    801050ba <scheduler+0x1e4>
        			continue;
801050b9:	90                   	nop
        	for(p1 = ptable.proc; p1 < &ptable.proc[NPROC]; p1++){
801050ba:	81 45 f0 9c 00 00 00 	addl   $0x9c,-0x10(%ebp)
801050c1:	81 7d f0 b4 60 11 80 	cmpl   $0x801160b4,-0x10(%ebp)
801050c8:	72 98                	jb     80105062 <scheduler+0x18c>
        		}
        		}
        		}
        		
        	p= highp;
801050ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801050cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        	c->proc =p;
801050d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801050d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050d6:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        	switchuvm(p);
801050dc:	83 ec 0c             	sub    $0xc,%esp
801050df:	ff 75 f4             	push   -0xc(%ebp)
801050e2:	e8 f1 39 00 00       	call   80108ad8 <switchuvm>
801050e7:	83 c4 10             	add    $0x10,%esp
      		p->state = RUNNING;
801050ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ed:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      		swtch(&(c->scheduler), p->context);
801050f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f7:	8b 40 1c             	mov    0x1c(%eax),%eax
801050fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801050fd:	83 c2 04             	add    $0x4,%edx
80105100:	83 ec 08             	sub    $0x8,%esp
80105103:	50                   	push   %eax
80105104:	52                   	push   %edx
80105105:	e8 de 10 00 00       	call   801061e8 <swtch>
8010510a:	83 c4 10             	add    $0x10,%esp
      		switchkvm();
8010510d:	e8 ad 39 00 00       	call   80108abf <switchkvm>

      		// Process is done running for now.
      		// It should have changed its p->state before coming back.
      		c->proc = 0;
80105112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105115:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010511c:	00 00 00 
8010511f:	eb 52                	jmp    80105173 <scheduler+0x29d>
        	
        	
        	//////////////////////////
        	
        else{			// Default round robin
        	 c->proc =p;
80105121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105124:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105127:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        
       
   
      switchuvm(p);
8010512d:	83 ec 0c             	sub    $0xc,%esp
80105130:	ff 75 f4             	push   -0xc(%ebp)
80105133:	e8 a0 39 00 00       	call   80108ad8 <switchuvm>
80105138:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010513b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80105145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105148:	8b 40 1c             	mov    0x1c(%eax),%eax
8010514b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010514e:	83 c2 04             	add    $0x4,%edx
80105151:	83 ec 08             	sub    $0x8,%esp
80105154:	50                   	push   %eax
80105155:	52                   	push   %edx
80105156:	e8 8d 10 00 00       	call   801061e8 <swtch>
8010515b:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010515e:	e8 5c 39 00 00       	call   80108abf <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80105163:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105166:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010516d:	00 00 00 
80105170:	eb 01                	jmp    80105173 <scheduler+0x29d>
        continue;
80105172:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105173:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
8010517a:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
80105181:	0f 82 d5 fd ff ff    	jb     80104f5c <scheduler+0x86>
    }
    }
    release(&ptable.lock);
80105187:	83 ec 0c             	sub    $0xc,%esp
8010518a:	68 80 39 11 80       	push   $0x80113980
8010518f:	e8 c7 0b 00 00       	call   80105d5b <release>
80105194:	83 c4 10             	add    $0x10,%esp
    for(;;){
80105197:	e9 55 fd ff ff       	jmp    80104ef1 <scheduler+0x1b>

8010519c <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010519c:	55                   	push   %ebp
8010519d:	89 e5                	mov    %esp,%ebp
8010519f:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801051a2:	e8 a9 f4 ff ff       	call   80104650 <myproc>
801051a7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801051aa:	83 ec 0c             	sub    $0xc,%esp
801051ad:	68 80 39 11 80       	push   $0x80113980
801051b2:	e8 71 0c 00 00       	call   80105e28 <holding>
801051b7:	83 c4 10             	add    $0x10,%esp
801051ba:	85 c0                	test   %eax,%eax
801051bc:	75 0d                	jne    801051cb <sched+0x2f>
    panic("sched ptable.lock");
801051be:	83 ec 0c             	sub    $0xc,%esp
801051c1:	68 67 96 10 80       	push   $0x80109667
801051c6:	e8 ea b3 ff ff       	call   801005b5 <panic>
  if(mycpu()->ncli != 1)
801051cb:	e8 08 f4 ff ff       	call   801045d8 <mycpu>
801051d0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051d6:	83 f8 01             	cmp    $0x1,%eax
801051d9:	74 0d                	je     801051e8 <sched+0x4c>
    panic("sched locks");
801051db:	83 ec 0c             	sub    $0xc,%esp
801051de:	68 79 96 10 80       	push   $0x80109679
801051e3:	e8 cd b3 ff ff       	call   801005b5 <panic>
  if(p->state == RUNNING)
801051e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051eb:	8b 40 0c             	mov    0xc(%eax),%eax
801051ee:	83 f8 04             	cmp    $0x4,%eax
801051f1:	75 0d                	jne    80105200 <sched+0x64>
    panic("sched running");
801051f3:	83 ec 0c             	sub    $0xc,%esp
801051f6:	68 85 96 10 80       	push   $0x80109685
801051fb:	e8 b5 b3 ff ff       	call   801005b5 <panic>
  if(readeflags()&FL_IF)
80105200:	e8 83 f3 ff ff       	call   80104588 <readeflags>
80105205:	25 00 02 00 00       	and    $0x200,%eax
8010520a:	85 c0                	test   %eax,%eax
8010520c:	74 0d                	je     8010521b <sched+0x7f>
    panic("sched interruptible");
8010520e:	83 ec 0c             	sub    $0xc,%esp
80105211:	68 93 96 10 80       	push   $0x80109693
80105216:	e8 9a b3 ff ff       	call   801005b5 <panic>
  intena = mycpu()->intena;
8010521b:	e8 b8 f3 ff ff       	call   801045d8 <mycpu>
80105220:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105226:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80105229:	e8 aa f3 ff ff       	call   801045d8 <mycpu>
8010522e:	8b 40 04             	mov    0x4(%eax),%eax
80105231:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105234:	83 c2 1c             	add    $0x1c,%edx
80105237:	83 ec 08             	sub    $0x8,%esp
8010523a:	50                   	push   %eax
8010523b:	52                   	push   %edx
8010523c:	e8 a7 0f 00 00       	call   801061e8 <swtch>
80105241:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80105244:	e8 8f f3 ff ff       	call   801045d8 <mycpu>
80105249:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010524c:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80105252:	90                   	nop
80105253:	c9                   	leave  
80105254:	c3                   	ret    

80105255 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105255:	55                   	push   %ebp
80105256:	89 e5                	mov    %esp,%ebp
80105258:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010525b:	83 ec 0c             	sub    $0xc,%esp
8010525e:	68 80 39 11 80       	push   $0x80113980
80105263:	e8 85 0a 00 00       	call   80105ced <acquire>
80105268:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010526b:	e8 e0 f3 ff ff       	call   80104650 <myproc>
80105270:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105277:	e8 20 ff ff ff       	call   8010519c <sched>
  release(&ptable.lock);
8010527c:	83 ec 0c             	sub    $0xc,%esp
8010527f:	68 80 39 11 80       	push   $0x80113980
80105284:	e8 d2 0a 00 00       	call   80105d5b <release>
80105289:	83 c4 10             	add    $0x10,%esp
}
8010528c:	90                   	nop
8010528d:	c9                   	leave  
8010528e:	c3                   	ret    

8010528f <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010528f:	55                   	push   %ebp
80105290:	89 e5                	mov    %esp,%ebp
80105292:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105295:	83 ec 0c             	sub    $0xc,%esp
80105298:	68 80 39 11 80       	push   $0x80113980
8010529d:	e8 b9 0a 00 00       	call   80105d5b <release>
801052a2:	83 c4 10             	add    $0x10,%esp

  if (first) {
801052a5:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801052aa:	85 c0                	test   %eax,%eax
801052ac:	74 24                	je     801052d2 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801052ae:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
801052b5:	00 00 00 
    iinit(ROOTDEV);
801052b8:	83 ec 0c             	sub    $0xc,%esp
801052bb:	6a 01                	push   $0x1
801052bd:	e8 9d c7 ff ff       	call   80101a5f <iinit>
801052c2:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801052c5:	83 ec 0c             	sub    $0xc,%esp
801052c8:	6a 01                	push   $0x1
801052ca:	e8 fb e3 ff ff       	call   801036ca <initlog>
801052cf:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801052d2:	90                   	nop
801052d3:	c9                   	leave  
801052d4:	c3                   	ret    

801052d5 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801052d5:	55                   	push   %ebp
801052d6:	89 e5                	mov    %esp,%ebp
801052d8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801052db:	e8 70 f3 ff ff       	call   80104650 <myproc>
801052e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801052e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052e7:	75 0d                	jne    801052f6 <sleep+0x21>
    panic("sleep");
801052e9:	83 ec 0c             	sub    $0xc,%esp
801052ec:	68 a7 96 10 80       	push   $0x801096a7
801052f1:	e8 bf b2 ff ff       	call   801005b5 <panic>

  if(lk == 0)
801052f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801052fa:	75 0d                	jne    80105309 <sleep+0x34>
    panic("sleep without lk");
801052fc:	83 ec 0c             	sub    $0xc,%esp
801052ff:	68 ad 96 10 80       	push   $0x801096ad
80105304:	e8 ac b2 ff ff       	call   801005b5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80105309:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105310:	74 1e                	je     80105330 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105312:	83 ec 0c             	sub    $0xc,%esp
80105315:	68 80 39 11 80       	push   $0x80113980
8010531a:	e8 ce 09 00 00       	call   80105ced <acquire>
8010531f:	83 c4 10             	add    $0x10,%esp
    release(lk);
80105322:	83 ec 0c             	sub    $0xc,%esp
80105325:	ff 75 0c             	push   0xc(%ebp)
80105328:	e8 2e 0a 00 00       	call   80105d5b <release>
8010532d:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80105330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105333:	8b 55 08             	mov    0x8(%ebp),%edx
80105336:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80105339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533c:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80105343:	e8 54 fe ff ff       	call   8010519c <sched>

  // Tidy up.
  p->chan = 0;
80105348:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010534b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105352:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105359:	74 1e                	je     80105379 <sleep+0xa4>
    release(&ptable.lock);
8010535b:	83 ec 0c             	sub    $0xc,%esp
8010535e:	68 80 39 11 80       	push   $0x80113980
80105363:	e8 f3 09 00 00       	call   80105d5b <release>
80105368:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010536b:	83 ec 0c             	sub    $0xc,%esp
8010536e:	ff 75 0c             	push   0xc(%ebp)
80105371:	e8 77 09 00 00       	call   80105ced <acquire>
80105376:	83 c4 10             	add    $0x10,%esp
  }
}
80105379:	90                   	nop
8010537a:	c9                   	leave  
8010537b:	c3                   	ret    

8010537c <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010537c:	55                   	push   %ebp
8010537d:	89 e5                	mov    %esp,%ebp
8010537f:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105382:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
80105389:	eb 27                	jmp    801053b2 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
8010538b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010538e:	8b 40 0c             	mov    0xc(%eax),%eax
80105391:	83 f8 02             	cmp    $0x2,%eax
80105394:	75 15                	jne    801053ab <wakeup1+0x2f>
80105396:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105399:	8b 40 20             	mov    0x20(%eax),%eax
8010539c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010539f:	75 0a                	jne    801053ab <wakeup1+0x2f>
      p->state = RUNNABLE;
801053a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053a4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801053ab:	81 45 fc 9c 00 00 00 	addl   $0x9c,-0x4(%ebp)
801053b2:	81 7d fc b4 60 11 80 	cmpl   $0x801160b4,-0x4(%ebp)
801053b9:	72 d0                	jb     8010538b <wakeup1+0xf>
}
801053bb:	90                   	nop
801053bc:	90                   	nop
801053bd:	c9                   	leave  
801053be:	c3                   	ret    

801053bf <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801053bf:	55                   	push   %ebp
801053c0:	89 e5                	mov    %esp,%ebp
801053c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801053c5:	83 ec 0c             	sub    $0xc,%esp
801053c8:	68 80 39 11 80       	push   $0x80113980
801053cd:	e8 1b 09 00 00       	call   80105ced <acquire>
801053d2:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801053d5:	83 ec 0c             	sub    $0xc,%esp
801053d8:	ff 75 08             	push   0x8(%ebp)
801053db:	e8 9c ff ff ff       	call   8010537c <wakeup1>
801053e0:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801053e3:	83 ec 0c             	sub    $0xc,%esp
801053e6:	68 80 39 11 80       	push   $0x80113980
801053eb:	e8 6b 09 00 00       	call   80105d5b <release>
801053f0:	83 c4 10             	add    $0x10,%esp
}
801053f3:	90                   	nop
801053f4:	c9                   	leave  
801053f5:	c3                   	ret    

801053f6 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801053f6:	55                   	push   %ebp
801053f7:	89 e5                	mov    %esp,%ebp
801053f9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801053fc:	83 ec 0c             	sub    $0xc,%esp
801053ff:	68 80 39 11 80       	push   $0x80113980
80105404:	e8 e4 08 00 00       	call   80105ced <acquire>
80105409:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010540c:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105413:	eb 48                	jmp    8010545d <kill+0x67>
    if(p->pid == pid){
80105415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105418:	8b 40 10             	mov    0x10(%eax),%eax
8010541b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010541e:	75 36                	jne    80105456 <kill+0x60>
      p->killed = 1;
80105420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105423:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010542a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010542d:	8b 40 0c             	mov    0xc(%eax),%eax
80105430:	83 f8 02             	cmp    $0x2,%eax
80105433:	75 0a                	jne    8010543f <kill+0x49>
        p->state = RUNNABLE;
80105435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105438:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010543f:	83 ec 0c             	sub    $0xc,%esp
80105442:	68 80 39 11 80       	push   $0x80113980
80105447:	e8 0f 09 00 00       	call   80105d5b <release>
8010544c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010544f:	b8 00 00 00 00       	mov    $0x0,%eax
80105454:	eb 25                	jmp    8010547b <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105456:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
8010545d:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
80105464:	72 af                	jb     80105415 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80105466:	83 ec 0c             	sub    $0xc,%esp
80105469:	68 80 39 11 80       	push   $0x80113980
8010546e:	e8 e8 08 00 00       	call   80105d5b <release>
80105473:	83 c4 10             	add    $0x10,%esp
  return -1;
80105476:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010547b:	c9                   	leave  
8010547c:	c3                   	ret    

8010547d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010547d:	55                   	push   %ebp
8010547e:	89 e5                	mov    %esp,%ebp
80105480:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105483:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
8010548a:	e9 da 00 00 00       	jmp    80105569 <procdump+0xec>
    if(p->state == UNUSED)
8010548f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105492:	8b 40 0c             	mov    0xc(%eax),%eax
80105495:	85 c0                	test   %eax,%eax
80105497:	0f 84 c4 00 00 00    	je     80105561 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010549d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054a0:	8b 40 0c             	mov    0xc(%eax),%eax
801054a3:	83 f8 05             	cmp    $0x5,%eax
801054a6:	77 23                	ja     801054cb <procdump+0x4e>
801054a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ab:	8b 40 0c             	mov    0xc(%eax),%eax
801054ae:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801054b5:	85 c0                	test   %eax,%eax
801054b7:	74 12                	je     801054cb <procdump+0x4e>
      state = states[p->state];
801054b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054bc:	8b 40 0c             	mov    0xc(%eax),%eax
801054bf:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801054c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801054c9:	eb 07                	jmp    801054d2 <procdump+0x55>
    else
      state = "???";
801054cb:	c7 45 ec be 96 10 80 	movl   $0x801096be,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801054d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054d5:	8d 50 6c             	lea    0x6c(%eax),%edx
801054d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054db:	8b 40 10             	mov    0x10(%eax),%eax
801054de:	52                   	push   %edx
801054df:	ff 75 ec             	push   -0x14(%ebp)
801054e2:	50                   	push   %eax
801054e3:	68 c2 96 10 80       	push   $0x801096c2
801054e8:	e8 13 af ff ff       	call   80100400 <cprintf>
801054ed:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801054f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f3:	8b 40 0c             	mov    0xc(%eax),%eax
801054f6:	83 f8 02             	cmp    $0x2,%eax
801054f9:	75 54                	jne    8010554f <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801054fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054fe:	8b 40 1c             	mov    0x1c(%eax),%eax
80105501:	8b 40 0c             	mov    0xc(%eax),%eax
80105504:	83 c0 08             	add    $0x8,%eax
80105507:	89 c2                	mov    %eax,%edx
80105509:	83 ec 08             	sub    $0x8,%esp
8010550c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010550f:	50                   	push   %eax
80105510:	52                   	push   %edx
80105511:	e8 97 08 00 00       	call   80105dad <getcallerpcs>
80105516:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105519:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105520:	eb 1c                	jmp    8010553e <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105525:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105529:	83 ec 08             	sub    $0x8,%esp
8010552c:	50                   	push   %eax
8010552d:	68 cb 96 10 80       	push   $0x801096cb
80105532:	e8 c9 ae ff ff       	call   80100400 <cprintf>
80105537:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010553a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010553e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105542:	7f 0b                	jg     8010554f <procdump+0xd2>
80105544:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105547:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010554b:	85 c0                	test   %eax,%eax
8010554d:	75 d3                	jne    80105522 <procdump+0xa5>
    }
    cprintf("\n");
8010554f:	83 ec 0c             	sub    $0xc,%esp
80105552:	68 cf 96 10 80       	push   $0x801096cf
80105557:	e8 a4 ae ff ff       	call   80100400 <cprintf>
8010555c:	83 c4 10             	add    $0x10,%esp
8010555f:	eb 01                	jmp    80105562 <procdump+0xe5>
      continue;
80105561:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105562:	81 45 f0 9c 00 00 00 	addl   $0x9c,-0x10(%ebp)
80105569:	81 7d f0 b4 60 11 80 	cmpl   $0x801160b4,-0x10(%ebp)
80105570:	0f 82 19 ff ff ff    	jb     8010548f <procdump+0x12>
  }
}
80105576:	90                   	nop
80105577:	90                   	nop
80105578:	c9                   	leave  
80105579:	c3                   	ret    

8010557a <process_status>:


void
process_status(void)
{
8010557a:	55                   	push   %ebp
8010557b:	89 e5                	mov    %esp,%ebp
8010557d:	56                   	push   %esi
8010557e:	53                   	push   %ebx
8010557f:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105582:	83 ec 0c             	sub    $0xc,%esp
80105585:	68 80 39 11 80       	push   $0x80113980
8010558a:	e8 5e 07 00 00       	call   80105ced <acquire>
8010558f:	83 c4 10             	add    $0x10,%esp
  cprintf("Name \tpid \tstate \t deadline \t execution Time \t sched_policy\n");
80105592:	83 ec 0c             	sub    $0xc,%esp
80105595:	68 d4 96 10 80       	push   $0x801096d4
8010559a:	e8 61 ae ff ff       	call   80100400 <cprintf>
8010559f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055a2:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801055a9:	e9 da 00 00 00       	jmp    80105688 <process_status+0x10e>
    if (p->state == SLEEPING) 
801055ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b1:	8b 40 0c             	mov    0xc(%eax),%eax
801055b4:	83 f8 02             	cmp    $0x2,%eax
801055b7:	75 3e                	jne    801055f7 <process_status+0x7d>
      cprintf("%s \t %d \t SLEEPING \t %d \t %d \t\t %d\n", p->name, p->pid,p->deadline,p->exec_time,p->policy);
801055b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bc:	8b 98 8c 00 00 00    	mov    0x8c(%eax),%ebx
801055c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c5:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
801055cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ce:	8b 50 7c             	mov    0x7c(%eax),%edx
801055d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d4:	8b 40 10             	mov    0x10(%eax),%eax
801055d7:	8b 75 f4             	mov    -0xc(%ebp),%esi
801055da:	83 c6 6c             	add    $0x6c,%esi
801055dd:	83 ec 08             	sub    $0x8,%esp
801055e0:	53                   	push   %ebx
801055e1:	51                   	push   %ecx
801055e2:	52                   	push   %edx
801055e3:	50                   	push   %eax
801055e4:	56                   	push   %esi
801055e5:	68 14 97 10 80       	push   $0x80109714
801055ea:	e8 11 ae ff ff       	call   80100400 <cprintf>
801055ef:	83 c4 20             	add    $0x20,%esp
801055f2:	e9 8a 00 00 00       	jmp    80105681 <process_status+0x107>
      
    else if (p->state == RUNNING) 
801055f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fa:	8b 40 0c             	mov    0xc(%eax),%eax
801055fd:	83 f8 04             	cmp    $0x4,%eax
80105600:	75 3b                	jne    8010563d <process_status+0xc3>
      cprintf("%s \t %d \t RUNNING \t %d \t %d \t\t %d\n", p->name, p->pid,p->deadline,p->exec_time,p->policy);
80105602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105605:	8b 98 8c 00 00 00    	mov    0x8c(%eax),%ebx
8010560b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560e:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
80105614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105617:	8b 50 7c             	mov    0x7c(%eax),%edx
8010561a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561d:	8b 40 10             	mov    0x10(%eax),%eax
80105620:	8b 75 f4             	mov    -0xc(%ebp),%esi
80105623:	83 c6 6c             	add    $0x6c,%esi
80105626:	83 ec 08             	sub    $0x8,%esp
80105629:	53                   	push   %ebx
8010562a:	51                   	push   %ecx
8010562b:	52                   	push   %edx
8010562c:	50                   	push   %eax
8010562d:	56                   	push   %esi
8010562e:	68 38 97 10 80       	push   $0x80109738
80105633:	e8 c8 ad ff ff       	call   80100400 <cprintf>
80105638:	83 c4 20             	add    $0x20,%esp
8010563b:	eb 44                	jmp    80105681 <process_status+0x107>
      
    else if (p->state == RUNNABLE) 
8010563d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105640:	8b 40 0c             	mov    0xc(%eax),%eax
80105643:	83 f8 03             	cmp    $0x3,%eax
80105646:	75 39                	jne    80105681 <process_status+0x107>
      cprintf("%s \t %d \t RUNNABLE \t %d \t %d \t\t %d\n", p->name, p->pid,p->deadline,p->exec_time,p->policy);
80105648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564b:	8b 98 8c 00 00 00    	mov    0x8c(%eax),%ebx
80105651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105654:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
8010565a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565d:	8b 50 7c             	mov    0x7c(%eax),%edx
80105660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105663:	8b 40 10             	mov    0x10(%eax),%eax
80105666:	8b 75 f4             	mov    -0xc(%ebp),%esi
80105669:	83 c6 6c             	add    $0x6c,%esi
8010566c:	83 ec 08             	sub    $0x8,%esp
8010566f:	53                   	push   %ebx
80105670:	51                   	push   %ecx
80105671:	52                   	push   %edx
80105672:	50                   	push   %eax
80105673:	56                   	push   %esi
80105674:	68 5c 97 10 80       	push   $0x8010975c
80105679:	e8 82 ad ff ff       	call   80100400 <cprintf>
8010567e:	83 c4 20             	add    $0x20,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105681:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80105688:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
8010568f:	0f 82 19 ff ff ff    	jb     801055ae <process_status+0x34>
    }
  
  release(&ptable.lock);
80105695:	83 ec 0c             	sub    $0xc,%esp
80105698:	68 80 39 11 80       	push   $0x80113980
8010569d:	e8 b9 06 00 00       	call   80105d5b <release>
801056a2:	83 c4 10             	add    $0x10,%esp
}
801056a5:	90                   	nop
801056a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801056a9:	5b                   	pop    %ebx
801056aa:	5e                   	pop    %esi
801056ab:	5d                   	pop    %ebp
801056ac:	c3                   	ret    

801056ad <change_exec_time>:


int 
change_exec_time( int pid, int exec_time)
{
801056ad:	55                   	push   %ebp
801056ae:	89 e5                	mov    %esp,%ebp
801056b0:	83 ec 18             	sub    $0x18,%esp
	struct proc *p;
	
	acquire(&ptable.lock);
801056b3:	83 ec 0c             	sub    $0xc,%esp
801056b6:	68 80 39 11 80       	push   $0x80113980
801056bb:	e8 2d 06 00 00       	call   80105ced <acquire>
801056c0:	83 c4 10             	add    $0x10,%esp
	for(p=ptable.proc; p<&ptable.proc[NPROC];p++){
801056c3:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801056ca:	eb 20                	jmp    801056ec <change_exec_time+0x3f>
	  if(p-> pid ==  pid){
801056cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056cf:	8b 40 10             	mov    0x10(%eax),%eax
801056d2:	39 45 08             	cmp    %eax,0x8(%ebp)
801056d5:	75 0e                	jne    801056e5 <change_exec_time+0x38>
	  	p-> exec_time= exec_time;
801056d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056da:	8b 55 0c             	mov    0xc(%ebp),%edx
801056dd:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
	  	break;
801056e3:	eb 10                	jmp    801056f5 <change_exec_time+0x48>
	for(p=ptable.proc; p<&ptable.proc[NPROC];p++){
801056e5:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
801056ec:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
801056f3:	72 d7                	jb     801056cc <change_exec_time+0x1f>
	  }
	}
	release(&ptable.lock);
801056f5:	83 ec 0c             	sub    $0xc,%esp
801056f8:	68 80 39 11 80       	push   $0x80113980
801056fd:	e8 59 06 00 00       	call   80105d5b <release>
80105702:	83 c4 10             	add    $0x10,%esp
	
	return 0;
80105705:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010570a:	c9                   	leave  
8010570b:	c3                   	ret    

8010570c <change_deadline>:
	
	
	
int 
change_deadline( int pid, int deadline)
{
8010570c:	55                   	push   %ebp
8010570d:	89 e5                	mov    %esp,%ebp
8010570f:	83 ec 18             	sub    $0x18,%esp
	struct proc *p;
	
	acquire(&ptable.lock);
80105712:	83 ec 0c             	sub    $0xc,%esp
80105715:	68 80 39 11 80       	push   $0x80113980
8010571a:	e8 ce 05 00 00       	call   80105ced <acquire>
8010571f:	83 c4 10             	add    $0x10,%esp
	for(p=ptable.proc; p<&ptable.proc[NPROC];p++){
80105722:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105729:	eb 1d                	jmp    80105748 <change_deadline+0x3c>
	  if(p-> pid ==  pid){
8010572b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010572e:	8b 40 10             	mov    0x10(%eax),%eax
80105731:	39 45 08             	cmp    %eax,0x8(%ebp)
80105734:	75 0b                	jne    80105741 <change_deadline+0x35>
	  	p-> deadline= deadline;
80105736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105739:	8b 55 0c             	mov    0xc(%ebp),%edx
8010573c:	89 50 7c             	mov    %edx,0x7c(%eax)
	  	break;
8010573f:	eb 10                	jmp    80105751 <change_deadline+0x45>
	for(p=ptable.proc; p<&ptable.proc[NPROC];p++){
80105741:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80105748:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
8010574f:	72 da                	jb     8010572b <change_deadline+0x1f>
	  }
	}
	release(&ptable.lock);
80105751:	83 ec 0c             	sub    $0xc,%esp
80105754:	68 80 39 11 80       	push   $0x80113980
80105759:	e8 fd 05 00 00       	call   80105d5b <release>
8010575e:	83 c4 10             	add    $0x10,%esp
	
	return 0;
80105761:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105766:	c9                   	leave  
80105767:	c3                   	ret    

80105768 <change_sched_policy>:
	
int 
change_sched_policy( int pid, int policy)
{	
80105768:	55                   	push   %ebp
80105769:	89 e5                	mov    %esp,%ebp
8010576b:	83 ec 28             	sub    $0x28,%esp
	struct proc *p;
	if(policy==0){
8010576e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105772:	0f 85 fa 00 00 00    	jne    80105872 <change_sched_policy+0x10a>
	
	int fraction=0;
80105778:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int test=0;
8010577f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	acquire(&ptable.lock);
80105786:	83 ec 0c             	sub    $0xc,%esp
80105789:	68 80 39 11 80       	push   $0x80113980
8010578e:	e8 5a 05 00 00       	call   80105ced <acquire>
80105793:	83 c4 10             	add    $0x10,%esp
	for(p=ptable.proc; p<&ptable.proc[NPROC];p++){
80105796:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010579d:	e9 a9 00 00 00       	jmp    8010584b <change_sched_policy+0xe3>
	  if(p-> pid ==  pid){
801057a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a5:	8b 40 10             	mov    0x10(%eax),%eax
801057a8:	39 45 08             	cmp    %eax,0x8(%ebp)
801057ab:	0f 85 93 00 00 00    	jne    80105844 <change_sched_policy+0xdc>
	   
	  	fraction= 10/((p->deadline)/(p->exec_time));
801057b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b4:	8b 40 7c             	mov    0x7c(%eax),%eax
801057b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057ba:	8b 8a 80 00 00 00    	mov    0x80(%edx),%ecx
801057c0:	99                   	cltd   
801057c1:	f7 f9                	idiv   %ecx
801057c3:	89 c1                	mov    %eax,%ecx
801057c5:	b8 0a 00 00 00       	mov    $0xa,%eax
801057ca:	99                   	cltd   
801057cb:	f7 f9                	idiv   %ecx
801057cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	  	test= U+fraction;
801057d0:	8b 15 60 39 11 80    	mov    0x80113960,%edx
801057d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057d9:	01 d0                	add    %edx,%eax
801057db:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  	if(test<=10){
801057de:	83 7d e0 0a          	cmpl   $0xa,-0x20(%ebp)
801057e2:	7f 2e                	jg     80105812 <change_sched_policy+0xaa>
	  		U = U+ fraction;
801057e4:	8b 15 60 39 11 80    	mov    0x80113960,%edx
801057ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057ed:	01 d0                	add    %edx,%eax
801057ef:	a3 60 39 11 80       	mov    %eax,0x80113960
	  		//cprintf("U : %lf ", U);
	  		p-> policy= policy;
801057f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801057fa:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
	  		p-> arrival_time=ticks;
80105800:	a1 f4 68 11 80       	mov    0x801168f4,%eax
80105805:	89 c2                	mov    %eax,%edx
80105807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010580a:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
	  		break;
80105810:	eb 46                	jmp    80105858 <change_sched_policy+0xf0>
	  	}
	  	else{
	  		release(&ptable.lock);
80105812:	83 ec 0c             	sub    $0xc,%esp
80105815:	68 80 39 11 80       	push   $0x80113980
8010581a:	e8 3c 05 00 00       	call   80105d5b <release>
8010581f:	83 c4 10             	add    $0x10,%esp
			kill(p->pid);
80105822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105825:	8b 40 10             	mov    0x10(%eax),%eax
80105828:	83 ec 0c             	sub    $0xc,%esp
8010582b:	50                   	push   %eax
8010582c:	e8 c5 fb ff ff       	call   801053f6 <kill>
80105831:	83 c4 10             	add    $0x10,%esp
			acquire(&ptable.lock);
80105834:	83 ec 0c             	sub    $0xc,%esp
80105837:	68 80 39 11 80       	push   $0x80113980
8010583c:	e8 ac 04 00 00       	call   80105ced <acquire>
80105841:	83 c4 10             	add    $0x10,%esp
	for(p=ptable.proc; p<&ptable.proc[NPROC];p++){
80105844:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
8010584b:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
80105852:	0f 82 4a ff ff ff    	jb     801057a2 <change_sched_policy+0x3a>
	  		}
	  }
	}
	release(&ptable.lock);
80105858:	83 ec 0c             	sub    $0xc,%esp
8010585b:	68 80 39 11 80       	push   $0x80113980
80105860:	e8 f6 04 00 00       	call   80105d5b <release>
80105865:	83 c4 10             	add    $0x10,%esp
	
	return 0;
80105868:	b8 00 00 00 00       	mov    $0x0,%eax
8010586d:	e9 03 02 00 00       	jmp    80105a75 <change_sched_policy+0x30d>
	}
	else if(policy==1){
80105872:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
80105876:	0f 85 f4 01 00 00    	jne    80105a70 <change_sched_policy+0x308>
	
  	int n = 1;
8010587c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105883:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010588a:	eb 19                	jmp    801058a5 <change_sched_policy+0x13d>
  		if(p->policy == 1)
8010588c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105895:	83 f8 01             	cmp    $0x1,%eax
80105898:	75 04                	jne    8010589e <change_sched_policy+0x136>
    			n++;
8010589a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010589e:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
801058a5:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
801058ac:	72 de                	jb     8010588c <change_sched_policy+0x124>
    	}	
	int u,test;
	if(n==1) test = 1000;
801058ae:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
801058b2:	75 0c                	jne    801058c0 <change_sched_policy+0x158>
801058b4:	c7 45 ec e8 03 00 00 	movl   $0x3e8,-0x14(%ebp)
801058bb:	e9 8e 00 00 00       	jmp    8010594e <change_sched_policy+0x1e6>
	else if(n==2) test = 828;
801058c0:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
801058c4:	75 09                	jne    801058cf <change_sched_policy+0x167>
801058c6:	c7 45 ec 3c 03 00 00 	movl   $0x33c,-0x14(%ebp)
801058cd:	eb 7f                	jmp    8010594e <change_sched_policy+0x1e6>
	else if(n==3) test = 779;
801058cf:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
801058d3:	75 09                	jne    801058de <change_sched_policy+0x176>
801058d5:	c7 45 ec 0b 03 00 00 	movl   $0x30b,-0x14(%ebp)
801058dc:	eb 70                	jmp    8010594e <change_sched_policy+0x1e6>
	else if(n==4) test = 757;
801058de:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801058e2:	75 09                	jne    801058ed <change_sched_policy+0x185>
801058e4:	c7 45 ec f5 02 00 00 	movl   $0x2f5,-0x14(%ebp)
801058eb:	eb 61                	jmp    8010594e <change_sched_policy+0x1e6>
	else if(n==5) test = 744;
801058ed:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
801058f1:	75 09                	jne    801058fc <change_sched_policy+0x194>
801058f3:	c7 45 ec e8 02 00 00 	movl   $0x2e8,-0x14(%ebp)
801058fa:	eb 52                	jmp    8010594e <change_sched_policy+0x1e6>
	else if(n==6) test = 735;
801058fc:	83 7d f0 06          	cmpl   $0x6,-0x10(%ebp)
80105900:	75 09                	jne    8010590b <change_sched_policy+0x1a3>
80105902:	c7 45 ec df 02 00 00 	movl   $0x2df,-0x14(%ebp)
80105909:	eb 43                	jmp    8010594e <change_sched_policy+0x1e6>
	else if(n==7) test = 728;
8010590b:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
8010590f:	75 09                	jne    8010591a <change_sched_policy+0x1b2>
80105911:	c7 45 ec d8 02 00 00 	movl   $0x2d8,-0x14(%ebp)
80105918:	eb 34                	jmp    8010594e <change_sched_policy+0x1e6>
	else if(n==8) test = 724;
8010591a:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
8010591e:	75 09                	jne    80105929 <change_sched_policy+0x1c1>
80105920:	c7 45 ec d4 02 00 00 	movl   $0x2d4,-0x14(%ebp)
80105927:	eb 25                	jmp    8010594e <change_sched_policy+0x1e6>
	else if(n==9) test = 721;
80105929:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
8010592d:	75 09                	jne    80105938 <change_sched_policy+0x1d0>
8010592f:	c7 45 ec d1 02 00 00 	movl   $0x2d1,-0x14(%ebp)
80105936:	eb 16                	jmp    8010594e <change_sched_policy+0x1e6>
	else if(n==10) test = 717;
80105938:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010593c:	75 09                	jne    80105947 <change_sched_policy+0x1df>
8010593e:	c7 45 ec cd 02 00 00 	movl   $0x2cd,-0x14(%ebp)
80105945:	eb 07                	jmp    8010594e <change_sched_policy+0x1e6>
	else test = 690;
80105947:	c7 45 ec b2 02 00 00 	movl   $0x2b2,-0x14(%ebp)
	
  	acquire(&ptable.lock);
8010594e:	83 ec 0c             	sub    $0xc,%esp
80105951:	68 80 39 11 80       	push   $0x80113980
80105956:	e8 92 03 00 00       	call   80105ced <acquire>
8010595b:	83 c4 10             	add    $0x10,%esp
  	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010595e:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105965:	e9 e2 00 00 00       	jmp    80105a4c <change_sched_policy+0x2e4>
    		if(p->pid == pid){
8010596a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596d:	8b 40 10             	mov    0x10(%eax),%eax
80105970:	39 45 08             	cmp    %eax,0x8(%ebp)
80105973:	0f 85 cc 00 00 00    	jne    80105a45 <change_sched_policy+0x2dd>
    			u = (10 * p->exec_time * p->rate);
80105979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597c:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105985:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
8010598b:	0f af d0             	imul   %eax,%edx
8010598e:	89 d0                	mov    %edx,%eax
80105990:	c1 e0 02             	shl    $0x2,%eax
80105993:	01 d0                	add    %edx,%eax
80105995:	01 c0                	add    %eax,%eax
80105997:	89 45 e8             	mov    %eax,-0x18(%ebp)
    			U = U + u;
8010599a:	8b 15 60 39 11 80    	mov    0x80113960,%edx
801059a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801059a3:	01 d0                	add    %edx,%eax
801059a5:	a3 60 39 11 80       	mov    %eax,0x80113960
    			
    			if(U>test){
801059aa:	a1 60 39 11 80       	mov    0x80113960,%eax
801059af:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801059b2:	7d 4d                	jge    80105a01 <change_sched_policy+0x299>
      				cprintf("Task with PID %d can not Added\n",p->pid);
801059b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b7:	8b 40 10             	mov    0x10(%eax),%eax
801059ba:	83 ec 08             	sub    $0x8,%esp
801059bd:	50                   	push   %eax
801059be:	68 80 97 10 80       	push   $0x80109780
801059c3:	e8 38 aa ff ff       	call   80100400 <cprintf>
801059c8:	83 c4 10             	add    $0x10,%esp
      				release(&ptable.lock);
801059cb:	83 ec 0c             	sub    $0xc,%esp
801059ce:	68 80 39 11 80       	push   $0x80113980
801059d3:	e8 83 03 00 00       	call   80105d5b <release>
801059d8:	83 c4 10             	add    $0x10,%esp
      				kill(p->pid);
801059db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059de:	8b 40 10             	mov    0x10(%eax),%eax
801059e1:	83 ec 0c             	sub    $0xc,%esp
801059e4:	50                   	push   %eax
801059e5:	e8 0c fa ff ff       	call   801053f6 <kill>
801059ea:	83 c4 10             	add    $0x10,%esp
      				U = U - u;
801059ed:	a1 60 39 11 80       	mov    0x80113960,%eax
801059f2:	2b 45 e8             	sub    -0x18(%ebp),%eax
801059f5:	a3 60 39 11 80       	mov    %eax,0x80113960
      				return -22;
801059fa:	b8 ea ff ff ff       	mov    $0xffffffea,%eax
801059ff:	eb 74                	jmp    80105a75 <change_sched_policy+0x30d>
      			}
      
      			p->policy = policy;
80105a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a04:	8b 55 0c             	mov    0xc(%ebp),%edx
80105a07:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      			p->arrival_time = ticks;
80105a0d:	a1 f4 68 11 80       	mov    0x801168f4,%eax
80105a12:	89 c2                	mov    %eax,%edx
80105a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a17:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
      			myproc()->state = RUNNABLE;
80105a1d:	e8 2e ec ff ff       	call   80104650 <myproc>
80105a22:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      			sched();					//added
80105a29:	e8 6e f7 ff ff       	call   8010519c <sched>
      			release(&ptable.lock);
80105a2e:	83 ec 0c             	sub    $0xc,%esp
80105a31:	68 80 39 11 80       	push   $0x80113980
80105a36:	e8 20 03 00 00       	call   80105d5b <release>
80105a3b:	83 c4 10             	add    $0x10,%esp
      			return 0;
80105a3e:	b8 00 00 00 00       	mov    $0x0,%eax
80105a43:	eb 30                	jmp    80105a75 <change_sched_policy+0x30d>
  	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a45:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80105a4c:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
80105a53:	0f 82 11 ff ff ff    	jb     8010596a <change_sched_policy+0x202>
    		}
  	}
 	 release(&ptable.lock);
80105a59:	83 ec 0c             	sub    $0xc,%esp
80105a5c:	68 80 39 11 80       	push   $0x80113980
80105a61:	e8 f5 02 00 00       	call   80105d5b <release>
80105a66:	83 c4 10             	add    $0x10,%esp
  	return -22;
80105a69:	b8 ea ff ff ff       	mov    $0xffffffea,%eax
80105a6e:	eb 05                	jmp    80105a75 <change_sched_policy+0x30d>

	}
	return 0;
80105a70:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a75:	c9                   	leave  
80105a76:	c3                   	ret    

80105a77 <change_rate>:
		
	

int
change_rate(int pid,int rate)
{
80105a77:	55                   	push   %ebp
80105a78:	89 e5                	mov    %esp,%ebp
80105a7a:	83 ec 18             	sub    $0x18,%esp
  int w;
  struct proc *p;
 
  acquire(&ptable.lock);
80105a7d:	83 ec 0c             	sub    $0xc,%esp
80105a80:	68 80 39 11 80       	push   $0x80113980
80105a85:	e8 63 02 00 00       	call   80105ced <acquire>
80105a8a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a8d:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105a94:	e9 8b 00 00 00       	jmp    80105b24 <change_rate+0xad>
    if(p->pid == pid){
80105a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9c:	8b 40 10             	mov    0x10(%eax),%eax
80105a9f:	39 45 08             	cmp    %eax,0x8(%ebp)
80105aa2:	75 79                	jne    80105b1d <change_rate+0xa6>
      p->rate = rate;
80105aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
80105aaa:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
      
      w = 300*(30-rate)/29;
80105ab0:	b8 1e 00 00 00       	mov    $0x1e,%eax
80105ab5:	2b 45 0c             	sub    0xc(%ebp),%eax
80105ab8:	69 c8 2c 01 00 00    	imul   $0x12c,%eax,%ecx
80105abe:	ba 09 cb 3d 8d       	mov    $0x8d3dcb09,%edx
80105ac3:	89 c8                	mov    %ecx,%eax
80105ac5:	f7 ea                	imul   %edx
80105ac7:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
80105aca:	c1 f8 04             	sar    $0x4,%eax
80105acd:	c1 f9 1f             	sar    $0x1f,%ecx
80105ad0:	89 ca                	mov    %ecx,%edx
80105ad2:	29 d0                	sub    %edx,%eax
80105ad4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(w>=0&&w<=100)
80105ad7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105adb:	78 15                	js     80105af2 <change_rate+0x7b>
80105add:	83 7d f0 64          	cmpl   $0x64,-0x10(%ebp)
80105ae1:	7f 0f                	jg     80105af2 <change_rate+0x7b>
      	p->priority = 1;
80105ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae6:	c7 80 94 00 00 00 01 	movl   $0x1,0x94(%eax)
80105aed:	00 00 00 
80105af0:	eb 2b                	jmp    80105b1d <change_rate+0xa6>
      else if(w>100&&w<=200)
80105af2:	83 7d f0 64          	cmpl   $0x64,-0x10(%ebp)
80105af6:	7e 18                	jle    80105b10 <change_rate+0x99>
80105af8:	81 7d f0 c8 00 00 00 	cmpl   $0xc8,-0x10(%ebp)
80105aff:	7f 0f                	jg     80105b10 <change_rate+0x99>
      	p->priority = 2;
80105b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b04:	c7 80 94 00 00 00 02 	movl   $0x2,0x94(%eax)
80105b0b:	00 00 00 
80105b0e:	eb 0d                	jmp    80105b1d <change_rate+0xa6>
      else
      	p->priority = 3;
80105b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b13:	c7 80 94 00 00 00 03 	movl   $0x3,0x94(%eax)
80105b1a:	00 00 00 
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b1d:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80105b24:	81 7d f4 b4 60 11 80 	cmpl   $0x801160b4,-0xc(%ebp)
80105b2b:	0f 82 68 ff ff ff    	jb     80105a99 <change_rate+0x22>
   
    }
  }
  release(&ptable.lock);
80105b31:	83 ec 0c             	sub    $0xc,%esp
80105b34:	68 80 39 11 80       	push   $0x80113980
80105b39:	e8 1d 02 00 00       	call   80105d5b <release>
80105b3e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105b41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b46:	c9                   	leave  
80105b47:	c3                   	ret    

80105b48 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105b48:	55                   	push   %ebp
80105b49:	89 e5                	mov    %esp,%ebp
80105b4b:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b51:	83 c0 04             	add    $0x4,%eax
80105b54:	83 ec 08             	sub    $0x8,%esp
80105b57:	68 ca 97 10 80       	push   $0x801097ca
80105b5c:	50                   	push   %eax
80105b5d:	e8 69 01 00 00       	call   80105ccb <initlock>
80105b62:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80105b65:	8b 45 08             	mov    0x8(%ebp),%eax
80105b68:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b6b:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105b77:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7a:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105b81:	90                   	nop
80105b82:	c9                   	leave  
80105b83:	c3                   	ret    

80105b84 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105b84:	55                   	push   %ebp
80105b85:	89 e5                	mov    %esp,%ebp
80105b87:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b8d:	83 c0 04             	add    $0x4,%eax
80105b90:	83 ec 0c             	sub    $0xc,%esp
80105b93:	50                   	push   %eax
80105b94:	e8 54 01 00 00       	call   80105ced <acquire>
80105b99:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105b9c:	eb 15                	jmp    80105bb3 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80105b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80105ba1:	83 c0 04             	add    $0x4,%eax
80105ba4:	83 ec 08             	sub    $0x8,%esp
80105ba7:	50                   	push   %eax
80105ba8:	ff 75 08             	push   0x8(%ebp)
80105bab:	e8 25 f7 ff ff       	call   801052d5 <sleep>
80105bb0:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb6:	8b 00                	mov    (%eax),%eax
80105bb8:	85 c0                	test   %eax,%eax
80105bba:	75 e2                	jne    80105b9e <acquiresleep+0x1a>
  }
  lk->locked = 1;
80105bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80105bbf:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105bc5:	e8 86 ea ff ff       	call   80104650 <myproc>
80105bca:	8b 50 10             	mov    0x10(%eax),%edx
80105bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd0:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd6:	83 c0 04             	add    $0x4,%eax
80105bd9:	83 ec 0c             	sub    $0xc,%esp
80105bdc:	50                   	push   %eax
80105bdd:	e8 79 01 00 00       	call   80105d5b <release>
80105be2:	83 c4 10             	add    $0x10,%esp
}
80105be5:	90                   	nop
80105be6:	c9                   	leave  
80105be7:	c3                   	ret    

80105be8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105be8:	55                   	push   %ebp
80105be9:	89 e5                	mov    %esp,%ebp
80105beb:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105bee:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf1:	83 c0 04             	add    $0x4,%eax
80105bf4:	83 ec 0c             	sub    $0xc,%esp
80105bf7:	50                   	push   %eax
80105bf8:	e8 f0 00 00 00       	call   80105ced <acquire>
80105bfd:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105c00:	8b 45 08             	mov    0x8(%ebp),%eax
80105c03:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105c09:	8b 45 08             	mov    0x8(%ebp),%eax
80105c0c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105c13:	83 ec 0c             	sub    $0xc,%esp
80105c16:	ff 75 08             	push   0x8(%ebp)
80105c19:	e8 a1 f7 ff ff       	call   801053bf <wakeup>
80105c1e:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105c21:	8b 45 08             	mov    0x8(%ebp),%eax
80105c24:	83 c0 04             	add    $0x4,%eax
80105c27:	83 ec 0c             	sub    $0xc,%esp
80105c2a:	50                   	push   %eax
80105c2b:	e8 2b 01 00 00       	call   80105d5b <release>
80105c30:	83 c4 10             	add    $0x10,%esp
}
80105c33:	90                   	nop
80105c34:	c9                   	leave  
80105c35:	c3                   	ret    

80105c36 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105c36:	55                   	push   %ebp
80105c37:	89 e5                	mov    %esp,%ebp
80105c39:	53                   	push   %ebx
80105c3a:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
80105c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c40:	83 c0 04             	add    $0x4,%eax
80105c43:	83 ec 0c             	sub    $0xc,%esp
80105c46:	50                   	push   %eax
80105c47:	e8 a1 00 00 00       	call   80105ced <acquire>
80105c4c:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
80105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c52:	8b 00                	mov    (%eax),%eax
80105c54:	85 c0                	test   %eax,%eax
80105c56:	74 19                	je     80105c71 <holdingsleep+0x3b>
80105c58:	8b 45 08             	mov    0x8(%ebp),%eax
80105c5b:	8b 58 3c             	mov    0x3c(%eax),%ebx
80105c5e:	e8 ed e9 ff ff       	call   80104650 <myproc>
80105c63:	8b 40 10             	mov    0x10(%eax),%eax
80105c66:	39 c3                	cmp    %eax,%ebx
80105c68:	75 07                	jne    80105c71 <holdingsleep+0x3b>
80105c6a:	b8 01 00 00 00       	mov    $0x1,%eax
80105c6f:	eb 05                	jmp    80105c76 <holdingsleep+0x40>
80105c71:	b8 00 00 00 00       	mov    $0x0,%eax
80105c76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105c79:	8b 45 08             	mov    0x8(%ebp),%eax
80105c7c:	83 c0 04             	add    $0x4,%eax
80105c7f:	83 ec 0c             	sub    $0xc,%esp
80105c82:	50                   	push   %eax
80105c83:	e8 d3 00 00 00       	call   80105d5b <release>
80105c88:	83 c4 10             	add    $0x10,%esp
  return r;
80105c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105c91:	c9                   	leave  
80105c92:	c3                   	ret    

80105c93 <readeflags>:
{
80105c93:	55                   	push   %ebp
80105c94:	89 e5                	mov    %esp,%ebp
80105c96:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105c99:	9c                   	pushf  
80105c9a:	58                   	pop    %eax
80105c9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105c9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ca1:	c9                   	leave  
80105ca2:	c3                   	ret    

80105ca3 <cli>:
{
80105ca3:	55                   	push   %ebp
80105ca4:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105ca6:	fa                   	cli    
}
80105ca7:	90                   	nop
80105ca8:	5d                   	pop    %ebp
80105ca9:	c3                   	ret    

80105caa <sti>:
{
80105caa:	55                   	push   %ebp
80105cab:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105cad:	fb                   	sti    
}
80105cae:	90                   	nop
80105caf:	5d                   	pop    %ebp
80105cb0:	c3                   	ret    

80105cb1 <xchg>:
{
80105cb1:	55                   	push   %ebp
80105cb2:	89 e5                	mov    %esp,%ebp
80105cb4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105cb7:	8b 55 08             	mov    0x8(%ebp),%edx
80105cba:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105cc0:	f0 87 02             	lock xchg %eax,(%edx)
80105cc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105cc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105cc9:	c9                   	leave  
80105cca:	c3                   	ret    

80105ccb <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105ccb:	55                   	push   %ebp
80105ccc:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105cce:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
80105cd4:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80105cda:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80105ce3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105cea:	90                   	nop
80105ceb:	5d                   	pop    %ebp
80105cec:	c3                   	ret    

80105ced <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105ced:	55                   	push   %ebp
80105cee:	89 e5                	mov    %esp,%ebp
80105cf0:	53                   	push   %ebx
80105cf1:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105cf4:	e8 6f 01 00 00       	call   80105e68 <pushcli>
  if(holding(lk))
80105cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80105cfc:	83 ec 0c             	sub    $0xc,%esp
80105cff:	50                   	push   %eax
80105d00:	e8 23 01 00 00       	call   80105e28 <holding>
80105d05:	83 c4 10             	add    $0x10,%esp
80105d08:	85 c0                	test   %eax,%eax
80105d0a:	74 0d                	je     80105d19 <acquire+0x2c>
    panic("acquire");
80105d0c:	83 ec 0c             	sub    $0xc,%esp
80105d0f:	68 d5 97 10 80       	push   $0x801097d5
80105d14:	e8 9c a8 ff ff       	call   801005b5 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105d19:	90                   	nop
80105d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80105d1d:	83 ec 08             	sub    $0x8,%esp
80105d20:	6a 01                	push   $0x1
80105d22:	50                   	push   %eax
80105d23:	e8 89 ff ff ff       	call   80105cb1 <xchg>
80105d28:	83 c4 10             	add    $0x10,%esp
80105d2b:	85 c0                	test   %eax,%eax
80105d2d:	75 eb                	jne    80105d1a <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105d2f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105d34:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105d37:	e8 9c e8 ff ff       	call   801045d8 <mycpu>
80105d3c:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80105d42:	83 c0 0c             	add    $0xc,%eax
80105d45:	83 ec 08             	sub    $0x8,%esp
80105d48:	50                   	push   %eax
80105d49:	8d 45 08             	lea    0x8(%ebp),%eax
80105d4c:	50                   	push   %eax
80105d4d:	e8 5b 00 00 00       	call   80105dad <getcallerpcs>
80105d52:	83 c4 10             	add    $0x10,%esp
}
80105d55:	90                   	nop
80105d56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105d59:	c9                   	leave  
80105d5a:	c3                   	ret    

80105d5b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105d5b:	55                   	push   %ebp
80105d5c:	89 e5                	mov    %esp,%ebp
80105d5e:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105d61:	83 ec 0c             	sub    $0xc,%esp
80105d64:	ff 75 08             	push   0x8(%ebp)
80105d67:	e8 bc 00 00 00       	call   80105e28 <holding>
80105d6c:	83 c4 10             	add    $0x10,%esp
80105d6f:	85 c0                	test   %eax,%eax
80105d71:	75 0d                	jne    80105d80 <release+0x25>
    panic("release");
80105d73:	83 ec 0c             	sub    $0xc,%esp
80105d76:	68 dd 97 10 80       	push   $0x801097dd
80105d7b:	e8 35 a8 ff ff       	call   801005b5 <panic>

  lk->pcs[0] = 0;
80105d80:	8b 45 08             	mov    0x8(%ebp),%eax
80105d83:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80105d8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105d94:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105d99:	8b 45 08             	mov    0x8(%ebp),%eax
80105d9c:	8b 55 08             	mov    0x8(%ebp),%edx
80105d9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105da5:	e8 0b 01 00 00       	call   80105eb5 <popcli>
}
80105daa:	90                   	nop
80105dab:	c9                   	leave  
80105dac:	c3                   	ret    

80105dad <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105dad:	55                   	push   %ebp
80105dae:	89 e5                	mov    %esp,%ebp
80105db0:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105db3:	8b 45 08             	mov    0x8(%ebp),%eax
80105db6:	83 e8 08             	sub    $0x8,%eax
80105db9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105dbc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105dc3:	eb 38                	jmp    80105dfd <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105dc5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105dc9:	74 53                	je     80105e1e <getcallerpcs+0x71>
80105dcb:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105dd2:	76 4a                	jbe    80105e1e <getcallerpcs+0x71>
80105dd4:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105dd8:	74 44                	je     80105e1e <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105dda:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ddd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105de4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105de7:	01 c2                	add    %eax,%edx
80105de9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dec:	8b 40 04             	mov    0x4(%eax),%eax
80105def:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105df1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105df4:	8b 00                	mov    (%eax),%eax
80105df6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105df9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105dfd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105e01:	7e c2                	jle    80105dc5 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105e03:	eb 19                	jmp    80105e1e <getcallerpcs+0x71>
    pcs[i] = 0;
80105e05:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e12:	01 d0                	add    %edx,%eax
80105e14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105e1a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105e1e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105e22:	7e e1                	jle    80105e05 <getcallerpcs+0x58>
}
80105e24:	90                   	nop
80105e25:	90                   	nop
80105e26:	c9                   	leave  
80105e27:	c3                   	ret    

80105e28 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105e28:	55                   	push   %ebp
80105e29:	89 e5                	mov    %esp,%ebp
80105e2b:	53                   	push   %ebx
80105e2c:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80105e2f:	e8 34 00 00 00       	call   80105e68 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80105e34:	8b 45 08             	mov    0x8(%ebp),%eax
80105e37:	8b 00                	mov    (%eax),%eax
80105e39:	85 c0                	test   %eax,%eax
80105e3b:	74 16                	je     80105e53 <holding+0x2b>
80105e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80105e40:	8b 58 08             	mov    0x8(%eax),%ebx
80105e43:	e8 90 e7 ff ff       	call   801045d8 <mycpu>
80105e48:	39 c3                	cmp    %eax,%ebx
80105e4a:	75 07                	jne    80105e53 <holding+0x2b>
80105e4c:	b8 01 00 00 00       	mov    $0x1,%eax
80105e51:	eb 05                	jmp    80105e58 <holding+0x30>
80105e53:	b8 00 00 00 00       	mov    $0x0,%eax
80105e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80105e5b:	e8 55 00 00 00       	call   80105eb5 <popcli>
  return r;
80105e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e66:	c9                   	leave  
80105e67:	c3                   	ret    

80105e68 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105e68:	55                   	push   %ebp
80105e69:	89 e5                	mov    %esp,%ebp
80105e6b:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105e6e:	e8 20 fe ff ff       	call   80105c93 <readeflags>
80105e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105e76:	e8 28 fe ff ff       	call   80105ca3 <cli>
  if(mycpu()->ncli == 0)
80105e7b:	e8 58 e7 ff ff       	call   801045d8 <mycpu>
80105e80:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105e86:	85 c0                	test   %eax,%eax
80105e88:	75 14                	jne    80105e9e <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105e8a:	e8 49 e7 ff ff       	call   801045d8 <mycpu>
80105e8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e92:	81 e2 00 02 00 00    	and    $0x200,%edx
80105e98:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105e9e:	e8 35 e7 ff ff       	call   801045d8 <mycpu>
80105ea3:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105ea9:	83 c2 01             	add    $0x1,%edx
80105eac:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105eb2:	90                   	nop
80105eb3:	c9                   	leave  
80105eb4:	c3                   	ret    

80105eb5 <popcli>:

void
popcli(void)
{
80105eb5:	55                   	push   %ebp
80105eb6:	89 e5                	mov    %esp,%ebp
80105eb8:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105ebb:	e8 d3 fd ff ff       	call   80105c93 <readeflags>
80105ec0:	25 00 02 00 00       	and    $0x200,%eax
80105ec5:	85 c0                	test   %eax,%eax
80105ec7:	74 0d                	je     80105ed6 <popcli+0x21>
    panic("popcli - interruptible");
80105ec9:	83 ec 0c             	sub    $0xc,%esp
80105ecc:	68 e5 97 10 80       	push   $0x801097e5
80105ed1:	e8 df a6 ff ff       	call   801005b5 <panic>
  if(--mycpu()->ncli < 0)
80105ed6:	e8 fd e6 ff ff       	call   801045d8 <mycpu>
80105edb:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105ee1:	83 ea 01             	sub    $0x1,%edx
80105ee4:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105eea:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105ef0:	85 c0                	test   %eax,%eax
80105ef2:	79 0d                	jns    80105f01 <popcli+0x4c>
    panic("popcli");
80105ef4:	83 ec 0c             	sub    $0xc,%esp
80105ef7:	68 fc 97 10 80       	push   $0x801097fc
80105efc:	e8 b4 a6 ff ff       	call   801005b5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105f01:	e8 d2 e6 ff ff       	call   801045d8 <mycpu>
80105f06:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105f0c:	85 c0                	test   %eax,%eax
80105f0e:	75 14                	jne    80105f24 <popcli+0x6f>
80105f10:	e8 c3 e6 ff ff       	call   801045d8 <mycpu>
80105f15:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105f1b:	85 c0                	test   %eax,%eax
80105f1d:	74 05                	je     80105f24 <popcli+0x6f>
    sti();
80105f1f:	e8 86 fd ff ff       	call   80105caa <sti>
}
80105f24:	90                   	nop
80105f25:	c9                   	leave  
80105f26:	c3                   	ret    

80105f27 <stosb>:
{
80105f27:	55                   	push   %ebp
80105f28:	89 e5                	mov    %esp,%ebp
80105f2a:	57                   	push   %edi
80105f2b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105f2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105f2f:	8b 55 10             	mov    0x10(%ebp),%edx
80105f32:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f35:	89 cb                	mov    %ecx,%ebx
80105f37:	89 df                	mov    %ebx,%edi
80105f39:	89 d1                	mov    %edx,%ecx
80105f3b:	fc                   	cld    
80105f3c:	f3 aa                	rep stos %al,%es:(%edi)
80105f3e:	89 ca                	mov    %ecx,%edx
80105f40:	89 fb                	mov    %edi,%ebx
80105f42:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105f45:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105f48:	90                   	nop
80105f49:	5b                   	pop    %ebx
80105f4a:	5f                   	pop    %edi
80105f4b:	5d                   	pop    %ebp
80105f4c:	c3                   	ret    

80105f4d <stosl>:
{
80105f4d:	55                   	push   %ebp
80105f4e:	89 e5                	mov    %esp,%ebp
80105f50:	57                   	push   %edi
80105f51:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105f52:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105f55:	8b 55 10             	mov    0x10(%ebp),%edx
80105f58:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f5b:	89 cb                	mov    %ecx,%ebx
80105f5d:	89 df                	mov    %ebx,%edi
80105f5f:	89 d1                	mov    %edx,%ecx
80105f61:	fc                   	cld    
80105f62:	f3 ab                	rep stos %eax,%es:(%edi)
80105f64:	89 ca                	mov    %ecx,%edx
80105f66:	89 fb                	mov    %edi,%ebx
80105f68:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105f6b:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105f6e:	90                   	nop
80105f6f:	5b                   	pop    %ebx
80105f70:	5f                   	pop    %edi
80105f71:	5d                   	pop    %ebp
80105f72:	c3                   	ret    

80105f73 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105f73:	55                   	push   %ebp
80105f74:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105f76:	8b 45 08             	mov    0x8(%ebp),%eax
80105f79:	83 e0 03             	and    $0x3,%eax
80105f7c:	85 c0                	test   %eax,%eax
80105f7e:	75 43                	jne    80105fc3 <memset+0x50>
80105f80:	8b 45 10             	mov    0x10(%ebp),%eax
80105f83:	83 e0 03             	and    $0x3,%eax
80105f86:	85 c0                	test   %eax,%eax
80105f88:	75 39                	jne    80105fc3 <memset+0x50>
    c &= 0xFF;
80105f8a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105f91:	8b 45 10             	mov    0x10(%ebp),%eax
80105f94:	c1 e8 02             	shr    $0x2,%eax
80105f97:	89 c2                	mov    %eax,%edx
80105f99:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f9c:	c1 e0 18             	shl    $0x18,%eax
80105f9f:	89 c1                	mov    %eax,%ecx
80105fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fa4:	c1 e0 10             	shl    $0x10,%eax
80105fa7:	09 c1                	or     %eax,%ecx
80105fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fac:	c1 e0 08             	shl    $0x8,%eax
80105faf:	09 c8                	or     %ecx,%eax
80105fb1:	0b 45 0c             	or     0xc(%ebp),%eax
80105fb4:	52                   	push   %edx
80105fb5:	50                   	push   %eax
80105fb6:	ff 75 08             	push   0x8(%ebp)
80105fb9:	e8 8f ff ff ff       	call   80105f4d <stosl>
80105fbe:	83 c4 0c             	add    $0xc,%esp
80105fc1:	eb 12                	jmp    80105fd5 <memset+0x62>
  } else
    stosb(dst, c, n);
80105fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80105fc6:	50                   	push   %eax
80105fc7:	ff 75 0c             	push   0xc(%ebp)
80105fca:	ff 75 08             	push   0x8(%ebp)
80105fcd:	e8 55 ff ff ff       	call   80105f27 <stosb>
80105fd2:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105fd5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105fd8:	c9                   	leave  
80105fd9:	c3                   	ret    

80105fda <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105fda:	55                   	push   %ebp
80105fdb:	89 e5                	mov    %esp,%ebp
80105fdd:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fe9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105fec:	eb 30                	jmp    8010601e <memcmp+0x44>
    if(*s1 != *s2)
80105fee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ff1:	0f b6 10             	movzbl (%eax),%edx
80105ff4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ff7:	0f b6 00             	movzbl (%eax),%eax
80105ffa:	38 c2                	cmp    %al,%dl
80105ffc:	74 18                	je     80106016 <memcmp+0x3c>
      return *s1 - *s2;
80105ffe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106001:	0f b6 00             	movzbl (%eax),%eax
80106004:	0f b6 d0             	movzbl %al,%edx
80106007:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010600a:	0f b6 00             	movzbl (%eax),%eax
8010600d:	0f b6 c8             	movzbl %al,%ecx
80106010:	89 d0                	mov    %edx,%eax
80106012:	29 c8                	sub    %ecx,%eax
80106014:	eb 1a                	jmp    80106030 <memcmp+0x56>
    s1++, s2++;
80106016:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010601a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010601e:	8b 45 10             	mov    0x10(%ebp),%eax
80106021:	8d 50 ff             	lea    -0x1(%eax),%edx
80106024:	89 55 10             	mov    %edx,0x10(%ebp)
80106027:	85 c0                	test   %eax,%eax
80106029:	75 c3                	jne    80105fee <memcmp+0x14>
  }

  return 0;
8010602b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106030:	c9                   	leave  
80106031:	c3                   	ret    

80106032 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106032:	55                   	push   %ebp
80106033:	89 e5                	mov    %esp,%ebp
80106035:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80106038:	8b 45 0c             	mov    0xc(%ebp),%eax
8010603b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010603e:	8b 45 08             	mov    0x8(%ebp),%eax
80106041:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106044:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106047:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010604a:	73 54                	jae    801060a0 <memmove+0x6e>
8010604c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010604f:	8b 45 10             	mov    0x10(%ebp),%eax
80106052:	01 d0                	add    %edx,%eax
80106054:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80106057:	73 47                	jae    801060a0 <memmove+0x6e>
    s += n;
80106059:	8b 45 10             	mov    0x10(%ebp),%eax
8010605c:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010605f:	8b 45 10             	mov    0x10(%ebp),%eax
80106062:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106065:	eb 13                	jmp    8010607a <memmove+0x48>
      *--d = *--s;
80106067:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010606b:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010606f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106072:	0f b6 10             	movzbl (%eax),%edx
80106075:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106078:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010607a:	8b 45 10             	mov    0x10(%ebp),%eax
8010607d:	8d 50 ff             	lea    -0x1(%eax),%edx
80106080:	89 55 10             	mov    %edx,0x10(%ebp)
80106083:	85 c0                	test   %eax,%eax
80106085:	75 e0                	jne    80106067 <memmove+0x35>
  if(s < d && s + n > d){
80106087:	eb 24                	jmp    801060ad <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80106089:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010608c:	8d 42 01             	lea    0x1(%edx),%eax
8010608f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106092:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106095:	8d 48 01             	lea    0x1(%eax),%ecx
80106098:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010609b:	0f b6 12             	movzbl (%edx),%edx
8010609e:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801060a0:	8b 45 10             	mov    0x10(%ebp),%eax
801060a3:	8d 50 ff             	lea    -0x1(%eax),%edx
801060a6:	89 55 10             	mov    %edx,0x10(%ebp)
801060a9:	85 c0                	test   %eax,%eax
801060ab:	75 dc                	jne    80106089 <memmove+0x57>

  return dst;
801060ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
801060b0:	c9                   	leave  
801060b1:	c3                   	ret    

801060b2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801060b2:	55                   	push   %ebp
801060b3:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801060b5:	ff 75 10             	push   0x10(%ebp)
801060b8:	ff 75 0c             	push   0xc(%ebp)
801060bb:	ff 75 08             	push   0x8(%ebp)
801060be:	e8 6f ff ff ff       	call   80106032 <memmove>
801060c3:	83 c4 0c             	add    $0xc,%esp
}
801060c6:	c9                   	leave  
801060c7:	c3                   	ret    

801060c8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801060c8:	55                   	push   %ebp
801060c9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801060cb:	eb 0c                	jmp    801060d9 <strncmp+0x11>
    n--, p++, q++;
801060cd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801060d1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801060d5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801060d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801060dd:	74 1a                	je     801060f9 <strncmp+0x31>
801060df:	8b 45 08             	mov    0x8(%ebp),%eax
801060e2:	0f b6 00             	movzbl (%eax),%eax
801060e5:	84 c0                	test   %al,%al
801060e7:	74 10                	je     801060f9 <strncmp+0x31>
801060e9:	8b 45 08             	mov    0x8(%ebp),%eax
801060ec:	0f b6 10             	movzbl (%eax),%edx
801060ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801060f2:	0f b6 00             	movzbl (%eax),%eax
801060f5:	38 c2                	cmp    %al,%dl
801060f7:	74 d4                	je     801060cd <strncmp+0x5>
  if(n == 0)
801060f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801060fd:	75 07                	jne    80106106 <strncmp+0x3e>
    return 0;
801060ff:	b8 00 00 00 00       	mov    $0x0,%eax
80106104:	eb 16                	jmp    8010611c <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106106:	8b 45 08             	mov    0x8(%ebp),%eax
80106109:	0f b6 00             	movzbl (%eax),%eax
8010610c:	0f b6 d0             	movzbl %al,%edx
8010610f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106112:	0f b6 00             	movzbl (%eax),%eax
80106115:	0f b6 c8             	movzbl %al,%ecx
80106118:	89 d0                	mov    %edx,%eax
8010611a:	29 c8                	sub    %ecx,%eax
}
8010611c:	5d                   	pop    %ebp
8010611d:	c3                   	ret    

8010611e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010611e:	55                   	push   %ebp
8010611f:	89 e5                	mov    %esp,%ebp
80106121:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80106124:	8b 45 08             	mov    0x8(%ebp),%eax
80106127:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010612a:	90                   	nop
8010612b:	8b 45 10             	mov    0x10(%ebp),%eax
8010612e:	8d 50 ff             	lea    -0x1(%eax),%edx
80106131:	89 55 10             	mov    %edx,0x10(%ebp)
80106134:	85 c0                	test   %eax,%eax
80106136:	7e 2c                	jle    80106164 <strncpy+0x46>
80106138:	8b 55 0c             	mov    0xc(%ebp),%edx
8010613b:	8d 42 01             	lea    0x1(%edx),%eax
8010613e:	89 45 0c             	mov    %eax,0xc(%ebp)
80106141:	8b 45 08             	mov    0x8(%ebp),%eax
80106144:	8d 48 01             	lea    0x1(%eax),%ecx
80106147:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010614a:	0f b6 12             	movzbl (%edx),%edx
8010614d:	88 10                	mov    %dl,(%eax)
8010614f:	0f b6 00             	movzbl (%eax),%eax
80106152:	84 c0                	test   %al,%al
80106154:	75 d5                	jne    8010612b <strncpy+0xd>
    ;
  while(n-- > 0)
80106156:	eb 0c                	jmp    80106164 <strncpy+0x46>
    *s++ = 0;
80106158:	8b 45 08             	mov    0x8(%ebp),%eax
8010615b:	8d 50 01             	lea    0x1(%eax),%edx
8010615e:	89 55 08             	mov    %edx,0x8(%ebp)
80106161:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80106164:	8b 45 10             	mov    0x10(%ebp),%eax
80106167:	8d 50 ff             	lea    -0x1(%eax),%edx
8010616a:	89 55 10             	mov    %edx,0x10(%ebp)
8010616d:	85 c0                	test   %eax,%eax
8010616f:	7f e7                	jg     80106158 <strncpy+0x3a>
  return os;
80106171:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106174:	c9                   	leave  
80106175:	c3                   	ret    

80106176 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106176:	55                   	push   %ebp
80106177:	89 e5                	mov    %esp,%ebp
80106179:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010617c:	8b 45 08             	mov    0x8(%ebp),%eax
8010617f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106182:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106186:	7f 05                	jg     8010618d <safestrcpy+0x17>
    return os;
80106188:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010618b:	eb 32                	jmp    801061bf <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
8010618d:	90                   	nop
8010618e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106192:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106196:	7e 1e                	jle    801061b6 <safestrcpy+0x40>
80106198:	8b 55 0c             	mov    0xc(%ebp),%edx
8010619b:	8d 42 01             	lea    0x1(%edx),%eax
8010619e:	89 45 0c             	mov    %eax,0xc(%ebp)
801061a1:	8b 45 08             	mov    0x8(%ebp),%eax
801061a4:	8d 48 01             	lea    0x1(%eax),%ecx
801061a7:	89 4d 08             	mov    %ecx,0x8(%ebp)
801061aa:	0f b6 12             	movzbl (%edx),%edx
801061ad:	88 10                	mov    %dl,(%eax)
801061af:	0f b6 00             	movzbl (%eax),%eax
801061b2:	84 c0                	test   %al,%al
801061b4:	75 d8                	jne    8010618e <safestrcpy+0x18>
    ;
  *s = 0;
801061b6:	8b 45 08             	mov    0x8(%ebp),%eax
801061b9:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801061bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801061bf:	c9                   	leave  
801061c0:	c3                   	ret    

801061c1 <strlen>:

int
strlen(const char *s)
{
801061c1:	55                   	push   %ebp
801061c2:	89 e5                	mov    %esp,%ebp
801061c4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801061c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801061ce:	eb 04                	jmp    801061d4 <strlen+0x13>
801061d0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801061d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061d7:	8b 45 08             	mov    0x8(%ebp),%eax
801061da:	01 d0                	add    %edx,%eax
801061dc:	0f b6 00             	movzbl (%eax),%eax
801061df:	84 c0                	test   %al,%al
801061e1:	75 ed                	jne    801061d0 <strlen+0xf>
    ;
  return n;
801061e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801061e6:	c9                   	leave  
801061e7:	c3                   	ret    

801061e8 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801061e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801061ec:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801061f0:	55                   	push   %ebp
  pushl %ebx
801061f1:	53                   	push   %ebx
  pushl %esi
801061f2:	56                   	push   %esi
  pushl %edi
801061f3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801061f4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801061f6:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801061f8:	5f                   	pop    %edi
  popl %esi
801061f9:	5e                   	pop    %esi
  popl %ebx
801061fa:	5b                   	pop    %ebx
  popl %ebp
801061fb:	5d                   	pop    %ebp
  ret
801061fc:	c3                   	ret    

801061fd <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801061fd:	55                   	push   %ebp
801061fe:	89 e5                	mov    %esp,%ebp
80106200:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80106203:	e8 48 e4 ff ff       	call   80104650 <myproc>
80106208:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010620b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620e:	8b 00                	mov    (%eax),%eax
80106210:	39 45 08             	cmp    %eax,0x8(%ebp)
80106213:	73 0f                	jae    80106224 <fetchint+0x27>
80106215:	8b 45 08             	mov    0x8(%ebp),%eax
80106218:	8d 50 04             	lea    0x4(%eax),%edx
8010621b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621e:	8b 00                	mov    (%eax),%eax
80106220:	39 c2                	cmp    %eax,%edx
80106222:	76 07                	jbe    8010622b <fetchint+0x2e>
    return -1;
80106224:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106229:	eb 0f                	jmp    8010623a <fetchint+0x3d>
  *ip = *(int*)(addr);
8010622b:	8b 45 08             	mov    0x8(%ebp),%eax
8010622e:	8b 10                	mov    (%eax),%edx
80106230:	8b 45 0c             	mov    0xc(%ebp),%eax
80106233:	89 10                	mov    %edx,(%eax)
  return 0;
80106235:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010623a:	c9                   	leave  
8010623b:	c3                   	ret    

8010623c <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010623c:	55                   	push   %ebp
8010623d:	89 e5                	mov    %esp,%ebp
8010623f:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80106242:	e8 09 e4 ff ff       	call   80104650 <myproc>
80106247:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010624a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624d:	8b 00                	mov    (%eax),%eax
8010624f:	39 45 08             	cmp    %eax,0x8(%ebp)
80106252:	72 07                	jb     8010625b <fetchstr+0x1f>
    return -1;
80106254:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106259:	eb 41                	jmp    8010629c <fetchstr+0x60>
  *pp = (char*)addr;
8010625b:	8b 55 08             	mov    0x8(%ebp),%edx
8010625e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106261:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80106263:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106266:	8b 00                	mov    (%eax),%eax
80106268:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010626b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010626e:	8b 00                	mov    (%eax),%eax
80106270:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106273:	eb 1a                	jmp    8010628f <fetchstr+0x53>
    if(*s == 0)
80106275:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106278:	0f b6 00             	movzbl (%eax),%eax
8010627b:	84 c0                	test   %al,%al
8010627d:	75 0c                	jne    8010628b <fetchstr+0x4f>
      return s - *pp;
8010627f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106282:	8b 10                	mov    (%eax),%edx
80106284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106287:	29 d0                	sub    %edx,%eax
80106289:	eb 11                	jmp    8010629c <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
8010628b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010628f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106292:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80106295:	72 de                	jb     80106275 <fetchstr+0x39>
  }
  return -1;
80106297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010629c:	c9                   	leave  
8010629d:	c3                   	ret    

8010629e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010629e:	55                   	push   %ebp
8010629f:	89 e5                	mov    %esp,%ebp
801062a1:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801062a4:	e8 a7 e3 ff ff       	call   80104650 <myproc>
801062a9:	8b 40 18             	mov    0x18(%eax),%eax
801062ac:	8b 50 44             	mov    0x44(%eax),%edx
801062af:	8b 45 08             	mov    0x8(%ebp),%eax
801062b2:	c1 e0 02             	shl    $0x2,%eax
801062b5:	01 d0                	add    %edx,%eax
801062b7:	83 c0 04             	add    $0x4,%eax
801062ba:	83 ec 08             	sub    $0x8,%esp
801062bd:	ff 75 0c             	push   0xc(%ebp)
801062c0:	50                   	push   %eax
801062c1:	e8 37 ff ff ff       	call   801061fd <fetchint>
801062c6:	83 c4 10             	add    $0x10,%esp
}
801062c9:	c9                   	leave  
801062ca:	c3                   	ret    

801062cb <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801062cb:	55                   	push   %ebp
801062cc:	89 e5                	mov    %esp,%ebp
801062ce:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801062d1:	e8 7a e3 ff ff       	call   80104650 <myproc>
801062d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801062d9:	83 ec 08             	sub    $0x8,%esp
801062dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062df:	50                   	push   %eax
801062e0:	ff 75 08             	push   0x8(%ebp)
801062e3:	e8 b6 ff ff ff       	call   8010629e <argint>
801062e8:	83 c4 10             	add    $0x10,%esp
801062eb:	85 c0                	test   %eax,%eax
801062ed:	79 07                	jns    801062f6 <argptr+0x2b>
    return -1;
801062ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f4:	eb 3b                	jmp    80106331 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801062f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062fa:	78 1f                	js     8010631b <argptr+0x50>
801062fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ff:	8b 00                	mov    (%eax),%eax
80106301:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106304:	39 d0                	cmp    %edx,%eax
80106306:	76 13                	jbe    8010631b <argptr+0x50>
80106308:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010630b:	89 c2                	mov    %eax,%edx
8010630d:	8b 45 10             	mov    0x10(%ebp),%eax
80106310:	01 c2                	add    %eax,%edx
80106312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106315:	8b 00                	mov    (%eax),%eax
80106317:	39 c2                	cmp    %eax,%edx
80106319:	76 07                	jbe    80106322 <argptr+0x57>
    return -1;
8010631b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106320:	eb 0f                	jmp    80106331 <argptr+0x66>
  *pp = (char*)i;
80106322:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106325:	89 c2                	mov    %eax,%edx
80106327:	8b 45 0c             	mov    0xc(%ebp),%eax
8010632a:	89 10                	mov    %edx,(%eax)
  return 0;
8010632c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106331:	c9                   	leave  
80106332:	c3                   	ret    

80106333 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106333:	55                   	push   %ebp
80106334:	89 e5                	mov    %esp,%ebp
80106336:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106339:	83 ec 08             	sub    $0x8,%esp
8010633c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010633f:	50                   	push   %eax
80106340:	ff 75 08             	push   0x8(%ebp)
80106343:	e8 56 ff ff ff       	call   8010629e <argint>
80106348:	83 c4 10             	add    $0x10,%esp
8010634b:	85 c0                	test   %eax,%eax
8010634d:	79 07                	jns    80106356 <argstr+0x23>
    return -1;
8010634f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106354:	eb 12                	jmp    80106368 <argstr+0x35>
  return fetchstr(addr, pp);
80106356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106359:	83 ec 08             	sub    $0x8,%esp
8010635c:	ff 75 0c             	push   0xc(%ebp)
8010635f:	50                   	push   %eax
80106360:	e8 d7 fe ff ff       	call   8010623c <fetchstr>
80106365:	83 c4 10             	add    $0x10,%esp
}
80106368:	c9                   	leave  
80106369:	c3                   	ret    

8010636a <syscall>:
[SYS_rate]      sys_rate,
};

void
syscall(void)
{
8010636a:	55                   	push   %ebp
8010636b:	89 e5                	mov    %esp,%ebp
8010636d:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80106370:	e8 db e2 ff ff       	call   80104650 <myproc>
80106375:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80106378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637b:	8b 40 18             	mov    0x18(%eax),%eax
8010637e:	8b 40 1c             	mov    0x1c(%eax),%eax
80106381:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106384:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106388:	7e 2f                	jle    801063b9 <syscall+0x4f>
8010638a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010638d:	83 f8 1a             	cmp    $0x1a,%eax
80106390:	77 27                	ja     801063b9 <syscall+0x4f>
80106392:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106395:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
8010639c:	85 c0                	test   %eax,%eax
8010639e:	74 19                	je     801063b9 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801063a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a3:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801063aa:	ff d0                	call   *%eax
801063ac:	89 c2                	mov    %eax,%edx
801063ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b1:	8b 40 18             	mov    0x18(%eax),%eax
801063b4:	89 50 1c             	mov    %edx,0x1c(%eax)
801063b7:	eb 2c                	jmp    801063e5 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801063b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063bc:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801063bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c2:	8b 40 10             	mov    0x10(%eax),%eax
801063c5:	ff 75 f0             	push   -0x10(%ebp)
801063c8:	52                   	push   %edx
801063c9:	50                   	push   %eax
801063ca:	68 03 98 10 80       	push   $0x80109803
801063cf:	e8 2c a0 ff ff       	call   80100400 <cprintf>
801063d4:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801063d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063da:	8b 40 18             	mov    0x18(%eax),%eax
801063dd:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801063e4:	90                   	nop
801063e5:	90                   	nop
801063e6:	c9                   	leave  
801063e7:	c3                   	ret    

801063e8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801063e8:	55                   	push   %ebp
801063e9:	89 e5                	mov    %esp,%ebp
801063eb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801063ee:	83 ec 08             	sub    $0x8,%esp
801063f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063f4:	50                   	push   %eax
801063f5:	ff 75 08             	push   0x8(%ebp)
801063f8:	e8 a1 fe ff ff       	call   8010629e <argint>
801063fd:	83 c4 10             	add    $0x10,%esp
80106400:	85 c0                	test   %eax,%eax
80106402:	79 07                	jns    8010640b <argfd+0x23>
    return -1;
80106404:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106409:	eb 4f                	jmp    8010645a <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010640b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640e:	85 c0                	test   %eax,%eax
80106410:	78 20                	js     80106432 <argfd+0x4a>
80106412:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106415:	83 f8 0f             	cmp    $0xf,%eax
80106418:	7f 18                	jg     80106432 <argfd+0x4a>
8010641a:	e8 31 e2 ff ff       	call   80104650 <myproc>
8010641f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106422:	83 c2 08             	add    $0x8,%edx
80106425:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106429:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010642c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106430:	75 07                	jne    80106439 <argfd+0x51>
    return -1;
80106432:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106437:	eb 21                	jmp    8010645a <argfd+0x72>
  if(pfd)
80106439:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010643d:	74 08                	je     80106447 <argfd+0x5f>
    *pfd = fd;
8010643f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106442:	8b 45 0c             	mov    0xc(%ebp),%eax
80106445:	89 10                	mov    %edx,(%eax)
  if(pf)
80106447:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010644b:	74 08                	je     80106455 <argfd+0x6d>
    *pf = f;
8010644d:	8b 45 10             	mov    0x10(%ebp),%eax
80106450:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106453:	89 10                	mov    %edx,(%eax)
  return 0;
80106455:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010645a:	c9                   	leave  
8010645b:	c3                   	ret    

8010645c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010645c:	55                   	push   %ebp
8010645d:	89 e5                	mov    %esp,%ebp
8010645f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80106462:	e8 e9 e1 ff ff       	call   80104650 <myproc>
80106467:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010646a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106471:	eb 2a                	jmp    8010649d <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80106473:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106476:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106479:	83 c2 08             	add    $0x8,%edx
8010647c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106480:	85 c0                	test   %eax,%eax
80106482:	75 15                	jne    80106499 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80106484:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106487:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010648a:	8d 4a 08             	lea    0x8(%edx),%ecx
8010648d:	8b 55 08             	mov    0x8(%ebp),%edx
80106490:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80106494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106497:	eb 0f                	jmp    801064a8 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80106499:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010649d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801064a1:	7e d0                	jle    80106473 <fdalloc+0x17>
    }
  }
  return -1;
801064a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801064a8:	c9                   	leave  
801064a9:	c3                   	ret    

801064aa <sys_dup>:

int
sys_dup(void)
{
801064aa:	55                   	push   %ebp
801064ab:	89 e5                	mov    %esp,%ebp
801064ad:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801064b0:	83 ec 04             	sub    $0x4,%esp
801064b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b6:	50                   	push   %eax
801064b7:	6a 00                	push   $0x0
801064b9:	6a 00                	push   $0x0
801064bb:	e8 28 ff ff ff       	call   801063e8 <argfd>
801064c0:	83 c4 10             	add    $0x10,%esp
801064c3:	85 c0                	test   %eax,%eax
801064c5:	79 07                	jns    801064ce <sys_dup+0x24>
    return -1;
801064c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cc:	eb 31                	jmp    801064ff <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801064ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d1:	83 ec 0c             	sub    $0xc,%esp
801064d4:	50                   	push   %eax
801064d5:	e8 82 ff ff ff       	call   8010645c <fdalloc>
801064da:	83 c4 10             	add    $0x10,%esp
801064dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064e4:	79 07                	jns    801064ed <sys_dup+0x43>
    return -1;
801064e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064eb:	eb 12                	jmp    801064ff <sys_dup+0x55>
  filedup(f);
801064ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064f0:	83 ec 0c             	sub    $0xc,%esp
801064f3:	50                   	push   %eax
801064f4:	e8 4b af ff ff       	call   80101444 <filedup>
801064f9:	83 c4 10             	add    $0x10,%esp
  return fd;
801064fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801064ff:	c9                   	leave  
80106500:	c3                   	ret    

80106501 <sys_read>:

int
sys_read(void)
{
80106501:	55                   	push   %ebp
80106502:	89 e5                	mov    %esp,%ebp
80106504:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106507:	83 ec 04             	sub    $0x4,%esp
8010650a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010650d:	50                   	push   %eax
8010650e:	6a 00                	push   $0x0
80106510:	6a 00                	push   $0x0
80106512:	e8 d1 fe ff ff       	call   801063e8 <argfd>
80106517:	83 c4 10             	add    $0x10,%esp
8010651a:	85 c0                	test   %eax,%eax
8010651c:	78 2e                	js     8010654c <sys_read+0x4b>
8010651e:	83 ec 08             	sub    $0x8,%esp
80106521:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106524:	50                   	push   %eax
80106525:	6a 02                	push   $0x2
80106527:	e8 72 fd ff ff       	call   8010629e <argint>
8010652c:	83 c4 10             	add    $0x10,%esp
8010652f:	85 c0                	test   %eax,%eax
80106531:	78 19                	js     8010654c <sys_read+0x4b>
80106533:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106536:	83 ec 04             	sub    $0x4,%esp
80106539:	50                   	push   %eax
8010653a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010653d:	50                   	push   %eax
8010653e:	6a 01                	push   $0x1
80106540:	e8 86 fd ff ff       	call   801062cb <argptr>
80106545:	83 c4 10             	add    $0x10,%esp
80106548:	85 c0                	test   %eax,%eax
8010654a:	79 07                	jns    80106553 <sys_read+0x52>
    return -1;
8010654c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106551:	eb 17                	jmp    8010656a <sys_read+0x69>
  return fileread(f, p, n);
80106553:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106556:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655c:	83 ec 04             	sub    $0x4,%esp
8010655f:	51                   	push   %ecx
80106560:	52                   	push   %edx
80106561:	50                   	push   %eax
80106562:	e8 6d b0 ff ff       	call   801015d4 <fileread>
80106567:	83 c4 10             	add    $0x10,%esp
}
8010656a:	c9                   	leave  
8010656b:	c3                   	ret    

8010656c <sys_write>:

int
sys_write(void)
{
8010656c:	55                   	push   %ebp
8010656d:	89 e5                	mov    %esp,%ebp
8010656f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106572:	83 ec 04             	sub    $0x4,%esp
80106575:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106578:	50                   	push   %eax
80106579:	6a 00                	push   $0x0
8010657b:	6a 00                	push   $0x0
8010657d:	e8 66 fe ff ff       	call   801063e8 <argfd>
80106582:	83 c4 10             	add    $0x10,%esp
80106585:	85 c0                	test   %eax,%eax
80106587:	78 2e                	js     801065b7 <sys_write+0x4b>
80106589:	83 ec 08             	sub    $0x8,%esp
8010658c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010658f:	50                   	push   %eax
80106590:	6a 02                	push   $0x2
80106592:	e8 07 fd ff ff       	call   8010629e <argint>
80106597:	83 c4 10             	add    $0x10,%esp
8010659a:	85 c0                	test   %eax,%eax
8010659c:	78 19                	js     801065b7 <sys_write+0x4b>
8010659e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a1:	83 ec 04             	sub    $0x4,%esp
801065a4:	50                   	push   %eax
801065a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065a8:	50                   	push   %eax
801065a9:	6a 01                	push   $0x1
801065ab:	e8 1b fd ff ff       	call   801062cb <argptr>
801065b0:	83 c4 10             	add    $0x10,%esp
801065b3:	85 c0                	test   %eax,%eax
801065b5:	79 07                	jns    801065be <sys_write+0x52>
    return -1;
801065b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065bc:	eb 17                	jmp    801065d5 <sys_write+0x69>
  return filewrite(f, p, n);
801065be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801065c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801065c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c7:	83 ec 04             	sub    $0x4,%esp
801065ca:	51                   	push   %ecx
801065cb:	52                   	push   %edx
801065cc:	50                   	push   %eax
801065cd:	e8 ba b0 ff ff       	call   8010168c <filewrite>
801065d2:	83 c4 10             	add    $0x10,%esp
}
801065d5:	c9                   	leave  
801065d6:	c3                   	ret    

801065d7 <sys_close>:

int
sys_close(void)
{
801065d7:	55                   	push   %ebp
801065d8:	89 e5                	mov    %esp,%ebp
801065da:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801065dd:	83 ec 04             	sub    $0x4,%esp
801065e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065e3:	50                   	push   %eax
801065e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065e7:	50                   	push   %eax
801065e8:	6a 00                	push   $0x0
801065ea:	e8 f9 fd ff ff       	call   801063e8 <argfd>
801065ef:	83 c4 10             	add    $0x10,%esp
801065f2:	85 c0                	test   %eax,%eax
801065f4:	79 07                	jns    801065fd <sys_close+0x26>
    return -1;
801065f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065fb:	eb 27                	jmp    80106624 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801065fd:	e8 4e e0 ff ff       	call   80104650 <myproc>
80106602:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106605:	83 c2 08             	add    $0x8,%edx
80106608:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010660f:	00 
  fileclose(f);
80106610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106613:	83 ec 0c             	sub    $0xc,%esp
80106616:	50                   	push   %eax
80106617:	e8 79 ae ff ff       	call   80101495 <fileclose>
8010661c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010661f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106624:	c9                   	leave  
80106625:	c3                   	ret    

80106626 <sys_fstat>:

int
sys_fstat(void)
{
80106626:	55                   	push   %ebp
80106627:	89 e5                	mov    %esp,%ebp
80106629:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010662c:	83 ec 04             	sub    $0x4,%esp
8010662f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106632:	50                   	push   %eax
80106633:	6a 00                	push   $0x0
80106635:	6a 00                	push   $0x0
80106637:	e8 ac fd ff ff       	call   801063e8 <argfd>
8010663c:	83 c4 10             	add    $0x10,%esp
8010663f:	85 c0                	test   %eax,%eax
80106641:	78 17                	js     8010665a <sys_fstat+0x34>
80106643:	83 ec 04             	sub    $0x4,%esp
80106646:	6a 14                	push   $0x14
80106648:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010664b:	50                   	push   %eax
8010664c:	6a 01                	push   $0x1
8010664e:	e8 78 fc ff ff       	call   801062cb <argptr>
80106653:	83 c4 10             	add    $0x10,%esp
80106656:	85 c0                	test   %eax,%eax
80106658:	79 07                	jns    80106661 <sys_fstat+0x3b>
    return -1;
8010665a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665f:	eb 13                	jmp    80106674 <sys_fstat+0x4e>
  return filestat(f, st);
80106661:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106667:	83 ec 08             	sub    $0x8,%esp
8010666a:	52                   	push   %edx
8010666b:	50                   	push   %eax
8010666c:	e8 0c af ff ff       	call   8010157d <filestat>
80106671:	83 c4 10             	add    $0x10,%esp
}
80106674:	c9                   	leave  
80106675:	c3                   	ret    

80106676 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106676:	55                   	push   %ebp
80106677:	89 e5                	mov    %esp,%ebp
80106679:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010667c:	83 ec 08             	sub    $0x8,%esp
8010667f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106682:	50                   	push   %eax
80106683:	6a 00                	push   $0x0
80106685:	e8 a9 fc ff ff       	call   80106333 <argstr>
8010668a:	83 c4 10             	add    $0x10,%esp
8010668d:	85 c0                	test   %eax,%eax
8010668f:	78 15                	js     801066a6 <sys_link+0x30>
80106691:	83 ec 08             	sub    $0x8,%esp
80106694:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106697:	50                   	push   %eax
80106698:	6a 01                	push   $0x1
8010669a:	e8 94 fc ff ff       	call   80106333 <argstr>
8010669f:	83 c4 10             	add    $0x10,%esp
801066a2:	85 c0                	test   %eax,%eax
801066a4:	79 0a                	jns    801066b0 <sys_link+0x3a>
    return -1;
801066a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ab:	e9 68 01 00 00       	jmp    80106818 <sys_link+0x1a2>

  begin_op();
801066b0:	e8 34 d2 ff ff       	call   801038e9 <begin_op>
  if((ip = namei(old)) == 0){
801066b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801066b8:	83 ec 0c             	sub    $0xc,%esp
801066bb:	50                   	push   %eax
801066bc:	e8 43 c2 ff ff       	call   80102904 <namei>
801066c1:	83 c4 10             	add    $0x10,%esp
801066c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066cb:	75 0f                	jne    801066dc <sys_link+0x66>
    end_op();
801066cd:	e8 a3 d2 ff ff       	call   80103975 <end_op>
    return -1;
801066d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066d7:	e9 3c 01 00 00       	jmp    80106818 <sys_link+0x1a2>
  }

  ilock(ip);
801066dc:	83 ec 0c             	sub    $0xc,%esp
801066df:	ff 75 f4             	push   -0xc(%ebp)
801066e2:	e8 ea b6 ff ff       	call   80101dd1 <ilock>
801066e7:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801066ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ed:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801066f1:	66 83 f8 01          	cmp    $0x1,%ax
801066f5:	75 1d                	jne    80106714 <sys_link+0x9e>
    iunlockput(ip);
801066f7:	83 ec 0c             	sub    $0xc,%esp
801066fa:	ff 75 f4             	push   -0xc(%ebp)
801066fd:	e8 00 b9 ff ff       	call   80102002 <iunlockput>
80106702:	83 c4 10             	add    $0x10,%esp
    end_op();
80106705:	e8 6b d2 ff ff       	call   80103975 <end_op>
    return -1;
8010670a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010670f:	e9 04 01 00 00       	jmp    80106818 <sys_link+0x1a2>
  }

  ip->nlink++;
80106714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106717:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010671b:	83 c0 01             	add    $0x1,%eax
8010671e:	89 c2                	mov    %eax,%edx
80106720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106723:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106727:	83 ec 0c             	sub    $0xc,%esp
8010672a:	ff 75 f4             	push   -0xc(%ebp)
8010672d:	e8 c2 b4 ff ff       	call   80101bf4 <iupdate>
80106732:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80106735:	83 ec 0c             	sub    $0xc,%esp
80106738:	ff 75 f4             	push   -0xc(%ebp)
8010673b:	e8 a4 b7 ff ff       	call   80101ee4 <iunlock>
80106740:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80106743:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106746:	83 ec 08             	sub    $0x8,%esp
80106749:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010674c:	52                   	push   %edx
8010674d:	50                   	push   %eax
8010674e:	e8 cd c1 ff ff       	call   80102920 <nameiparent>
80106753:	83 c4 10             	add    $0x10,%esp
80106756:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106759:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010675d:	74 71                	je     801067d0 <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010675f:	83 ec 0c             	sub    $0xc,%esp
80106762:	ff 75 f0             	push   -0x10(%ebp)
80106765:	e8 67 b6 ff ff       	call   80101dd1 <ilock>
8010676a:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010676d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106770:	8b 10                	mov    (%eax),%edx
80106772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106775:	8b 00                	mov    (%eax),%eax
80106777:	39 c2                	cmp    %eax,%edx
80106779:	75 1d                	jne    80106798 <sys_link+0x122>
8010677b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677e:	8b 40 04             	mov    0x4(%eax),%eax
80106781:	83 ec 04             	sub    $0x4,%esp
80106784:	50                   	push   %eax
80106785:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106788:	50                   	push   %eax
80106789:	ff 75 f0             	push   -0x10(%ebp)
8010678c:	e8 dc be ff ff       	call   8010266d <dirlink>
80106791:	83 c4 10             	add    $0x10,%esp
80106794:	85 c0                	test   %eax,%eax
80106796:	79 10                	jns    801067a8 <sys_link+0x132>
    iunlockput(dp);
80106798:	83 ec 0c             	sub    $0xc,%esp
8010679b:	ff 75 f0             	push   -0x10(%ebp)
8010679e:	e8 5f b8 ff ff       	call   80102002 <iunlockput>
801067a3:	83 c4 10             	add    $0x10,%esp
    goto bad;
801067a6:	eb 29                	jmp    801067d1 <sys_link+0x15b>
  }
  iunlockput(dp);
801067a8:	83 ec 0c             	sub    $0xc,%esp
801067ab:	ff 75 f0             	push   -0x10(%ebp)
801067ae:	e8 4f b8 ff ff       	call   80102002 <iunlockput>
801067b3:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801067b6:	83 ec 0c             	sub    $0xc,%esp
801067b9:	ff 75 f4             	push   -0xc(%ebp)
801067bc:	e8 71 b7 ff ff       	call   80101f32 <iput>
801067c1:	83 c4 10             	add    $0x10,%esp

  end_op();
801067c4:	e8 ac d1 ff ff       	call   80103975 <end_op>

  return 0;
801067c9:	b8 00 00 00 00       	mov    $0x0,%eax
801067ce:	eb 48                	jmp    80106818 <sys_link+0x1a2>
    goto bad;
801067d0:	90                   	nop

bad:
  ilock(ip);
801067d1:	83 ec 0c             	sub    $0xc,%esp
801067d4:	ff 75 f4             	push   -0xc(%ebp)
801067d7:	e8 f5 b5 ff ff       	call   80101dd1 <ilock>
801067dc:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801067df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801067e6:	83 e8 01             	sub    $0x1,%eax
801067e9:	89 c2                	mov    %eax,%edx
801067eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ee:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801067f2:	83 ec 0c             	sub    $0xc,%esp
801067f5:	ff 75 f4             	push   -0xc(%ebp)
801067f8:	e8 f7 b3 ff ff       	call   80101bf4 <iupdate>
801067fd:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106800:	83 ec 0c             	sub    $0xc,%esp
80106803:	ff 75 f4             	push   -0xc(%ebp)
80106806:	e8 f7 b7 ff ff       	call   80102002 <iunlockput>
8010680b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010680e:	e8 62 d1 ff ff       	call   80103975 <end_op>
  return -1;
80106813:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106818:	c9                   	leave  
80106819:	c3                   	ret    

8010681a <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010681a:	55                   	push   %ebp
8010681b:	89 e5                	mov    %esp,%ebp
8010681d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106820:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106827:	eb 40                	jmp    80106869 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682c:	6a 10                	push   $0x10
8010682e:	50                   	push   %eax
8010682f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106832:	50                   	push   %eax
80106833:	ff 75 08             	push   0x8(%ebp)
80106836:	e8 82 ba ff ff       	call   801022bd <readi>
8010683b:	83 c4 10             	add    $0x10,%esp
8010683e:	83 f8 10             	cmp    $0x10,%eax
80106841:	74 0d                	je     80106850 <isdirempty+0x36>
      panic("isdirempty: readi");
80106843:	83 ec 0c             	sub    $0xc,%esp
80106846:	68 1f 98 10 80       	push   $0x8010981f
8010684b:	e8 65 9d ff ff       	call   801005b5 <panic>
    if(de.inum != 0)
80106850:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106854:	66 85 c0             	test   %ax,%ax
80106857:	74 07                	je     80106860 <isdirempty+0x46>
      return 0;
80106859:	b8 00 00 00 00       	mov    $0x0,%eax
8010685e:	eb 1b                	jmp    8010687b <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106863:	83 c0 10             	add    $0x10,%eax
80106866:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106869:	8b 45 08             	mov    0x8(%ebp),%eax
8010686c:	8b 50 58             	mov    0x58(%eax),%edx
8010686f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106872:	39 c2                	cmp    %eax,%edx
80106874:	77 b3                	ja     80106829 <isdirempty+0xf>
  }
  return 1;
80106876:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010687b:	c9                   	leave  
8010687c:	c3                   	ret    

8010687d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010687d:	55                   	push   %ebp
8010687e:	89 e5                	mov    %esp,%ebp
80106880:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106883:	83 ec 08             	sub    $0x8,%esp
80106886:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106889:	50                   	push   %eax
8010688a:	6a 00                	push   $0x0
8010688c:	e8 a2 fa ff ff       	call   80106333 <argstr>
80106891:	83 c4 10             	add    $0x10,%esp
80106894:	85 c0                	test   %eax,%eax
80106896:	79 0a                	jns    801068a2 <sys_unlink+0x25>
    return -1;
80106898:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010689d:	e9 bf 01 00 00       	jmp    80106a61 <sys_unlink+0x1e4>

  begin_op();
801068a2:	e8 42 d0 ff ff       	call   801038e9 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801068a7:	8b 45 cc             	mov    -0x34(%ebp),%eax
801068aa:	83 ec 08             	sub    $0x8,%esp
801068ad:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801068b0:	52                   	push   %edx
801068b1:	50                   	push   %eax
801068b2:	e8 69 c0 ff ff       	call   80102920 <nameiparent>
801068b7:	83 c4 10             	add    $0x10,%esp
801068ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068c1:	75 0f                	jne    801068d2 <sys_unlink+0x55>
    end_op();
801068c3:	e8 ad d0 ff ff       	call   80103975 <end_op>
    return -1;
801068c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068cd:	e9 8f 01 00 00       	jmp    80106a61 <sys_unlink+0x1e4>
  }

  ilock(dp);
801068d2:	83 ec 0c             	sub    $0xc,%esp
801068d5:	ff 75 f4             	push   -0xc(%ebp)
801068d8:	e8 f4 b4 ff ff       	call   80101dd1 <ilock>
801068dd:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801068e0:	83 ec 08             	sub    $0x8,%esp
801068e3:	68 31 98 10 80       	push   $0x80109831
801068e8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801068eb:	50                   	push   %eax
801068ec:	e8 a7 bc ff ff       	call   80102598 <namecmp>
801068f1:	83 c4 10             	add    $0x10,%esp
801068f4:	85 c0                	test   %eax,%eax
801068f6:	0f 84 49 01 00 00    	je     80106a45 <sys_unlink+0x1c8>
801068fc:	83 ec 08             	sub    $0x8,%esp
801068ff:	68 33 98 10 80       	push   $0x80109833
80106904:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106907:	50                   	push   %eax
80106908:	e8 8b bc ff ff       	call   80102598 <namecmp>
8010690d:	83 c4 10             	add    $0x10,%esp
80106910:	85 c0                	test   %eax,%eax
80106912:	0f 84 2d 01 00 00    	je     80106a45 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106918:	83 ec 04             	sub    $0x4,%esp
8010691b:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010691e:	50                   	push   %eax
8010691f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106922:	50                   	push   %eax
80106923:	ff 75 f4             	push   -0xc(%ebp)
80106926:	e8 88 bc ff ff       	call   801025b3 <dirlookup>
8010692b:	83 c4 10             	add    $0x10,%esp
8010692e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106931:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106935:	0f 84 0d 01 00 00    	je     80106a48 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010693b:	83 ec 0c             	sub    $0xc,%esp
8010693e:	ff 75 f0             	push   -0x10(%ebp)
80106941:	e8 8b b4 ff ff       	call   80101dd1 <ilock>
80106946:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010694c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106950:	66 85 c0             	test   %ax,%ax
80106953:	7f 0d                	jg     80106962 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106955:	83 ec 0c             	sub    $0xc,%esp
80106958:	68 36 98 10 80       	push   $0x80109836
8010695d:	e8 53 9c ff ff       	call   801005b5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106962:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106965:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106969:	66 83 f8 01          	cmp    $0x1,%ax
8010696d:	75 25                	jne    80106994 <sys_unlink+0x117>
8010696f:	83 ec 0c             	sub    $0xc,%esp
80106972:	ff 75 f0             	push   -0x10(%ebp)
80106975:	e8 a0 fe ff ff       	call   8010681a <isdirempty>
8010697a:	83 c4 10             	add    $0x10,%esp
8010697d:	85 c0                	test   %eax,%eax
8010697f:	75 13                	jne    80106994 <sys_unlink+0x117>
    iunlockput(ip);
80106981:	83 ec 0c             	sub    $0xc,%esp
80106984:	ff 75 f0             	push   -0x10(%ebp)
80106987:	e8 76 b6 ff ff       	call   80102002 <iunlockput>
8010698c:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010698f:	e9 b5 00 00 00       	jmp    80106a49 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80106994:	83 ec 04             	sub    $0x4,%esp
80106997:	6a 10                	push   $0x10
80106999:	6a 00                	push   $0x0
8010699b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010699e:	50                   	push   %eax
8010699f:	e8 cf f5 ff ff       	call   80105f73 <memset>
801069a4:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801069a7:	8b 45 c8             	mov    -0x38(%ebp),%eax
801069aa:	6a 10                	push   $0x10
801069ac:	50                   	push   %eax
801069ad:	8d 45 e0             	lea    -0x20(%ebp),%eax
801069b0:	50                   	push   %eax
801069b1:	ff 75 f4             	push   -0xc(%ebp)
801069b4:	e8 59 ba ff ff       	call   80102412 <writei>
801069b9:	83 c4 10             	add    $0x10,%esp
801069bc:	83 f8 10             	cmp    $0x10,%eax
801069bf:	74 0d                	je     801069ce <sys_unlink+0x151>
    panic("unlink: writei");
801069c1:	83 ec 0c             	sub    $0xc,%esp
801069c4:	68 48 98 10 80       	push   $0x80109848
801069c9:	e8 e7 9b ff ff       	call   801005b5 <panic>
  if(ip->type == T_DIR){
801069ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069d1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801069d5:	66 83 f8 01          	cmp    $0x1,%ax
801069d9:	75 21                	jne    801069fc <sys_unlink+0x17f>
    dp->nlink--;
801069db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069de:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801069e2:	83 e8 01             	sub    $0x1,%eax
801069e5:	89 c2                	mov    %eax,%edx
801069e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ea:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801069ee:	83 ec 0c             	sub    $0xc,%esp
801069f1:	ff 75 f4             	push   -0xc(%ebp)
801069f4:	e8 fb b1 ff ff       	call   80101bf4 <iupdate>
801069f9:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801069fc:	83 ec 0c             	sub    $0xc,%esp
801069ff:	ff 75 f4             	push   -0xc(%ebp)
80106a02:	e8 fb b5 ff ff       	call   80102002 <iunlockput>
80106a07:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a0d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106a11:	83 e8 01             	sub    $0x1,%eax
80106a14:	89 c2                	mov    %eax,%edx
80106a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a19:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106a1d:	83 ec 0c             	sub    $0xc,%esp
80106a20:	ff 75 f0             	push   -0x10(%ebp)
80106a23:	e8 cc b1 ff ff       	call   80101bf4 <iupdate>
80106a28:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106a2b:	83 ec 0c             	sub    $0xc,%esp
80106a2e:	ff 75 f0             	push   -0x10(%ebp)
80106a31:	e8 cc b5 ff ff       	call   80102002 <iunlockput>
80106a36:	83 c4 10             	add    $0x10,%esp

  end_op();
80106a39:	e8 37 cf ff ff       	call   80103975 <end_op>

  return 0;
80106a3e:	b8 00 00 00 00       	mov    $0x0,%eax
80106a43:	eb 1c                	jmp    80106a61 <sys_unlink+0x1e4>
    goto bad;
80106a45:	90                   	nop
80106a46:	eb 01                	jmp    80106a49 <sys_unlink+0x1cc>
    goto bad;
80106a48:	90                   	nop

bad:
  iunlockput(dp);
80106a49:	83 ec 0c             	sub    $0xc,%esp
80106a4c:	ff 75 f4             	push   -0xc(%ebp)
80106a4f:	e8 ae b5 ff ff       	call   80102002 <iunlockput>
80106a54:	83 c4 10             	add    $0x10,%esp
  end_op();
80106a57:	e8 19 cf ff ff       	call   80103975 <end_op>
  return -1;
80106a5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106a61:	c9                   	leave  
80106a62:	c3                   	ret    

80106a63 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106a63:	55                   	push   %ebp
80106a64:	89 e5                	mov    %esp,%ebp
80106a66:	83 ec 38             	sub    $0x38,%esp
80106a69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106a6c:	8b 55 10             	mov    0x10(%ebp),%edx
80106a6f:	8b 45 14             	mov    0x14(%ebp),%eax
80106a72:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106a76:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106a7a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106a7e:	83 ec 08             	sub    $0x8,%esp
80106a81:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106a84:	50                   	push   %eax
80106a85:	ff 75 08             	push   0x8(%ebp)
80106a88:	e8 93 be ff ff       	call   80102920 <nameiparent>
80106a8d:	83 c4 10             	add    $0x10,%esp
80106a90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a97:	75 0a                	jne    80106aa3 <create+0x40>
    return 0;
80106a99:	b8 00 00 00 00       	mov    $0x0,%eax
80106a9e:	e9 8e 01 00 00       	jmp    80106c31 <create+0x1ce>
  ilock(dp);
80106aa3:	83 ec 0c             	sub    $0xc,%esp
80106aa6:	ff 75 f4             	push   -0xc(%ebp)
80106aa9:	e8 23 b3 ff ff       	call   80101dd1 <ilock>
80106aae:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80106ab1:	83 ec 04             	sub    $0x4,%esp
80106ab4:	6a 00                	push   $0x0
80106ab6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106ab9:	50                   	push   %eax
80106aba:	ff 75 f4             	push   -0xc(%ebp)
80106abd:	e8 f1 ba ff ff       	call   801025b3 <dirlookup>
80106ac2:	83 c4 10             	add    $0x10,%esp
80106ac5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ac8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106acc:	74 50                	je     80106b1e <create+0xbb>
    iunlockput(dp);
80106ace:	83 ec 0c             	sub    $0xc,%esp
80106ad1:	ff 75 f4             	push   -0xc(%ebp)
80106ad4:	e8 29 b5 ff ff       	call   80102002 <iunlockput>
80106ad9:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106adc:	83 ec 0c             	sub    $0xc,%esp
80106adf:	ff 75 f0             	push   -0x10(%ebp)
80106ae2:	e8 ea b2 ff ff       	call   80101dd1 <ilock>
80106ae7:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106aea:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106aef:	75 15                	jne    80106b06 <create+0xa3>
80106af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106af4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106af8:	66 83 f8 02          	cmp    $0x2,%ax
80106afc:	75 08                	jne    80106b06 <create+0xa3>
      return ip;
80106afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b01:	e9 2b 01 00 00       	jmp    80106c31 <create+0x1ce>
    iunlockput(ip);
80106b06:	83 ec 0c             	sub    $0xc,%esp
80106b09:	ff 75 f0             	push   -0x10(%ebp)
80106b0c:	e8 f1 b4 ff ff       	call   80102002 <iunlockput>
80106b11:	83 c4 10             	add    $0x10,%esp
    return 0;
80106b14:	b8 00 00 00 00       	mov    $0x0,%eax
80106b19:	e9 13 01 00 00       	jmp    80106c31 <create+0x1ce>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106b1e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b25:	8b 00                	mov    (%eax),%eax
80106b27:	83 ec 08             	sub    $0x8,%esp
80106b2a:	52                   	push   %edx
80106b2b:	50                   	push   %eax
80106b2c:	e8 ec af ff ff       	call   80101b1d <ialloc>
80106b31:	83 c4 10             	add    $0x10,%esp
80106b34:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b3b:	75 0d                	jne    80106b4a <create+0xe7>
    panic("create: ialloc");
80106b3d:	83 ec 0c             	sub    $0xc,%esp
80106b40:	68 57 98 10 80       	push   $0x80109857
80106b45:	e8 6b 9a ff ff       	call   801005b5 <panic>

  ilock(ip);
80106b4a:	83 ec 0c             	sub    $0xc,%esp
80106b4d:	ff 75 f0             	push   -0x10(%ebp)
80106b50:	e8 7c b2 ff ff       	call   80101dd1 <ilock>
80106b55:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b5b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106b5f:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80106b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b66:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106b6a:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b71:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106b77:	83 ec 0c             	sub    $0xc,%esp
80106b7a:	ff 75 f0             	push   -0x10(%ebp)
80106b7d:	e8 72 b0 ff ff       	call   80101bf4 <iupdate>
80106b82:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106b85:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106b8a:	75 6a                	jne    80106bf6 <create+0x193>
    dp->nlink++;  // for ".."
80106b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106b93:	83 c0 01             	add    $0x1,%eax
80106b96:	89 c2                	mov    %eax,%edx
80106b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9b:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106b9f:	83 ec 0c             	sub    $0xc,%esp
80106ba2:	ff 75 f4             	push   -0xc(%ebp)
80106ba5:	e8 4a b0 ff ff       	call   80101bf4 <iupdate>
80106baa:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bb0:	8b 40 04             	mov    0x4(%eax),%eax
80106bb3:	83 ec 04             	sub    $0x4,%esp
80106bb6:	50                   	push   %eax
80106bb7:	68 31 98 10 80       	push   $0x80109831
80106bbc:	ff 75 f0             	push   -0x10(%ebp)
80106bbf:	e8 a9 ba ff ff       	call   8010266d <dirlink>
80106bc4:	83 c4 10             	add    $0x10,%esp
80106bc7:	85 c0                	test   %eax,%eax
80106bc9:	78 1e                	js     80106be9 <create+0x186>
80106bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bce:	8b 40 04             	mov    0x4(%eax),%eax
80106bd1:	83 ec 04             	sub    $0x4,%esp
80106bd4:	50                   	push   %eax
80106bd5:	68 33 98 10 80       	push   $0x80109833
80106bda:	ff 75 f0             	push   -0x10(%ebp)
80106bdd:	e8 8b ba ff ff       	call   8010266d <dirlink>
80106be2:	83 c4 10             	add    $0x10,%esp
80106be5:	85 c0                	test   %eax,%eax
80106be7:	79 0d                	jns    80106bf6 <create+0x193>
      panic("create dots");
80106be9:	83 ec 0c             	sub    $0xc,%esp
80106bec:	68 66 98 10 80       	push   $0x80109866
80106bf1:	e8 bf 99 ff ff       	call   801005b5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bf9:	8b 40 04             	mov    0x4(%eax),%eax
80106bfc:	83 ec 04             	sub    $0x4,%esp
80106bff:	50                   	push   %eax
80106c00:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106c03:	50                   	push   %eax
80106c04:	ff 75 f4             	push   -0xc(%ebp)
80106c07:	e8 61 ba ff ff       	call   8010266d <dirlink>
80106c0c:	83 c4 10             	add    $0x10,%esp
80106c0f:	85 c0                	test   %eax,%eax
80106c11:	79 0d                	jns    80106c20 <create+0x1bd>
    panic("create: dirlink");
80106c13:	83 ec 0c             	sub    $0xc,%esp
80106c16:	68 72 98 10 80       	push   $0x80109872
80106c1b:	e8 95 99 ff ff       	call   801005b5 <panic>

  iunlockput(dp);
80106c20:	83 ec 0c             	sub    $0xc,%esp
80106c23:	ff 75 f4             	push   -0xc(%ebp)
80106c26:	e8 d7 b3 ff ff       	call   80102002 <iunlockput>
80106c2b:	83 c4 10             	add    $0x10,%esp

  return ip;
80106c2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106c31:	c9                   	leave  
80106c32:	c3                   	ret    

80106c33 <sys_open>:

int
sys_open(void)
{
80106c33:	55                   	push   %ebp
80106c34:	89 e5                	mov    %esp,%ebp
80106c36:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106c39:	83 ec 08             	sub    $0x8,%esp
80106c3c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106c3f:	50                   	push   %eax
80106c40:	6a 00                	push   $0x0
80106c42:	e8 ec f6 ff ff       	call   80106333 <argstr>
80106c47:	83 c4 10             	add    $0x10,%esp
80106c4a:	85 c0                	test   %eax,%eax
80106c4c:	78 15                	js     80106c63 <sys_open+0x30>
80106c4e:	83 ec 08             	sub    $0x8,%esp
80106c51:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106c54:	50                   	push   %eax
80106c55:	6a 01                	push   $0x1
80106c57:	e8 42 f6 ff ff       	call   8010629e <argint>
80106c5c:	83 c4 10             	add    $0x10,%esp
80106c5f:	85 c0                	test   %eax,%eax
80106c61:	79 0a                	jns    80106c6d <sys_open+0x3a>
    return -1;
80106c63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c68:	e9 61 01 00 00       	jmp    80106dce <sys_open+0x19b>

  begin_op();
80106c6d:	e8 77 cc ff ff       	call   801038e9 <begin_op>

  if(omode & O_CREATE){
80106c72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c75:	25 00 02 00 00       	and    $0x200,%eax
80106c7a:	85 c0                	test   %eax,%eax
80106c7c:	74 2a                	je     80106ca8 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106c7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c81:	6a 00                	push   $0x0
80106c83:	6a 00                	push   $0x0
80106c85:	6a 02                	push   $0x2
80106c87:	50                   	push   %eax
80106c88:	e8 d6 fd ff ff       	call   80106a63 <create>
80106c8d:	83 c4 10             	add    $0x10,%esp
80106c90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106c93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c97:	75 75                	jne    80106d0e <sys_open+0xdb>
      end_op();
80106c99:	e8 d7 cc ff ff       	call   80103975 <end_op>
      return -1;
80106c9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ca3:	e9 26 01 00 00       	jmp    80106dce <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106ca8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106cab:	83 ec 0c             	sub    $0xc,%esp
80106cae:	50                   	push   %eax
80106caf:	e8 50 bc ff ff       	call   80102904 <namei>
80106cb4:	83 c4 10             	add    $0x10,%esp
80106cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cbe:	75 0f                	jne    80106ccf <sys_open+0x9c>
      end_op();
80106cc0:	e8 b0 cc ff ff       	call   80103975 <end_op>
      return -1;
80106cc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cca:	e9 ff 00 00 00       	jmp    80106dce <sys_open+0x19b>
    }
    ilock(ip);
80106ccf:	83 ec 0c             	sub    $0xc,%esp
80106cd2:	ff 75 f4             	push   -0xc(%ebp)
80106cd5:	e8 f7 b0 ff ff       	call   80101dd1 <ilock>
80106cda:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ce0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106ce4:	66 83 f8 01          	cmp    $0x1,%ax
80106ce8:	75 24                	jne    80106d0e <sys_open+0xdb>
80106cea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ced:	85 c0                	test   %eax,%eax
80106cef:	74 1d                	je     80106d0e <sys_open+0xdb>
      iunlockput(ip);
80106cf1:	83 ec 0c             	sub    $0xc,%esp
80106cf4:	ff 75 f4             	push   -0xc(%ebp)
80106cf7:	e8 06 b3 ff ff       	call   80102002 <iunlockput>
80106cfc:	83 c4 10             	add    $0x10,%esp
      end_op();
80106cff:	e8 71 cc ff ff       	call   80103975 <end_op>
      return -1;
80106d04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d09:	e9 c0 00 00 00       	jmp    80106dce <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106d0e:	e8 c4 a6 ff ff       	call   801013d7 <filealloc>
80106d13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d1a:	74 17                	je     80106d33 <sys_open+0x100>
80106d1c:	83 ec 0c             	sub    $0xc,%esp
80106d1f:	ff 75 f0             	push   -0x10(%ebp)
80106d22:	e8 35 f7 ff ff       	call   8010645c <fdalloc>
80106d27:	83 c4 10             	add    $0x10,%esp
80106d2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106d2d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106d31:	79 2e                	jns    80106d61 <sys_open+0x12e>
    if(f)
80106d33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d37:	74 0e                	je     80106d47 <sys_open+0x114>
      fileclose(f);
80106d39:	83 ec 0c             	sub    $0xc,%esp
80106d3c:	ff 75 f0             	push   -0x10(%ebp)
80106d3f:	e8 51 a7 ff ff       	call   80101495 <fileclose>
80106d44:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106d47:	83 ec 0c             	sub    $0xc,%esp
80106d4a:	ff 75 f4             	push   -0xc(%ebp)
80106d4d:	e8 b0 b2 ff ff       	call   80102002 <iunlockput>
80106d52:	83 c4 10             	add    $0x10,%esp
    end_op();
80106d55:	e8 1b cc ff ff       	call   80103975 <end_op>
    return -1;
80106d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d5f:	eb 6d                	jmp    80106dce <sys_open+0x19b>
  }
  iunlock(ip);
80106d61:	83 ec 0c             	sub    $0xc,%esp
80106d64:	ff 75 f4             	push   -0xc(%ebp)
80106d67:	e8 78 b1 ff ff       	call   80101ee4 <iunlock>
80106d6c:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d6f:	e8 01 cc ff ff       	call   80103975 <end_op>

  f->type = FD_INODE;
80106d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d77:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d83:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106d86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d89:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106d90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d93:	83 e0 01             	and    $0x1,%eax
80106d96:	85 c0                	test   %eax,%eax
80106d98:	0f 94 c0             	sete   %al
80106d9b:	89 c2                	mov    %eax,%edx
80106d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106da0:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106da3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106da6:	83 e0 01             	and    $0x1,%eax
80106da9:	85 c0                	test   %eax,%eax
80106dab:	75 0a                	jne    80106db7 <sys_open+0x184>
80106dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106db0:	83 e0 02             	and    $0x2,%eax
80106db3:	85 c0                	test   %eax,%eax
80106db5:	74 07                	je     80106dbe <sys_open+0x18b>
80106db7:	b8 01 00 00 00       	mov    $0x1,%eax
80106dbc:	eb 05                	jmp    80106dc3 <sys_open+0x190>
80106dbe:	b8 00 00 00 00       	mov    $0x0,%eax
80106dc3:	89 c2                	mov    %eax,%edx
80106dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc8:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106dcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106dce:	c9                   	leave  
80106dcf:	c3                   	ret    

80106dd0 <sys_mkdir>:

int
sys_mkdir(void)
{
80106dd0:	55                   	push   %ebp
80106dd1:	89 e5                	mov    %esp,%ebp
80106dd3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106dd6:	e8 0e cb ff ff       	call   801038e9 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106ddb:	83 ec 08             	sub    $0x8,%esp
80106dde:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106de1:	50                   	push   %eax
80106de2:	6a 00                	push   $0x0
80106de4:	e8 4a f5 ff ff       	call   80106333 <argstr>
80106de9:	83 c4 10             	add    $0x10,%esp
80106dec:	85 c0                	test   %eax,%eax
80106dee:	78 1b                	js     80106e0b <sys_mkdir+0x3b>
80106df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106df3:	6a 00                	push   $0x0
80106df5:	6a 00                	push   $0x0
80106df7:	6a 01                	push   $0x1
80106df9:	50                   	push   %eax
80106dfa:	e8 64 fc ff ff       	call   80106a63 <create>
80106dff:	83 c4 10             	add    $0x10,%esp
80106e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e09:	75 0c                	jne    80106e17 <sys_mkdir+0x47>
    end_op();
80106e0b:	e8 65 cb ff ff       	call   80103975 <end_op>
    return -1;
80106e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e15:	eb 18                	jmp    80106e2f <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106e17:	83 ec 0c             	sub    $0xc,%esp
80106e1a:	ff 75 f4             	push   -0xc(%ebp)
80106e1d:	e8 e0 b1 ff ff       	call   80102002 <iunlockput>
80106e22:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e25:	e8 4b cb ff ff       	call   80103975 <end_op>
  return 0;
80106e2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e2f:	c9                   	leave  
80106e30:	c3                   	ret    

80106e31 <sys_mknod>:

int
sys_mknod(void)
{
80106e31:	55                   	push   %ebp
80106e32:	89 e5                	mov    %esp,%ebp
80106e34:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106e37:	e8 ad ca ff ff       	call   801038e9 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106e3c:	83 ec 08             	sub    $0x8,%esp
80106e3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e42:	50                   	push   %eax
80106e43:	6a 00                	push   $0x0
80106e45:	e8 e9 f4 ff ff       	call   80106333 <argstr>
80106e4a:	83 c4 10             	add    $0x10,%esp
80106e4d:	85 c0                	test   %eax,%eax
80106e4f:	78 4f                	js     80106ea0 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80106e51:	83 ec 08             	sub    $0x8,%esp
80106e54:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e57:	50                   	push   %eax
80106e58:	6a 01                	push   $0x1
80106e5a:	e8 3f f4 ff ff       	call   8010629e <argint>
80106e5f:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106e62:	85 c0                	test   %eax,%eax
80106e64:	78 3a                	js     80106ea0 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80106e66:	83 ec 08             	sub    $0x8,%esp
80106e69:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e6c:	50                   	push   %eax
80106e6d:	6a 02                	push   $0x2
80106e6f:	e8 2a f4 ff ff       	call   8010629e <argint>
80106e74:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106e77:	85 c0                	test   %eax,%eax
80106e79:	78 25                	js     80106ea0 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106e7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106e7e:	0f bf c8             	movswl %ax,%ecx
80106e81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106e84:	0f bf d0             	movswl %ax,%edx
80106e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e8a:	51                   	push   %ecx
80106e8b:	52                   	push   %edx
80106e8c:	6a 03                	push   $0x3
80106e8e:	50                   	push   %eax
80106e8f:	e8 cf fb ff ff       	call   80106a63 <create>
80106e94:	83 c4 10             	add    $0x10,%esp
80106e97:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106e9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e9e:	75 0c                	jne    80106eac <sys_mknod+0x7b>
    end_op();
80106ea0:	e8 d0 ca ff ff       	call   80103975 <end_op>
    return -1;
80106ea5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106eaa:	eb 18                	jmp    80106ec4 <sys_mknod+0x93>
  }
  iunlockput(ip);
80106eac:	83 ec 0c             	sub    $0xc,%esp
80106eaf:	ff 75 f4             	push   -0xc(%ebp)
80106eb2:	e8 4b b1 ff ff       	call   80102002 <iunlockput>
80106eb7:	83 c4 10             	add    $0x10,%esp
  end_op();
80106eba:	e8 b6 ca ff ff       	call   80103975 <end_op>
  return 0;
80106ebf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ec4:	c9                   	leave  
80106ec5:	c3                   	ret    

80106ec6 <sys_chdir>:

int
sys_chdir(void)
{
80106ec6:	55                   	push   %ebp
80106ec7:	89 e5                	mov    %esp,%ebp
80106ec9:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106ecc:	e8 7f d7 ff ff       	call   80104650 <myproc>
80106ed1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106ed4:	e8 10 ca ff ff       	call   801038e9 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106ed9:	83 ec 08             	sub    $0x8,%esp
80106edc:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106edf:	50                   	push   %eax
80106ee0:	6a 00                	push   $0x0
80106ee2:	e8 4c f4 ff ff       	call   80106333 <argstr>
80106ee7:	83 c4 10             	add    $0x10,%esp
80106eea:	85 c0                	test   %eax,%eax
80106eec:	78 18                	js     80106f06 <sys_chdir+0x40>
80106eee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106ef1:	83 ec 0c             	sub    $0xc,%esp
80106ef4:	50                   	push   %eax
80106ef5:	e8 0a ba ff ff       	call   80102904 <namei>
80106efa:	83 c4 10             	add    $0x10,%esp
80106efd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106f00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106f04:	75 0c                	jne    80106f12 <sys_chdir+0x4c>
    end_op();
80106f06:	e8 6a ca ff ff       	call   80103975 <end_op>
    return -1;
80106f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f10:	eb 68                	jmp    80106f7a <sys_chdir+0xb4>
  }
  ilock(ip);
80106f12:	83 ec 0c             	sub    $0xc,%esp
80106f15:	ff 75 f0             	push   -0x10(%ebp)
80106f18:	e8 b4 ae ff ff       	call   80101dd1 <ilock>
80106f1d:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f23:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106f27:	66 83 f8 01          	cmp    $0x1,%ax
80106f2b:	74 1a                	je     80106f47 <sys_chdir+0x81>
    iunlockput(ip);
80106f2d:	83 ec 0c             	sub    $0xc,%esp
80106f30:	ff 75 f0             	push   -0x10(%ebp)
80106f33:	e8 ca b0 ff ff       	call   80102002 <iunlockput>
80106f38:	83 c4 10             	add    $0x10,%esp
    end_op();
80106f3b:	e8 35 ca ff ff       	call   80103975 <end_op>
    return -1;
80106f40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f45:	eb 33                	jmp    80106f7a <sys_chdir+0xb4>
  }
  iunlock(ip);
80106f47:	83 ec 0c             	sub    $0xc,%esp
80106f4a:	ff 75 f0             	push   -0x10(%ebp)
80106f4d:	e8 92 af ff ff       	call   80101ee4 <iunlock>
80106f52:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f58:	8b 40 68             	mov    0x68(%eax),%eax
80106f5b:	83 ec 0c             	sub    $0xc,%esp
80106f5e:	50                   	push   %eax
80106f5f:	e8 ce af ff ff       	call   80101f32 <iput>
80106f64:	83 c4 10             	add    $0x10,%esp
  end_op();
80106f67:	e8 09 ca ff ff       	call   80103975 <end_op>
  curproc->cwd = ip;
80106f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f6f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f72:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106f75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f7a:	c9                   	leave  
80106f7b:	c3                   	ret    

80106f7c <sys_exec>:

int
sys_exec(void)
{
80106f7c:	55                   	push   %ebp
80106f7d:	89 e5                	mov    %esp,%ebp
80106f7f:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106f85:	83 ec 08             	sub    $0x8,%esp
80106f88:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f8b:	50                   	push   %eax
80106f8c:	6a 00                	push   $0x0
80106f8e:	e8 a0 f3 ff ff       	call   80106333 <argstr>
80106f93:	83 c4 10             	add    $0x10,%esp
80106f96:	85 c0                	test   %eax,%eax
80106f98:	78 18                	js     80106fb2 <sys_exec+0x36>
80106f9a:	83 ec 08             	sub    $0x8,%esp
80106f9d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106fa3:	50                   	push   %eax
80106fa4:	6a 01                	push   $0x1
80106fa6:	e8 f3 f2 ff ff       	call   8010629e <argint>
80106fab:	83 c4 10             	add    $0x10,%esp
80106fae:	85 c0                	test   %eax,%eax
80106fb0:	79 0a                	jns    80106fbc <sys_exec+0x40>
    return -1;
80106fb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fb7:	e9 c6 00 00 00       	jmp    80107082 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106fbc:	83 ec 04             	sub    $0x4,%esp
80106fbf:	68 80 00 00 00       	push   $0x80
80106fc4:	6a 00                	push   $0x0
80106fc6:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106fcc:	50                   	push   %eax
80106fcd:	e8 a1 ef ff ff       	call   80105f73 <memset>
80106fd2:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106fd5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fdf:	83 f8 1f             	cmp    $0x1f,%eax
80106fe2:	76 0a                	jbe    80106fee <sys_exec+0x72>
      return -1;
80106fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fe9:	e9 94 00 00 00       	jmp    80107082 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff1:	c1 e0 02             	shl    $0x2,%eax
80106ff4:	89 c2                	mov    %eax,%edx
80106ff6:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106ffc:	01 c2                	add    %eax,%edx
80106ffe:	83 ec 08             	sub    $0x8,%esp
80107001:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107007:	50                   	push   %eax
80107008:	52                   	push   %edx
80107009:	e8 ef f1 ff ff       	call   801061fd <fetchint>
8010700e:	83 c4 10             	add    $0x10,%esp
80107011:	85 c0                	test   %eax,%eax
80107013:	79 07                	jns    8010701c <sys_exec+0xa0>
      return -1;
80107015:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010701a:	eb 66                	jmp    80107082 <sys_exec+0x106>
    if(uarg == 0){
8010701c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107022:	85 c0                	test   %eax,%eax
80107024:	75 27                	jne    8010704d <sys_exec+0xd1>
      argv[i] = 0;
80107026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107029:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107030:	00 00 00 00 
      break;
80107034:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107035:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107038:	83 ec 08             	sub    $0x8,%esp
8010703b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107041:	52                   	push   %edx
80107042:	50                   	push   %eax
80107043:	e8 7b 9b ff ff       	call   80100bc3 <exec>
80107048:	83 c4 10             	add    $0x10,%esp
8010704b:	eb 35                	jmp    80107082 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
8010704d:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107056:	c1 e0 02             	shl    $0x2,%eax
80107059:	01 c2                	add    %eax,%edx
8010705b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107061:	83 ec 08             	sub    $0x8,%esp
80107064:	52                   	push   %edx
80107065:	50                   	push   %eax
80107066:	e8 d1 f1 ff ff       	call   8010623c <fetchstr>
8010706b:	83 c4 10             	add    $0x10,%esp
8010706e:	85 c0                	test   %eax,%eax
80107070:	79 07                	jns    80107079 <sys_exec+0xfd>
      return -1;
80107072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107077:	eb 09                	jmp    80107082 <sys_exec+0x106>
  for(i=0;; i++){
80107079:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
8010707d:	e9 5a ff ff ff       	jmp    80106fdc <sys_exec+0x60>
}
80107082:	c9                   	leave  
80107083:	c3                   	ret    

80107084 <sys_pipe>:

int
sys_pipe(void)
{
80107084:	55                   	push   %ebp
80107085:	89 e5                	mov    %esp,%ebp
80107087:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010708a:	83 ec 04             	sub    $0x4,%esp
8010708d:	6a 08                	push   $0x8
8010708f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107092:	50                   	push   %eax
80107093:	6a 00                	push   $0x0
80107095:	e8 31 f2 ff ff       	call   801062cb <argptr>
8010709a:	83 c4 10             	add    $0x10,%esp
8010709d:	85 c0                	test   %eax,%eax
8010709f:	79 0a                	jns    801070ab <sys_pipe+0x27>
    return -1;
801070a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070a6:	e9 ae 00 00 00       	jmp    80107159 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
801070ab:	83 ec 08             	sub    $0x8,%esp
801070ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801070b1:	50                   	push   %eax
801070b2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801070b5:	50                   	push   %eax
801070b6:	e8 d2 d0 ff ff       	call   8010418d <pipealloc>
801070bb:	83 c4 10             	add    $0x10,%esp
801070be:	85 c0                	test   %eax,%eax
801070c0:	79 0a                	jns    801070cc <sys_pipe+0x48>
    return -1;
801070c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070c7:	e9 8d 00 00 00       	jmp    80107159 <sys_pipe+0xd5>
  fd0 = -1;
801070cc:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801070d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801070d6:	83 ec 0c             	sub    $0xc,%esp
801070d9:	50                   	push   %eax
801070da:	e8 7d f3 ff ff       	call   8010645c <fdalloc>
801070df:	83 c4 10             	add    $0x10,%esp
801070e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801070e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801070e9:	78 18                	js     80107103 <sys_pipe+0x7f>
801070eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070ee:	83 ec 0c             	sub    $0xc,%esp
801070f1:	50                   	push   %eax
801070f2:	e8 65 f3 ff ff       	call   8010645c <fdalloc>
801070f7:	83 c4 10             	add    $0x10,%esp
801070fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801070fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107101:	79 3e                	jns    80107141 <sys_pipe+0xbd>
    if(fd0 >= 0)
80107103:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107107:	78 13                	js     8010711c <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80107109:	e8 42 d5 ff ff       	call   80104650 <myproc>
8010710e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107111:	83 c2 08             	add    $0x8,%edx
80107114:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010711b:	00 
    fileclose(rf);
8010711c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010711f:	83 ec 0c             	sub    $0xc,%esp
80107122:	50                   	push   %eax
80107123:	e8 6d a3 ff ff       	call   80101495 <fileclose>
80107128:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010712b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010712e:	83 ec 0c             	sub    $0xc,%esp
80107131:	50                   	push   %eax
80107132:	e8 5e a3 ff ff       	call   80101495 <fileclose>
80107137:	83 c4 10             	add    $0x10,%esp
    return -1;
8010713a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010713f:	eb 18                	jmp    80107159 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80107141:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107144:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107147:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107149:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010714c:	8d 50 04             	lea    0x4(%eax),%edx
8010714f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107152:	89 02                	mov    %eax,(%edx)
  return 0;
80107154:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107159:	c9                   	leave  
8010715a:	c3                   	ret    

8010715b <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010715b:	55                   	push   %ebp
8010715c:	89 e5                	mov    %esp,%ebp
8010715e:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107161:	e8 37 d8 ff ff       	call   8010499d <fork>
}
80107166:	c9                   	leave  
80107167:	c3                   	ret    

80107168 <sys_exit>:

int
sys_exit(void)
{
80107168:	55                   	push   %ebp
80107169:	89 e5                	mov    %esp,%ebp
8010716b:	83 ec 08             	sub    $0x8,%esp
  exit();
8010716e:	e8 a3 d9 ff ff       	call   80104b16 <exit>
  return 0;  // not reached
80107173:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107178:	c9                   	leave  
80107179:	c3                   	ret    

8010717a <sys_wait>:

int
sys_wait(void)
{
8010717a:	55                   	push   %ebp
8010717b:	89 e5                	mov    %esp,%ebp
8010717d:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107180:	e8 2e dc ff ff       	call   80104db3 <wait>
}
80107185:	c9                   	leave  
80107186:	c3                   	ret    

80107187 <sys_kill>:

int
sys_kill(void)
{
80107187:	55                   	push   %ebp
80107188:	89 e5                	mov    %esp,%ebp
8010718a:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010718d:	83 ec 08             	sub    $0x8,%esp
80107190:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107193:	50                   	push   %eax
80107194:	6a 00                	push   $0x0
80107196:	e8 03 f1 ff ff       	call   8010629e <argint>
8010719b:	83 c4 10             	add    $0x10,%esp
8010719e:	85 c0                	test   %eax,%eax
801071a0:	79 07                	jns    801071a9 <sys_kill+0x22>
    return -1;
801071a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071a7:	eb 0f                	jmp    801071b8 <sys_kill+0x31>
  return kill(pid);
801071a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ac:	83 ec 0c             	sub    $0xc,%esp
801071af:	50                   	push   %eax
801071b0:	e8 41 e2 ff ff       	call   801053f6 <kill>
801071b5:	83 c4 10             	add    $0x10,%esp
}
801071b8:	c9                   	leave  
801071b9:	c3                   	ret    

801071ba <sys_getpid>:

int
sys_getpid(void)
{
801071ba:	55                   	push   %ebp
801071bb:	89 e5                	mov    %esp,%ebp
801071bd:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801071c0:	e8 8b d4 ff ff       	call   80104650 <myproc>
801071c5:	8b 40 10             	mov    0x10(%eax),%eax
}
801071c8:	c9                   	leave  
801071c9:	c3                   	ret    

801071ca <sys_sbrk>:

int
sys_sbrk(void)
{
801071ca:	55                   	push   %ebp
801071cb:	89 e5                	mov    %esp,%ebp
801071cd:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801071d0:	83 ec 08             	sub    $0x8,%esp
801071d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071d6:	50                   	push   %eax
801071d7:	6a 00                	push   $0x0
801071d9:	e8 c0 f0 ff ff       	call   8010629e <argint>
801071de:	83 c4 10             	add    $0x10,%esp
801071e1:	85 c0                	test   %eax,%eax
801071e3:	79 07                	jns    801071ec <sys_sbrk+0x22>
    return -1;
801071e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ea:	eb 27                	jmp    80107213 <sys_sbrk+0x49>
  addr = myproc()->sz;
801071ec:	e8 5f d4 ff ff       	call   80104650 <myproc>
801071f1:	8b 00                	mov    (%eax),%eax
801071f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801071f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071f9:	83 ec 0c             	sub    $0xc,%esp
801071fc:	50                   	push   %eax
801071fd:	e8 00 d7 ff ff       	call   80104902 <growproc>
80107202:	83 c4 10             	add    $0x10,%esp
80107205:	85 c0                	test   %eax,%eax
80107207:	79 07                	jns    80107210 <sys_sbrk+0x46>
    return -1;
80107209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010720e:	eb 03                	jmp    80107213 <sys_sbrk+0x49>
  return addr;
80107210:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107213:	c9                   	leave  
80107214:	c3                   	ret    

80107215 <sys_sleep>:

int
sys_sleep(void)
{
80107215:	55                   	push   %ebp
80107216:	89 e5                	mov    %esp,%ebp
80107218:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010721b:	83 ec 08             	sub    $0x8,%esp
8010721e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107221:	50                   	push   %eax
80107222:	6a 00                	push   $0x0
80107224:	e8 75 f0 ff ff       	call   8010629e <argint>
80107229:	83 c4 10             	add    $0x10,%esp
8010722c:	85 c0                	test   %eax,%eax
8010722e:	79 07                	jns    80107237 <sys_sleep+0x22>
    return -1;
80107230:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107235:	eb 76                	jmp    801072ad <sys_sleep+0x98>
  acquire(&tickslock);
80107237:	83 ec 0c             	sub    $0xc,%esp
8010723a:	68 c0 68 11 80       	push   $0x801168c0
8010723f:	e8 a9 ea ff ff       	call   80105ced <acquire>
80107244:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80107247:	a1 f4 68 11 80       	mov    0x801168f4,%eax
8010724c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010724f:	eb 38                	jmp    80107289 <sys_sleep+0x74>
    if(myproc()->killed){
80107251:	e8 fa d3 ff ff       	call   80104650 <myproc>
80107256:	8b 40 24             	mov    0x24(%eax),%eax
80107259:	85 c0                	test   %eax,%eax
8010725b:	74 17                	je     80107274 <sys_sleep+0x5f>
      release(&tickslock);
8010725d:	83 ec 0c             	sub    $0xc,%esp
80107260:	68 c0 68 11 80       	push   $0x801168c0
80107265:	e8 f1 ea ff ff       	call   80105d5b <release>
8010726a:	83 c4 10             	add    $0x10,%esp
      return -1;
8010726d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107272:	eb 39                	jmp    801072ad <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80107274:	83 ec 08             	sub    $0x8,%esp
80107277:	68 c0 68 11 80       	push   $0x801168c0
8010727c:	68 f4 68 11 80       	push   $0x801168f4
80107281:	e8 4f e0 ff ff       	call   801052d5 <sleep>
80107286:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80107289:	a1 f4 68 11 80       	mov    0x801168f4,%eax
8010728e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107291:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107294:	39 d0                	cmp    %edx,%eax
80107296:	72 b9                	jb     80107251 <sys_sleep+0x3c>
  }
  release(&tickslock);
80107298:	83 ec 0c             	sub    $0xc,%esp
8010729b:	68 c0 68 11 80       	push   $0x801168c0
801072a0:	e8 b6 ea ff ff       	call   80105d5b <release>
801072a5:	83 c4 10             	add    $0x10,%esp
  return 0;
801072a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072ad:	c9                   	leave  
801072ae:	c3                   	ret    

801072af <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801072af:	55                   	push   %ebp
801072b0:	89 e5                	mov    %esp,%ebp
801072b2:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801072b5:	83 ec 0c             	sub    $0xc,%esp
801072b8:	68 c0 68 11 80       	push   $0x801168c0
801072bd:	e8 2b ea ff ff       	call   80105ced <acquire>
801072c2:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801072c5:	a1 f4 68 11 80       	mov    0x801168f4,%eax
801072ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801072cd:	83 ec 0c             	sub    $0xc,%esp
801072d0:	68 c0 68 11 80       	push   $0x801168c0
801072d5:	e8 81 ea ff ff       	call   80105d5b <release>
801072da:	83 c4 10             	add    $0x10,%esp
  return xticks;
801072dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801072e0:	c9                   	leave  
801072e1:	c3                   	ret    

801072e2 <sys_ps>:

// MOD-1 : System call to show running processes
void process_status(void);
int
sys_ps(void)
{
801072e2:	55                   	push   %ebp
801072e3:	89 e5                	mov    %esp,%ebp
801072e5:	83 ec 08             	sub    $0x8,%esp
  process_status();
801072e8:	e8 8d e2 ff ff       	call   8010557a <process_status>
  return 0;
801072ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072f2:	c9                   	leave  
801072f3:	c3                   	ret    

801072f4 <sys_exec_time>:


// System call exect time 
int change_exec_time(int,int);
int
sys_exec_time(void){
801072f4:	55                   	push   %ebp
801072f5:	89 e5                	mov    %esp,%ebp
801072f7:	83 ec 18             	sub    $0x18,%esp

int pid,et;
if(argint(0,&pid)<0)
801072fa:	83 ec 08             	sub    $0x8,%esp
801072fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107300:	50                   	push   %eax
80107301:	6a 00                	push   $0x0
80107303:	e8 96 ef ff ff       	call   8010629e <argint>
80107308:	83 c4 10             	add    $0x10,%esp
8010730b:	85 c0                	test   %eax,%eax
8010730d:	79 07                	jns    80107316 <sys_exec_time+0x22>
	return -1;
8010730f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107314:	eb 2f                	jmp    80107345 <sys_exec_time+0x51>

if(argint(1,&et)<0)
80107316:	83 ec 08             	sub    $0x8,%esp
80107319:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010731c:	50                   	push   %eax
8010731d:	6a 01                	push   $0x1
8010731f:	e8 7a ef ff ff       	call   8010629e <argint>
80107324:	83 c4 10             	add    $0x10,%esp
80107327:	85 c0                	test   %eax,%eax
80107329:	79 07                	jns    80107332 <sys_exec_time+0x3e>
	return -1;
8010732b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107330:	eb 13                	jmp    80107345 <sys_exec_time+0x51>
	
return change_exec_time(pid,et);
80107332:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107338:	83 ec 08             	sub    $0x8,%esp
8010733b:	52                   	push   %edx
8010733c:	50                   	push   %eax
8010733d:	e8 6b e3 ff ff       	call   801056ad <change_exec_time>
80107342:	83 c4 10             	add    $0x10,%esp

}
80107345:	c9                   	leave  
80107346:	c3                   	ret    

80107347 <sys_deadline>:

// System call deadline 
int change_deadline(int,int);
int
sys_deadline(void){
80107347:	55                   	push   %ebp
80107348:	89 e5                	mov    %esp,%ebp
8010734a:	83 ec 18             	sub    $0x18,%esp

int pid,dl;
if(argint(0,&pid)<0)
8010734d:	83 ec 08             	sub    $0x8,%esp
80107350:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107353:	50                   	push   %eax
80107354:	6a 00                	push   $0x0
80107356:	e8 43 ef ff ff       	call   8010629e <argint>
8010735b:	83 c4 10             	add    $0x10,%esp
8010735e:	85 c0                	test   %eax,%eax
80107360:	79 07                	jns    80107369 <sys_deadline+0x22>
	return -1;
80107362:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107367:	eb 2f                	jmp    80107398 <sys_deadline+0x51>

if(argint(1,&dl)<0)
80107369:	83 ec 08             	sub    $0x8,%esp
8010736c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010736f:	50                   	push   %eax
80107370:	6a 01                	push   $0x1
80107372:	e8 27 ef ff ff       	call   8010629e <argint>
80107377:	83 c4 10             	add    $0x10,%esp
8010737a:	85 c0                	test   %eax,%eax
8010737c:	79 07                	jns    80107385 <sys_deadline+0x3e>
	return -1;
8010737e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107383:	eb 13                	jmp    80107398 <sys_deadline+0x51>
	
return change_deadline(pid,dl);
80107385:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738b:	83 ec 08             	sub    $0x8,%esp
8010738e:	52                   	push   %edx
8010738f:	50                   	push   %eax
80107390:	e8 77 e3 ff ff       	call   8010570c <change_deadline>
80107395:	83 c4 10             	add    $0x10,%esp

}
80107398:	c9                   	leave  
80107399:	c3                   	ret    

8010739a <sys_sched_policy>:


// System call policy 
int change_sched_policy(int,int);
int
sys_sched_policy(void){
8010739a:	55                   	push   %ebp
8010739b:	89 e5                	mov    %esp,%ebp
8010739d:	83 ec 18             	sub    $0x18,%esp

int pid,py;
if(argint(0,&pid)<0)
801073a0:	83 ec 08             	sub    $0x8,%esp
801073a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073a6:	50                   	push   %eax
801073a7:	6a 00                	push   $0x0
801073a9:	e8 f0 ee ff ff       	call   8010629e <argint>
801073ae:	83 c4 10             	add    $0x10,%esp
801073b1:	85 c0                	test   %eax,%eax
801073b3:	79 07                	jns    801073bc <sys_sched_policy+0x22>
	return -1;
801073b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ba:	eb 2f                	jmp    801073eb <sys_sched_policy+0x51>

if(argint(1,&py)<0)
801073bc:	83 ec 08             	sub    $0x8,%esp
801073bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073c2:	50                   	push   %eax
801073c3:	6a 01                	push   $0x1
801073c5:	e8 d4 ee ff ff       	call   8010629e <argint>
801073ca:	83 c4 10             	add    $0x10,%esp
801073cd:	85 c0                	test   %eax,%eax
801073cf:	79 07                	jns    801073d8 <sys_sched_policy+0x3e>
	return -1;
801073d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073d6:	eb 13                	jmp    801073eb <sys_sched_policy+0x51>
	
return change_sched_policy(pid,py);
801073d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801073db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073de:	83 ec 08             	sub    $0x8,%esp
801073e1:	52                   	push   %edx
801073e2:	50                   	push   %eax
801073e3:	e8 80 e3 ff ff       	call   80105768 <change_sched_policy>
801073e8:	83 c4 10             	add    $0x10,%esp

}
801073eb:	c9                   	leave  
801073ec:	c3                   	ret    

801073ed <sys_rate>:

int change_rate(int,int);
int
sys_rate(void){
801073ed:	55                   	push   %ebp
801073ee:	89 e5                	mov    %esp,%ebp
801073f0:	83 ec 18             	sub    $0x18,%esp

int pid,rt;
if(argint(0,&pid)<0)
801073f3:	83 ec 08             	sub    $0x8,%esp
801073f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073f9:	50                   	push   %eax
801073fa:	6a 00                	push   $0x0
801073fc:	e8 9d ee ff ff       	call   8010629e <argint>
80107401:	83 c4 10             	add    $0x10,%esp
80107404:	85 c0                	test   %eax,%eax
80107406:	79 07                	jns    8010740f <sys_rate+0x22>
	return -1;
80107408:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010740d:	eb 2f                	jmp    8010743e <sys_rate+0x51>

if(argint(1,&rt)<0)
8010740f:	83 ec 08             	sub    $0x8,%esp
80107412:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107415:	50                   	push   %eax
80107416:	6a 01                	push   $0x1
80107418:	e8 81 ee ff ff       	call   8010629e <argint>
8010741d:	83 c4 10             	add    $0x10,%esp
80107420:	85 c0                	test   %eax,%eax
80107422:	79 07                	jns    8010742b <sys_rate+0x3e>
	return -1;
80107424:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107429:	eb 13                	jmp    8010743e <sys_rate+0x51>

	
return change_rate(pid,rt);
8010742b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010742e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107431:	83 ec 08             	sub    $0x8,%esp
80107434:	52                   	push   %edx
80107435:	50                   	push   %eax
80107436:	e8 3c e6 ff ff       	call   80105a77 <change_rate>
8010743b:	83 c4 10             	add    $0x10,%esp

}
8010743e:	c9                   	leave  
8010743f:	c3                   	ret    

80107440 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107440:	1e                   	push   %ds
  pushl %es
80107441:	06                   	push   %es
  pushl %fs
80107442:	0f a0                	push   %fs
  pushl %gs
80107444:	0f a8                	push   %gs
  pushal
80107446:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80107447:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010744b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010744d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010744f:	54                   	push   %esp
  call trap
80107450:	e8 d7 01 00 00       	call   8010762c <trap>
  addl $4, %esp
80107455:	83 c4 04             	add    $0x4,%esp

80107458 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107458:	61                   	popa   
  popl %gs
80107459:	0f a9                	pop    %gs
  popl %fs
8010745b:	0f a1                	pop    %fs
  popl %es
8010745d:	07                   	pop    %es
  popl %ds
8010745e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010745f:	83 c4 08             	add    $0x8,%esp
  iret
80107462:	cf                   	iret   

80107463 <lidt>:
{
80107463:	55                   	push   %ebp
80107464:	89 e5                	mov    %esp,%ebp
80107466:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107469:	8b 45 0c             	mov    0xc(%ebp),%eax
8010746c:	83 e8 01             	sub    $0x1,%eax
8010746f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107473:	8b 45 08             	mov    0x8(%ebp),%eax
80107476:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010747a:	8b 45 08             	mov    0x8(%ebp),%eax
8010747d:	c1 e8 10             	shr    $0x10,%eax
80107480:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80107484:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107487:	0f 01 18             	lidtl  (%eax)
}
8010748a:	90                   	nop
8010748b:	c9                   	leave  
8010748c:	c3                   	ret    

8010748d <rcr2>:

static inline uint
rcr2(void)
{
8010748d:	55                   	push   %ebp
8010748e:	89 e5                	mov    %esp,%ebp
80107490:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107493:	0f 20 d0             	mov    %cr2,%eax
80107496:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107499:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010749c:	c9                   	leave  
8010749d:	c3                   	ret    

8010749e <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010749e:	55                   	push   %ebp
8010749f:	89 e5                	mov    %esp,%ebp
801074a1:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801074a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801074ab:	e9 c3 00 00 00       	jmp    80107573 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801074b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b3:	8b 04 85 8c c0 10 80 	mov    -0x7fef3f74(,%eax,4),%eax
801074ba:	89 c2                	mov    %eax,%edx
801074bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074bf:	66 89 14 c5 c0 60 11 	mov    %dx,-0x7fee9f40(,%eax,8)
801074c6:	80 
801074c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ca:	66 c7 04 c5 c2 60 11 	movw   $0x8,-0x7fee9f3e(,%eax,8)
801074d1:	80 08 00 
801074d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d7:	0f b6 14 c5 c4 60 11 	movzbl -0x7fee9f3c(,%eax,8),%edx
801074de:	80 
801074df:	83 e2 e0             	and    $0xffffffe0,%edx
801074e2:	88 14 c5 c4 60 11 80 	mov    %dl,-0x7fee9f3c(,%eax,8)
801074e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ec:	0f b6 14 c5 c4 60 11 	movzbl -0x7fee9f3c(,%eax,8),%edx
801074f3:	80 
801074f4:	83 e2 1f             	and    $0x1f,%edx
801074f7:	88 14 c5 c4 60 11 80 	mov    %dl,-0x7fee9f3c(,%eax,8)
801074fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107501:	0f b6 14 c5 c5 60 11 	movzbl -0x7fee9f3b(,%eax,8),%edx
80107508:	80 
80107509:	83 e2 f0             	and    $0xfffffff0,%edx
8010750c:	83 ca 0e             	or     $0xe,%edx
8010750f:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
80107516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107519:	0f b6 14 c5 c5 60 11 	movzbl -0x7fee9f3b(,%eax,8),%edx
80107520:	80 
80107521:	83 e2 ef             	and    $0xffffffef,%edx
80107524:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
8010752b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752e:	0f b6 14 c5 c5 60 11 	movzbl -0x7fee9f3b(,%eax,8),%edx
80107535:	80 
80107536:	83 e2 9f             	and    $0xffffff9f,%edx
80107539:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
80107540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107543:	0f b6 14 c5 c5 60 11 	movzbl -0x7fee9f3b(,%eax,8),%edx
8010754a:	80 
8010754b:	83 ca 80             	or     $0xffffff80,%edx
8010754e:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
80107555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107558:	8b 04 85 8c c0 10 80 	mov    -0x7fef3f74(,%eax,4),%eax
8010755f:	c1 e8 10             	shr    $0x10,%eax
80107562:	89 c2                	mov    %eax,%edx
80107564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107567:	66 89 14 c5 c6 60 11 	mov    %dx,-0x7fee9f3a(,%eax,8)
8010756e:	80 
  for(i = 0; i < 256; i++)
8010756f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107573:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010757a:	0f 8e 30 ff ff ff    	jle    801074b0 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107580:	a1 8c c1 10 80       	mov    0x8010c18c,%eax
80107585:	66 a3 c0 62 11 80    	mov    %ax,0x801162c0
8010758b:	66 c7 05 c2 62 11 80 	movw   $0x8,0x801162c2
80107592:	08 00 
80107594:	0f b6 05 c4 62 11 80 	movzbl 0x801162c4,%eax
8010759b:	83 e0 e0             	and    $0xffffffe0,%eax
8010759e:	a2 c4 62 11 80       	mov    %al,0x801162c4
801075a3:	0f b6 05 c4 62 11 80 	movzbl 0x801162c4,%eax
801075aa:	83 e0 1f             	and    $0x1f,%eax
801075ad:	a2 c4 62 11 80       	mov    %al,0x801162c4
801075b2:	0f b6 05 c5 62 11 80 	movzbl 0x801162c5,%eax
801075b9:	83 c8 0f             	or     $0xf,%eax
801075bc:	a2 c5 62 11 80       	mov    %al,0x801162c5
801075c1:	0f b6 05 c5 62 11 80 	movzbl 0x801162c5,%eax
801075c8:	83 e0 ef             	and    $0xffffffef,%eax
801075cb:	a2 c5 62 11 80       	mov    %al,0x801162c5
801075d0:	0f b6 05 c5 62 11 80 	movzbl 0x801162c5,%eax
801075d7:	83 c8 60             	or     $0x60,%eax
801075da:	a2 c5 62 11 80       	mov    %al,0x801162c5
801075df:	0f b6 05 c5 62 11 80 	movzbl 0x801162c5,%eax
801075e6:	83 c8 80             	or     $0xffffff80,%eax
801075e9:	a2 c5 62 11 80       	mov    %al,0x801162c5
801075ee:	a1 8c c1 10 80       	mov    0x8010c18c,%eax
801075f3:	c1 e8 10             	shr    $0x10,%eax
801075f6:	66 a3 c6 62 11 80    	mov    %ax,0x801162c6

  initlock(&tickslock, "time");
801075fc:	83 ec 08             	sub    $0x8,%esp
801075ff:	68 84 98 10 80       	push   $0x80109884
80107604:	68 c0 68 11 80       	push   $0x801168c0
80107609:	e8 bd e6 ff ff       	call   80105ccb <initlock>
8010760e:	83 c4 10             	add    $0x10,%esp
}
80107611:	90                   	nop
80107612:	c9                   	leave  
80107613:	c3                   	ret    

80107614 <idtinit>:

void
idtinit(void)
{
80107614:	55                   	push   %ebp
80107615:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107617:	68 00 08 00 00       	push   $0x800
8010761c:	68 c0 60 11 80       	push   $0x801160c0
80107621:	e8 3d fe ff ff       	call   80107463 <lidt>
80107626:	83 c4 08             	add    $0x8,%esp
}
80107629:	90                   	nop
8010762a:	c9                   	leave  
8010762b:	c3                   	ret    

8010762c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010762c:	55                   	push   %ebp
8010762d:	89 e5                	mov    %esp,%ebp
8010762f:	57                   	push   %edi
80107630:	56                   	push   %esi
80107631:	53                   	push   %ebx
80107632:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80107635:	8b 45 08             	mov    0x8(%ebp),%eax
80107638:	8b 40 30             	mov    0x30(%eax),%eax
8010763b:	83 f8 40             	cmp    $0x40,%eax
8010763e:	75 3b                	jne    8010767b <trap+0x4f>
    if(myproc()->killed)
80107640:	e8 0b d0 ff ff       	call   80104650 <myproc>
80107645:	8b 40 24             	mov    0x24(%eax),%eax
80107648:	85 c0                	test   %eax,%eax
8010764a:	74 05                	je     80107651 <trap+0x25>
      exit();
8010764c:	e8 c5 d4 ff ff       	call   80104b16 <exit>
    myproc()->tf = tf;
80107651:	e8 fa cf ff ff       	call   80104650 <myproc>
80107656:	8b 55 08             	mov    0x8(%ebp),%edx
80107659:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010765c:	e8 09 ed ff ff       	call   8010636a <syscall>
    if(myproc()->killed)
80107661:	e8 ea cf ff ff       	call   80104650 <myproc>
80107666:	8b 40 24             	mov    0x24(%eax),%eax
80107669:	85 c0                	test   %eax,%eax
8010766b:	0f 84 73 02 00 00    	je     801078e4 <trap+0x2b8>
      exit();
80107671:	e8 a0 d4 ff ff       	call   80104b16 <exit>
    return;
80107676:	e9 69 02 00 00       	jmp    801078e4 <trap+0x2b8>
  }

  switch(tf->trapno){
8010767b:	8b 45 08             	mov    0x8(%ebp),%eax
8010767e:	8b 40 30             	mov    0x30(%eax),%eax
80107681:	83 e8 20             	sub    $0x20,%eax
80107684:	83 f8 1f             	cmp    $0x1f,%eax
80107687:	0f 87 b5 00 00 00    	ja     80107742 <trap+0x116>
8010768d:	8b 04 85 70 99 10 80 	mov    -0x7fef6690(,%eax,4),%eax
80107694:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80107696:	e8 22 cf ff ff       	call   801045bd <cpuid>
8010769b:	85 c0                	test   %eax,%eax
8010769d:	75 3d                	jne    801076dc <trap+0xb0>
      acquire(&tickslock);
8010769f:	83 ec 0c             	sub    $0xc,%esp
801076a2:	68 c0 68 11 80       	push   $0x801168c0
801076a7:	e8 41 e6 ff ff       	call   80105ced <acquire>
801076ac:	83 c4 10             	add    $0x10,%esp
      ticks++;
801076af:	a1 f4 68 11 80       	mov    0x801168f4,%eax
801076b4:	83 c0 01             	add    $0x1,%eax
801076b7:	a3 f4 68 11 80       	mov    %eax,0x801168f4
      wakeup(&ticks);
801076bc:	83 ec 0c             	sub    $0xc,%esp
801076bf:	68 f4 68 11 80       	push   $0x801168f4
801076c4:	e8 f6 dc ff ff       	call   801053bf <wakeup>
801076c9:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801076cc:	83 ec 0c             	sub    $0xc,%esp
801076cf:	68 c0 68 11 80       	push   $0x801168c0
801076d4:	e8 82 e6 ff ff       	call   80105d5b <release>
801076d9:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801076dc:	e8 e8 bc ff ff       	call   801033c9 <lapiceoi>
    break;
801076e1:	e9 11 01 00 00       	jmp    801077f7 <trap+0x1cb>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801076e6:	e8 52 b5 ff ff       	call   80102c3d <ideintr>
    lapiceoi();
801076eb:	e8 d9 bc ff ff       	call   801033c9 <lapiceoi>
    break;
801076f0:	e9 02 01 00 00       	jmp    801077f7 <trap+0x1cb>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801076f5:	e8 14 bb ff ff       	call   8010320e <kbdintr>
    lapiceoi();
801076fa:	e8 ca bc ff ff       	call   801033c9 <lapiceoi>
    break;
801076ff:	e9 f3 00 00 00       	jmp    801077f7 <trap+0x1cb>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107704:	e8 b1 03 00 00       	call   80107aba <uartintr>
    lapiceoi();
80107709:	e8 bb bc ff ff       	call   801033c9 <lapiceoi>
    break;
8010770e:	e9 e4 00 00 00       	jmp    801077f7 <trap+0x1cb>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107713:	8b 45 08             	mov    0x8(%ebp),%eax
80107716:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80107719:	8b 45 08             	mov    0x8(%ebp),%eax
8010771c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107720:	0f b7 d8             	movzwl %ax,%ebx
80107723:	e8 95 ce ff ff       	call   801045bd <cpuid>
80107728:	56                   	push   %esi
80107729:	53                   	push   %ebx
8010772a:	50                   	push   %eax
8010772b:	68 8c 98 10 80       	push   $0x8010988c
80107730:	e8 cb 8c ff ff       	call   80100400 <cprintf>
80107735:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80107738:	e8 8c bc ff ff       	call   801033c9 <lapiceoi>
    break;
8010773d:	e9 b5 00 00 00       	jmp    801077f7 <trap+0x1cb>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80107742:	e8 09 cf ff ff       	call   80104650 <myproc>
80107747:	85 c0                	test   %eax,%eax
80107749:	74 11                	je     8010775c <trap+0x130>
8010774b:	8b 45 08             	mov    0x8(%ebp),%eax
8010774e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107752:	0f b7 c0             	movzwl %ax,%eax
80107755:	83 e0 03             	and    $0x3,%eax
80107758:	85 c0                	test   %eax,%eax
8010775a:	75 39                	jne    80107795 <trap+0x169>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010775c:	e8 2c fd ff ff       	call   8010748d <rcr2>
80107761:	89 c3                	mov    %eax,%ebx
80107763:	8b 45 08             	mov    0x8(%ebp),%eax
80107766:	8b 70 38             	mov    0x38(%eax),%esi
80107769:	e8 4f ce ff ff       	call   801045bd <cpuid>
8010776e:	8b 55 08             	mov    0x8(%ebp),%edx
80107771:	8b 52 30             	mov    0x30(%edx),%edx
80107774:	83 ec 0c             	sub    $0xc,%esp
80107777:	53                   	push   %ebx
80107778:	56                   	push   %esi
80107779:	50                   	push   %eax
8010777a:	52                   	push   %edx
8010777b:	68 b0 98 10 80       	push   $0x801098b0
80107780:	e8 7b 8c ff ff       	call   80100400 <cprintf>
80107785:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80107788:	83 ec 0c             	sub    $0xc,%esp
8010778b:	68 e2 98 10 80       	push   $0x801098e2
80107790:	e8 20 8e ff ff       	call   801005b5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107795:	e8 f3 fc ff ff       	call   8010748d <rcr2>
8010779a:	89 c6                	mov    %eax,%esi
8010779c:	8b 45 08             	mov    0x8(%ebp),%eax
8010779f:	8b 40 38             	mov    0x38(%eax),%eax
801077a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077a5:	e8 13 ce ff ff       	call   801045bd <cpuid>
801077aa:	89 c3                	mov    %eax,%ebx
801077ac:	8b 45 08             	mov    0x8(%ebp),%eax
801077af:	8b 48 34             	mov    0x34(%eax),%ecx
801077b2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801077b5:	8b 45 08             	mov    0x8(%ebp),%eax
801077b8:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801077bb:	e8 90 ce ff ff       	call   80104650 <myproc>
801077c0:	8d 50 6c             	lea    0x6c(%eax),%edx
801077c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
801077c6:	e8 85 ce ff ff       	call   80104650 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801077cb:	8b 40 10             	mov    0x10(%eax),%eax
801077ce:	56                   	push   %esi
801077cf:	ff 75 e4             	push   -0x1c(%ebp)
801077d2:	53                   	push   %ebx
801077d3:	ff 75 e0             	push   -0x20(%ebp)
801077d6:	57                   	push   %edi
801077d7:	ff 75 dc             	push   -0x24(%ebp)
801077da:	50                   	push   %eax
801077db:	68 e8 98 10 80       	push   $0x801098e8
801077e0:	e8 1b 8c ff ff       	call   80100400 <cprintf>
801077e5:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801077e8:	e8 63 ce ff ff       	call   80104650 <myproc>
801077ed:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801077f4:	eb 01                	jmp    801077f7 <trap+0x1cb>
    break;
801077f6:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801077f7:	e8 54 ce ff ff       	call   80104650 <myproc>
801077fc:	85 c0                	test   %eax,%eax
801077fe:	74 23                	je     80107823 <trap+0x1f7>
80107800:	e8 4b ce ff ff       	call   80104650 <myproc>
80107805:	8b 40 24             	mov    0x24(%eax),%eax
80107808:	85 c0                	test   %eax,%eax
8010780a:	74 17                	je     80107823 <trap+0x1f7>
8010780c:	8b 45 08             	mov    0x8(%ebp),%eax
8010780f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107813:	0f b7 c0             	movzwl %ax,%eax
80107816:	83 e0 03             	and    $0x3,%eax
80107819:	83 f8 03             	cmp    $0x3,%eax
8010781c:	75 05                	jne    80107823 <trap+0x1f7>
    exit();
8010781e:	e8 f3 d2 ff ff       	call   80104b16 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107823:	e8 28 ce ff ff       	call   80104650 <myproc>
80107828:	85 c0                	test   %eax,%eax
8010782a:	0f 84 86 00 00 00    	je     801078b6 <trap+0x28a>
80107830:	e8 1b ce ff ff       	call   80104650 <myproc>
80107835:	8b 40 0c             	mov    0xc(%eax),%eax
80107838:	83 f8 04             	cmp    $0x4,%eax
8010783b:	75 79                	jne    801078b6 <trap+0x28a>
     tf->trapno == T_IRQ0+IRQ_TIMER){
8010783d:	8b 45 08             	mov    0x8(%ebp),%eax
80107840:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80107843:	83 f8 20             	cmp    $0x20,%eax
80107846:	75 6e                	jne    801078b6 <trap+0x28a>
    myproc()->elapsed_time++;		// decrease exec time at each tick
80107848:	e8 03 ce ff ff       	call   80104650 <myproc>
8010784d:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80107853:	83 c2 01             	add    $0x1,%edx
80107856:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    if((myproc()->policy >= 0) &&
8010785c:	e8 ef cd ff ff       	call   80104650 <myproc>
80107861:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80107867:	85 c0                	test   %eax,%eax
80107869:	78 46                	js     801078b1 <trap+0x285>
	(myproc()->elapsed_time >= myproc()->exec_time))
8010786b:	e8 e0 cd ff ff       	call   80104650 <myproc>
80107870:	8b 98 84 00 00 00    	mov    0x84(%eax),%ebx
80107876:	e8 d5 cd ff ff       	call   80104650 <myproc>
8010787b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
    if((myproc()->policy >= 0) &&
80107881:	39 c3                	cmp    %eax,%ebx
80107883:	7c 2c                	jl     801078b1 <trap+0x285>
{
	cprintf("The arrival time and pid value of the completed process is %d %d\n",
	myproc()->arrival_time,myproc()->pid);
80107885:	e8 c6 cd ff ff       	call   80104650 <myproc>
	cprintf("The arrival time and pid value of the completed process is %d %d\n",
8010788a:	8b 58 10             	mov    0x10(%eax),%ebx
	myproc()->arrival_time,myproc()->pid);
8010788d:	e8 be cd ff ff       	call   80104650 <myproc>
	cprintf("The arrival time and pid value of the completed process is %d %d\n",
80107892:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80107898:	83 ec 04             	sub    $0x4,%esp
8010789b:	53                   	push   %ebx
8010789c:	50                   	push   %eax
8010789d:	68 2c 99 10 80       	push   $0x8010992c
801078a2:	e8 59 8b ff ff       	call   80100400 <cprintf>
801078a7:	83 c4 10             	add    $0x10,%esp
	exit();
801078aa:	e8 67 d2 ff ff       	call   80104b16 <exit>
801078af:	eb 05                	jmp    801078b6 <trap+0x28a>
}
    else
	yield();
801078b1:	e8 9f d9 ff ff       	call   80105255 <yield>
}


  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801078b6:	e8 95 cd ff ff       	call   80104650 <myproc>
801078bb:	85 c0                	test   %eax,%eax
801078bd:	74 26                	je     801078e5 <trap+0x2b9>
801078bf:	e8 8c cd ff ff       	call   80104650 <myproc>
801078c4:	8b 40 24             	mov    0x24(%eax),%eax
801078c7:	85 c0                	test   %eax,%eax
801078c9:	74 1a                	je     801078e5 <trap+0x2b9>
801078cb:	8b 45 08             	mov    0x8(%ebp),%eax
801078ce:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801078d2:	0f b7 c0             	movzwl %ax,%eax
801078d5:	83 e0 03             	and    $0x3,%eax
801078d8:	83 f8 03             	cmp    $0x3,%eax
801078db:	75 08                	jne    801078e5 <trap+0x2b9>
    exit();
801078dd:	e8 34 d2 ff ff       	call   80104b16 <exit>
801078e2:	eb 01                	jmp    801078e5 <trap+0x2b9>
    return;
801078e4:	90                   	nop
}
801078e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801078e8:	5b                   	pop    %ebx
801078e9:	5e                   	pop    %esi
801078ea:	5f                   	pop    %edi
801078eb:	5d                   	pop    %ebp
801078ec:	c3                   	ret    

801078ed <inb>:
{
801078ed:	55                   	push   %ebp
801078ee:	89 e5                	mov    %esp,%ebp
801078f0:	83 ec 14             	sub    $0x14,%esp
801078f3:	8b 45 08             	mov    0x8(%ebp),%eax
801078f6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801078fa:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801078fe:	89 c2                	mov    %eax,%edx
80107900:	ec                   	in     (%dx),%al
80107901:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107904:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107908:	c9                   	leave  
80107909:	c3                   	ret    

8010790a <outb>:
{
8010790a:	55                   	push   %ebp
8010790b:	89 e5                	mov    %esp,%ebp
8010790d:	83 ec 08             	sub    $0x8,%esp
80107910:	8b 45 08             	mov    0x8(%ebp),%eax
80107913:	8b 55 0c             	mov    0xc(%ebp),%edx
80107916:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010791a:	89 d0                	mov    %edx,%eax
8010791c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010791f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107923:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107927:	ee                   	out    %al,(%dx)
}
80107928:	90                   	nop
80107929:	c9                   	leave  
8010792a:	c3                   	ret    

8010792b <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010792b:	55                   	push   %ebp
8010792c:	89 e5                	mov    %esp,%ebp
8010792e:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107931:	6a 00                	push   $0x0
80107933:	68 fa 03 00 00       	push   $0x3fa
80107938:	e8 cd ff ff ff       	call   8010790a <outb>
8010793d:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107940:	68 80 00 00 00       	push   $0x80
80107945:	68 fb 03 00 00       	push   $0x3fb
8010794a:	e8 bb ff ff ff       	call   8010790a <outb>
8010794f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107952:	6a 0c                	push   $0xc
80107954:	68 f8 03 00 00       	push   $0x3f8
80107959:	e8 ac ff ff ff       	call   8010790a <outb>
8010795e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107961:	6a 00                	push   $0x0
80107963:	68 f9 03 00 00       	push   $0x3f9
80107968:	e8 9d ff ff ff       	call   8010790a <outb>
8010796d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107970:	6a 03                	push   $0x3
80107972:	68 fb 03 00 00       	push   $0x3fb
80107977:	e8 8e ff ff ff       	call   8010790a <outb>
8010797c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010797f:	6a 00                	push   $0x0
80107981:	68 fc 03 00 00       	push   $0x3fc
80107986:	e8 7f ff ff ff       	call   8010790a <outb>
8010798b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010798e:	6a 01                	push   $0x1
80107990:	68 f9 03 00 00       	push   $0x3f9
80107995:	e8 70 ff ff ff       	call   8010790a <outb>
8010799a:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010799d:	68 fd 03 00 00       	push   $0x3fd
801079a2:	e8 46 ff ff ff       	call   801078ed <inb>
801079a7:	83 c4 04             	add    $0x4,%esp
801079aa:	3c ff                	cmp    $0xff,%al
801079ac:	74 61                	je     80107a0f <uartinit+0xe4>
    return;
  uart = 1;
801079ae:	c7 05 f8 68 11 80 01 	movl   $0x1,0x801168f8
801079b5:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801079b8:	68 fa 03 00 00       	push   $0x3fa
801079bd:	e8 2b ff ff ff       	call   801078ed <inb>
801079c2:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801079c5:	68 f8 03 00 00       	push   $0x3f8
801079ca:	e8 1e ff ff ff       	call   801078ed <inb>
801079cf:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801079d2:	83 ec 08             	sub    $0x8,%esp
801079d5:	6a 00                	push   $0x0
801079d7:	6a 04                	push   $0x4
801079d9:	e8 fd b4 ff ff       	call   80102edb <ioapicenable>
801079de:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801079e1:	c7 45 f4 f0 99 10 80 	movl   $0x801099f0,-0xc(%ebp)
801079e8:	eb 19                	jmp    80107a03 <uartinit+0xd8>
    uartputc(*p);
801079ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ed:	0f b6 00             	movzbl (%eax),%eax
801079f0:	0f be c0             	movsbl %al,%eax
801079f3:	83 ec 0c             	sub    $0xc,%esp
801079f6:	50                   	push   %eax
801079f7:	e8 16 00 00 00       	call   80107a12 <uartputc>
801079fc:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801079ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a06:	0f b6 00             	movzbl (%eax),%eax
80107a09:	84 c0                	test   %al,%al
80107a0b:	75 dd                	jne    801079ea <uartinit+0xbf>
80107a0d:	eb 01                	jmp    80107a10 <uartinit+0xe5>
    return;
80107a0f:	90                   	nop
}
80107a10:	c9                   	leave  
80107a11:	c3                   	ret    

80107a12 <uartputc>:

void
uartputc(int c)
{
80107a12:	55                   	push   %ebp
80107a13:	89 e5                	mov    %esp,%ebp
80107a15:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107a18:	a1 f8 68 11 80       	mov    0x801168f8,%eax
80107a1d:	85 c0                	test   %eax,%eax
80107a1f:	74 53                	je     80107a74 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a28:	eb 11                	jmp    80107a3b <uartputc+0x29>
    microdelay(10);
80107a2a:	83 ec 0c             	sub    $0xc,%esp
80107a2d:	6a 0a                	push   $0xa
80107a2f:	e8 b0 b9 ff ff       	call   801033e4 <microdelay>
80107a34:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a3b:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107a3f:	7f 1a                	jg     80107a5b <uartputc+0x49>
80107a41:	83 ec 0c             	sub    $0xc,%esp
80107a44:	68 fd 03 00 00       	push   $0x3fd
80107a49:	e8 9f fe ff ff       	call   801078ed <inb>
80107a4e:	83 c4 10             	add    $0x10,%esp
80107a51:	0f b6 c0             	movzbl %al,%eax
80107a54:	83 e0 20             	and    $0x20,%eax
80107a57:	85 c0                	test   %eax,%eax
80107a59:	74 cf                	je     80107a2a <uartputc+0x18>
  outb(COM1+0, c);
80107a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a5e:	0f b6 c0             	movzbl %al,%eax
80107a61:	83 ec 08             	sub    $0x8,%esp
80107a64:	50                   	push   %eax
80107a65:	68 f8 03 00 00       	push   $0x3f8
80107a6a:	e8 9b fe ff ff       	call   8010790a <outb>
80107a6f:	83 c4 10             	add    $0x10,%esp
80107a72:	eb 01                	jmp    80107a75 <uartputc+0x63>
    return;
80107a74:	90                   	nop
}
80107a75:	c9                   	leave  
80107a76:	c3                   	ret    

80107a77 <uartgetc>:

static int
uartgetc(void)
{
80107a77:	55                   	push   %ebp
80107a78:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107a7a:	a1 f8 68 11 80       	mov    0x801168f8,%eax
80107a7f:	85 c0                	test   %eax,%eax
80107a81:	75 07                	jne    80107a8a <uartgetc+0x13>
    return -1;
80107a83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a88:	eb 2e                	jmp    80107ab8 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107a8a:	68 fd 03 00 00       	push   $0x3fd
80107a8f:	e8 59 fe ff ff       	call   801078ed <inb>
80107a94:	83 c4 04             	add    $0x4,%esp
80107a97:	0f b6 c0             	movzbl %al,%eax
80107a9a:	83 e0 01             	and    $0x1,%eax
80107a9d:	85 c0                	test   %eax,%eax
80107a9f:	75 07                	jne    80107aa8 <uartgetc+0x31>
    return -1;
80107aa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107aa6:	eb 10                	jmp    80107ab8 <uartgetc+0x41>
  return inb(COM1+0);
80107aa8:	68 f8 03 00 00       	push   $0x3f8
80107aad:	e8 3b fe ff ff       	call   801078ed <inb>
80107ab2:	83 c4 04             	add    $0x4,%esp
80107ab5:	0f b6 c0             	movzbl %al,%eax
}
80107ab8:	c9                   	leave  
80107ab9:	c3                   	ret    

80107aba <uartintr>:

void
uartintr(void)
{
80107aba:	55                   	push   %ebp
80107abb:	89 e5                	mov    %esp,%ebp
80107abd:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107ac0:	83 ec 0c             	sub    $0xc,%esp
80107ac3:	68 77 7a 10 80       	push   $0x80107a77
80107ac8:	e8 82 8d ff ff       	call   8010084f <consoleintr>
80107acd:	83 c4 10             	add    $0x10,%esp
}
80107ad0:	90                   	nop
80107ad1:	c9                   	leave  
80107ad2:	c3                   	ret    

80107ad3 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107ad3:	6a 00                	push   $0x0
  pushl $0
80107ad5:	6a 00                	push   $0x0
  jmp alltraps
80107ad7:	e9 64 f9 ff ff       	jmp    80107440 <alltraps>

80107adc <vector1>:
.globl vector1
vector1:
  pushl $0
80107adc:	6a 00                	push   $0x0
  pushl $1
80107ade:	6a 01                	push   $0x1
  jmp alltraps
80107ae0:	e9 5b f9 ff ff       	jmp    80107440 <alltraps>

80107ae5 <vector2>:
.globl vector2
vector2:
  pushl $0
80107ae5:	6a 00                	push   $0x0
  pushl $2
80107ae7:	6a 02                	push   $0x2
  jmp alltraps
80107ae9:	e9 52 f9 ff ff       	jmp    80107440 <alltraps>

80107aee <vector3>:
.globl vector3
vector3:
  pushl $0
80107aee:	6a 00                	push   $0x0
  pushl $3
80107af0:	6a 03                	push   $0x3
  jmp alltraps
80107af2:	e9 49 f9 ff ff       	jmp    80107440 <alltraps>

80107af7 <vector4>:
.globl vector4
vector4:
  pushl $0
80107af7:	6a 00                	push   $0x0
  pushl $4
80107af9:	6a 04                	push   $0x4
  jmp alltraps
80107afb:	e9 40 f9 ff ff       	jmp    80107440 <alltraps>

80107b00 <vector5>:
.globl vector5
vector5:
  pushl $0
80107b00:	6a 00                	push   $0x0
  pushl $5
80107b02:	6a 05                	push   $0x5
  jmp alltraps
80107b04:	e9 37 f9 ff ff       	jmp    80107440 <alltraps>

80107b09 <vector6>:
.globl vector6
vector6:
  pushl $0
80107b09:	6a 00                	push   $0x0
  pushl $6
80107b0b:	6a 06                	push   $0x6
  jmp alltraps
80107b0d:	e9 2e f9 ff ff       	jmp    80107440 <alltraps>

80107b12 <vector7>:
.globl vector7
vector7:
  pushl $0
80107b12:	6a 00                	push   $0x0
  pushl $7
80107b14:	6a 07                	push   $0x7
  jmp alltraps
80107b16:	e9 25 f9 ff ff       	jmp    80107440 <alltraps>

80107b1b <vector8>:
.globl vector8
vector8:
  pushl $8
80107b1b:	6a 08                	push   $0x8
  jmp alltraps
80107b1d:	e9 1e f9 ff ff       	jmp    80107440 <alltraps>

80107b22 <vector9>:
.globl vector9
vector9:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $9
80107b24:	6a 09                	push   $0x9
  jmp alltraps
80107b26:	e9 15 f9 ff ff       	jmp    80107440 <alltraps>

80107b2b <vector10>:
.globl vector10
vector10:
  pushl $10
80107b2b:	6a 0a                	push   $0xa
  jmp alltraps
80107b2d:	e9 0e f9 ff ff       	jmp    80107440 <alltraps>

80107b32 <vector11>:
.globl vector11
vector11:
  pushl $11
80107b32:	6a 0b                	push   $0xb
  jmp alltraps
80107b34:	e9 07 f9 ff ff       	jmp    80107440 <alltraps>

80107b39 <vector12>:
.globl vector12
vector12:
  pushl $12
80107b39:	6a 0c                	push   $0xc
  jmp alltraps
80107b3b:	e9 00 f9 ff ff       	jmp    80107440 <alltraps>

80107b40 <vector13>:
.globl vector13
vector13:
  pushl $13
80107b40:	6a 0d                	push   $0xd
  jmp alltraps
80107b42:	e9 f9 f8 ff ff       	jmp    80107440 <alltraps>

80107b47 <vector14>:
.globl vector14
vector14:
  pushl $14
80107b47:	6a 0e                	push   $0xe
  jmp alltraps
80107b49:	e9 f2 f8 ff ff       	jmp    80107440 <alltraps>

80107b4e <vector15>:
.globl vector15
vector15:
  pushl $0
80107b4e:	6a 00                	push   $0x0
  pushl $15
80107b50:	6a 0f                	push   $0xf
  jmp alltraps
80107b52:	e9 e9 f8 ff ff       	jmp    80107440 <alltraps>

80107b57 <vector16>:
.globl vector16
vector16:
  pushl $0
80107b57:	6a 00                	push   $0x0
  pushl $16
80107b59:	6a 10                	push   $0x10
  jmp alltraps
80107b5b:	e9 e0 f8 ff ff       	jmp    80107440 <alltraps>

80107b60 <vector17>:
.globl vector17
vector17:
  pushl $17
80107b60:	6a 11                	push   $0x11
  jmp alltraps
80107b62:	e9 d9 f8 ff ff       	jmp    80107440 <alltraps>

80107b67 <vector18>:
.globl vector18
vector18:
  pushl $0
80107b67:	6a 00                	push   $0x0
  pushl $18
80107b69:	6a 12                	push   $0x12
  jmp alltraps
80107b6b:	e9 d0 f8 ff ff       	jmp    80107440 <alltraps>

80107b70 <vector19>:
.globl vector19
vector19:
  pushl $0
80107b70:	6a 00                	push   $0x0
  pushl $19
80107b72:	6a 13                	push   $0x13
  jmp alltraps
80107b74:	e9 c7 f8 ff ff       	jmp    80107440 <alltraps>

80107b79 <vector20>:
.globl vector20
vector20:
  pushl $0
80107b79:	6a 00                	push   $0x0
  pushl $20
80107b7b:	6a 14                	push   $0x14
  jmp alltraps
80107b7d:	e9 be f8 ff ff       	jmp    80107440 <alltraps>

80107b82 <vector21>:
.globl vector21
vector21:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $21
80107b84:	6a 15                	push   $0x15
  jmp alltraps
80107b86:	e9 b5 f8 ff ff       	jmp    80107440 <alltraps>

80107b8b <vector22>:
.globl vector22
vector22:
  pushl $0
80107b8b:	6a 00                	push   $0x0
  pushl $22
80107b8d:	6a 16                	push   $0x16
  jmp alltraps
80107b8f:	e9 ac f8 ff ff       	jmp    80107440 <alltraps>

80107b94 <vector23>:
.globl vector23
vector23:
  pushl $0
80107b94:	6a 00                	push   $0x0
  pushl $23
80107b96:	6a 17                	push   $0x17
  jmp alltraps
80107b98:	e9 a3 f8 ff ff       	jmp    80107440 <alltraps>

80107b9d <vector24>:
.globl vector24
vector24:
  pushl $0
80107b9d:	6a 00                	push   $0x0
  pushl $24
80107b9f:	6a 18                	push   $0x18
  jmp alltraps
80107ba1:	e9 9a f8 ff ff       	jmp    80107440 <alltraps>

80107ba6 <vector25>:
.globl vector25
vector25:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $25
80107ba8:	6a 19                	push   $0x19
  jmp alltraps
80107baa:	e9 91 f8 ff ff       	jmp    80107440 <alltraps>

80107baf <vector26>:
.globl vector26
vector26:
  pushl $0
80107baf:	6a 00                	push   $0x0
  pushl $26
80107bb1:	6a 1a                	push   $0x1a
  jmp alltraps
80107bb3:	e9 88 f8 ff ff       	jmp    80107440 <alltraps>

80107bb8 <vector27>:
.globl vector27
vector27:
  pushl $0
80107bb8:	6a 00                	push   $0x0
  pushl $27
80107bba:	6a 1b                	push   $0x1b
  jmp alltraps
80107bbc:	e9 7f f8 ff ff       	jmp    80107440 <alltraps>

80107bc1 <vector28>:
.globl vector28
vector28:
  pushl $0
80107bc1:	6a 00                	push   $0x0
  pushl $28
80107bc3:	6a 1c                	push   $0x1c
  jmp alltraps
80107bc5:	e9 76 f8 ff ff       	jmp    80107440 <alltraps>

80107bca <vector29>:
.globl vector29
vector29:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $29
80107bcc:	6a 1d                	push   $0x1d
  jmp alltraps
80107bce:	e9 6d f8 ff ff       	jmp    80107440 <alltraps>

80107bd3 <vector30>:
.globl vector30
vector30:
  pushl $0
80107bd3:	6a 00                	push   $0x0
  pushl $30
80107bd5:	6a 1e                	push   $0x1e
  jmp alltraps
80107bd7:	e9 64 f8 ff ff       	jmp    80107440 <alltraps>

80107bdc <vector31>:
.globl vector31
vector31:
  pushl $0
80107bdc:	6a 00                	push   $0x0
  pushl $31
80107bde:	6a 1f                	push   $0x1f
  jmp alltraps
80107be0:	e9 5b f8 ff ff       	jmp    80107440 <alltraps>

80107be5 <vector32>:
.globl vector32
vector32:
  pushl $0
80107be5:	6a 00                	push   $0x0
  pushl $32
80107be7:	6a 20                	push   $0x20
  jmp alltraps
80107be9:	e9 52 f8 ff ff       	jmp    80107440 <alltraps>

80107bee <vector33>:
.globl vector33
vector33:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $33
80107bf0:	6a 21                	push   $0x21
  jmp alltraps
80107bf2:	e9 49 f8 ff ff       	jmp    80107440 <alltraps>

80107bf7 <vector34>:
.globl vector34
vector34:
  pushl $0
80107bf7:	6a 00                	push   $0x0
  pushl $34
80107bf9:	6a 22                	push   $0x22
  jmp alltraps
80107bfb:	e9 40 f8 ff ff       	jmp    80107440 <alltraps>

80107c00 <vector35>:
.globl vector35
vector35:
  pushl $0
80107c00:	6a 00                	push   $0x0
  pushl $35
80107c02:	6a 23                	push   $0x23
  jmp alltraps
80107c04:	e9 37 f8 ff ff       	jmp    80107440 <alltraps>

80107c09 <vector36>:
.globl vector36
vector36:
  pushl $0
80107c09:	6a 00                	push   $0x0
  pushl $36
80107c0b:	6a 24                	push   $0x24
  jmp alltraps
80107c0d:	e9 2e f8 ff ff       	jmp    80107440 <alltraps>

80107c12 <vector37>:
.globl vector37
vector37:
  pushl $0
80107c12:	6a 00                	push   $0x0
  pushl $37
80107c14:	6a 25                	push   $0x25
  jmp alltraps
80107c16:	e9 25 f8 ff ff       	jmp    80107440 <alltraps>

80107c1b <vector38>:
.globl vector38
vector38:
  pushl $0
80107c1b:	6a 00                	push   $0x0
  pushl $38
80107c1d:	6a 26                	push   $0x26
  jmp alltraps
80107c1f:	e9 1c f8 ff ff       	jmp    80107440 <alltraps>

80107c24 <vector39>:
.globl vector39
vector39:
  pushl $0
80107c24:	6a 00                	push   $0x0
  pushl $39
80107c26:	6a 27                	push   $0x27
  jmp alltraps
80107c28:	e9 13 f8 ff ff       	jmp    80107440 <alltraps>

80107c2d <vector40>:
.globl vector40
vector40:
  pushl $0
80107c2d:	6a 00                	push   $0x0
  pushl $40
80107c2f:	6a 28                	push   $0x28
  jmp alltraps
80107c31:	e9 0a f8 ff ff       	jmp    80107440 <alltraps>

80107c36 <vector41>:
.globl vector41
vector41:
  pushl $0
80107c36:	6a 00                	push   $0x0
  pushl $41
80107c38:	6a 29                	push   $0x29
  jmp alltraps
80107c3a:	e9 01 f8 ff ff       	jmp    80107440 <alltraps>

80107c3f <vector42>:
.globl vector42
vector42:
  pushl $0
80107c3f:	6a 00                	push   $0x0
  pushl $42
80107c41:	6a 2a                	push   $0x2a
  jmp alltraps
80107c43:	e9 f8 f7 ff ff       	jmp    80107440 <alltraps>

80107c48 <vector43>:
.globl vector43
vector43:
  pushl $0
80107c48:	6a 00                	push   $0x0
  pushl $43
80107c4a:	6a 2b                	push   $0x2b
  jmp alltraps
80107c4c:	e9 ef f7 ff ff       	jmp    80107440 <alltraps>

80107c51 <vector44>:
.globl vector44
vector44:
  pushl $0
80107c51:	6a 00                	push   $0x0
  pushl $44
80107c53:	6a 2c                	push   $0x2c
  jmp alltraps
80107c55:	e9 e6 f7 ff ff       	jmp    80107440 <alltraps>

80107c5a <vector45>:
.globl vector45
vector45:
  pushl $0
80107c5a:	6a 00                	push   $0x0
  pushl $45
80107c5c:	6a 2d                	push   $0x2d
  jmp alltraps
80107c5e:	e9 dd f7 ff ff       	jmp    80107440 <alltraps>

80107c63 <vector46>:
.globl vector46
vector46:
  pushl $0
80107c63:	6a 00                	push   $0x0
  pushl $46
80107c65:	6a 2e                	push   $0x2e
  jmp alltraps
80107c67:	e9 d4 f7 ff ff       	jmp    80107440 <alltraps>

80107c6c <vector47>:
.globl vector47
vector47:
  pushl $0
80107c6c:	6a 00                	push   $0x0
  pushl $47
80107c6e:	6a 2f                	push   $0x2f
  jmp alltraps
80107c70:	e9 cb f7 ff ff       	jmp    80107440 <alltraps>

80107c75 <vector48>:
.globl vector48
vector48:
  pushl $0
80107c75:	6a 00                	push   $0x0
  pushl $48
80107c77:	6a 30                	push   $0x30
  jmp alltraps
80107c79:	e9 c2 f7 ff ff       	jmp    80107440 <alltraps>

80107c7e <vector49>:
.globl vector49
vector49:
  pushl $0
80107c7e:	6a 00                	push   $0x0
  pushl $49
80107c80:	6a 31                	push   $0x31
  jmp alltraps
80107c82:	e9 b9 f7 ff ff       	jmp    80107440 <alltraps>

80107c87 <vector50>:
.globl vector50
vector50:
  pushl $0
80107c87:	6a 00                	push   $0x0
  pushl $50
80107c89:	6a 32                	push   $0x32
  jmp alltraps
80107c8b:	e9 b0 f7 ff ff       	jmp    80107440 <alltraps>

80107c90 <vector51>:
.globl vector51
vector51:
  pushl $0
80107c90:	6a 00                	push   $0x0
  pushl $51
80107c92:	6a 33                	push   $0x33
  jmp alltraps
80107c94:	e9 a7 f7 ff ff       	jmp    80107440 <alltraps>

80107c99 <vector52>:
.globl vector52
vector52:
  pushl $0
80107c99:	6a 00                	push   $0x0
  pushl $52
80107c9b:	6a 34                	push   $0x34
  jmp alltraps
80107c9d:	e9 9e f7 ff ff       	jmp    80107440 <alltraps>

80107ca2 <vector53>:
.globl vector53
vector53:
  pushl $0
80107ca2:	6a 00                	push   $0x0
  pushl $53
80107ca4:	6a 35                	push   $0x35
  jmp alltraps
80107ca6:	e9 95 f7 ff ff       	jmp    80107440 <alltraps>

80107cab <vector54>:
.globl vector54
vector54:
  pushl $0
80107cab:	6a 00                	push   $0x0
  pushl $54
80107cad:	6a 36                	push   $0x36
  jmp alltraps
80107caf:	e9 8c f7 ff ff       	jmp    80107440 <alltraps>

80107cb4 <vector55>:
.globl vector55
vector55:
  pushl $0
80107cb4:	6a 00                	push   $0x0
  pushl $55
80107cb6:	6a 37                	push   $0x37
  jmp alltraps
80107cb8:	e9 83 f7 ff ff       	jmp    80107440 <alltraps>

80107cbd <vector56>:
.globl vector56
vector56:
  pushl $0
80107cbd:	6a 00                	push   $0x0
  pushl $56
80107cbf:	6a 38                	push   $0x38
  jmp alltraps
80107cc1:	e9 7a f7 ff ff       	jmp    80107440 <alltraps>

80107cc6 <vector57>:
.globl vector57
vector57:
  pushl $0
80107cc6:	6a 00                	push   $0x0
  pushl $57
80107cc8:	6a 39                	push   $0x39
  jmp alltraps
80107cca:	e9 71 f7 ff ff       	jmp    80107440 <alltraps>

80107ccf <vector58>:
.globl vector58
vector58:
  pushl $0
80107ccf:	6a 00                	push   $0x0
  pushl $58
80107cd1:	6a 3a                	push   $0x3a
  jmp alltraps
80107cd3:	e9 68 f7 ff ff       	jmp    80107440 <alltraps>

80107cd8 <vector59>:
.globl vector59
vector59:
  pushl $0
80107cd8:	6a 00                	push   $0x0
  pushl $59
80107cda:	6a 3b                	push   $0x3b
  jmp alltraps
80107cdc:	e9 5f f7 ff ff       	jmp    80107440 <alltraps>

80107ce1 <vector60>:
.globl vector60
vector60:
  pushl $0
80107ce1:	6a 00                	push   $0x0
  pushl $60
80107ce3:	6a 3c                	push   $0x3c
  jmp alltraps
80107ce5:	e9 56 f7 ff ff       	jmp    80107440 <alltraps>

80107cea <vector61>:
.globl vector61
vector61:
  pushl $0
80107cea:	6a 00                	push   $0x0
  pushl $61
80107cec:	6a 3d                	push   $0x3d
  jmp alltraps
80107cee:	e9 4d f7 ff ff       	jmp    80107440 <alltraps>

80107cf3 <vector62>:
.globl vector62
vector62:
  pushl $0
80107cf3:	6a 00                	push   $0x0
  pushl $62
80107cf5:	6a 3e                	push   $0x3e
  jmp alltraps
80107cf7:	e9 44 f7 ff ff       	jmp    80107440 <alltraps>

80107cfc <vector63>:
.globl vector63
vector63:
  pushl $0
80107cfc:	6a 00                	push   $0x0
  pushl $63
80107cfe:	6a 3f                	push   $0x3f
  jmp alltraps
80107d00:	e9 3b f7 ff ff       	jmp    80107440 <alltraps>

80107d05 <vector64>:
.globl vector64
vector64:
  pushl $0
80107d05:	6a 00                	push   $0x0
  pushl $64
80107d07:	6a 40                	push   $0x40
  jmp alltraps
80107d09:	e9 32 f7 ff ff       	jmp    80107440 <alltraps>

80107d0e <vector65>:
.globl vector65
vector65:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $65
80107d10:	6a 41                	push   $0x41
  jmp alltraps
80107d12:	e9 29 f7 ff ff       	jmp    80107440 <alltraps>

80107d17 <vector66>:
.globl vector66
vector66:
  pushl $0
80107d17:	6a 00                	push   $0x0
  pushl $66
80107d19:	6a 42                	push   $0x42
  jmp alltraps
80107d1b:	e9 20 f7 ff ff       	jmp    80107440 <alltraps>

80107d20 <vector67>:
.globl vector67
vector67:
  pushl $0
80107d20:	6a 00                	push   $0x0
  pushl $67
80107d22:	6a 43                	push   $0x43
  jmp alltraps
80107d24:	e9 17 f7 ff ff       	jmp    80107440 <alltraps>

80107d29 <vector68>:
.globl vector68
vector68:
  pushl $0
80107d29:	6a 00                	push   $0x0
  pushl $68
80107d2b:	6a 44                	push   $0x44
  jmp alltraps
80107d2d:	e9 0e f7 ff ff       	jmp    80107440 <alltraps>

80107d32 <vector69>:
.globl vector69
vector69:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $69
80107d34:	6a 45                	push   $0x45
  jmp alltraps
80107d36:	e9 05 f7 ff ff       	jmp    80107440 <alltraps>

80107d3b <vector70>:
.globl vector70
vector70:
  pushl $0
80107d3b:	6a 00                	push   $0x0
  pushl $70
80107d3d:	6a 46                	push   $0x46
  jmp alltraps
80107d3f:	e9 fc f6 ff ff       	jmp    80107440 <alltraps>

80107d44 <vector71>:
.globl vector71
vector71:
  pushl $0
80107d44:	6a 00                	push   $0x0
  pushl $71
80107d46:	6a 47                	push   $0x47
  jmp alltraps
80107d48:	e9 f3 f6 ff ff       	jmp    80107440 <alltraps>

80107d4d <vector72>:
.globl vector72
vector72:
  pushl $0
80107d4d:	6a 00                	push   $0x0
  pushl $72
80107d4f:	6a 48                	push   $0x48
  jmp alltraps
80107d51:	e9 ea f6 ff ff       	jmp    80107440 <alltraps>

80107d56 <vector73>:
.globl vector73
vector73:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $73
80107d58:	6a 49                	push   $0x49
  jmp alltraps
80107d5a:	e9 e1 f6 ff ff       	jmp    80107440 <alltraps>

80107d5f <vector74>:
.globl vector74
vector74:
  pushl $0
80107d5f:	6a 00                	push   $0x0
  pushl $74
80107d61:	6a 4a                	push   $0x4a
  jmp alltraps
80107d63:	e9 d8 f6 ff ff       	jmp    80107440 <alltraps>

80107d68 <vector75>:
.globl vector75
vector75:
  pushl $0
80107d68:	6a 00                	push   $0x0
  pushl $75
80107d6a:	6a 4b                	push   $0x4b
  jmp alltraps
80107d6c:	e9 cf f6 ff ff       	jmp    80107440 <alltraps>

80107d71 <vector76>:
.globl vector76
vector76:
  pushl $0
80107d71:	6a 00                	push   $0x0
  pushl $76
80107d73:	6a 4c                	push   $0x4c
  jmp alltraps
80107d75:	e9 c6 f6 ff ff       	jmp    80107440 <alltraps>

80107d7a <vector77>:
.globl vector77
vector77:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $77
80107d7c:	6a 4d                	push   $0x4d
  jmp alltraps
80107d7e:	e9 bd f6 ff ff       	jmp    80107440 <alltraps>

80107d83 <vector78>:
.globl vector78
vector78:
  pushl $0
80107d83:	6a 00                	push   $0x0
  pushl $78
80107d85:	6a 4e                	push   $0x4e
  jmp alltraps
80107d87:	e9 b4 f6 ff ff       	jmp    80107440 <alltraps>

80107d8c <vector79>:
.globl vector79
vector79:
  pushl $0
80107d8c:	6a 00                	push   $0x0
  pushl $79
80107d8e:	6a 4f                	push   $0x4f
  jmp alltraps
80107d90:	e9 ab f6 ff ff       	jmp    80107440 <alltraps>

80107d95 <vector80>:
.globl vector80
vector80:
  pushl $0
80107d95:	6a 00                	push   $0x0
  pushl $80
80107d97:	6a 50                	push   $0x50
  jmp alltraps
80107d99:	e9 a2 f6 ff ff       	jmp    80107440 <alltraps>

80107d9e <vector81>:
.globl vector81
vector81:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $81
80107da0:	6a 51                	push   $0x51
  jmp alltraps
80107da2:	e9 99 f6 ff ff       	jmp    80107440 <alltraps>

80107da7 <vector82>:
.globl vector82
vector82:
  pushl $0
80107da7:	6a 00                	push   $0x0
  pushl $82
80107da9:	6a 52                	push   $0x52
  jmp alltraps
80107dab:	e9 90 f6 ff ff       	jmp    80107440 <alltraps>

80107db0 <vector83>:
.globl vector83
vector83:
  pushl $0
80107db0:	6a 00                	push   $0x0
  pushl $83
80107db2:	6a 53                	push   $0x53
  jmp alltraps
80107db4:	e9 87 f6 ff ff       	jmp    80107440 <alltraps>

80107db9 <vector84>:
.globl vector84
vector84:
  pushl $0
80107db9:	6a 00                	push   $0x0
  pushl $84
80107dbb:	6a 54                	push   $0x54
  jmp alltraps
80107dbd:	e9 7e f6 ff ff       	jmp    80107440 <alltraps>

80107dc2 <vector85>:
.globl vector85
vector85:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $85
80107dc4:	6a 55                	push   $0x55
  jmp alltraps
80107dc6:	e9 75 f6 ff ff       	jmp    80107440 <alltraps>

80107dcb <vector86>:
.globl vector86
vector86:
  pushl $0
80107dcb:	6a 00                	push   $0x0
  pushl $86
80107dcd:	6a 56                	push   $0x56
  jmp alltraps
80107dcf:	e9 6c f6 ff ff       	jmp    80107440 <alltraps>

80107dd4 <vector87>:
.globl vector87
vector87:
  pushl $0
80107dd4:	6a 00                	push   $0x0
  pushl $87
80107dd6:	6a 57                	push   $0x57
  jmp alltraps
80107dd8:	e9 63 f6 ff ff       	jmp    80107440 <alltraps>

80107ddd <vector88>:
.globl vector88
vector88:
  pushl $0
80107ddd:	6a 00                	push   $0x0
  pushl $88
80107ddf:	6a 58                	push   $0x58
  jmp alltraps
80107de1:	e9 5a f6 ff ff       	jmp    80107440 <alltraps>

80107de6 <vector89>:
.globl vector89
vector89:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $89
80107de8:	6a 59                	push   $0x59
  jmp alltraps
80107dea:	e9 51 f6 ff ff       	jmp    80107440 <alltraps>

80107def <vector90>:
.globl vector90
vector90:
  pushl $0
80107def:	6a 00                	push   $0x0
  pushl $90
80107df1:	6a 5a                	push   $0x5a
  jmp alltraps
80107df3:	e9 48 f6 ff ff       	jmp    80107440 <alltraps>

80107df8 <vector91>:
.globl vector91
vector91:
  pushl $0
80107df8:	6a 00                	push   $0x0
  pushl $91
80107dfa:	6a 5b                	push   $0x5b
  jmp alltraps
80107dfc:	e9 3f f6 ff ff       	jmp    80107440 <alltraps>

80107e01 <vector92>:
.globl vector92
vector92:
  pushl $0
80107e01:	6a 00                	push   $0x0
  pushl $92
80107e03:	6a 5c                	push   $0x5c
  jmp alltraps
80107e05:	e9 36 f6 ff ff       	jmp    80107440 <alltraps>

80107e0a <vector93>:
.globl vector93
vector93:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $93
80107e0c:	6a 5d                	push   $0x5d
  jmp alltraps
80107e0e:	e9 2d f6 ff ff       	jmp    80107440 <alltraps>

80107e13 <vector94>:
.globl vector94
vector94:
  pushl $0
80107e13:	6a 00                	push   $0x0
  pushl $94
80107e15:	6a 5e                	push   $0x5e
  jmp alltraps
80107e17:	e9 24 f6 ff ff       	jmp    80107440 <alltraps>

80107e1c <vector95>:
.globl vector95
vector95:
  pushl $0
80107e1c:	6a 00                	push   $0x0
  pushl $95
80107e1e:	6a 5f                	push   $0x5f
  jmp alltraps
80107e20:	e9 1b f6 ff ff       	jmp    80107440 <alltraps>

80107e25 <vector96>:
.globl vector96
vector96:
  pushl $0
80107e25:	6a 00                	push   $0x0
  pushl $96
80107e27:	6a 60                	push   $0x60
  jmp alltraps
80107e29:	e9 12 f6 ff ff       	jmp    80107440 <alltraps>

80107e2e <vector97>:
.globl vector97
vector97:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $97
80107e30:	6a 61                	push   $0x61
  jmp alltraps
80107e32:	e9 09 f6 ff ff       	jmp    80107440 <alltraps>

80107e37 <vector98>:
.globl vector98
vector98:
  pushl $0
80107e37:	6a 00                	push   $0x0
  pushl $98
80107e39:	6a 62                	push   $0x62
  jmp alltraps
80107e3b:	e9 00 f6 ff ff       	jmp    80107440 <alltraps>

80107e40 <vector99>:
.globl vector99
vector99:
  pushl $0
80107e40:	6a 00                	push   $0x0
  pushl $99
80107e42:	6a 63                	push   $0x63
  jmp alltraps
80107e44:	e9 f7 f5 ff ff       	jmp    80107440 <alltraps>

80107e49 <vector100>:
.globl vector100
vector100:
  pushl $0
80107e49:	6a 00                	push   $0x0
  pushl $100
80107e4b:	6a 64                	push   $0x64
  jmp alltraps
80107e4d:	e9 ee f5 ff ff       	jmp    80107440 <alltraps>

80107e52 <vector101>:
.globl vector101
vector101:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $101
80107e54:	6a 65                	push   $0x65
  jmp alltraps
80107e56:	e9 e5 f5 ff ff       	jmp    80107440 <alltraps>

80107e5b <vector102>:
.globl vector102
vector102:
  pushl $0
80107e5b:	6a 00                	push   $0x0
  pushl $102
80107e5d:	6a 66                	push   $0x66
  jmp alltraps
80107e5f:	e9 dc f5 ff ff       	jmp    80107440 <alltraps>

80107e64 <vector103>:
.globl vector103
vector103:
  pushl $0
80107e64:	6a 00                	push   $0x0
  pushl $103
80107e66:	6a 67                	push   $0x67
  jmp alltraps
80107e68:	e9 d3 f5 ff ff       	jmp    80107440 <alltraps>

80107e6d <vector104>:
.globl vector104
vector104:
  pushl $0
80107e6d:	6a 00                	push   $0x0
  pushl $104
80107e6f:	6a 68                	push   $0x68
  jmp alltraps
80107e71:	e9 ca f5 ff ff       	jmp    80107440 <alltraps>

80107e76 <vector105>:
.globl vector105
vector105:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $105
80107e78:	6a 69                	push   $0x69
  jmp alltraps
80107e7a:	e9 c1 f5 ff ff       	jmp    80107440 <alltraps>

80107e7f <vector106>:
.globl vector106
vector106:
  pushl $0
80107e7f:	6a 00                	push   $0x0
  pushl $106
80107e81:	6a 6a                	push   $0x6a
  jmp alltraps
80107e83:	e9 b8 f5 ff ff       	jmp    80107440 <alltraps>

80107e88 <vector107>:
.globl vector107
vector107:
  pushl $0
80107e88:	6a 00                	push   $0x0
  pushl $107
80107e8a:	6a 6b                	push   $0x6b
  jmp alltraps
80107e8c:	e9 af f5 ff ff       	jmp    80107440 <alltraps>

80107e91 <vector108>:
.globl vector108
vector108:
  pushl $0
80107e91:	6a 00                	push   $0x0
  pushl $108
80107e93:	6a 6c                	push   $0x6c
  jmp alltraps
80107e95:	e9 a6 f5 ff ff       	jmp    80107440 <alltraps>

80107e9a <vector109>:
.globl vector109
vector109:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $109
80107e9c:	6a 6d                	push   $0x6d
  jmp alltraps
80107e9e:	e9 9d f5 ff ff       	jmp    80107440 <alltraps>

80107ea3 <vector110>:
.globl vector110
vector110:
  pushl $0
80107ea3:	6a 00                	push   $0x0
  pushl $110
80107ea5:	6a 6e                	push   $0x6e
  jmp alltraps
80107ea7:	e9 94 f5 ff ff       	jmp    80107440 <alltraps>

80107eac <vector111>:
.globl vector111
vector111:
  pushl $0
80107eac:	6a 00                	push   $0x0
  pushl $111
80107eae:	6a 6f                	push   $0x6f
  jmp alltraps
80107eb0:	e9 8b f5 ff ff       	jmp    80107440 <alltraps>

80107eb5 <vector112>:
.globl vector112
vector112:
  pushl $0
80107eb5:	6a 00                	push   $0x0
  pushl $112
80107eb7:	6a 70                	push   $0x70
  jmp alltraps
80107eb9:	e9 82 f5 ff ff       	jmp    80107440 <alltraps>

80107ebe <vector113>:
.globl vector113
vector113:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $113
80107ec0:	6a 71                	push   $0x71
  jmp alltraps
80107ec2:	e9 79 f5 ff ff       	jmp    80107440 <alltraps>

80107ec7 <vector114>:
.globl vector114
vector114:
  pushl $0
80107ec7:	6a 00                	push   $0x0
  pushl $114
80107ec9:	6a 72                	push   $0x72
  jmp alltraps
80107ecb:	e9 70 f5 ff ff       	jmp    80107440 <alltraps>

80107ed0 <vector115>:
.globl vector115
vector115:
  pushl $0
80107ed0:	6a 00                	push   $0x0
  pushl $115
80107ed2:	6a 73                	push   $0x73
  jmp alltraps
80107ed4:	e9 67 f5 ff ff       	jmp    80107440 <alltraps>

80107ed9 <vector116>:
.globl vector116
vector116:
  pushl $0
80107ed9:	6a 00                	push   $0x0
  pushl $116
80107edb:	6a 74                	push   $0x74
  jmp alltraps
80107edd:	e9 5e f5 ff ff       	jmp    80107440 <alltraps>

80107ee2 <vector117>:
.globl vector117
vector117:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $117
80107ee4:	6a 75                	push   $0x75
  jmp alltraps
80107ee6:	e9 55 f5 ff ff       	jmp    80107440 <alltraps>

80107eeb <vector118>:
.globl vector118
vector118:
  pushl $0
80107eeb:	6a 00                	push   $0x0
  pushl $118
80107eed:	6a 76                	push   $0x76
  jmp alltraps
80107eef:	e9 4c f5 ff ff       	jmp    80107440 <alltraps>

80107ef4 <vector119>:
.globl vector119
vector119:
  pushl $0
80107ef4:	6a 00                	push   $0x0
  pushl $119
80107ef6:	6a 77                	push   $0x77
  jmp alltraps
80107ef8:	e9 43 f5 ff ff       	jmp    80107440 <alltraps>

80107efd <vector120>:
.globl vector120
vector120:
  pushl $0
80107efd:	6a 00                	push   $0x0
  pushl $120
80107eff:	6a 78                	push   $0x78
  jmp alltraps
80107f01:	e9 3a f5 ff ff       	jmp    80107440 <alltraps>

80107f06 <vector121>:
.globl vector121
vector121:
  pushl $0
80107f06:	6a 00                	push   $0x0
  pushl $121
80107f08:	6a 79                	push   $0x79
  jmp alltraps
80107f0a:	e9 31 f5 ff ff       	jmp    80107440 <alltraps>

80107f0f <vector122>:
.globl vector122
vector122:
  pushl $0
80107f0f:	6a 00                	push   $0x0
  pushl $122
80107f11:	6a 7a                	push   $0x7a
  jmp alltraps
80107f13:	e9 28 f5 ff ff       	jmp    80107440 <alltraps>

80107f18 <vector123>:
.globl vector123
vector123:
  pushl $0
80107f18:	6a 00                	push   $0x0
  pushl $123
80107f1a:	6a 7b                	push   $0x7b
  jmp alltraps
80107f1c:	e9 1f f5 ff ff       	jmp    80107440 <alltraps>

80107f21 <vector124>:
.globl vector124
vector124:
  pushl $0
80107f21:	6a 00                	push   $0x0
  pushl $124
80107f23:	6a 7c                	push   $0x7c
  jmp alltraps
80107f25:	e9 16 f5 ff ff       	jmp    80107440 <alltraps>

80107f2a <vector125>:
.globl vector125
vector125:
  pushl $0
80107f2a:	6a 00                	push   $0x0
  pushl $125
80107f2c:	6a 7d                	push   $0x7d
  jmp alltraps
80107f2e:	e9 0d f5 ff ff       	jmp    80107440 <alltraps>

80107f33 <vector126>:
.globl vector126
vector126:
  pushl $0
80107f33:	6a 00                	push   $0x0
  pushl $126
80107f35:	6a 7e                	push   $0x7e
  jmp alltraps
80107f37:	e9 04 f5 ff ff       	jmp    80107440 <alltraps>

80107f3c <vector127>:
.globl vector127
vector127:
  pushl $0
80107f3c:	6a 00                	push   $0x0
  pushl $127
80107f3e:	6a 7f                	push   $0x7f
  jmp alltraps
80107f40:	e9 fb f4 ff ff       	jmp    80107440 <alltraps>

80107f45 <vector128>:
.globl vector128
vector128:
  pushl $0
80107f45:	6a 00                	push   $0x0
  pushl $128
80107f47:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107f4c:	e9 ef f4 ff ff       	jmp    80107440 <alltraps>

80107f51 <vector129>:
.globl vector129
vector129:
  pushl $0
80107f51:	6a 00                	push   $0x0
  pushl $129
80107f53:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107f58:	e9 e3 f4 ff ff       	jmp    80107440 <alltraps>

80107f5d <vector130>:
.globl vector130
vector130:
  pushl $0
80107f5d:	6a 00                	push   $0x0
  pushl $130
80107f5f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107f64:	e9 d7 f4 ff ff       	jmp    80107440 <alltraps>

80107f69 <vector131>:
.globl vector131
vector131:
  pushl $0
80107f69:	6a 00                	push   $0x0
  pushl $131
80107f6b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107f70:	e9 cb f4 ff ff       	jmp    80107440 <alltraps>

80107f75 <vector132>:
.globl vector132
vector132:
  pushl $0
80107f75:	6a 00                	push   $0x0
  pushl $132
80107f77:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107f7c:	e9 bf f4 ff ff       	jmp    80107440 <alltraps>

80107f81 <vector133>:
.globl vector133
vector133:
  pushl $0
80107f81:	6a 00                	push   $0x0
  pushl $133
80107f83:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107f88:	e9 b3 f4 ff ff       	jmp    80107440 <alltraps>

80107f8d <vector134>:
.globl vector134
vector134:
  pushl $0
80107f8d:	6a 00                	push   $0x0
  pushl $134
80107f8f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107f94:	e9 a7 f4 ff ff       	jmp    80107440 <alltraps>

80107f99 <vector135>:
.globl vector135
vector135:
  pushl $0
80107f99:	6a 00                	push   $0x0
  pushl $135
80107f9b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107fa0:	e9 9b f4 ff ff       	jmp    80107440 <alltraps>

80107fa5 <vector136>:
.globl vector136
vector136:
  pushl $0
80107fa5:	6a 00                	push   $0x0
  pushl $136
80107fa7:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107fac:	e9 8f f4 ff ff       	jmp    80107440 <alltraps>

80107fb1 <vector137>:
.globl vector137
vector137:
  pushl $0
80107fb1:	6a 00                	push   $0x0
  pushl $137
80107fb3:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107fb8:	e9 83 f4 ff ff       	jmp    80107440 <alltraps>

80107fbd <vector138>:
.globl vector138
vector138:
  pushl $0
80107fbd:	6a 00                	push   $0x0
  pushl $138
80107fbf:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107fc4:	e9 77 f4 ff ff       	jmp    80107440 <alltraps>

80107fc9 <vector139>:
.globl vector139
vector139:
  pushl $0
80107fc9:	6a 00                	push   $0x0
  pushl $139
80107fcb:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107fd0:	e9 6b f4 ff ff       	jmp    80107440 <alltraps>

80107fd5 <vector140>:
.globl vector140
vector140:
  pushl $0
80107fd5:	6a 00                	push   $0x0
  pushl $140
80107fd7:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107fdc:	e9 5f f4 ff ff       	jmp    80107440 <alltraps>

80107fe1 <vector141>:
.globl vector141
vector141:
  pushl $0
80107fe1:	6a 00                	push   $0x0
  pushl $141
80107fe3:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107fe8:	e9 53 f4 ff ff       	jmp    80107440 <alltraps>

80107fed <vector142>:
.globl vector142
vector142:
  pushl $0
80107fed:	6a 00                	push   $0x0
  pushl $142
80107fef:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107ff4:	e9 47 f4 ff ff       	jmp    80107440 <alltraps>

80107ff9 <vector143>:
.globl vector143
vector143:
  pushl $0
80107ff9:	6a 00                	push   $0x0
  pushl $143
80107ffb:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108000:	e9 3b f4 ff ff       	jmp    80107440 <alltraps>

80108005 <vector144>:
.globl vector144
vector144:
  pushl $0
80108005:	6a 00                	push   $0x0
  pushl $144
80108007:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010800c:	e9 2f f4 ff ff       	jmp    80107440 <alltraps>

80108011 <vector145>:
.globl vector145
vector145:
  pushl $0
80108011:	6a 00                	push   $0x0
  pushl $145
80108013:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108018:	e9 23 f4 ff ff       	jmp    80107440 <alltraps>

8010801d <vector146>:
.globl vector146
vector146:
  pushl $0
8010801d:	6a 00                	push   $0x0
  pushl $146
8010801f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108024:	e9 17 f4 ff ff       	jmp    80107440 <alltraps>

80108029 <vector147>:
.globl vector147
vector147:
  pushl $0
80108029:	6a 00                	push   $0x0
  pushl $147
8010802b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108030:	e9 0b f4 ff ff       	jmp    80107440 <alltraps>

80108035 <vector148>:
.globl vector148
vector148:
  pushl $0
80108035:	6a 00                	push   $0x0
  pushl $148
80108037:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010803c:	e9 ff f3 ff ff       	jmp    80107440 <alltraps>

80108041 <vector149>:
.globl vector149
vector149:
  pushl $0
80108041:	6a 00                	push   $0x0
  pushl $149
80108043:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108048:	e9 f3 f3 ff ff       	jmp    80107440 <alltraps>

8010804d <vector150>:
.globl vector150
vector150:
  pushl $0
8010804d:	6a 00                	push   $0x0
  pushl $150
8010804f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108054:	e9 e7 f3 ff ff       	jmp    80107440 <alltraps>

80108059 <vector151>:
.globl vector151
vector151:
  pushl $0
80108059:	6a 00                	push   $0x0
  pushl $151
8010805b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108060:	e9 db f3 ff ff       	jmp    80107440 <alltraps>

80108065 <vector152>:
.globl vector152
vector152:
  pushl $0
80108065:	6a 00                	push   $0x0
  pushl $152
80108067:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010806c:	e9 cf f3 ff ff       	jmp    80107440 <alltraps>

80108071 <vector153>:
.globl vector153
vector153:
  pushl $0
80108071:	6a 00                	push   $0x0
  pushl $153
80108073:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108078:	e9 c3 f3 ff ff       	jmp    80107440 <alltraps>

8010807d <vector154>:
.globl vector154
vector154:
  pushl $0
8010807d:	6a 00                	push   $0x0
  pushl $154
8010807f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108084:	e9 b7 f3 ff ff       	jmp    80107440 <alltraps>

80108089 <vector155>:
.globl vector155
vector155:
  pushl $0
80108089:	6a 00                	push   $0x0
  pushl $155
8010808b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108090:	e9 ab f3 ff ff       	jmp    80107440 <alltraps>

80108095 <vector156>:
.globl vector156
vector156:
  pushl $0
80108095:	6a 00                	push   $0x0
  pushl $156
80108097:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010809c:	e9 9f f3 ff ff       	jmp    80107440 <alltraps>

801080a1 <vector157>:
.globl vector157
vector157:
  pushl $0
801080a1:	6a 00                	push   $0x0
  pushl $157
801080a3:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801080a8:	e9 93 f3 ff ff       	jmp    80107440 <alltraps>

801080ad <vector158>:
.globl vector158
vector158:
  pushl $0
801080ad:	6a 00                	push   $0x0
  pushl $158
801080af:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801080b4:	e9 87 f3 ff ff       	jmp    80107440 <alltraps>

801080b9 <vector159>:
.globl vector159
vector159:
  pushl $0
801080b9:	6a 00                	push   $0x0
  pushl $159
801080bb:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801080c0:	e9 7b f3 ff ff       	jmp    80107440 <alltraps>

801080c5 <vector160>:
.globl vector160
vector160:
  pushl $0
801080c5:	6a 00                	push   $0x0
  pushl $160
801080c7:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801080cc:	e9 6f f3 ff ff       	jmp    80107440 <alltraps>

801080d1 <vector161>:
.globl vector161
vector161:
  pushl $0
801080d1:	6a 00                	push   $0x0
  pushl $161
801080d3:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801080d8:	e9 63 f3 ff ff       	jmp    80107440 <alltraps>

801080dd <vector162>:
.globl vector162
vector162:
  pushl $0
801080dd:	6a 00                	push   $0x0
  pushl $162
801080df:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801080e4:	e9 57 f3 ff ff       	jmp    80107440 <alltraps>

801080e9 <vector163>:
.globl vector163
vector163:
  pushl $0
801080e9:	6a 00                	push   $0x0
  pushl $163
801080eb:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801080f0:	e9 4b f3 ff ff       	jmp    80107440 <alltraps>

801080f5 <vector164>:
.globl vector164
vector164:
  pushl $0
801080f5:	6a 00                	push   $0x0
  pushl $164
801080f7:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801080fc:	e9 3f f3 ff ff       	jmp    80107440 <alltraps>

80108101 <vector165>:
.globl vector165
vector165:
  pushl $0
80108101:	6a 00                	push   $0x0
  pushl $165
80108103:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108108:	e9 33 f3 ff ff       	jmp    80107440 <alltraps>

8010810d <vector166>:
.globl vector166
vector166:
  pushl $0
8010810d:	6a 00                	push   $0x0
  pushl $166
8010810f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108114:	e9 27 f3 ff ff       	jmp    80107440 <alltraps>

80108119 <vector167>:
.globl vector167
vector167:
  pushl $0
80108119:	6a 00                	push   $0x0
  pushl $167
8010811b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108120:	e9 1b f3 ff ff       	jmp    80107440 <alltraps>

80108125 <vector168>:
.globl vector168
vector168:
  pushl $0
80108125:	6a 00                	push   $0x0
  pushl $168
80108127:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010812c:	e9 0f f3 ff ff       	jmp    80107440 <alltraps>

80108131 <vector169>:
.globl vector169
vector169:
  pushl $0
80108131:	6a 00                	push   $0x0
  pushl $169
80108133:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108138:	e9 03 f3 ff ff       	jmp    80107440 <alltraps>

8010813d <vector170>:
.globl vector170
vector170:
  pushl $0
8010813d:	6a 00                	push   $0x0
  pushl $170
8010813f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108144:	e9 f7 f2 ff ff       	jmp    80107440 <alltraps>

80108149 <vector171>:
.globl vector171
vector171:
  pushl $0
80108149:	6a 00                	push   $0x0
  pushl $171
8010814b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108150:	e9 eb f2 ff ff       	jmp    80107440 <alltraps>

80108155 <vector172>:
.globl vector172
vector172:
  pushl $0
80108155:	6a 00                	push   $0x0
  pushl $172
80108157:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010815c:	e9 df f2 ff ff       	jmp    80107440 <alltraps>

80108161 <vector173>:
.globl vector173
vector173:
  pushl $0
80108161:	6a 00                	push   $0x0
  pushl $173
80108163:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108168:	e9 d3 f2 ff ff       	jmp    80107440 <alltraps>

8010816d <vector174>:
.globl vector174
vector174:
  pushl $0
8010816d:	6a 00                	push   $0x0
  pushl $174
8010816f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108174:	e9 c7 f2 ff ff       	jmp    80107440 <alltraps>

80108179 <vector175>:
.globl vector175
vector175:
  pushl $0
80108179:	6a 00                	push   $0x0
  pushl $175
8010817b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108180:	e9 bb f2 ff ff       	jmp    80107440 <alltraps>

80108185 <vector176>:
.globl vector176
vector176:
  pushl $0
80108185:	6a 00                	push   $0x0
  pushl $176
80108187:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010818c:	e9 af f2 ff ff       	jmp    80107440 <alltraps>

80108191 <vector177>:
.globl vector177
vector177:
  pushl $0
80108191:	6a 00                	push   $0x0
  pushl $177
80108193:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108198:	e9 a3 f2 ff ff       	jmp    80107440 <alltraps>

8010819d <vector178>:
.globl vector178
vector178:
  pushl $0
8010819d:	6a 00                	push   $0x0
  pushl $178
8010819f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801081a4:	e9 97 f2 ff ff       	jmp    80107440 <alltraps>

801081a9 <vector179>:
.globl vector179
vector179:
  pushl $0
801081a9:	6a 00                	push   $0x0
  pushl $179
801081ab:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801081b0:	e9 8b f2 ff ff       	jmp    80107440 <alltraps>

801081b5 <vector180>:
.globl vector180
vector180:
  pushl $0
801081b5:	6a 00                	push   $0x0
  pushl $180
801081b7:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801081bc:	e9 7f f2 ff ff       	jmp    80107440 <alltraps>

801081c1 <vector181>:
.globl vector181
vector181:
  pushl $0
801081c1:	6a 00                	push   $0x0
  pushl $181
801081c3:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801081c8:	e9 73 f2 ff ff       	jmp    80107440 <alltraps>

801081cd <vector182>:
.globl vector182
vector182:
  pushl $0
801081cd:	6a 00                	push   $0x0
  pushl $182
801081cf:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801081d4:	e9 67 f2 ff ff       	jmp    80107440 <alltraps>

801081d9 <vector183>:
.globl vector183
vector183:
  pushl $0
801081d9:	6a 00                	push   $0x0
  pushl $183
801081db:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801081e0:	e9 5b f2 ff ff       	jmp    80107440 <alltraps>

801081e5 <vector184>:
.globl vector184
vector184:
  pushl $0
801081e5:	6a 00                	push   $0x0
  pushl $184
801081e7:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801081ec:	e9 4f f2 ff ff       	jmp    80107440 <alltraps>

801081f1 <vector185>:
.globl vector185
vector185:
  pushl $0
801081f1:	6a 00                	push   $0x0
  pushl $185
801081f3:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801081f8:	e9 43 f2 ff ff       	jmp    80107440 <alltraps>

801081fd <vector186>:
.globl vector186
vector186:
  pushl $0
801081fd:	6a 00                	push   $0x0
  pushl $186
801081ff:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108204:	e9 37 f2 ff ff       	jmp    80107440 <alltraps>

80108209 <vector187>:
.globl vector187
vector187:
  pushl $0
80108209:	6a 00                	push   $0x0
  pushl $187
8010820b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108210:	e9 2b f2 ff ff       	jmp    80107440 <alltraps>

80108215 <vector188>:
.globl vector188
vector188:
  pushl $0
80108215:	6a 00                	push   $0x0
  pushl $188
80108217:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010821c:	e9 1f f2 ff ff       	jmp    80107440 <alltraps>

80108221 <vector189>:
.globl vector189
vector189:
  pushl $0
80108221:	6a 00                	push   $0x0
  pushl $189
80108223:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108228:	e9 13 f2 ff ff       	jmp    80107440 <alltraps>

8010822d <vector190>:
.globl vector190
vector190:
  pushl $0
8010822d:	6a 00                	push   $0x0
  pushl $190
8010822f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108234:	e9 07 f2 ff ff       	jmp    80107440 <alltraps>

80108239 <vector191>:
.globl vector191
vector191:
  pushl $0
80108239:	6a 00                	push   $0x0
  pushl $191
8010823b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108240:	e9 fb f1 ff ff       	jmp    80107440 <alltraps>

80108245 <vector192>:
.globl vector192
vector192:
  pushl $0
80108245:	6a 00                	push   $0x0
  pushl $192
80108247:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010824c:	e9 ef f1 ff ff       	jmp    80107440 <alltraps>

80108251 <vector193>:
.globl vector193
vector193:
  pushl $0
80108251:	6a 00                	push   $0x0
  pushl $193
80108253:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108258:	e9 e3 f1 ff ff       	jmp    80107440 <alltraps>

8010825d <vector194>:
.globl vector194
vector194:
  pushl $0
8010825d:	6a 00                	push   $0x0
  pushl $194
8010825f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108264:	e9 d7 f1 ff ff       	jmp    80107440 <alltraps>

80108269 <vector195>:
.globl vector195
vector195:
  pushl $0
80108269:	6a 00                	push   $0x0
  pushl $195
8010826b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108270:	e9 cb f1 ff ff       	jmp    80107440 <alltraps>

80108275 <vector196>:
.globl vector196
vector196:
  pushl $0
80108275:	6a 00                	push   $0x0
  pushl $196
80108277:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010827c:	e9 bf f1 ff ff       	jmp    80107440 <alltraps>

80108281 <vector197>:
.globl vector197
vector197:
  pushl $0
80108281:	6a 00                	push   $0x0
  pushl $197
80108283:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108288:	e9 b3 f1 ff ff       	jmp    80107440 <alltraps>

8010828d <vector198>:
.globl vector198
vector198:
  pushl $0
8010828d:	6a 00                	push   $0x0
  pushl $198
8010828f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108294:	e9 a7 f1 ff ff       	jmp    80107440 <alltraps>

80108299 <vector199>:
.globl vector199
vector199:
  pushl $0
80108299:	6a 00                	push   $0x0
  pushl $199
8010829b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801082a0:	e9 9b f1 ff ff       	jmp    80107440 <alltraps>

801082a5 <vector200>:
.globl vector200
vector200:
  pushl $0
801082a5:	6a 00                	push   $0x0
  pushl $200
801082a7:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801082ac:	e9 8f f1 ff ff       	jmp    80107440 <alltraps>

801082b1 <vector201>:
.globl vector201
vector201:
  pushl $0
801082b1:	6a 00                	push   $0x0
  pushl $201
801082b3:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801082b8:	e9 83 f1 ff ff       	jmp    80107440 <alltraps>

801082bd <vector202>:
.globl vector202
vector202:
  pushl $0
801082bd:	6a 00                	push   $0x0
  pushl $202
801082bf:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801082c4:	e9 77 f1 ff ff       	jmp    80107440 <alltraps>

801082c9 <vector203>:
.globl vector203
vector203:
  pushl $0
801082c9:	6a 00                	push   $0x0
  pushl $203
801082cb:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801082d0:	e9 6b f1 ff ff       	jmp    80107440 <alltraps>

801082d5 <vector204>:
.globl vector204
vector204:
  pushl $0
801082d5:	6a 00                	push   $0x0
  pushl $204
801082d7:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801082dc:	e9 5f f1 ff ff       	jmp    80107440 <alltraps>

801082e1 <vector205>:
.globl vector205
vector205:
  pushl $0
801082e1:	6a 00                	push   $0x0
  pushl $205
801082e3:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801082e8:	e9 53 f1 ff ff       	jmp    80107440 <alltraps>

801082ed <vector206>:
.globl vector206
vector206:
  pushl $0
801082ed:	6a 00                	push   $0x0
  pushl $206
801082ef:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801082f4:	e9 47 f1 ff ff       	jmp    80107440 <alltraps>

801082f9 <vector207>:
.globl vector207
vector207:
  pushl $0
801082f9:	6a 00                	push   $0x0
  pushl $207
801082fb:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108300:	e9 3b f1 ff ff       	jmp    80107440 <alltraps>

80108305 <vector208>:
.globl vector208
vector208:
  pushl $0
80108305:	6a 00                	push   $0x0
  pushl $208
80108307:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010830c:	e9 2f f1 ff ff       	jmp    80107440 <alltraps>

80108311 <vector209>:
.globl vector209
vector209:
  pushl $0
80108311:	6a 00                	push   $0x0
  pushl $209
80108313:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108318:	e9 23 f1 ff ff       	jmp    80107440 <alltraps>

8010831d <vector210>:
.globl vector210
vector210:
  pushl $0
8010831d:	6a 00                	push   $0x0
  pushl $210
8010831f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108324:	e9 17 f1 ff ff       	jmp    80107440 <alltraps>

80108329 <vector211>:
.globl vector211
vector211:
  pushl $0
80108329:	6a 00                	push   $0x0
  pushl $211
8010832b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108330:	e9 0b f1 ff ff       	jmp    80107440 <alltraps>

80108335 <vector212>:
.globl vector212
vector212:
  pushl $0
80108335:	6a 00                	push   $0x0
  pushl $212
80108337:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010833c:	e9 ff f0 ff ff       	jmp    80107440 <alltraps>

80108341 <vector213>:
.globl vector213
vector213:
  pushl $0
80108341:	6a 00                	push   $0x0
  pushl $213
80108343:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108348:	e9 f3 f0 ff ff       	jmp    80107440 <alltraps>

8010834d <vector214>:
.globl vector214
vector214:
  pushl $0
8010834d:	6a 00                	push   $0x0
  pushl $214
8010834f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108354:	e9 e7 f0 ff ff       	jmp    80107440 <alltraps>

80108359 <vector215>:
.globl vector215
vector215:
  pushl $0
80108359:	6a 00                	push   $0x0
  pushl $215
8010835b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108360:	e9 db f0 ff ff       	jmp    80107440 <alltraps>

80108365 <vector216>:
.globl vector216
vector216:
  pushl $0
80108365:	6a 00                	push   $0x0
  pushl $216
80108367:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010836c:	e9 cf f0 ff ff       	jmp    80107440 <alltraps>

80108371 <vector217>:
.globl vector217
vector217:
  pushl $0
80108371:	6a 00                	push   $0x0
  pushl $217
80108373:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108378:	e9 c3 f0 ff ff       	jmp    80107440 <alltraps>

8010837d <vector218>:
.globl vector218
vector218:
  pushl $0
8010837d:	6a 00                	push   $0x0
  pushl $218
8010837f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108384:	e9 b7 f0 ff ff       	jmp    80107440 <alltraps>

80108389 <vector219>:
.globl vector219
vector219:
  pushl $0
80108389:	6a 00                	push   $0x0
  pushl $219
8010838b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108390:	e9 ab f0 ff ff       	jmp    80107440 <alltraps>

80108395 <vector220>:
.globl vector220
vector220:
  pushl $0
80108395:	6a 00                	push   $0x0
  pushl $220
80108397:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010839c:	e9 9f f0 ff ff       	jmp    80107440 <alltraps>

801083a1 <vector221>:
.globl vector221
vector221:
  pushl $0
801083a1:	6a 00                	push   $0x0
  pushl $221
801083a3:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801083a8:	e9 93 f0 ff ff       	jmp    80107440 <alltraps>

801083ad <vector222>:
.globl vector222
vector222:
  pushl $0
801083ad:	6a 00                	push   $0x0
  pushl $222
801083af:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801083b4:	e9 87 f0 ff ff       	jmp    80107440 <alltraps>

801083b9 <vector223>:
.globl vector223
vector223:
  pushl $0
801083b9:	6a 00                	push   $0x0
  pushl $223
801083bb:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801083c0:	e9 7b f0 ff ff       	jmp    80107440 <alltraps>

801083c5 <vector224>:
.globl vector224
vector224:
  pushl $0
801083c5:	6a 00                	push   $0x0
  pushl $224
801083c7:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801083cc:	e9 6f f0 ff ff       	jmp    80107440 <alltraps>

801083d1 <vector225>:
.globl vector225
vector225:
  pushl $0
801083d1:	6a 00                	push   $0x0
  pushl $225
801083d3:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801083d8:	e9 63 f0 ff ff       	jmp    80107440 <alltraps>

801083dd <vector226>:
.globl vector226
vector226:
  pushl $0
801083dd:	6a 00                	push   $0x0
  pushl $226
801083df:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801083e4:	e9 57 f0 ff ff       	jmp    80107440 <alltraps>

801083e9 <vector227>:
.globl vector227
vector227:
  pushl $0
801083e9:	6a 00                	push   $0x0
  pushl $227
801083eb:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801083f0:	e9 4b f0 ff ff       	jmp    80107440 <alltraps>

801083f5 <vector228>:
.globl vector228
vector228:
  pushl $0
801083f5:	6a 00                	push   $0x0
  pushl $228
801083f7:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801083fc:	e9 3f f0 ff ff       	jmp    80107440 <alltraps>

80108401 <vector229>:
.globl vector229
vector229:
  pushl $0
80108401:	6a 00                	push   $0x0
  pushl $229
80108403:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108408:	e9 33 f0 ff ff       	jmp    80107440 <alltraps>

8010840d <vector230>:
.globl vector230
vector230:
  pushl $0
8010840d:	6a 00                	push   $0x0
  pushl $230
8010840f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108414:	e9 27 f0 ff ff       	jmp    80107440 <alltraps>

80108419 <vector231>:
.globl vector231
vector231:
  pushl $0
80108419:	6a 00                	push   $0x0
  pushl $231
8010841b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108420:	e9 1b f0 ff ff       	jmp    80107440 <alltraps>

80108425 <vector232>:
.globl vector232
vector232:
  pushl $0
80108425:	6a 00                	push   $0x0
  pushl $232
80108427:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010842c:	e9 0f f0 ff ff       	jmp    80107440 <alltraps>

80108431 <vector233>:
.globl vector233
vector233:
  pushl $0
80108431:	6a 00                	push   $0x0
  pushl $233
80108433:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108438:	e9 03 f0 ff ff       	jmp    80107440 <alltraps>

8010843d <vector234>:
.globl vector234
vector234:
  pushl $0
8010843d:	6a 00                	push   $0x0
  pushl $234
8010843f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108444:	e9 f7 ef ff ff       	jmp    80107440 <alltraps>

80108449 <vector235>:
.globl vector235
vector235:
  pushl $0
80108449:	6a 00                	push   $0x0
  pushl $235
8010844b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108450:	e9 eb ef ff ff       	jmp    80107440 <alltraps>

80108455 <vector236>:
.globl vector236
vector236:
  pushl $0
80108455:	6a 00                	push   $0x0
  pushl $236
80108457:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010845c:	e9 df ef ff ff       	jmp    80107440 <alltraps>

80108461 <vector237>:
.globl vector237
vector237:
  pushl $0
80108461:	6a 00                	push   $0x0
  pushl $237
80108463:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108468:	e9 d3 ef ff ff       	jmp    80107440 <alltraps>

8010846d <vector238>:
.globl vector238
vector238:
  pushl $0
8010846d:	6a 00                	push   $0x0
  pushl $238
8010846f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108474:	e9 c7 ef ff ff       	jmp    80107440 <alltraps>

80108479 <vector239>:
.globl vector239
vector239:
  pushl $0
80108479:	6a 00                	push   $0x0
  pushl $239
8010847b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108480:	e9 bb ef ff ff       	jmp    80107440 <alltraps>

80108485 <vector240>:
.globl vector240
vector240:
  pushl $0
80108485:	6a 00                	push   $0x0
  pushl $240
80108487:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010848c:	e9 af ef ff ff       	jmp    80107440 <alltraps>

80108491 <vector241>:
.globl vector241
vector241:
  pushl $0
80108491:	6a 00                	push   $0x0
  pushl $241
80108493:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108498:	e9 a3 ef ff ff       	jmp    80107440 <alltraps>

8010849d <vector242>:
.globl vector242
vector242:
  pushl $0
8010849d:	6a 00                	push   $0x0
  pushl $242
8010849f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801084a4:	e9 97 ef ff ff       	jmp    80107440 <alltraps>

801084a9 <vector243>:
.globl vector243
vector243:
  pushl $0
801084a9:	6a 00                	push   $0x0
  pushl $243
801084ab:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801084b0:	e9 8b ef ff ff       	jmp    80107440 <alltraps>

801084b5 <vector244>:
.globl vector244
vector244:
  pushl $0
801084b5:	6a 00                	push   $0x0
  pushl $244
801084b7:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801084bc:	e9 7f ef ff ff       	jmp    80107440 <alltraps>

801084c1 <vector245>:
.globl vector245
vector245:
  pushl $0
801084c1:	6a 00                	push   $0x0
  pushl $245
801084c3:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801084c8:	e9 73 ef ff ff       	jmp    80107440 <alltraps>

801084cd <vector246>:
.globl vector246
vector246:
  pushl $0
801084cd:	6a 00                	push   $0x0
  pushl $246
801084cf:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801084d4:	e9 67 ef ff ff       	jmp    80107440 <alltraps>

801084d9 <vector247>:
.globl vector247
vector247:
  pushl $0
801084d9:	6a 00                	push   $0x0
  pushl $247
801084db:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801084e0:	e9 5b ef ff ff       	jmp    80107440 <alltraps>

801084e5 <vector248>:
.globl vector248
vector248:
  pushl $0
801084e5:	6a 00                	push   $0x0
  pushl $248
801084e7:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801084ec:	e9 4f ef ff ff       	jmp    80107440 <alltraps>

801084f1 <vector249>:
.globl vector249
vector249:
  pushl $0
801084f1:	6a 00                	push   $0x0
  pushl $249
801084f3:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801084f8:	e9 43 ef ff ff       	jmp    80107440 <alltraps>

801084fd <vector250>:
.globl vector250
vector250:
  pushl $0
801084fd:	6a 00                	push   $0x0
  pushl $250
801084ff:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108504:	e9 37 ef ff ff       	jmp    80107440 <alltraps>

80108509 <vector251>:
.globl vector251
vector251:
  pushl $0
80108509:	6a 00                	push   $0x0
  pushl $251
8010850b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108510:	e9 2b ef ff ff       	jmp    80107440 <alltraps>

80108515 <vector252>:
.globl vector252
vector252:
  pushl $0
80108515:	6a 00                	push   $0x0
  pushl $252
80108517:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010851c:	e9 1f ef ff ff       	jmp    80107440 <alltraps>

80108521 <vector253>:
.globl vector253
vector253:
  pushl $0
80108521:	6a 00                	push   $0x0
  pushl $253
80108523:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108528:	e9 13 ef ff ff       	jmp    80107440 <alltraps>

8010852d <vector254>:
.globl vector254
vector254:
  pushl $0
8010852d:	6a 00                	push   $0x0
  pushl $254
8010852f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108534:	e9 07 ef ff ff       	jmp    80107440 <alltraps>

80108539 <vector255>:
.globl vector255
vector255:
  pushl $0
80108539:	6a 00                	push   $0x0
  pushl $255
8010853b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108540:	e9 fb ee ff ff       	jmp    80107440 <alltraps>

80108545 <lgdt>:
{
80108545:	55                   	push   %ebp
80108546:	89 e5                	mov    %esp,%ebp
80108548:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010854b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010854e:	83 e8 01             	sub    $0x1,%eax
80108551:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108555:	8b 45 08             	mov    0x8(%ebp),%eax
80108558:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010855c:	8b 45 08             	mov    0x8(%ebp),%eax
8010855f:	c1 e8 10             	shr    $0x10,%eax
80108562:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80108566:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108569:	0f 01 10             	lgdtl  (%eax)
}
8010856c:	90                   	nop
8010856d:	c9                   	leave  
8010856e:	c3                   	ret    

8010856f <ltr>:
{
8010856f:	55                   	push   %ebp
80108570:	89 e5                	mov    %esp,%ebp
80108572:	83 ec 04             	sub    $0x4,%esp
80108575:	8b 45 08             	mov    0x8(%ebp),%eax
80108578:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010857c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108580:	0f 00 d8             	ltr    %ax
}
80108583:	90                   	nop
80108584:	c9                   	leave  
80108585:	c3                   	ret    

80108586 <lcr3>:

static inline void
lcr3(uint val)
{
80108586:	55                   	push   %ebp
80108587:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108589:	8b 45 08             	mov    0x8(%ebp),%eax
8010858c:	0f 22 d8             	mov    %eax,%cr3
}
8010858f:	90                   	nop
80108590:	5d                   	pop    %ebp
80108591:	c3                   	ret    

80108592 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108592:	55                   	push   %ebp
80108593:	89 e5                	mov    %esp,%ebp
80108595:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80108598:	e8 20 c0 ff ff       	call   801045bd <cpuid>
8010859d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801085a3:	05 e0 37 11 80       	add    $0x801137e0,%eax
801085a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801085ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ae:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801085b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b7:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801085bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c0:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801085c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085cb:	83 e2 f0             	and    $0xfffffff0,%edx
801085ce:	83 ca 0a             	or     $0xa,%edx
801085d1:	88 50 7d             	mov    %dl,0x7d(%eax)
801085d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085db:	83 ca 10             	or     $0x10,%edx
801085de:	88 50 7d             	mov    %dl,0x7d(%eax)
801085e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085e8:	83 e2 9f             	and    $0xffffff9f,%edx
801085eb:	88 50 7d             	mov    %dl,0x7d(%eax)
801085ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085f5:	83 ca 80             	or     $0xffffff80,%edx
801085f8:	88 50 7d             	mov    %dl,0x7d(%eax)
801085fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fe:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108602:	83 ca 0f             	or     $0xf,%edx
80108605:	88 50 7e             	mov    %dl,0x7e(%eax)
80108608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010860f:	83 e2 ef             	and    $0xffffffef,%edx
80108612:	88 50 7e             	mov    %dl,0x7e(%eax)
80108615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108618:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010861c:	83 e2 df             	and    $0xffffffdf,%edx
8010861f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108625:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108629:	83 ca 40             	or     $0x40,%edx
8010862c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010862f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108632:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108636:	83 ca 80             	or     $0xffffff80,%edx
80108639:	88 50 7e             	mov    %dl,0x7e(%eax)
8010863c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108646:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010864d:	ff ff 
8010864f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108652:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108659:	00 00 
8010865b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108668:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010866f:	83 e2 f0             	and    $0xfffffff0,%edx
80108672:	83 ca 02             	or     $0x2,%edx
80108675:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010867b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108685:	83 ca 10             	or     $0x10,%edx
80108688:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010868e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108691:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108698:	83 e2 9f             	and    $0xffffff9f,%edx
8010869b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086ab:	83 ca 80             	or     $0xffffff80,%edx
801086ae:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086be:	83 ca 0f             	or     $0xf,%edx
801086c1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ca:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086d1:	83 e2 ef             	and    $0xffffffef,%edx
801086d4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086dd:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086e4:	83 e2 df             	and    $0xffffffdf,%edx
801086e7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086f7:	83 ca 40             	or     $0x40,%edx
801086fa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108703:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010870a:	83 ca 80             	or     $0xffffff80,%edx
8010870d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108716:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010871d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108720:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80108727:	ff ff 
80108729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872c:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80108733:	00 00 
80108735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108738:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010873f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108742:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108749:	83 e2 f0             	and    $0xfffffff0,%edx
8010874c:	83 ca 0a             	or     $0xa,%edx
8010874f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108758:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010875f:	83 ca 10             	or     $0x10,%edx
80108762:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108768:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108772:	83 ca 60             	or     $0x60,%edx
80108775:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010877b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108785:	83 ca 80             	or     $0xffffff80,%edx
80108788:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010878e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108791:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108798:	83 ca 0f             	or     $0xf,%edx
8010879b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801087ab:	83 e2 ef             	and    $0xffffffef,%edx
801087ae:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801087be:	83 e2 df             	and    $0xffffffdf,%edx
801087c1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ca:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801087d1:	83 ca 40             	or     $0x40,%edx
801087d4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087dd:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801087e4:	83 ca 80             	or     $0xffffff80,%edx
801087e7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f0:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801087f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fa:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108801:	ff ff 
80108803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108806:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010880d:	00 00 
8010880f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108812:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108823:	83 e2 f0             	and    $0xfffffff0,%edx
80108826:	83 ca 02             	or     $0x2,%edx
80108829:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010882f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108832:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108839:	83 ca 10             	or     $0x10,%edx
8010883c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108845:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010884c:	83 ca 60             	or     $0x60,%edx
8010884f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108855:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108858:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010885f:	83 ca 80             	or     $0xffffff80,%edx
80108862:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108872:	83 ca 0f             	or     $0xf,%edx
80108875:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010887b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108885:	83 e2 ef             	and    $0xffffffef,%edx
80108888:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010888e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108891:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108898:	83 e2 df             	and    $0xffffffdf,%edx
8010889b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088ab:	83 ca 40             	or     $0x40,%edx
801088ae:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088be:	83 ca 80             	or     $0xffffff80,%edx
801088c1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ca:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801088d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d4:	83 c0 70             	add    $0x70,%eax
801088d7:	83 ec 08             	sub    $0x8,%esp
801088da:	6a 30                	push   $0x30
801088dc:	50                   	push   %eax
801088dd:	e8 63 fc ff ff       	call   80108545 <lgdt>
801088e2:	83 c4 10             	add    $0x10,%esp
}
801088e5:	90                   	nop
801088e6:	c9                   	leave  
801088e7:	c3                   	ret    

801088e8 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801088e8:	55                   	push   %ebp
801088e9:	89 e5                	mov    %esp,%ebp
801088eb:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801088ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801088f1:	c1 e8 16             	shr    $0x16,%eax
801088f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801088fb:	8b 45 08             	mov    0x8(%ebp),%eax
801088fe:	01 d0                	add    %edx,%eax
80108900:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108906:	8b 00                	mov    (%eax),%eax
80108908:	83 e0 01             	and    $0x1,%eax
8010890b:	85 c0                	test   %eax,%eax
8010890d:	74 14                	je     80108923 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010890f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108912:	8b 00                	mov    (%eax),%eax
80108914:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108919:	05 00 00 00 80       	add    $0x80000000,%eax
8010891e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108921:	eb 42                	jmp    80108965 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108923:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108927:	74 0e                	je     80108937 <walkpgdir+0x4f>
80108929:	e8 1f a7 ff ff       	call   8010304d <kalloc>
8010892e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108931:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108935:	75 07                	jne    8010893e <walkpgdir+0x56>
      return 0;
80108937:	b8 00 00 00 00       	mov    $0x0,%eax
8010893c:	eb 3e                	jmp    8010897c <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010893e:	83 ec 04             	sub    $0x4,%esp
80108941:	68 00 10 00 00       	push   $0x1000
80108946:	6a 00                	push   $0x0
80108948:	ff 75 f4             	push   -0xc(%ebp)
8010894b:	e8 23 d6 ff ff       	call   80105f73 <memset>
80108950:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80108953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108956:	05 00 00 00 80       	add    $0x80000000,%eax
8010895b:	83 c8 07             	or     $0x7,%eax
8010895e:	89 c2                	mov    %eax,%edx
80108960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108963:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108965:	8b 45 0c             	mov    0xc(%ebp),%eax
80108968:	c1 e8 0c             	shr    $0xc,%eax
8010896b:	25 ff 03 00 00       	and    $0x3ff,%eax
80108970:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897a:	01 d0                	add    %edx,%eax
}
8010897c:	c9                   	leave  
8010897d:	c3                   	ret    

8010897e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010897e:	55                   	push   %ebp
8010897f:	89 e5                	mov    %esp,%ebp
80108981:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108984:	8b 45 0c             	mov    0xc(%ebp),%eax
80108987:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010898c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010898f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108992:	8b 45 10             	mov    0x10(%ebp),%eax
80108995:	01 d0                	add    %edx,%eax
80108997:	83 e8 01             	sub    $0x1,%eax
8010899a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010899f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801089a2:	83 ec 04             	sub    $0x4,%esp
801089a5:	6a 01                	push   $0x1
801089a7:	ff 75 f4             	push   -0xc(%ebp)
801089aa:	ff 75 08             	push   0x8(%ebp)
801089ad:	e8 36 ff ff ff       	call   801088e8 <walkpgdir>
801089b2:	83 c4 10             	add    $0x10,%esp
801089b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801089b8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801089bc:	75 07                	jne    801089c5 <mappages+0x47>
      return -1;
801089be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089c3:	eb 47                	jmp    80108a0c <mappages+0x8e>
    if(*pte & PTE_P)
801089c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089c8:	8b 00                	mov    (%eax),%eax
801089ca:	83 e0 01             	and    $0x1,%eax
801089cd:	85 c0                	test   %eax,%eax
801089cf:	74 0d                	je     801089de <mappages+0x60>
      panic("remap");
801089d1:	83 ec 0c             	sub    $0xc,%esp
801089d4:	68 f8 99 10 80       	push   $0x801099f8
801089d9:	e8 d7 7b ff ff       	call   801005b5 <panic>
    *pte = pa | perm | PTE_P;
801089de:	8b 45 18             	mov    0x18(%ebp),%eax
801089e1:	0b 45 14             	or     0x14(%ebp),%eax
801089e4:	83 c8 01             	or     $0x1,%eax
801089e7:	89 c2                	mov    %eax,%edx
801089e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ec:	89 10                	mov    %edx,(%eax)
    if(a == last)
801089ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801089f4:	74 10                	je     80108a06 <mappages+0x88>
      break;
    a += PGSIZE;
801089f6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801089fd:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108a04:	eb 9c                	jmp    801089a2 <mappages+0x24>
      break;
80108a06:	90                   	nop
  }
  return 0;
80108a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a0c:	c9                   	leave  
80108a0d:	c3                   	ret    

80108a0e <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108a0e:	55                   	push   %ebp
80108a0f:	89 e5                	mov    %esp,%ebp
80108a11:	53                   	push   %ebx
80108a12:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108a15:	e8 33 a6 ff ff       	call   8010304d <kalloc>
80108a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a1d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a21:	75 07                	jne    80108a2a <setupkvm+0x1c>
    return 0;
80108a23:	b8 00 00 00 00       	mov    $0x0,%eax
80108a28:	eb 78                	jmp    80108aa2 <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80108a2a:	83 ec 04             	sub    $0x4,%esp
80108a2d:	68 00 10 00 00       	push   $0x1000
80108a32:	6a 00                	push   $0x0
80108a34:	ff 75 f0             	push   -0x10(%ebp)
80108a37:	e8 37 d5 ff ff       	call   80105f73 <memset>
80108a3c:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108a3f:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108a46:	eb 4e                	jmp    80108a96 <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80108a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a51:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a57:	8b 58 08             	mov    0x8(%eax),%ebx
80108a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5d:	8b 40 04             	mov    0x4(%eax),%eax
80108a60:	29 c3                	sub    %eax,%ebx
80108a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a65:	8b 00                	mov    (%eax),%eax
80108a67:	83 ec 0c             	sub    $0xc,%esp
80108a6a:	51                   	push   %ecx
80108a6b:	52                   	push   %edx
80108a6c:	53                   	push   %ebx
80108a6d:	50                   	push   %eax
80108a6e:	ff 75 f0             	push   -0x10(%ebp)
80108a71:	e8 08 ff ff ff       	call   8010897e <mappages>
80108a76:	83 c4 20             	add    $0x20,%esp
80108a79:	85 c0                	test   %eax,%eax
80108a7b:	79 15                	jns    80108a92 <setupkvm+0x84>
      freevm(pgdir);
80108a7d:	83 ec 0c             	sub    $0xc,%esp
80108a80:	ff 75 f0             	push   -0x10(%ebp)
80108a83:	e8 f5 04 00 00       	call   80108f7d <freevm>
80108a88:	83 c4 10             	add    $0x10,%esp
      return 0;
80108a8b:	b8 00 00 00 00       	mov    $0x0,%eax
80108a90:	eb 10                	jmp    80108aa2 <setupkvm+0x94>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108a92:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108a96:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108a9d:	72 a9                	jb     80108a48 <setupkvm+0x3a>
    }
  return pgdir;
80108a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108aa5:	c9                   	leave  
80108aa6:	c3                   	ret    

80108aa7 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108aa7:	55                   	push   %ebp
80108aa8:	89 e5                	mov    %esp,%ebp
80108aaa:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108aad:	e8 5c ff ff ff       	call   80108a0e <setupkvm>
80108ab2:	a3 fc 68 11 80       	mov    %eax,0x801168fc
  switchkvm();
80108ab7:	e8 03 00 00 00       	call   80108abf <switchkvm>
}
80108abc:	90                   	nop
80108abd:	c9                   	leave  
80108abe:	c3                   	ret    

80108abf <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108abf:	55                   	push   %ebp
80108ac0:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108ac2:	a1 fc 68 11 80       	mov    0x801168fc,%eax
80108ac7:	05 00 00 00 80       	add    $0x80000000,%eax
80108acc:	50                   	push   %eax
80108acd:	e8 b4 fa ff ff       	call   80108586 <lcr3>
80108ad2:	83 c4 04             	add    $0x4,%esp
}
80108ad5:	90                   	nop
80108ad6:	c9                   	leave  
80108ad7:	c3                   	ret    

80108ad8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108ad8:	55                   	push   %ebp
80108ad9:	89 e5                	mov    %esp,%ebp
80108adb:	56                   	push   %esi
80108adc:	53                   	push   %ebx
80108add:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108ae0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108ae4:	75 0d                	jne    80108af3 <switchuvm+0x1b>
    panic("switchuvm: no process");
80108ae6:	83 ec 0c             	sub    $0xc,%esp
80108ae9:	68 fe 99 10 80       	push   $0x801099fe
80108aee:	e8 c2 7a ff ff       	call   801005b5 <panic>
  if(p->kstack == 0)
80108af3:	8b 45 08             	mov    0x8(%ebp),%eax
80108af6:	8b 40 08             	mov    0x8(%eax),%eax
80108af9:	85 c0                	test   %eax,%eax
80108afb:	75 0d                	jne    80108b0a <switchuvm+0x32>
    panic("switchuvm: no kstack");
80108afd:	83 ec 0c             	sub    $0xc,%esp
80108b00:	68 14 9a 10 80       	push   $0x80109a14
80108b05:	e8 ab 7a ff ff       	call   801005b5 <panic>
  if(p->pgdir == 0)
80108b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80108b0d:	8b 40 04             	mov    0x4(%eax),%eax
80108b10:	85 c0                	test   %eax,%eax
80108b12:	75 0d                	jne    80108b21 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80108b14:	83 ec 0c             	sub    $0xc,%esp
80108b17:	68 29 9a 10 80       	push   $0x80109a29
80108b1c:	e8 94 7a ff ff       	call   801005b5 <panic>

  pushcli();
80108b21:	e8 42 d3 ff ff       	call   80105e68 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108b26:	e8 ad ba ff ff       	call   801045d8 <mycpu>
80108b2b:	89 c3                	mov    %eax,%ebx
80108b2d:	e8 a6 ba ff ff       	call   801045d8 <mycpu>
80108b32:	83 c0 08             	add    $0x8,%eax
80108b35:	89 c6                	mov    %eax,%esi
80108b37:	e8 9c ba ff ff       	call   801045d8 <mycpu>
80108b3c:	83 c0 08             	add    $0x8,%eax
80108b3f:	c1 e8 10             	shr    $0x10,%eax
80108b42:	88 45 f7             	mov    %al,-0x9(%ebp)
80108b45:	e8 8e ba ff ff       	call   801045d8 <mycpu>
80108b4a:	83 c0 08             	add    $0x8,%eax
80108b4d:	c1 e8 18             	shr    $0x18,%eax
80108b50:	89 c2                	mov    %eax,%edx
80108b52:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108b59:	67 00 
80108b5b:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108b62:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108b66:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108b6c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108b73:	83 e0 f0             	and    $0xfffffff0,%eax
80108b76:	83 c8 09             	or     $0x9,%eax
80108b79:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108b7f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108b86:	83 c8 10             	or     $0x10,%eax
80108b89:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108b8f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108b96:	83 e0 9f             	and    $0xffffff9f,%eax
80108b99:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108b9f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108ba6:	83 c8 80             	or     $0xffffff80,%eax
80108ba9:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108baf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108bb6:	83 e0 f0             	and    $0xfffffff0,%eax
80108bb9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108bbf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108bc6:	83 e0 ef             	and    $0xffffffef,%eax
80108bc9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108bcf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108bd6:	83 e0 df             	and    $0xffffffdf,%eax
80108bd9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108bdf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108be6:	83 c8 40             	or     $0x40,%eax
80108be9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108bef:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108bf6:	83 e0 7f             	and    $0x7f,%eax
80108bf9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108bff:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108c05:	e8 ce b9 ff ff       	call   801045d8 <mycpu>
80108c0a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108c11:	83 e2 ef             	and    $0xffffffef,%edx
80108c14:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108c1a:	e8 b9 b9 ff ff       	call   801045d8 <mycpu>
80108c1f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108c25:	8b 45 08             	mov    0x8(%ebp),%eax
80108c28:	8b 40 08             	mov    0x8(%eax),%eax
80108c2b:	89 c3                	mov    %eax,%ebx
80108c2d:	e8 a6 b9 ff ff       	call   801045d8 <mycpu>
80108c32:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108c38:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108c3b:	e8 98 b9 ff ff       	call   801045d8 <mycpu>
80108c40:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108c46:	83 ec 0c             	sub    $0xc,%esp
80108c49:	6a 28                	push   $0x28
80108c4b:	e8 1f f9 ff ff       	call   8010856f <ltr>
80108c50:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108c53:	8b 45 08             	mov    0x8(%ebp),%eax
80108c56:	8b 40 04             	mov    0x4(%eax),%eax
80108c59:	05 00 00 00 80       	add    $0x80000000,%eax
80108c5e:	83 ec 0c             	sub    $0xc,%esp
80108c61:	50                   	push   %eax
80108c62:	e8 1f f9 ff ff       	call   80108586 <lcr3>
80108c67:	83 c4 10             	add    $0x10,%esp
  popcli();
80108c6a:	e8 46 d2 ff ff       	call   80105eb5 <popcli>
}
80108c6f:	90                   	nop
80108c70:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108c73:	5b                   	pop    %ebx
80108c74:	5e                   	pop    %esi
80108c75:	5d                   	pop    %ebp
80108c76:	c3                   	ret    

80108c77 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108c77:	55                   	push   %ebp
80108c78:	89 e5                	mov    %esp,%ebp
80108c7a:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108c7d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108c84:	76 0d                	jbe    80108c93 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108c86:	83 ec 0c             	sub    $0xc,%esp
80108c89:	68 3d 9a 10 80       	push   $0x80109a3d
80108c8e:	e8 22 79 ff ff       	call   801005b5 <panic>
  mem = kalloc();
80108c93:	e8 b5 a3 ff ff       	call   8010304d <kalloc>
80108c98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108c9b:	83 ec 04             	sub    $0x4,%esp
80108c9e:	68 00 10 00 00       	push   $0x1000
80108ca3:	6a 00                	push   $0x0
80108ca5:	ff 75 f4             	push   -0xc(%ebp)
80108ca8:	e8 c6 d2 ff ff       	call   80105f73 <memset>
80108cad:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb3:	05 00 00 00 80       	add    $0x80000000,%eax
80108cb8:	83 ec 0c             	sub    $0xc,%esp
80108cbb:	6a 06                	push   $0x6
80108cbd:	50                   	push   %eax
80108cbe:	68 00 10 00 00       	push   $0x1000
80108cc3:	6a 00                	push   $0x0
80108cc5:	ff 75 08             	push   0x8(%ebp)
80108cc8:	e8 b1 fc ff ff       	call   8010897e <mappages>
80108ccd:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108cd0:	83 ec 04             	sub    $0x4,%esp
80108cd3:	ff 75 10             	push   0x10(%ebp)
80108cd6:	ff 75 0c             	push   0xc(%ebp)
80108cd9:	ff 75 f4             	push   -0xc(%ebp)
80108cdc:	e8 51 d3 ff ff       	call   80106032 <memmove>
80108ce1:	83 c4 10             	add    $0x10,%esp
}
80108ce4:	90                   	nop
80108ce5:	c9                   	leave  
80108ce6:	c3                   	ret    

80108ce7 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108ce7:	55                   	push   %ebp
80108ce8:	89 e5                	mov    %esp,%ebp
80108cea:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108ced:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cf0:	25 ff 0f 00 00       	and    $0xfff,%eax
80108cf5:	85 c0                	test   %eax,%eax
80108cf7:	74 0d                	je     80108d06 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108cf9:	83 ec 0c             	sub    $0xc,%esp
80108cfc:	68 58 9a 10 80       	push   $0x80109a58
80108d01:	e8 af 78 ff ff       	call   801005b5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108d06:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d0d:	e9 8f 00 00 00       	jmp    80108da1 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108d12:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d18:	01 d0                	add    %edx,%eax
80108d1a:	83 ec 04             	sub    $0x4,%esp
80108d1d:	6a 00                	push   $0x0
80108d1f:	50                   	push   %eax
80108d20:	ff 75 08             	push   0x8(%ebp)
80108d23:	e8 c0 fb ff ff       	call   801088e8 <walkpgdir>
80108d28:	83 c4 10             	add    $0x10,%esp
80108d2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d2e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d32:	75 0d                	jne    80108d41 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80108d34:	83 ec 0c             	sub    $0xc,%esp
80108d37:	68 7b 9a 10 80       	push   $0x80109a7b
80108d3c:	e8 74 78 ff ff       	call   801005b5 <panic>
    pa = PTE_ADDR(*pte);
80108d41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d44:	8b 00                	mov    (%eax),%eax
80108d46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d4b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108d4e:	8b 45 18             	mov    0x18(%ebp),%eax
80108d51:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108d54:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108d59:	77 0b                	ja     80108d66 <loaduvm+0x7f>
      n = sz - i;
80108d5b:	8b 45 18             	mov    0x18(%ebp),%eax
80108d5e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108d61:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108d64:	eb 07                	jmp    80108d6d <loaduvm+0x86>
    else
      n = PGSIZE;
80108d66:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108d6d:	8b 55 14             	mov    0x14(%ebp),%edx
80108d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d73:	01 d0                	add    %edx,%eax
80108d75:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108d78:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108d7e:	ff 75 f0             	push   -0x10(%ebp)
80108d81:	50                   	push   %eax
80108d82:	52                   	push   %edx
80108d83:	ff 75 10             	push   0x10(%ebp)
80108d86:	e8 32 95 ff ff       	call   801022bd <readi>
80108d8b:	83 c4 10             	add    $0x10,%esp
80108d8e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108d91:	74 07                	je     80108d9a <loaduvm+0xb3>
      return -1;
80108d93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d98:	eb 18                	jmp    80108db2 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80108d9a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da4:	3b 45 18             	cmp    0x18(%ebp),%eax
80108da7:	0f 82 65 ff ff ff    	jb     80108d12 <loaduvm+0x2b>
  }
  return 0;
80108dad:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108db2:	c9                   	leave  
80108db3:	c3                   	ret    

80108db4 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108db4:	55                   	push   %ebp
80108db5:	89 e5                	mov    %esp,%ebp
80108db7:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108dba:	8b 45 10             	mov    0x10(%ebp),%eax
80108dbd:	85 c0                	test   %eax,%eax
80108dbf:	79 0a                	jns    80108dcb <allocuvm+0x17>
    return 0;
80108dc1:	b8 00 00 00 00       	mov    $0x0,%eax
80108dc6:	e9 ec 00 00 00       	jmp    80108eb7 <allocuvm+0x103>
  if(newsz < oldsz)
80108dcb:	8b 45 10             	mov    0x10(%ebp),%eax
80108dce:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108dd1:	73 08                	jae    80108ddb <allocuvm+0x27>
    return oldsz;
80108dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dd6:	e9 dc 00 00 00       	jmp    80108eb7 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80108ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dde:	05 ff 0f 00 00       	add    $0xfff,%eax
80108de3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108de8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108deb:	e9 b8 00 00 00       	jmp    80108ea8 <allocuvm+0xf4>
    mem = kalloc();
80108df0:	e8 58 a2 ff ff       	call   8010304d <kalloc>
80108df5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108df8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108dfc:	75 2e                	jne    80108e2c <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80108dfe:	83 ec 0c             	sub    $0xc,%esp
80108e01:	68 99 9a 10 80       	push   $0x80109a99
80108e06:	e8 f5 75 ff ff       	call   80100400 <cprintf>
80108e0b:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108e0e:	83 ec 04             	sub    $0x4,%esp
80108e11:	ff 75 0c             	push   0xc(%ebp)
80108e14:	ff 75 10             	push   0x10(%ebp)
80108e17:	ff 75 08             	push   0x8(%ebp)
80108e1a:	e8 9a 00 00 00       	call   80108eb9 <deallocuvm>
80108e1f:	83 c4 10             	add    $0x10,%esp
      return 0;
80108e22:	b8 00 00 00 00       	mov    $0x0,%eax
80108e27:	e9 8b 00 00 00       	jmp    80108eb7 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80108e2c:	83 ec 04             	sub    $0x4,%esp
80108e2f:	68 00 10 00 00       	push   $0x1000
80108e34:	6a 00                	push   $0x0
80108e36:	ff 75 f0             	push   -0x10(%ebp)
80108e39:	e8 35 d1 ff ff       	call   80105f73 <memset>
80108e3e:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e44:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e4d:	83 ec 0c             	sub    $0xc,%esp
80108e50:	6a 06                	push   $0x6
80108e52:	52                   	push   %edx
80108e53:	68 00 10 00 00       	push   $0x1000
80108e58:	50                   	push   %eax
80108e59:	ff 75 08             	push   0x8(%ebp)
80108e5c:	e8 1d fb ff ff       	call   8010897e <mappages>
80108e61:	83 c4 20             	add    $0x20,%esp
80108e64:	85 c0                	test   %eax,%eax
80108e66:	79 39                	jns    80108ea1 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80108e68:	83 ec 0c             	sub    $0xc,%esp
80108e6b:	68 b1 9a 10 80       	push   $0x80109ab1
80108e70:	e8 8b 75 ff ff       	call   80100400 <cprintf>
80108e75:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108e78:	83 ec 04             	sub    $0x4,%esp
80108e7b:	ff 75 0c             	push   0xc(%ebp)
80108e7e:	ff 75 10             	push   0x10(%ebp)
80108e81:	ff 75 08             	push   0x8(%ebp)
80108e84:	e8 30 00 00 00       	call   80108eb9 <deallocuvm>
80108e89:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108e8c:	83 ec 0c             	sub    $0xc,%esp
80108e8f:	ff 75 f0             	push   -0x10(%ebp)
80108e92:	e8 1c a1 ff ff       	call   80102fb3 <kfree>
80108e97:	83 c4 10             	add    $0x10,%esp
      return 0;
80108e9a:	b8 00 00 00 00       	mov    $0x0,%eax
80108e9f:	eb 16                	jmp    80108eb7 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80108ea1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eab:	3b 45 10             	cmp    0x10(%ebp),%eax
80108eae:	0f 82 3c ff ff ff    	jb     80108df0 <allocuvm+0x3c>
    }
  }
  return newsz;
80108eb4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108eb7:	c9                   	leave  
80108eb8:	c3                   	ret    

80108eb9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108eb9:	55                   	push   %ebp
80108eba:	89 e5                	mov    %esp,%ebp
80108ebc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108ebf:	8b 45 10             	mov    0x10(%ebp),%eax
80108ec2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ec5:	72 08                	jb     80108ecf <deallocuvm+0x16>
    return oldsz;
80108ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eca:	e9 ac 00 00 00       	jmp    80108f7b <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108ecf:	8b 45 10             	mov    0x10(%ebp),%eax
80108ed2:	05 ff 0f 00 00       	add    $0xfff,%eax
80108ed7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108edc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108edf:	e9 88 00 00 00       	jmp    80108f6c <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee7:	83 ec 04             	sub    $0x4,%esp
80108eea:	6a 00                	push   $0x0
80108eec:	50                   	push   %eax
80108eed:	ff 75 08             	push   0x8(%ebp)
80108ef0:	e8 f3 f9 ff ff       	call   801088e8 <walkpgdir>
80108ef5:	83 c4 10             	add    $0x10,%esp
80108ef8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108efb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108eff:	75 16                	jne    80108f17 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f04:	c1 e8 16             	shr    $0x16,%eax
80108f07:	83 c0 01             	add    $0x1,%eax
80108f0a:	c1 e0 16             	shl    $0x16,%eax
80108f0d:	2d 00 10 00 00       	sub    $0x1000,%eax
80108f12:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108f15:	eb 4e                	jmp    80108f65 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f1a:	8b 00                	mov    (%eax),%eax
80108f1c:	83 e0 01             	and    $0x1,%eax
80108f1f:	85 c0                	test   %eax,%eax
80108f21:	74 42                	je     80108f65 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f26:	8b 00                	mov    (%eax),%eax
80108f28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108f30:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f34:	75 0d                	jne    80108f43 <deallocuvm+0x8a>
        panic("kfree");
80108f36:	83 ec 0c             	sub    $0xc,%esp
80108f39:	68 cd 9a 10 80       	push   $0x80109acd
80108f3e:	e8 72 76 ff ff       	call   801005b5 <panic>
      char *v = P2V(pa);
80108f43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f46:	05 00 00 00 80       	add    $0x80000000,%eax
80108f4b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108f4e:	83 ec 0c             	sub    $0xc,%esp
80108f51:	ff 75 e8             	push   -0x18(%ebp)
80108f54:	e8 5a a0 ff ff       	call   80102fb3 <kfree>
80108f59:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108f65:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f72:	0f 82 6c ff ff ff    	jb     80108ee4 <deallocuvm+0x2b>
    }
  }
  return newsz;
80108f78:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108f7b:	c9                   	leave  
80108f7c:	c3                   	ret    

80108f7d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108f7d:	55                   	push   %ebp
80108f7e:	89 e5                	mov    %esp,%ebp
80108f80:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108f83:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108f87:	75 0d                	jne    80108f96 <freevm+0x19>
    panic("freevm: no pgdir");
80108f89:	83 ec 0c             	sub    $0xc,%esp
80108f8c:	68 d3 9a 10 80       	push   $0x80109ad3
80108f91:	e8 1f 76 ff ff       	call   801005b5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108f96:	83 ec 04             	sub    $0x4,%esp
80108f99:	6a 00                	push   $0x0
80108f9b:	68 00 00 00 80       	push   $0x80000000
80108fa0:	ff 75 08             	push   0x8(%ebp)
80108fa3:	e8 11 ff ff ff       	call   80108eb9 <deallocuvm>
80108fa8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108fab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108fb2:	eb 48                	jmp    80108ffc <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80108fc1:	01 d0                	add    %edx,%eax
80108fc3:	8b 00                	mov    (%eax),%eax
80108fc5:	83 e0 01             	and    $0x1,%eax
80108fc8:	85 c0                	test   %eax,%eax
80108fca:	74 2c                	je     80108ff8 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fcf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80108fd9:	01 d0                	add    %edx,%eax
80108fdb:	8b 00                	mov    (%eax),%eax
80108fdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fe2:	05 00 00 00 80       	add    $0x80000000,%eax
80108fe7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108fea:	83 ec 0c             	sub    $0xc,%esp
80108fed:	ff 75 f0             	push   -0x10(%ebp)
80108ff0:	e8 be 9f ff ff       	call   80102fb3 <kfree>
80108ff5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108ff8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ffc:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109003:	76 af                	jbe    80108fb4 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80109005:	83 ec 0c             	sub    $0xc,%esp
80109008:	ff 75 08             	push   0x8(%ebp)
8010900b:	e8 a3 9f ff ff       	call   80102fb3 <kfree>
80109010:	83 c4 10             	add    $0x10,%esp
}
80109013:	90                   	nop
80109014:	c9                   	leave  
80109015:	c3                   	ret    

80109016 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109016:	55                   	push   %ebp
80109017:	89 e5                	mov    %esp,%ebp
80109019:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010901c:	83 ec 04             	sub    $0x4,%esp
8010901f:	6a 00                	push   $0x0
80109021:	ff 75 0c             	push   0xc(%ebp)
80109024:	ff 75 08             	push   0x8(%ebp)
80109027:	e8 bc f8 ff ff       	call   801088e8 <walkpgdir>
8010902c:	83 c4 10             	add    $0x10,%esp
8010902f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109032:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109036:	75 0d                	jne    80109045 <clearpteu+0x2f>
    panic("clearpteu");
80109038:	83 ec 0c             	sub    $0xc,%esp
8010903b:	68 e4 9a 10 80       	push   $0x80109ae4
80109040:	e8 70 75 ff ff       	call   801005b5 <panic>
  *pte &= ~PTE_U;
80109045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109048:	8b 00                	mov    (%eax),%eax
8010904a:	83 e0 fb             	and    $0xfffffffb,%eax
8010904d:	89 c2                	mov    %eax,%edx
8010904f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109052:	89 10                	mov    %edx,(%eax)
}
80109054:	90                   	nop
80109055:	c9                   	leave  
80109056:	c3                   	ret    

80109057 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109057:	55                   	push   %ebp
80109058:	89 e5                	mov    %esp,%ebp
8010905a:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010905d:	e8 ac f9 ff ff       	call   80108a0e <setupkvm>
80109062:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109065:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109069:	75 0a                	jne    80109075 <copyuvm+0x1e>
    return 0;
8010906b:	b8 00 00 00 00       	mov    $0x0,%eax
80109070:	e9 f8 00 00 00       	jmp    8010916d <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80109075:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010907c:	e9 c7 00 00 00       	jmp    80109148 <copyuvm+0xf1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109084:	83 ec 04             	sub    $0x4,%esp
80109087:	6a 00                	push   $0x0
80109089:	50                   	push   %eax
8010908a:	ff 75 08             	push   0x8(%ebp)
8010908d:	e8 56 f8 ff ff       	call   801088e8 <walkpgdir>
80109092:	83 c4 10             	add    $0x10,%esp
80109095:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109098:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010909c:	75 0d                	jne    801090ab <copyuvm+0x54>
      panic("copyuvm: pte should exist");
8010909e:	83 ec 0c             	sub    $0xc,%esp
801090a1:	68 ee 9a 10 80       	push   $0x80109aee
801090a6:	e8 0a 75 ff ff       	call   801005b5 <panic>
    if(!(*pte & PTE_P))
801090ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090ae:	8b 00                	mov    (%eax),%eax
801090b0:	83 e0 01             	and    $0x1,%eax
801090b3:	85 c0                	test   %eax,%eax
801090b5:	75 0d                	jne    801090c4 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801090b7:	83 ec 0c             	sub    $0xc,%esp
801090ba:	68 08 9b 10 80       	push   $0x80109b08
801090bf:	e8 f1 74 ff ff       	call   801005b5 <panic>
    pa = PTE_ADDR(*pte);
801090c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090c7:	8b 00                	mov    (%eax),%eax
801090c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801090d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090d4:	8b 00                	mov    (%eax),%eax
801090d6:	25 ff 0f 00 00       	and    $0xfff,%eax
801090db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801090de:	e8 6a 9f ff ff       	call   8010304d <kalloc>
801090e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801090e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801090ea:	74 6d                	je     80109159 <copyuvm+0x102>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801090ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090ef:	05 00 00 00 80       	add    $0x80000000,%eax
801090f4:	83 ec 04             	sub    $0x4,%esp
801090f7:	68 00 10 00 00       	push   $0x1000
801090fc:	50                   	push   %eax
801090fd:	ff 75 e0             	push   -0x20(%ebp)
80109100:	e8 2d cf ff ff       	call   80106032 <memmove>
80109105:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80109108:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010910b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010910e:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80109114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109117:	83 ec 0c             	sub    $0xc,%esp
8010911a:	52                   	push   %edx
8010911b:	51                   	push   %ecx
8010911c:	68 00 10 00 00       	push   $0x1000
80109121:	50                   	push   %eax
80109122:	ff 75 f0             	push   -0x10(%ebp)
80109125:	e8 54 f8 ff ff       	call   8010897e <mappages>
8010912a:	83 c4 20             	add    $0x20,%esp
8010912d:	85 c0                	test   %eax,%eax
8010912f:	79 10                	jns    80109141 <copyuvm+0xea>
      kfree(mem);
80109131:	83 ec 0c             	sub    $0xc,%esp
80109134:	ff 75 e0             	push   -0x20(%ebp)
80109137:	e8 77 9e ff ff       	call   80102fb3 <kfree>
8010913c:	83 c4 10             	add    $0x10,%esp
      goto bad;
8010913f:	eb 19                	jmp    8010915a <copyuvm+0x103>
  for(i = 0; i < sz; i += PGSIZE){
80109141:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010914b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010914e:	0f 82 2d ff ff ff    	jb     80109081 <copyuvm+0x2a>
    }
  }
  return d;
80109154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109157:	eb 14                	jmp    8010916d <copyuvm+0x116>
      goto bad;
80109159:	90                   	nop

bad:
  freevm(d);
8010915a:	83 ec 0c             	sub    $0xc,%esp
8010915d:	ff 75 f0             	push   -0x10(%ebp)
80109160:	e8 18 fe ff ff       	call   80108f7d <freevm>
80109165:	83 c4 10             	add    $0x10,%esp
  return 0;
80109168:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010916d:	c9                   	leave  
8010916e:	c3                   	ret    

8010916f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010916f:	55                   	push   %ebp
80109170:	89 e5                	mov    %esp,%ebp
80109172:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109175:	83 ec 04             	sub    $0x4,%esp
80109178:	6a 00                	push   $0x0
8010917a:	ff 75 0c             	push   0xc(%ebp)
8010917d:	ff 75 08             	push   0x8(%ebp)
80109180:	e8 63 f7 ff ff       	call   801088e8 <walkpgdir>
80109185:	83 c4 10             	add    $0x10,%esp
80109188:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010918b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918e:	8b 00                	mov    (%eax),%eax
80109190:	83 e0 01             	and    $0x1,%eax
80109193:	85 c0                	test   %eax,%eax
80109195:	75 07                	jne    8010919e <uva2ka+0x2f>
    return 0;
80109197:	b8 00 00 00 00       	mov    $0x0,%eax
8010919c:	eb 22                	jmp    801091c0 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
8010919e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a1:	8b 00                	mov    (%eax),%eax
801091a3:	83 e0 04             	and    $0x4,%eax
801091a6:	85 c0                	test   %eax,%eax
801091a8:	75 07                	jne    801091b1 <uva2ka+0x42>
    return 0;
801091aa:	b8 00 00 00 00       	mov    $0x0,%eax
801091af:	eb 0f                	jmp    801091c0 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801091b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b4:	8b 00                	mov    (%eax),%eax
801091b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091bb:	05 00 00 00 80       	add    $0x80000000,%eax
}
801091c0:	c9                   	leave  
801091c1:	c3                   	ret    

801091c2 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801091c2:	55                   	push   %ebp
801091c3:	89 e5                	mov    %esp,%ebp
801091c5:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801091c8:	8b 45 10             	mov    0x10(%ebp),%eax
801091cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801091ce:	eb 7f                	jmp    8010924f <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801091d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801091d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801091db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091de:	83 ec 08             	sub    $0x8,%esp
801091e1:	50                   	push   %eax
801091e2:	ff 75 08             	push   0x8(%ebp)
801091e5:	e8 85 ff ff ff       	call   8010916f <uva2ka>
801091ea:	83 c4 10             	add    $0x10,%esp
801091ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801091f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801091f4:	75 07                	jne    801091fd <copyout+0x3b>
      return -1;
801091f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091fb:	eb 61                	jmp    8010925e <copyout+0x9c>
    n = PGSIZE - (va - va0);
801091fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109200:	2b 45 0c             	sub    0xc(%ebp),%eax
80109203:	05 00 10 00 00       	add    $0x1000,%eax
80109208:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010920b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010920e:	3b 45 14             	cmp    0x14(%ebp),%eax
80109211:	76 06                	jbe    80109219 <copyout+0x57>
      n = len;
80109213:	8b 45 14             	mov    0x14(%ebp),%eax
80109216:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109219:	8b 45 0c             	mov    0xc(%ebp),%eax
8010921c:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010921f:	89 c2                	mov    %eax,%edx
80109221:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109224:	01 d0                	add    %edx,%eax
80109226:	83 ec 04             	sub    $0x4,%esp
80109229:	ff 75 f0             	push   -0x10(%ebp)
8010922c:	ff 75 f4             	push   -0xc(%ebp)
8010922f:	50                   	push   %eax
80109230:	e8 fd cd ff ff       	call   80106032 <memmove>
80109235:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109238:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010923b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010923e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109241:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109244:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109247:	05 00 10 00 00       	add    $0x1000,%eax
8010924c:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010924f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109253:	0f 85 77 ff ff ff    	jne    801091d0 <copyout+0xe>
  }
  return 0;
80109259:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010925e:	c9                   	leave  
8010925f:	c3                   	ret    
