---
title: Introduction to Nmap
date: "2015-04-19"
tags: nmap
---

Nmap is one of my favorite tools. It gives you an easy way to discover the machines available on a network, and determine the services that each one is running. However, networks are complicated – this is reflected in the sheer number of options which Nmap provides (running `nmap` with no arguments outputs over 110 lines of available flags).

### Basics

The simplest way to use Nmap is to give it an address to scan. Here's the output of scanning an instance of [Metasploitable][1] running locally in Virtualbox:

	› nmap 192.168.1.79

	Starting Nmap 6.47 ( http://nmap.org ) at 2015-04-19 16:03 PDT
	Nmap scan report for 192.168.1.79
	Host is up (0.0018s latency).
	Not shown: 976 closed ports
	PORT      STATE SERVICE
	21/tcp    open  ftp
	22/tcp    open  ssh
	23/tcp    open  telnet
	25/tcp    open  smtp
	53/tcp    open  domain
	80/tcp    open  http
	111/tcp   open  rpcbind
	139/tcp   open  netbios-ssn
	445/tcp   open  microsoft-ds
	512/tcp   open  exec
	513/tcp   open  login
	514/tcp   open  shell
	1099/tcp  open  rmiregistry
	1524/tcp  open  ingreslock
	2049/tcp  open  nfs
	2121/tcp  open  ccproxy-ftp
	3306/tcp  open  mysql
	5432/tcp  open  postgresql
	5900/tcp  open  vnc
	6000/tcp  open  X11
	6667/tcp  open  irc
	8009/tcp  open  ajp13
	8180/tcp  open  unknown
	49167/tcp open  unknown

	Nmap done: 1 IP address (1 host up) scanned in 1.25 seconds

Without even passing any arguments, Nmap spits out some useful output. By default, Nmap scans what it calls the *top ports*, a number which changes based on the version but is usually around \~1500. There are a couple ways to get finer control over the ports scanned.

`nmap -p1-1000 192.168.1.79` is how you would scan a range of ports, in this case ports 1 through 1000. It's also possible to add additional ports along with a range, with port 1200 added to the previous command: `nmap -p1200,1-1000 192.168.1.79`.

### Host Discovery

Often, you don't have a particular IP in mind when you're looking to scan something. Nmap can scan a range of IP addresses and display those which were successfully reached. Here's how to run a ping scan on your local network (the actual scanning of ports won't happen this way):

	› nmap -sP 192.168.1.\*

	Starting Nmap 6.47 ( http://nmap.org ) at 2015-04-19 16:11 PDT
	Nmap scan report for 192.168.1.64
	Host is up (0.12s latency).
	Nmap scan report for 192.168.1.70
	Host is up (0.12s latency).
	Nmap scan report for 192.168.1.71
	Host is up (0.12s latency).
	Nmap scan report for 192.168.1.75
	Host is up (0.066s latency).
	Nmap scan report for 192.168.1.76
	Host is up (0.0031s latency).
	Nmap scan report for 192.168.1.79
	Host is up (0.0028s latency).
	Nmap scan report for 192.168.1.254
	Host is up (0.0033s latency).
	Nmap done: 256 IP addresses (7 hosts up) scanned in 12.43 seconds

You can even run that previous scan as root in order to get back the hostname for each address.

One more feature that it pretty useful is the ability to detect which operating system each host is running. By running `nmap -O 192.168.1.*`, Nmap will print a run-down of each machine. Here's an example on my local network (I won't put the entire output here, because it's a lot):

	Nmap scan report for 192.168.1.71
	Host is up (0.0075s latency).
	All 1000 scanned ports on 192.168.1.71 are closed
	MAC Address: E8:61:7E:A1:E0:E7 (Liteon Technology)
	Device type: firewall|general purpose|game console
	Running: Cisco AsyncOS 7.X, FreeBSD 6.X|7.X|8.X, Sony FreeBSD
	OS CPE: cpe:/h:cisco:ironport\_c650 cpe:/o:cisco:asyncos:7.0.1 cpe:/o:freebsd:freebsd:6.2 cpe:/o:freebsd:freebsd:7.0:beta2 cpe:/o:freebsd:freebsd:8 cpe:/o:sony:freebsd
	Too many fingerprints match this host to give specific OS details
	Network Distance: 1 hop

It's running Sony's version of FreeBSD. I have a PS4 on the network; looks like Nmap found it!

### Conclusion

Nmap is a great tool; this article does not come even close to doing it justice. Nmap supports all sorts of scanning options, output formats, scan resuming... you name it, Nmap can probably do it.

Go download a copy of Metasploitable and see what trouble you can get into. Just remember not to do anything dumb.

[1]:	http://sourceforge.net/projects/metasploitable/
