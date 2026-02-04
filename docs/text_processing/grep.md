# Grep: The Ultimate Searcher

If you spend any time in the Linux terminal, **`grep`** will quickly become your most-used tool. Its name stands for **G**lobal **R**egular **E**xpression **P**rint.

Its job is simple: scan a file (or input) and print only the lines that match a specific pattern.

## 1. Basic Usage

The simplest way to use grep is to search for a word in a file.

`grep "error" server.log`

This will print every line in `server.log` that contains the word "error."

## 2. Common Flags

`grep` is much more powerful when you use its flags:

-   **`-i` (Ignore Case):** Matches "ERROR," "Error," and "error."
    -   `grep -i "error" server.log`
-   **`-v` (Invert Match):** Prints everything **except** the lines that match.
    -   `grep -v "debug" server.log` (Show me everything that isn't a debug message).
-   **`-r` (Recursive):** Searches for the pattern in all files in a directory and its subdirectories.
    -   `grep -r "password" /etc/`
-   **`-n` (Line Number):** Shows you which line the match was found on.
-   **`-c` (Count):** Just tells you *how many* lines matched, rather than printing the lines.

## 3. Regular Expressions (Regex)

Grep is named after **Regular Expressions**. You aren't limited to searching for exact words; you can search for patterns. (Learn more about patterns in the [Regular Expressions](regular_expressions.md) article).

-   **`^` (Start of line):** `grep "^Search" file` (Find lines starting with Search).
-   **`$` (End of line):** `grep "End$" file` (Find lines ending with End).
-   **`.` (Any character):** `grep "h.t" file` (Matches "hat," "hit," "hot").

## 4. Grep in a Pipeline

Grep is most commonly used at the end of a pipe to filter output from other commands.

`ps aux | grep "python"`
*(List all running processes, but only show the ones related to Python).*

## Practice Problems

??? question "Practice Problem 1: Finding IP Addresses"

    You have a file `access.log`. You want to see every line that **does NOT** come from the IP `192.168.1.1`. Which command do you use?

    ??? tip "Solution"
        **`grep -v "192.168.1.1" access.log`**
        
        The `-v` flag tells grep to "invert" the search, showing only the lines that don't match the pattern.

??? question "Practice Problem 2: Counting Errors"

    How many times does the word "Critical" appear in `syslog`? (You only want the number).

    ??? tip "Solution"
        **`grep -c "Critical" /var/log/syslog`**
        
        The `-c` flag returns the count of matching lines.

## Key Takeaways

-   **Grep** filters text line by line.
-   Use **`-i`** for case-insensitivity and **`-v`** to exclude lines.
-   Combine it with **Pipes** to filter output from any command.

---

Grep is the "X-Ray vision" of the Linux terminal. Whether you are searching through source code, log files, or system configurations, `grep` allows you to cut through the noise and see exactly the information you need.
