---
title: Reverse Engineering With Radare2, Part 1
date: "2015-07-05"
tags: [ "radare", "reverse engineering" ]
slug: "reverse-engineering-with-radare2-part-1"
---

A couple of weeks back, the folks at RPISEC [posted the lecture slides and lab contents][1] of their [Modern Binary Exploitation course][2], held earlier this year. The course is designed to take somebody with basic C skills and have them work their way through a series of reverse engineering challenges of increasing difficulty.

This seemed like a great opportunity to fire up [Radare2][3] and put it to work. This series of posts will work through each of the lecture challenges and labs, with a focus on solving them using Radare2 (and a little help from gdb and friends along the way).

I believe that reverse engineering is a fantastic skill for software developers to pick up. The idea may carry connotations of software piracy with it, but it's tremendously useful for debugging software and learning how compilers work. Plus, it's just _fun_.

### Introduction to Radare2

The first order of business: what _is_ Radare2? It's... a little complicated. At its core, it is an [open source][4] framework designed to help disassemble software.

It comes with a set of utilities to help with common RE tasks, like base conversion and file info extraction. It also packs a powerful CLI, `r2`, for interactively disassembling programs. If you're familiar with [IDA Pro][5] or [Hopper][6], then you have a good idea of what this CLI can do.

Programs like IDA may be easier to get up and running with, but I'm a fan of Radare2 because it can be set up on remote servers easily, and often comes preinstalled on CTF sites like [Smash The Stack][7].

### Setting Up

To kick things off, I'll walk through the [first few challenges for lecture two][8]. The next entries will take a more direct approach at solving the problems – this article is more concerned about getting familiar with Radare2.

Grab a copy of the challenges and install Radare2. On Mac OS X, `brew install radare2` will do the job. For other operating systems, check out the [installation page on radare.org][9].

If you're keen to check out the rest of the challenges ahead of time, the full set of lecture content is available on the [course website][10]. (Be sure to send a thank-you note to the people at RPISEC!)

> **PS:** These are all [ELF][11] binaries, so you'll need a Linux system to run them. I'm running an Ubuntu VM in VMware Workstation, but you could set up a cheap server on [Digital Ocean][12] and get the same result. If you just want to statically analyze the files without actually executing them, OS X or Windows will do fine.

> **PPS:** I'm assuming you're at least somewhat familiar with X86 assembly. If not, [Programming From The Ground Up][13] is a good, free introduction. Another great book is [Practical Reverse Engineering][14], which also covers ARM assembly and the Windows kernel.

### Challenge 1: crackme0x00a

After running `./crackme0x00a` and entering a few passwords unsuccessfully, it's clear that a brute force approach is not going to work. A smarter tactic is to disassemble the file and figure out how it works by reading the output.

The primary Radare2 UI can be started using the `r2` command. It takes a path to a binary as an argument, along with some optional arguments, which I'll dig into in a future article. For now, run `r2 crackme0x00a` to open the first challenge.

The main UI is reminiscent of a Meterpreter shell, but capable of much more. It has its own commands and state which you can use to explore a file, as well as editing and running it with a debugger. To illustrate how shell-like Radare2 is, you can navigate the file system just like you would in bash:

	sam@remote:/challenges/lecture1$ r2 crackme0x00a
	 -- Trust no one, nor a zero. Both lie.
	[0x100000d78]> pwd
	/Users/samsymons/Desktop
	[0x100000d78]> cd ~
	[0x100000d78]> pwd
	Users/samsymons
	[0x100000d78]>

The first thing you see when launching `r2`, besides the start-up message, is the input section preceded by a memory address. This memory address indicates your current position in the file. If you were to print out the next 16 hex values, for example, it would do so from that address:

	[0x100000d78]> x 16
	offset -    0 1  2 3  4 5  6 7  8 9  A B  C D  E F  0123456789ABCDEF
	0x100000d78  5548 89e5 4883 c768 4883 c668 5de9 2638  UH..H..hH..h].&8

To navigate the binary, there is the seek command, `s`. To learn how seek works, give the help operator, `?`, a try. It can be appended to any `r2` command, so in this situation you would use `s?`. It can also be used on its own to print a generalized help message.

With that out of the way, it's time to start analyzing the first challenge. Radare2 can analyze a binary using the `a` command – this is useful, but the real workhorse is the `aa` subcommand, short for _analyze all_. `aa` will (unsurprisingly) search through the entire binary and analyze its symbols.

Now for the fun part: disassembling functions. Radare2 provides this in the form of the _print disassemble function_ command, `pdf`. `pdf @ main` will analyze the main function and print its disassembly.

Here's what you get when disassembling `main`:

<script src="https://gist.github.com/samsymons/e24e0b7ff24a641231bc.js"></script>

I cheated a little bit and added some newlines between a few function calls in the disassembly to help with readability. There are a couple interesting things here:

1. Radare2 adds ASCII-art arrows to indicate control flow, which is amazingly useful
2. Strings are automatically read from the binary and added as comments
3. Strings are prefixed with `str.`, whereas imports use `imp.`

On lines 30 and 31 of the disassembly, you can see a call to `strcmp` with `g00dJ0B!` as one of the arguments. There's a pretty good chance that this is the password.

	sam@remote:/challenges/lecture1$ ./crackme0x00a
	Enter password: g00dJ0B!
	Congrats!

Bingo! Not all of the challenges will have the answer lying out in the open like that, but this is a good start!

### Challenge 2: crackme0x00b

Alright, time for round 2. Open up `crackme0x00b` in r2, use `aa` to analyze the file and its symbols, then disassemble `main` using `pdf @ main`. The disassembly is largely uninteresting, but this section sticks out.

	0x080484bf    8d44241c       lea eax, [esp + 0x1c]           ; 0x1c
	0x080484c3    89442404       mov dword [esp + 4], eax        ; [0x4:4]=0x10101
	0x080484c7    c7042440a004.  mov dword [esp], sym.pass.1964  ; [0x804a040:4]=119 ; "w" @ 0x804a040
	0x080484ce    e8bdfeffff     call sym.imp.wcscmp ;sym.imp.wcscmp()

Hmm. On the surface, this looks like a string comparison with `w` as an argument to the `wcscmp` function. Seems a little too easy... let's try anyway.

	sam@remote:/challenges/lecture1$ ./crackme0x00b
	Enter password: w
	Wrong!

Alright, that was a long shot. The `wcscmp` function is interesting though. Perhaps it can be used to figure out if something is preventing the true password from being printed. The man page for `wcscmp` has this to say:

	The wcscmp() function is the wide-character equivalent of the strcmp(3) function. It compares the wide-character string pointed to by s1 and the wide-character string pointed to by s2.

That explains it! Wide-characters on Linux are 32-bits in length, so when Radare2 was looking up the string to print beside the `wcscmp` argument, it would have read the character `w` before hitting a null character and stopping; it didn't know to expect 32-bit characters! If we can inspect the location of the string in memory, the password should become obvious.

In the disassembly above, the target string is at `sym.pass.1964`. What happens when the hex values at this address are printed out using the `print hex` command, `px`?

	[0x080483e0]> px @ sym.pass.1964
	offset -   0 1  2 3  4 5  6 7  8 9  A B  C D  E F  0123456789ABCDEF
	0x0804a040  7700 0000 3000 0000 7700 0000 6700 0000  w...0...w...g...
	0x0804a050  7200 0000 6500 0000 6100 0000 7400 0000  r...e...a...t...
	0x0804a060  0000 0000 4743 433a 2028 5562 756e 7475  ....GCC: (Ubuntu
	0x0804a070  2f4c 696e 6172 6f20 342e 362e 312d 3975  Linaro 4.6.1-9u
	0x0804a080  6275 6e74 7533 2920 342e 362e 3100 002e  buntu3) 4.6.1...
	0x0804a090  7379 6d74 6162 002e 7374 7274 6162 002e  symtab..strtab..
	0x0804a0a0  7368 7374 72                             shstr

As predicted, the password was being prematurely terminated by r2. The program is reading in characters in 32-bit pieces (each hex digit is 4 bits, and there are 8 hex digits per character). The ASCII values of the hex to the right hand side reveal the password: `w0wgreat`.

### Challenge 3: crackme0x01

Alright, we're through the qualifying rounds! There are now 9 binaries to work through, but let's just tackle the first one and leave the others for part 2.

`crackme0x01` is another nice, simple puzzle. After going through the usual analyze-then-disassemble routine, the `main` function quickly reveals the solution. There are two calls to `printf`, followed by a call to `scanf` which expects an integer as an argument.

_Wait a second..._ how can you tell that it expects an integer? In the comments provided by `r2`, the string passed to `scanf` is revealed to be set to `%d`, the format specifier for signed decimal values. Try running `ps @ 0x804854c` in Radare2 if you want a second opinion.

After the program prints some labels and takes our input, the program reaches a particularly interesting line: `cmp dword [ebp-local_1], 0x149a`. This line is comparing a variable against an integer constant, likely the constant that the program expects as the password! There's just one problem: the constant is hex, and the program's input is expecting a plain old base 10 value.

Remember that set of utilities mentioned earlier? Radare2 comes with a program called `rax2`, which is capable of converting one base to another, like decimal (base 10) to hex (base 16). Outside of the `r2` environment, `rax2 0x149a` will print out the integer (and password) `5274`. If you don't want to exit `r2` just to convert a number, `? 0x149a` will display the value in a range of formats, including binary and octal. Run the program and enter `5274` to win!

### Finishing Up

Hopefully you're beginning to comprehend the raw power of Radare2. This article barely skims the surface – `r2` packs a near limitless number of handy features, including an excellent visual interface capable of changing between display modes.

Although these challenges were pretty simple, this is a solid starting point. The next entries in this series will eventually work towards challenges which feature buffer overflows, encryption, ROP chaining, and more. Have fun!

[1]:	https://github.com/RPISEC/MBE
[2]:	http://security.cs.rpi.edu/courses/binexp-spring2015/
[3]:	http://radare.org/r/index.html
[4]:	https://github.com/radare/radare2
[5]:	https://www.hex-rays.com/products/ida/index.shtml
[6]:	http://hopperapp.com/
[7]:	http://smashthestack.org/
[8]:	http://security.cs.rpi.edu/courses/binexp-spring2015/lectures/2/challenges.zip
[9]:	http://radare.org/r/down.html
[10]:	http://security.cs.rpi.edu/courses/binexp-spring2015/
[11]:	https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
[12]:	https://www.digitalocean.com/?refcode=6b824f15292b
[13]:	https://savannah.nongnu.org/projects/pgubook/
[14]:	http://www.amazon.com/Practical-Reverse-Engineering-Reversing-Obfuscation/dp/1118787315
