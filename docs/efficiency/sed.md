# Sed: The Stream Editor

**`sed`** is short for **S**tream **Ed**itor. Unlike a text editor like Vim or Nano, where you open a file and manually type changes, `sed` performs edits automatically as text "streams" through it.

It is most commonly used for **Search and Replace**.

## 1. Basic Substitution

The core syntax for substitution is:
`sed 's/find/replace/' file`

**Example:**
`echo "The cat sat on the mat" | sed 's/cat/dog/'`
-   *Output:* "The dog sat on the mat"

## 2. The Global Flag (`g`)

By default, `sed` only replaces the **first** occurrence on each line.

`echo "red fish blue fish" | sed 's/fish/cat/'`
-   *Output:* "red cat blue fish"

To replace every occurrence, add the `g` (global) flag:
`echo "red fish blue fish" | sed 's/fish/cat/g'`
-   *Output:* "red cat blue cat"

## 3. In-place Editing (`-i`)

Normally, `sed` prints the edited text to the screen but **does not change the original file**.

To save your changes directly to the file, use the **`-i`** flag. 

`sed -i 's/localhost/127.0.0.1/g' config.txt`
*(This will permanently update `config.txt`)*.

**Warning:** Be careful with `-i`! It’s a good idea to run the command without it first to make sure your substitution is correct before committing the change to the file.

## 4. Deleting Lines

You can also use `sed` to delete lines that match a pattern.

`sed '/debug/d' log.txt`
*(This prints `log.txt` but deletes any line containing the word "debug")*.

## Practice Problems

??? question "Practice Problem 1: Changing Delimiters"

    You want to change the word "path/to/file" to "new/path". Using `sed 's/path\/to\/file/new\/path/'` is messy because of the slashes. Is there a better way?

    ??? tip "Solution"
        **Yes.** 
        
        You can use any character as a delimiter in `sed`, not just `/`. Many people use `|` or `:` to make it cleaner:
        `sed 's|path/to/file|new/path|' file`

??? question "Practice Problem 2: Global Replace"

    You have a file `names.txt` where the word "John" appears three times on the first line. You run `sed 's/John/Doe/' names.txt`. How many times is "John" replaced on that first line?

    ??? tip "Solution"
        **Once.** 
        
        Without the `g` flag, `sed` only replaces the first instance it finds on each line.

## Key Takeaways

-   **`s/old/new/`** is the command for substitution.
-   Add **`g`** to the end to replace all instances on a line.
-   Use **`-i`** to save changes directly to the file.
-   Use **`/pattern/d`** to delete matching lines.

---

`sed` is a scalpel for text processing. While it has a massive list of complex commands, mastering the basic search-and-replace syntax gives you the power to automate repetitive editing tasks across thousands of files in seconds.
