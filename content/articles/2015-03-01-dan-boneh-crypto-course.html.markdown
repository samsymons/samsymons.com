---
title: Dan Boneh's Crypto Course
date: "2015-03-01"
tags: course, cryptography
---

Inspired by [Ole Begemann's review of the Programming Languages course][1], I wanted to write about my experience with [Dan Boneh's Cryptography course][2] on Coursera.

### Overview

The course assumes you have no cryptographic background; at the beginning it covers the history of cryptography, basic ciphers like the Caesar and Vigenère cipher, and a review of the probability used to assess crypto algorithms. Even if you've never even used a crypto library before, you'd be just fine here.

The bulk of the course covers the algorithms used in cryptography, and how you can assemble basic cryptography primitives to build robust ciphers. A significant amount of time is spent discussing how to build ciphers which guarantee both confidentiality and integrity (that is, you can guarantee a message came from a certain person, and that nobody else has read or tampered with it).

With each topic, Dan showed how easy it was for algorithms to be implemented slightly incorrectly, and that even slight mistakes are enough to break the entire encryption process. Even if you're not looking to implement crypto algorithms yourself (_I hope you're not!_), the course was a fantastic guide on how to correctly use algorithms from existing libraries like [PyCrypto][3].

The course ended with an introduction to number theory and its use with public key exchange. This part gave me the most trouble compared to the other topics since I have a pretty terrible mathematical background, but was also the most rewarding. The math is applicable in all sorts of areas, so I would certainly recommend picking up a good number theory book.

Because of the technical nature of these algorithms, programming experience is basically required – there isn't any overview of programming at the start, so you'd have to study up before-hand.

### Workload

I spent roughly 8 hours a week on the course, including the programming assignments and any outside reading on the topics of the current week.

The programming assignments here were superb. The first assignment entailed breaking ciphertext created with a many-time pad, and my favorite had you attack a contrived web server via a [padding oracle attack][4]. I felt that the quizzes were a little weak in places (specifically, the final exam covered far less material than I expected it to), but the assignments are where the real learning took place.

The programming language used in sample code is Python, though the assignments are open enough that any language can be used without any fuss. I hadn't had much Python experience before this, so I opted to become more familiar with it (I'm glad I did).

### Final Notes

I took this course alongside a couple others, and (to my surprise) found this to be the easiest to follow, purely because of Dan's excellent lecture videos. I can't wait for the second half of the course.

[1]:	http://oleb.net/blog/2014/12/programming-languages-mooc/
[2]:	https://www.coursera.org/course/crypto
[3]:	https://www.dlitz.net/software/pycrypto/
[4]:	http://en.wikipedia.org/wiki/Padding_oracle_attack
