---
title: "BASH If/Else Statements"
date: 2023-03-28T08:37:52-03:00
draft: false
---

Shell scripting comes fully equipped with `if/else` statement capabilities.  This is commonly used to evaluate conditions such as input from parameters, ensure files exist, ensure that processes are running, and there are several other use cases.  The syntax is a little different than some other languages, but for the most part BASH `if/else` statements are easy, even for those who haven't used other programming languages.  

In this demo, we'll write a simple script to check if a file exists on the system.  The finished product will work like this:

![Testing If `myFile.txt` Exists]({{< siteurl >}}/images/testMyFileDemo.png)

## Step 1: Determine the Condition 
One of the really fantastic things about shell scripting is that it will run most anything that will run in the standard CLI.  This can make testing conditionals very simple - check the output of any command with the server is running in the desired state, then use that same command in a script.  For example, if checking to see if the SSH service is running, issue this command:

``` shell
# Check to see if SSH is mentioned in a PID, removing the grep results, and counting the number of lines in the result
ps aux | grep ssh | grep -v grep | wc -l
```

Which results in:

![Checking SSH is Running]({{< siteurl >}}/images/grepSSHwc.png)

So, as there is one line returned, there is one SSH process running.  This command could be embedded in any shell script as `echo $(ps aux | grep ssh | grep -v grep | wc -l)`.  Or, as we'll see below, it could be used as a conditional in an `if/else` statement.

> Tip: If the above command is unclear, reverse engineer it by removing the piped sections one-by-one and figure out how this command works.

For the script we're about to write, we're going to check if a file exists.  This is a very useful check for scripts that rely on parameter files or logs to exist before they can run correctly.  Its also a useful example to illustrate the versatility and diversity of BASH scripting - it's a conditional that can't be used directly in command-line usage.

## Step 2: Create the File

> Before creating any file, it is a smart idea to check and see where the BASH shell is located.  This is standardized to `/bin/bash`, however, a quick `which bash` will make sure that BASH is where it is expected

Creating the file is as simple as `vim testMyFile.sh`.  This is the file in which we'll check to see if "myFile.txt" exists or not.  After jumping into `INSERT` mode, add the "shebang" line:

``` shell
#!/bin/bash
```

This tells the kernel that the contents of the file should be interpreted using the BASH program.  If the "shebang" is missing, the file won't run correctly.  

> Note - this also works for other programming languages.  For example, when writing a Python script, the "shebang" might be `#!/bin/python3`, and the kernel will interpret the program using Python

## Step 3: Write the If/Else Statement
Now on to the fun part - writing the `if/else` statement.  The finished product looks like this:

![BASH If/Else Demo]({{< siteurl >}}/images/ifElseFileExists.png)

Before just copy/pasting this, lets break it down and explain it a little.

### The "If" Statement

Any `if/else` statement starts with `if [ <condition> ]; then`.  In pseudo-code, this translates to "if this condition is met, do the following":

``` shell
# If myFile.txt exists, do the following:
if [ -f myFile.txt ]; then
    # Write in the terminal that the file exists
    echo "The file exists!"
fi
```

Notice the `fi` at the end of the statement - this is how an `if` statement is closed in BASH.  Its just the reverse of `if`.

> Note that single square brackets may not work on UNIX operating systems such as AIX and Solaris.  For these systems, use double square-brackets.  Also, the checks for equality are a little unique - for example `-gt` (greater than) or `-le` (less than or equal) - rather than more standard `>=` used by most programming languages.

### Add the Catch-All "Else" 

An `if` statement is plenty useful just by itself.  Adding an `else` to perform a different action if the condition IS NOT met increases the versatility exponentially.  In our example, if a file exists, we tell the user, "The file exists!".  But if the file doesn't exist, we tell them "Not there!":

``` shell
if [ -f myFile.txt ]; then
    echo "The file exists!"
# Catch-all else statement, if file doesn't exist, do this:
else
    # Write to the terminal that the file isn't there
    echo "Not there!"
    # Write an exit code for the script that shows a generic "1" error
    exit 1
fi
```

Note the `exit 1` line within the `else` section.  This is not strictly necessary, but is a good example of what could happen if a condition isn't met.  Having a script exit if conditions for it success are not met is very common in Enterprise Linux scripting.

> This is a small and simple example with all the unnecessary complexity stripped out.  It would be much more useful if this `else` statement actually sent an alert or an email to an administrator saying "The critical file needed for this process is missing!" - but that might muddle the examination of the `else` statement.

### How About Multiple Possibilities?

BASH `if/else` statements also handle multiple possibilities with the `elif` statement.  It is used in the exact same ways as the `if` statement.  For example, our script above could be expanded to check if a different file exists instead:

``` shell
if [ -f myFile.txt ]; then
    echo "The file exists!"
elif [ -f myOtherFile.txt ]; then
    echo "The other file exists, using that instead."
else
    echo "Not there!"
    exit 1
fi
```
