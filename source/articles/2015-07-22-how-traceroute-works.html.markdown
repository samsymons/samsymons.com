---
title: How Traceroute Works
date: 2015-07-22 00:30 UTC
tags: networking
---

After taking Stanford's [introductory networking course][1] earlier this year, I decided it would be fun exercise to put some of that knowledge into practice and go about recreating traceroute in Rust. Traceroute is a neat little program; it ties together a bunch of networking protocols in a relatively simple way, making for a good test of a language's networking APIs.

### A Brief Overview of Network Protocols

If you've done any basic network programming in the past, you're likely familiar with the IP protocol, along with its partners, [TCP][2] and [UDP][3]. The IP protocol is one of the most important protocols ever created; it is the basis of the Internet, as it allows for data to be transferred from point to point.

#### IP

IP, the Internet Protocol, provides a base level of functionality for packets. It allows for packet expiration (known as Time To Live, or TTL), error correction (networks are notoriously unreliable), and routing between IP addresses. Because these properties are so important to the operation of the Internet, TCP and UDP are implemented on top of IP.

IP forgoes many sophisticated features in favor of simplicity. It has no guarantee of delivery, no promise to deliver packets in the correct sequence, and it doesn't do anything to prevent the network being flooded. It does the bare minimum that is required of it – anything more is left to higher level protocols.

Coming back to the TTL concept for a second, one consequence of the Internet being a vast web of interconnected devices is the possibility of infinite loops. Router A might decide that Router B is the next best option for a packet, which in turn might choose Router C as the place to go. Router C could then pick Router A, leaving a packet stuck in an endless cycle. To work around this possibility, IP packets can only live for so long. Routers will decrement their TTL fields before forwarding them, meaning that their TTL field will eventually hit 0, causing them to be dropped before they can loop around any further.

#### UDP

UDP is the simpler of the UDP/TCP pair. It's so simple, in fact, that it only adds a couple extra features to IP: source and destination ports. _(It also has a couple of fields to indicate the length and checksum, in addition to IP's own length and checksum.)_

UDP, like IP, is connectionless. When you want to send a UDP datagram to another host, you create it, send it, and move on. Once that datagram is out the door, you can forget about it. A consequence of this is that datagrams can get lost along the way, and you won't know about it; perhaps they get corrupted on the wire, or one of the intermediary routers is too busy to process it, so they discard it.

That may sound a little strange. Why send data if you can't even guarantee that it's going to arrive? In some cases, this is _exactly_ what you want. Multiplayer games use UDP at the transport layer because the data is so short lived. If a packet gets dropped, there isn't enough time to resend it, so it would be best to just send a new packet with newer data. Another major user of UDP is [WebRTC][4]. If you have a video frame which gets dropped during transmission, it makes sense to just let a newer frame go through, rather than try to resend the old one.

#### TCP

While UDP has its uses, most of the time you're going to want to know that your data has been successfully received. TCP, the Transmission Control Protocol, does exactly this. While UDP is very minimal, TCP has been built up over the years to include astounding levels of performance optimization and reliability.

TCP is built around the idea of a _connection_. Before any real data is transmitted, TCP has to set up a connection with its destination, which it does using its three-way handshake. The sender, perhaps your laptop, will send a `SYN` (synchronization) packet to its destination, which will respond with a `SYN-ACK` (synchronization + acknowledgment) packet. The sender will send the final `ACK` packet along with the first portion of data. Packets can include data along with `ACK` flags, to save on the total number of packets sent.

Once the connection is established, TCP uses a number of techniques to ensure that data is transmitted in the correct order, while checking that it is not flooding the network with too much traffic. The algorithms used to control network traffic are extremely clever; they're outside the scope of this article, but I definitely recommend [reading up on them][5].

### ICMP

The Internet Control Message Protocol, [ICMP][6], is not as famous as TCP or UDP. As useful as it is, it typically isn't the concern of application-level network programmers.

The ICMP protocol is mainly used to send diagnostic information between devices. If a packet could not be delivered to its destination, for example, you would get back an ICMP packet of the type `Destination Unreachable`.

### What Is Traceroute?

When you send a packet to a host, you have no knowledge of how it got from your machine to the target. The complexity of The Internet is entirely abstracted away from you as a programmer – you don't need to know _how_ a packet got from A to B, it only matters whether or not it did (and to protocols like UDP, even _that_ doesn’t matter).

Sometimes, though, you need to know how packets are traversing the network. If your Internet connection goes down, it would be handy to know where packets are being tripped up. The traceroute program can figure out the exact path taken to send data from you to your target by cleverly harnessing existing protocols like UDP and ICMP.

The key to traceroute's operation is the TTL field. Every time a router processes a packet, it decreases the TTL value by one – if it decrements this field and notices that the value has reached 0, it won't send it any further. Instead, it will send back an ICMP error packet to let you know that your packet died en-route. By sending packets out into the ether using a gradually increasing TTL value, traceroute can inspect the packets which come back and use their source IP address to learn where they came from.

### Tracing Traceroute

Merely reading about a topic isn't nearly enough to truly _learn_ it. To cement this knowledge, you'll need practical experience with network protocols. I'm going to use the command-line component of Wireshark, tshark, to watch traceroute as it figures out a path from my local IP to `samsymons.com`.

Wireshark is a program which can capture local network traffic for analysis. You can use it to determine which devices are flooding a LAN, or perhaps which server a certain program is trying to reach. It also allows for some pretty elaborate filtering, to allow you to strip out any irrelevant traffic.

This isn't meant to be a complete introduction to Wireshark, so you may want to check out [the man page for tshark][7] to get a better idea of what's happening here.

#### Capturing The Data

To capture data with tshark, you need two things: a network interface, and root privileges. To start, I'm going to look up the IP address for `samsymons.com` using `dig samsymons.com`. Because this website has multiple A records, I want to find out one of its IP addresses to use ahead of time, so it can be used as a capture filter when reading packets.

	› dig samsymons.com
	
	; <<>> DiG 9.8.3-P1 <<>> samsymons.com
	;; global options: +cmd
	;; Got answer:
	;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 13652
	;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0
	
	;; QUESTION SECTION:
	;samsymons.com.                 IN      A
	
	;; ANSWER SECTION:
	samsymons.com.          300     IN      A       104.28.22.206
	samsymons.com.          300     IN      A       104.28.23.206
	
	;; Query time: 54 msec
	;; SERVER: 192.168.1.254#53(192.168.1.254)
	;; WHEN: Wed Jul 22 15:29:48 2015
	;; MSG SIZE  rcvd: 63

The answer section of the query shows two IP addresses. I’ll arbitrarily choose `104.28.22.206` to use with tshark. Running tshark by itself will capture all network traffic and will not display the TTL of each packet, so a bit of command line magic is required.

	sudo tshark -f "icmp or host 104.28.22.206" -T fields \
	-e frame.number -e frame.time_relative -e ip.src -e ip.dst \
	-e _ws.col.Protocol -e ip.ttl -e _ws.col.Info -E occurrence=f

This looks a bit intimidating, but I promise that it's not that bad. Here's what's going down:

1. The first option is specifying a capture filter which includes packets to/from the target IP, plus any ICMP packets which are received
2. The fields section is including the frame number, IP addresses, etc.
3. `-E occurrence=f` is being used to prevent duplicate data being printed

Now that you’re set up to capture packets, run `traceroute 104.28.22.206` to actually trace the route between your local machine and `samsymons.com`.

#### Reading The Data

After running traceroute, here's what was printed:

	1       0.000000000     192.168.1.78    104.28.22.206   UDP     1       Source port: 45462  Destination port: 33435
	2       0.001175000     192.168.1.254   192.168.1.78    ICMP    64      Time-to-live exceeded (Time to live exceeded in transit)
	3       0.001813000     192.168.1.78    104.28.22.206   UDP     1       Source port: 45462  Destination port: 33436
	4       0.003100000     192.168.1.254   192.168.1.78    ICMP    64      Time-to-live exceeded (Time to live exceeded in transit)
	5       0.003234000     192.168.1.78    104.28.22.206   UDP     1       Source port: 45462  Destination port: 33437
	6       0.004227000     192.168.1.254   192.168.1.78    ICMP    64      Time-to-live exceeded (Time to live exceeded in transit)
	
	7       0.004378000     192.168.1.78    104.28.22.206   UDP     2       Source port: 45462  Destination port: 33438
	8       0.122021000     10.29.242.1     192.168.1.78    ICMP    63      Time-to-live exceeded (Time to live exceeded in transit)
	9       0.123096000     192.168.1.78    104.28.22.206   UDP     2       Source port: 45462  Destination port: 33439
	10      0.224505000     10.29.242.1     192.168.1.78    ICMP    63      Time-to-live exceeded (Time to live exceeded in transit)
	11      0.224687000     192.168.1.78    104.28.22.206   UDP     2       Source port: 45462  Destination port: 33440
	12      0.328691000     10.29.242.1     192.168.1.78    ICMP    63      Time-to-live exceeded (Time to live exceeded in transit)
	
	13      0.328855000     192.168.1.78    104.28.22.206   UDP     3       Source port: 45462  Destination port: 33441
	14      0.484253000     75.154.223.211  192.168.1.78    ICMP    249     Time-to-live exceeded (Time to live exceeded in transit)
	15      0.485000000     192.168.1.78    104.28.22.206   UDP     3       Source port: 45462  Destination port: 33442
	16      0.595150000     75.154.223.211  192.168.1.78    ICMP    249     Time-to-live exceeded (Time to live exceeded in transit)
	17      0.595348000     192.168.1.78    104.28.22.206   UDP     3       Source port: 45462  Destination port: 33443
	18      0.727938000     75.154.223.209  192.168.1.78    ICMP    249     Time-to-live exceeded (Time to live exceeded in transit)
	
	19      0.728994000     192.168.1.78    104.28.22.206   UDP     4       Source port: 45462  Destination port: 33444
	20      0.869751000     206.223.119.180 192.168.1.78    ICMP    249     Time-to-live exceeded (Time to live exceeded in transit)
	21      0.870464000     192.168.1.78    104.28.22.206   UDP     4       Source port: 45462  Destination port: 33445
	22      0.999830000     206.223.119.180 192.168.1.78    ICMP    249     Time-to-live exceeded (Time to live exceeded in transit)
	23      0.999994000     192.168.1.78    104.28.22.206   UDP     4       Source port: 45462  Destination port: 33446
	24      1.111686000     206.223.119.180 192.168.1.78    ICMP    249     Time-to-live exceeded (Time to live exceeded in transit)
	
	25      1.111879000     192.168.1.78    104.28.22.206   UDP     5       Source port: 45462  Destination port: 33447
	26      1.225611000     104.28.22.206   192.168.1.78    ICMP    60      Destination unreachable (Port unreachable)
	27      1.228582000     192.168.1.78    104.28.22.206   UDP     5       Source port: 45462  Destination port: 33448
	28      1.333820000     104.28.22.206   192.168.1.78    ICMP    60      Destination unreachable (Port unreachable)
	29      1.333986000     192.168.1.78    104.28.22.206   UDP     5       Source port: 45462  Destination port: 33449
	30      1.415013000     104.28.22.206   192.168.1.78    ICMP    60      Destination unreachable (Port unreachable)

A lot of this data is pretty self explanatory, but it's worth some analysis. The first packet being sent is from my laptop's IP to the target IP. It's a UDP packet with a TTL of 1, meaning that the very first hop along the path will be the one to kill this packet and send back an ICMP response. The second packet is that exact response – the source IP belongs to the router. The first packet didn't even make it out of the local network!

You may be a little puzzled by the next 2 outbound packets. They both have a TTL set to 1! Didn't traceroute already try that value? One of the goals of traceroute is to figure out the roundtrip time between each hop, so sending three packets is a way to get the average time.

Another reason for sending multiple packets to each hop is the fact that UDP is an unreliable protocol. There's every chance that a traceroute probe packet might get dropped somewhere along the way. Sometimes you'll encounter routers which deliberately refuse to respond to certain packets, so traceroute will just give up on these and move on to the next hop.

The final three received packets are the cue to stop; they were received and processed by a machine with the target IP address. Because it had the correct IP, the target will have tried to forward the packets to the designated port on the system, and come up empty handed.

Traceroute deliberately picks unlikely port numbers because it has nothing to actually deliver to any service on the other end. This is why the final set of ICMP responses will have `Destination unreachable` types.

### Next Time

By now you should have a fairly good idea of how traceroute does its thing. In the next article, I’ll investigate how you can use Rust to reimplement traceroute’s basic functionality.

[1]:	http://online.stanford.edu/course/intro-computer-networking-winter-2014
[2]:	https://en.wikipedia.org/wiki/Transmission_Control_Protocol "TCP on Wikipedia"
[3]:	https://en.wikipedia.org/wiki/User_Datagram_Protocol "UDP on Wikipedia"
[4]:	http://www.webrtc.org
[5]:	https://en.wikipedia.org/wiki/TCP_congestion-avoidance_algorithm "TCP's congestion avoidance algorithms on Wikipedia"
[6]:	https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol "ICMP on Wikipedia"
[7]:	https://www.wireshark.org/docs/man-pages/tshark.html
