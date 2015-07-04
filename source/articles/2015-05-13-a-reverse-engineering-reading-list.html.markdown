---
title: A Reverse Engineering Reading List
date: 2015-05-13 03:31 UTC
tags:
---

One of my hobbies is taking apart binaries and figuring out how they work. It is really satisfying to take a program and break it apart, before reassembling the pieces in a way that you understand. There are so many resources for picking up this stuff that it seemed like a crime to not collect it in one place.

### Warming Up

If you're just getting into reverse engineering, there are a number of concepts you'll need to get your head around. If you've been writing software for a while then chances are that you'll have a working knowledge of how disassemblers and debuggers operate, but it's worth a refresher.

[gdb](http://www.gnu.org/software/gdb/) is the main debugger worth knowing these days. I use lldb for work, but it never really made its way into my side projects. Brian Hall [wrote a nice gdb intro](http://beej.us/guide/bggdb/) which is enough to get started.

The subject of disassemblers is a little more complicated. [IDA Pro](https://www.hex-rays.com/products/ida/) is the big one, both in terms of features and price, but a number of smaller disassemblers have sprouted up around it. [Hopper for Mac](http://hopperapp.com/) is a good one, and a personal favorite is [radare2](http://radare.org/r/). Pick one that sounds good and master it.

The last thing to mention is assembly. Without that, you'll have no hope of deciphering the output of a disassembler. [Programming From The Ground Up](http://mirror.csclub.uwaterloo.ca/nongnu//pgubook/ProgrammingGroundUp-1-0-booksize.pdf) is a great way to pick up x86 assembly; once you've got that sorted it's not too tricky to learn the other popular flavors as necessary.

> A worthy mention for this section is the [Reverse Engineering site on Stack Exchange](http://reverseengineering.stackexchange.com/) – there are answers to all sorts of interesting [questions](http://reverseengineering.stackexchange.com/questions/250/what-is-the-purpose-of-mov-edi-edi) over there.

### Practicing

There's an enormous number of ways to practice reverse engineering in a safe (and legal) manner. Here are the websites which I regularly toy with:

* [Exploit Exercises](https://exploit-exercises.com/) has a bunch of VMs which you can run in something like VirtualBox to get a feel for reverse engineering. Nebula is a good one for finding your feet in Linux, whereas Protostar is the place to go for lower-level memory exploitation.
* [crackmes.de](http://www.crackmes.de/) is a user driven database of exploitable binaries. Note that, like anything on the Internet, these could be horribly virus-ridden so it's on you to vet them. (Reading the comments is probably fine.)
* [Smash The Stack](http://smashthestack.org/) is the premier wargaming site out there. The [IO game](http://io.smashthestack.org:84/) is a great place to start.

### Books

My all-time favorite low-level security book is [Hacking: The Art of Exploitation](http://www.nostarch.com/hacking2.htm). I've spent many hours poring over this book; it's been worth every minute. There is a great chapter on writing shellcode, and the section on ARP spoofing is particularly fun.

Another No Starch book is [Practical Malware Analysis](http://www.nostarch.com/malware). I've just started on this but so far, so good. Malware analysis is a natural progression point for reverse engineering so keep this book in mind.

Finally, for the Windows crowd, [Practical Reverse Engineering](http://ca.wiley.com/WileyCDA/WileyTitle/productCd-1118787315,subjectCd-CSJ0.html) is the book to get. There are some wonderful sections on the Windows kernel in there (which I really need to read again one day soon).

### Videos

[Open Security Training](http://opensecuritytraining.info/Training.html) recorded some of their security courses and put them up on YouTube for free. I'm still working my way through these – they're really good so far. The [Intro x86 course](http://opensecuritytraining.info/IntroX86.html) is a good starting point.

[DEFCON](https://www.defcon.org/) and [Black Hat](https://www.blackhat.com/us-14/) are more general security conferences, but there is plenty there to check out. Dive into the [DEFCON media server](https://media.defcon.org/) and have fun!
