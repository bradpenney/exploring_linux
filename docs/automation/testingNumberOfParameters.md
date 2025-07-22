---
title: "Testing the Number Of Parameters Passed to a Shell Script"
date: 2023-03-26T06:54:47-03:00
draft: false 
---

More often than not, custom shell scripts accept parameters supplied by the command-line user.  In case you're wondering what sort of things commonly get passed to custom shell scripts, here are some examples:

1. Which Process ID (PID) to perform an action on
2. Custom location for a log file
3. Desired location for the output
4. Which database or application to perform an action on
5. Anything else that could be changed on each run of the script.

In situations like these, it may be CRITICAL that the correct number of parameters are supplied (otherwise the script will run incorrectly!).  Writing a quick check to confirm that the correct number of parameters was supplied is a step in the right direction for error checking.  Here's an example:

``` shell
#!/bin/bash

NUM_REQUIRED_PARAMS=2
num_params=$#

# Were 2 parameters supplied?
if [[ num_params -lt $NUM_REQUIRED_PARAMS ]] ; then
  echo "Not enough parameters.  This script requires ${NUM_REQUIRED_PARAMS}."
  sleep 2
  exit 1
fi

# OPTIONAL - useful for sending parameters to logs
# for loop showing how many parameters
echo "You ran this program with ${num_prams} parameters. Here they are:"
for param in "$@":
do
   echo "$param"
done
```

> Note that this doesn't guarantee that the parameters are in the correct order or have appropriate values supplied.  These conditions should be checked as well.  In a robust script, this would just be the first check of several.
