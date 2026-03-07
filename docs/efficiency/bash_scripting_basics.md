# Scripting `Hello World`

Writing a Hello World program is a rite of passage in programming — like your first cup of really good coffee. ☕ Here's how to do it in a shell script — straight from the command line on an enterprise Linux system.

???+ warning "Prerequisites"

     This guide assumes you're comfortable with
     [`vim`](../basic_toolset/text_editors.md#vi-vim).  If not, maybe start
     there first.

## Step-by-Step Guide

1. **Create the script file**

    Starting from a [shell](../basic_toolset/shells.md), create and open a new file,
    "HelloWorld.sh", using `vim`:

    ``` shell title="Create HelloWorld.sh"
    vim HelloWorld.sh
    ```

2. **Write the script**

    Inside "HelloWorld.sh", enter *Insert mode* and type this *exactly*:

    ``` shell title="Write HelloWorld.sh"
    #!/bin/bash

    echo "Hello World!"
    ```

    ![Write `HelloWorld.sh` in `vim`](../images/vim_hello_world.png)

    - The first line (`#!/bin/bash`) is called a shebang. It tells Linux which
      interpreter should run the script. In this case, it's the Bash shell.
    - The blank line is optional, but it makes the script easier to read.
    - The next line with the keyword `echo` just prints Hello World! to the
      screen.

3. **Save and exit**

    Go back to *Normal mode*, save the file, and exit using `:wq`

4. **Make the file executable**

    By default, new files aren't executable. Add that permission:

    ``` bash title="Make the file executable"
    chmod 700 HelloWorld.sh # (1)!
    ```

    1.  Using `700` gives the owner full permissions (read, write, execute) while removing all permissions for group and others. See [Basic Permissions](../essential_concepts/file_permissions.md) for a more thorough explanation.

5. **Run the script**

    Finally, run it:

    ``` bash title="Run the script"
    ./HelloWorld.sh
    ```

    ![Run `HelloWorld.sh`](../images/hello_world.png)

## Troubleshooting

If your script didn’t run the first time, don’t worry — here are the
common gotchas:

### Permission denied when running `./HelloWorld.sh`

- You probably forgot to make it executable. Run:

    ``` bash title="Make the file executable"
    chmod 700 HelloWorld.sh
    ```

### `command not found` or nothing happens

- Make sure you're running it with `./HelloWorld.sh` and not just
`HelloWorld.sh`. The `./` tells the shell to look in the current directory
for the script.

### Weird characters in the output
- Make sure you typed the script exactly as shown, especially the quotes
around "Hello World!".
- Double-check that the first line is `#!/bin/bash` with no extra spaces or
characters. If you leave out the `!`, for example, it won't work.

### Using Windows line endings

- If you created the script on Windows and then copied it to Linux, it may
have Windows-style line endings (CRLF) instead of Unix-style (LF). This can
cause issues. To fix it, run:

    ``` bash title="Convert line endings"
    dos2unix HelloWorld.sh
    ```

### Still stuck?

- Try running the script with `bash -x` to see what’s going on behind the
    scenes:

    ``` bash title="Run with bash -x"
    bash -x HelloWorld.sh
    ```