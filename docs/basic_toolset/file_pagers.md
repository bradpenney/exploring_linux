# File Pagers

When you’re poking around in Linux and need to peek inside a file, you’ve
got a handful of handy pager commands at your disposal. Here are some of the one's you've got at your disposal, including a few tips on each.

## 1. `more`

Think of `more` as the classic, old‑school pager. Press **Space** to keep
moving through the file. You can also search with `/`, just like in `man`
pages or `vim`.

**Examples:**

```bash
more myFile.txt
cat myFile.txt | more
```

*(Yep, people still do this… even though it’s not the most efficient.)*

## 2. `less`

This is the pager most folks actually use day‑to‑day. It fixes a bunch of
`more`’s limitations: you can scroll with the arrow keys or Space, and `/`
search works here too. Once you try it, you’ll rarely go back.

**Examples:**

```bash
less myFile.txt
cat myFile.txt | less
```

*(Again, not ideal… but you’ll see it around.)*

## 3. `view`

This one’s basically `vim` in read‑only mode. You get all the movement and
search powers of `vim`, but by default you can’t save changes — unless you
really mean it with a `!` (and have write permissions).

**Example:**

```bash
view myFile.txt
```

## 4. `cat`

Not technically a pager, but worth mentioning. `cat` just dumps the whole
file to your terminal in one go. Perfect for tiny files, less fun for giant
log monsters. It’s also a common building block when you’re piping output to
other commands.

**Examples:**

```bash
cat myFile.txt
cat myFile.txt | grep -v 'notLinesWithThisText'
```

> **Pro tip:**
> If you’re not sure which to use, start with `less`. It’s faster, friendlier,
> and more flexible than the others. Happy paging! 🎉

