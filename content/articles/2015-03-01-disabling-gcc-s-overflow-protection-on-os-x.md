---
title: Disabling GCC's Overflow Protection on OS X
date: "2015-03-01"
tags: gcc, security
---

Earlier, I was playing with some code from [Jon Erickson's book][1] which exploited stack overflow bugs, on an older Linux system. When it came time to bring that code over to OS X though, the overflow protection would kill the process before it got a chance to do anything nasty.

Here's the incantation required to disable it:

	gcc -fno-stack-protector -D_FORTIFY_SOURCE=0 -g -o overflow overflow.c

Before:

	› ./overflow 1234567890
	[BEFORE] second_buffer is at 0x7fff52d22868 and contains 'two'
	[BEFORE] first_buffer is at 0x7fff52d22870 and contains 'one'
	[BEFORE] value is at 0x7fff52d22854 and contains 5 (0x00000005)
	Copying 10 bytes into second_buffer
	zsh: abort      ./overflow 1234567890

After:

	› ./overflow 1234567890
	[BEFORE] second_buffer is at 0x7fff5e14e85c and contains 'two'
	[BEFORE] first_buffer is at 0x7fff5e14e864 and contains 'one'
	[BEFORE] value is at 0x7fff5e14e86c and contains 5 (0x00000005)
	Copying 10 bytes into second_buffer
	[AFTER] second_buffer is at 0x7fff5e14e85c and contains '1234567890'
	[AFTER] first_buffer is at 0x7fff5e14e864 and contains '90'
	[AFTER] value is at 0x7fff5e14e86c and contains 5 (0x00000005)

[1]:	http://www.nostarch.com/hacking2.htm
