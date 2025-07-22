---
title: "Generating the Manual"
date: 2023-03-15T21:12:47-03:00
draft: false 
---

A listing of the pages held within the Manual are stored in a system-generated database.  Accessing them is as simple as `man <command>`, and (usually) detailed listing of how to use a command is presented. Check out [Finding Help in Linux]({{< ref "findingHelpInLinux.md" >}}) for more information about how to use `man`
 
### Help! The Manual is Missing!
On freshly created Linux system, it is common that the Manual Pages have not yet been generated.  Running a `man <command>` results in an error, even for basic core utilities such as `ls`.  This can be a problem - as especially on newly-created systems, it is really common to need to issue lots of commands with rarely-used options.  It is also worth noting that sometimes the Manual can become outdated during a software update and might need to be rebuilt.

Most distributions of Linux use a scheduled job to generate the Manual - usually daily.  Predictably, there is also a manual way to generate the Manual quickly and easily.  Run the `mandb` command to update the Manual to the latest and greatest version:

![Generate the Manual]({{< siteurl >}}/images/endOfManDBCommand.png)

Once this has successfully completed, a fully populated Manual awaits the curious user.  Let the learning commence!
