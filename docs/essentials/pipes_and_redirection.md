# Pipes and Redirection

In Linux, the "Unix Philosophy" is: *"Write programs that do one thing and do it well. Write programs to work together."*

To make programs work together, we use **Pipes** and **Redirection**. They allow us to connect the output of one command to the input of another, creating a powerful "assembly line" for data.

## 1. Standard Streams

Every command in Linux has three "pipes" attached to it automatically:
1.  **STDIN (0):** Standard Input (usually your keyboard).
2.  **STDOUT (1):** Standard Output (usually your screen).
3.  **STDERR (2):** Standard Error (where error messages go).

## 2. Redirection: To and From Files

Instead of printing to the screen, you can redirect output to a file.

-   **`>` (Overwrite):** Saves output to a file, deleting anything that was already there.
    -   `ls > files.txt`
-   **`>>` (Append):** Adds output to the end of a file.
    -   `echo "New line" >> notes.txt`
-   **`<` (Input):** Feeds a file into a command.
    -   `sort < names.txt`

## 3. Pipes: Command to Command

A **Pipe (`|`)** takes the STDOUT of the command on the left and feeds it into the STDIN of the command on the right.

**Example:**
`ls -l /etc | less`
1.  `ls -l` lists all files.
2.  Instead of printing 500 lines to the screen, the pipe sends them to `less`.
3.  `less` allows you to scroll through the list one page at a time.

**Complex Pipeline:**
`cat access.log | grep "404" | wc -l`
1.  Read the log file.
2.  Find lines containing "404".
3.  Count how many lines were found.

## Practice Problems

??? question "Practice Problem 1: Overwrite vs Append"

    You run `echo "Hello" > test.txt`.
    Then you run `echo "World" > test.txt`.
    What is inside `test.txt`?

    ??? tip "Solution"
        **"World"**
        
        The single `>` overwrites the file. If you wanted both words, you should have used `>>` for the second command.

??? question "Practice Problem 2: Hidden Errors"

    You run a command that produces an error, and you try to save it to a file:
    `bad_command > error.log`
    The file `error.log` is empty, and the error still prints to the screen. Why?

    ??? tip "Solution"
        Because `>` only redirects **STDOUT (1)**. Error messages are sent to **STDERR (2)**. To redirect errors, you must use `2>`:
        `bad_command 2> error.log`

## Key Takeaways

| Symbol | Action |
| :--- | :--- |
| **`>`** | Redirect Output (Overwrite). |
| **`>>`** | Redirect Output (Append). |
| **`<`** | Redirect Input. |
| **`|`** | Send output of one command to input of another. |

---

Pipes are the "glue" of Linux. By combining small, simple tools into a pipeline, you can perform complex data processing tasks that would normally require a custom-written program.
