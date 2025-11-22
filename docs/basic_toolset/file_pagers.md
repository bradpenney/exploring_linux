# File Pagers

When you’re poking around in Linux and want to peek inside a file, you’ve
got a handful of handy pager commands at your disposal. Here are some of
the ones you can use, plus a few tips for each.

## `more`

Think of `more` as the classic, old-school pager. Press **Space** to keep
moving through the file. You can also search with `/`, just like in `man`
pages or `vim`.

``` bash
more myFile.txt
cat myFile.txt | more
```

## `less`

This is the pager most folks actually use day-to-day. (The name is a joke — "less is more." 😄) It fixes a bunch of `more`'s limitations: you can scroll with the arrow keys or Space, and `/` search works here too. Once you try it, you'll rarely go back.

``` bash
less myFile.txt
cat myFile.txt | less
```

## `view`

This one’s basically `vim` in read-only mode. You get all the movement and
search powers of `vim`, but by default you can’t save changes — unless you
really mean it with a `!` (and have write permissions).

``` bash
view myFile.txt
```

## `cat`

Not technically a pager, but worth mentioning. `cat` just dumps the whole
file to your terminal in one go. Perfect for tiny files, less fun for giant
log monsters. It’s also a common building block when you’re piping output to
other commands.

``` bash
cat myFile.txt
cat myFile.txt | grep -v 'notLinesWithThisText'
```

??? tip "Not sure which to use?"

    If you’re not sure which to use, start with `less`. It’s faster, friendlier,
    and more flexible than the others. Happy paging! 🎉
