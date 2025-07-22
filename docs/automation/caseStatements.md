---
title: "BASH Case Statements"
date: 2023-04-06T07:59:35-03:00
draft: false
---

One of the very nice options available in shell scripting is the `case` statement.  The case statement allows the script to test many different conditionals much more efficiently (in terms of lines of code) than an `if/elif/else` statement (see [Decision Making - `if/else` Statements]({{< ref "ifElseStatements.md" >}}) for further details).  

> Shell's `case` statement is similar to the `switch` statement found in other programming languages (both of which are missing entirely from Python!)

As an example, a recent version of Manjaro running i3wm includes the following case statement in its `.bashrc` file; it decides how to correctly handle compressed files:

![.bashrc Case Statement]({{< siteurl >}}/images/caseStatement.png)

## Case Statement Syntax and Basic Usage

The syntax of the case statement is as follows:

``` shell
case variable in
    pattern1)
        command1
        ;;
    pattern2)
        command2
        ;;
    pattern3)
        command3
        ;;
    *)
        default_command
        ;;
esac

```

Here, `variable` is the value to check, and `pattern1`, `pattern2`, `pattern3` are the possible values to match. `command1`, `command2`, and `command3` are the commands to be executed a match is found.  The `default_command` will be executed if none of the patterns match.  

A very simple example to understand the case statement is as follows:

``` shell 
#!/bin/bash

# User is prompted to provide input
echo "Enter a number between 1 and 3: "
# Input is taken from the user
read num

# Case Statement Evaluates the Response and Responds
case $num in
    1)
        echo "You entered one."
        ;;
    2)
        echo "You entered two."
        ;;
    3)
        echo "You entered three."
        ;;
    *)
        echo "Invalid number."
        ;;
esac
```

## Best Practices for Using Case Statements

While case statements can be powerful tools for shell scripting, they can also be tricky to use correctly. Here are some best practices to keep in mind when using case statements:

1. **Use the correct syntax:** Make sure that your case statement follows the correct syntax. Any mistakes in the syntax can cause your script to fail.

2. **Use meaningful variable names:** Choose variable names that are meaningful and descriptive. This will make it easier to understand the purpose of the case statement.

3. **Use consistent indentation:** Use consistent indentation for each case statement block. This will make it easier to read and understand the code.

4. **Use comments:** Use comments to explain the purpose of the case statement and each block of code. This will make it easier for others to understand your code.

5. **Use patterns wisely:** Choose patterns that are easy to understand and maintain. Avoid using complex regular expressions that can be difficult to read and understand.

6. **Use a default block:** Always include a default block in your case statement. This will ensure that your script handles unexpected values correctly.

7. **Keep it simple:** Use the case statement only when it is necessary. If a simple if statement can accomplish the same task, use it instead.

Case statements are powerful tools for shell scripting that allow checking the value of a variable and executing different blocks of code based on its value. Enjoy!

