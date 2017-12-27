---
title: Inspecting Binaries with Hexdump
date: "2015-04-20"
tags: assembly, hexdump
---

Lately I've been working on an 8080 emulator in Swift. The process of having to take a binary apart and figure out which byte is associated with which instruction has gotten me interested in programs and how they work under the hood.

Instead of doing some private research and calling it a day, I wanted to try and put things together into one place.

### What Are Binaries?

A binary is nothing more than an executable chunk of data arranged in a certain way. In fact, everything on a computer is a chunk of data. Images, music, movies – these are all just sets of ones and zeros arranged in such a way that they can produce some meaningful output when interpreted in a certain way.

### Understanding Binaries

As mentioned, a binary is just data. Nothing but a long series of ones and zeros, the same as everything else on a hard disk. Here's the trick, though: ones and zeros can mean different things based on how you interpret them.

Take the following series of bits: `0100 0001 0100 0010`. A byte is 8 bits, so we're looking at two bytes. If you were to consult a hex editor, it would take each nibble (half a byte, or 4 binary digits) and display it as a hex digit (a single hex digit is 4 bits). It would tell you that this particular string represents `4142`. It's not wrong – this string is definitely `4142` in hexadecimal... but it can mean something entirely different depending on who you ask.

A text editor would take each byte and figure out which character that should be. By [consulting an ASCII table][1], we see that `41` in hex is `A`, and `42` is `B`. So a text editor's verdict would be that this particular binary string represents `AB`. Just like a hex editor tells you that its understanding of the string is `4142`, the text editor is *also* correct. It's all a matter of interpretation.

> If the data wasn't intended to be human-readable, the result will be mostly garbled. You've probably tried to open up a program in a text editor before and seen this yourself.

So, we know about the hex editor's opinion, as well as the text editor's. But what would a *CPU* think? Now things are getting interesting. Before we delve down that rabbit hole, let's build a binary of our very own.

### Building Our Own Binary

With the following source code, and a bit of help from a compiler, we can produce a binary which can then be executed by our computer.

<script src="https://gist.github.com/samsymons/d2195227a1e116b84268.js"></script>

> The command I used was `gcc -fno-stack-protector -D_FORTIFY_SOURCE=0 -g -o hello_world hello_world.c`, which asks gcc to produce a binary named `hello_world` from the `hello_world.c` source file. The extra arguments just make the output a little easier to deal with.

Alright, we've got our binary! Take it for a spin with `./hello_world`. The output probably won't surprise you.

Now that we have our program compiled, we can try to read the result. If you're anything like me, you prefer reading English characters – a string of binary digits isn't very helpful. A common way of reading a program after it has been compiled is by converting it to hex. Your computer will likely have a program for this exact purpose: [hexdump][2].

> hexdumps themselves aren't actually *that* useful unless you know what to look for. An even better way to understand a compiled program is to run it through a [disassembler][3].

To try out `hexdump`, let's run our binary through it with the command `hexdump -C hello_world`. It's a little on the lengthy side, but it's worth looking over the entire thing.

<script src="https://gist.github.com/samsymons/cf71ed2e575f917daaba.js"></script>

Because I compiled this on Mac OS X, I know from experience that the binary will be in the Mach-O format. I have trust issues though; let's check anyway. According to [this Mach-O format poster][4], the first 4 bytes should be `CE FA ED FE`. A quick comparison to the hexdump file confirms it – this is Mach-O!

A nice feature of hexdump is that it will check whether each byte is printable – if it is, then it will display it in the right-hand column. This is why you can see "Hello, world!" right there in the hexdump. (If it's not printable, it just puts a period instead.)

> A binary format is a way of laying out a program. Mach-O is the way that Macs format their programs, so that each one can be understood by the operating system. Linux-based computers have a different format (ELF), with the same applying to Windows.

### How CPUs Interpret Data

Previously, I asked how a CPU might interpret strings of ones and zeros. It does it the same way a text editor would: it reads a byte, and then decides what to do with it. A text editor decides which character to display, whereas a CPU decides which instruction to execute. The way it decides is through what is called an *instruction set*.

Each CPU has its own instruction set. 8080 processors have [their own instruction set][5], 6502 processors [have another][6]. An instruction set defines everything that a computer can do – there are instructions for addition, multiplication, manipulating data, encryption, and *much* more. Every program you write can be distilled into these instructions.

For each byte in the text section of our hexdump (see the Mach-O poster for information on the text section), you can look up which instruction will be executed, and how many bytes it takes as arguments.

There's not much more to say here without getting into assembly programming, which is a phenomenally large topic on its own. If you want to learn more, check out [Programming From The Ground Up][7] for a nice assembly intro.

> If you're curious, Intel has [free PDFs about their architectures][8] available. Never fear, new programmers: for regular programming jobs, you should never need to look at these.

### Wrapping Up

You've learned that binaries come in all shapes and sizes, as well as how to rip one apart to understand how it operates. Not bad for a day's work. Try writing a few programs of your own on various architectures, so you can get a feel for the various binary formats out there.

If you really want to step up your game, build a binary and then try to edit it so that it does something else. This is how people pirate software and do all sorts of shady things (don't be a jerk).

[1]:	http://www.asciitable.com/
[2]:	http://en.wikipedia.org/wiki/Hex_dump#od_and_hexdump
[3]:	http://en.wikipedia.org/wiki/Disassembler
[4]:	http://i.imgur.com/Q4w9qLp.png
[5]:	http://pastraiser.com/cpu/i8080/i8080_opcodes.html
[6]:	http://e-tradition.net/bytes/6502/6502_instruction_set.html
[7]:	http://mirror.csclub.uwaterloo.ca/nongnu//pgubook/ProgrammingGroundUp-1-0-booksize.pdf
[8]:	http://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-manual-325462.pdf
