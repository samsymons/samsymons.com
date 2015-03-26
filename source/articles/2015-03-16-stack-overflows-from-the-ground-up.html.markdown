---
title: Stack Overflows From The Ground Up
date: 2015-03-16 05:51 UTC
tags:
---

Stack overflows may be the most famous of all program exploits.

Modern compilers have a bunch of defenses against memory-related vulnerabilities, so you'll have to disable these to demonstrate how these attacks work (I'll show you how to do that later on).

To get the most out of this article, you should be comfortable with general programming concepts, like functions and arguments. If you're still not quite sold on the idea of a variable, this will probably be a bit much to take in.

*(Also, heads up: these code samples were written on a 64-bit machine running OS X.)*

### The C Memory Model

Before we can get to the good stuff, it's important to understand how C programs keep track of everything they need to remember. Where do variables go? Where are my functions? What makes static variables so terrible anyway? These are all legitimate questions.

Every C program you write is allowed to play with some fixed amount of memory (called an address space). On a 32-bit Linux system, this is around 4GB. Instead of each 32-bit Linux program having to be told by the operating system, "*Okay, program, there are a bunch of other processes running at the moment so you can only use memory from addresses `x` to `y`. Have fun!*", they get to use the same 4GB of memory every time they run, and the computer handles the rest. This is what people are talking about when they harp on about *virtual memory*.

"Hold up a minute!", you cry. "My computer only has 2 gigabytes of memory! Programs on my computer don't somehow get access to 4 gigabytes of memory, do they?"

Yes.

Virtual memory is your computer's way of giving each program equal standing in the world. When you access a chunk of memory in your program, the computer takes that address and translates it into a physical address for you. Thanks, computer!

Without further ado, here is a diagram of the C memory layout.

![A diagram of the C memory layout](static/images/memory-layout.png)

This layout is just the way that the aforementioned address space is divided up. There's nothing special about this particular layout – the stack and the heap could have been swapped around, or the environment variables could have gone at the bottom. Like most things in life, it's completely arbitrary.

By the way: don't worry about trying to remember the exact layout of the address space; it changes depending on your operating system. As long as you remember that the stack starts from a high address and the heap starts near the bottom, you'll be set.

> Perhaps this article should have been titled *Stack Overflows From The Top Down*. Alas.

### Call Me, Maybe?

Now you know how your C program sees the world. From here on out, we'll only concern ourselves with the stack (it's not called a stack overflow for nothing, after all).

The next thing to learn is how C programs call functions. This isn't nearly as scary as you probably think it is, I promise. This may be hard to come to terms with, but here it is: computers aren't magic. When you call a function in a program, they need to do all kinds of stuff, like keeping track of arguments, clearing space for local variables, and remembering the return address so they know where to continue executing once the function has finished its work.

Before we go any further, have a read through this vulnerable C program.

<script src="https://gist.github.com/samsymons/6b0f6308a898b8231a71.js"></script>

What happens when the `authenticate` function is called? The computer pushes what is called a *stack frame* onto the stack. A stack frame is a chunk of data which represents a single function call.

1. The function's arguments are pushed onto the stack, in reverse order. If you have a function `int func(int a, int b);`, then the stack will have `b` pushed onto it before `a`.
2. It pushed the current instruction pointer onto the stack. This is the return address for your function. When your function returns, the program will be able to go back to this address and resume where it left off.
3. The current stack pointer is pushed onto the stack, and is set as the base pointer (`%ebp` or `%rbp` depending on whether you're running on a 32-bit processor). This is used when referring to local variables or arguments – it serves as the *base* of the function.
4. Last of all, the local variables are pushed onto the stack. This is done in the order that they are declared. These variables are where the stack overflow will go down.

All said and done, the stack looks something like this:

![A diagram of the stack layout](static/images/stack-diagram.png)

### Smashing The Stack

Alright! We've learned a lot so far. We now know how C programs call functions and keep track of state while they do it. But why stop there? What good is all this power if you can't use it to do something terrible?

Enter the dreaded stack overflow. This is a vulnerability that has plagued programmers for many years, and will continue to do so for the foreseeable future. It can be exploited to do some truly devious things, which is what makes it so valuable to learn about. It's hard to defend yourself against something you don't understand.

In `authenticate.c`, the program asks for a password, then stores that input in the `password` buffer before comparing it with the secret. Can you spot the flaw in this code? The `gets` function doesn't check the length of its input before storing it in the buffer. The consequence of this is that `gets` will just keep writing bytes until it hits the end of the string (the NUL terminator), which could be much longer than the 8 byte capacity of our buffer.

### Defending The Stack

With the exploits demonstrated so far, you may have noticed that each one required overwriting some data along the way. What if some of that data was actually **required** to execute a function? You couldn't overwrite it! Behold, the [stack canary](http://en.wikipedia.org/wiki/Buffer_overflow_protection#Canaries).

A stack canary is a random value placed between the stack frame's return address and the function's variables. Before a function's return address is used, the program will ask, "*Hey, stack canary, are you still alive over there?*" If not, game over: when the canary has been overwritten then somebody has probably tried to modify the return address.

When you use a modern compiler, like GCC or clang, you get this stack protection for free.

