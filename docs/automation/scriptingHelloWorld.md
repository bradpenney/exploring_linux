---
title: "Scripting 'Hello World'"
date: 2023-03-26T07:22:44-03:00
draft: false 
---

> If you've never written a shell script before, this is the place to start.  If you have, maybe skip this as it covers the absolute basics.

Writing a "Hello World" program is a rite-of-passage in the programming world.  Here is how to do it in shell scripting (via the command line in an enterprise-grade Linux system).  

> Assumption: You already know how you use `vim`.

1. Starting from the command line, create a new file called "HelloWorld.sh" using `vim`:

``` shell 
vim HelloWorld.sh
```

2. Inside "HelloWorld.sh", write the following:

``` shell
#!/bin/bash 

echo "Hello World!"
```

![Write `HelloWorld.sh` in `vim`"]({{< siteurl >}}/images/vimHelloWorld.png) 

3. Save the file and exit using `:wq`

4. Make the file executable by issuing the command `chmod 700 HelloWorld.sh` (see [Basic Permissions]({{< ref "../everydayadmin/basicPermissions.md" >}}) for a more thorough explanation).

5. Run your file with `./HelloWorld.sh`:

![Run `HelloWorld.sh`]({{< siteurl >}}/images/HelloWorld.png)
