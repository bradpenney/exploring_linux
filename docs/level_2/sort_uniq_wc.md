# Sorting and Counting

!!! quote "Organize, deduplicate, quantify"

## Why These Tools Matter

You've searched files and found matches. Now you need to make sense of the data - organize it, remove duplicates, count occurrences.

**Three simple tools handle most of these tasks:**

- **`sort`** - Arrange lines in order (alphabetical, numerical, reverse, etc.)
- **`uniq`** - Remove or identify duplicate lines
- **`wc`** - Count lines, words, characters

They're deceptively simple individually, but powerful when combined via pipes.

## Sorting: The `sort` Command

`sort` arranges lines of text in order.

### Basic Sorting

```bash title="Sort lines alphabetically"
sort names.txt
```

**Input (names.txt):**
```
Charlie
Alice
Bob
```

**Output:**
```
Alice
Bob
Charlie
```

**Sort output from another command:**

```bash title="List files, sorted alphabetically"
ls | sort
```

### Reverse Sort

```bash title="Sort in reverse order"
sort -r names.txt
```

**Output:**
```
Charlie
Bob
Alice
```

### Numerical Sort

By default, `sort` treats everything as strings:

```bash
echo -e "10\n2\n1\n20" | sort
```

**Output:**
```
1
10
2
20
```

That's alphabetical order (1, 10, 2, 20), not numerical.

**Sort numerically:**

```bash title="Numerical sort"
echo -e "10\n2\n1\n20" | sort -n
```

**Output:**
```
1
2
10
20
```

### Human-Readable Numerical Sort

File sizes like "1K", "1M", "1G":

```bash title="Sort human-readable numbers"
du -h * | sort -h
```

**Output:**
```
4.0K file1.txt
128K file2.txt
1.5M file3.txt
2.3G file4.iso
```

### Sort by Column/Field

Many files have columns separated by spaces, tabs, or delimiters.

```bash title="Sort by second column"
sort -k 2 data.txt
```

**Input (data.txt):**
```
Alice 30
Bob 25
Charlie 35
```

**Output (sorted by age):**
```
Bob 25
Alice 30
Charlie 35
```

**Sort by second column numerically:**

```bash
sort -k 2 -n data.txt
```

**Use different delimiter:**

```bash title="Sort CSV by third column"
sort -t ',' -k 3 data.csv
```

`-t ','` sets delimiter to comma.

### Remove Duplicates While Sorting

```bash title="Sort and remove duplicates"
sort -u names.txt
```

This is equivalent to `sort names.txt | uniq`, but faster.

### Case-Insensitive Sort

```bash title="Ignore case while sorting"
sort -f names.txt
```

Treats "Alice" and "alice" as the same for sorting purposes.

### Practical Sort Examples

**Sort log files by timestamp:**

```bash
sort access.log
```

If timestamps are at the beginning, this chronologically orders entries.

**Find largest files:**

```bash
du -h * | sort -h -r
```

`-h` for human-readable numbers, `-r` for reverse (largest first).

**Sort IP addresses:**

```bash title="Sort IPs numerically"
sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n ips.txt
```

Sorts each octet numerically.

**Sort and show top 10:**

```bash
sort file.txt | head -10
```

## Removing Duplicates: The `uniq` Command

`uniq` filters out duplicate lines - but **only adjacent duplicates**.

That's why it's almost always used after `sort`.

### Basic Duplicate Removal

```bash title="Remove duplicate lines"
sort names.txt | uniq
```

**Input (names.txt):**
```
Alice
Bob
Alice
Charlie
Bob
```

**After sort:**
```
Alice
Alice
Bob
Bob
Charlie
```

**After uniq:**
```
Alice
Bob
Charlie
```

### Count Occurrences

```bash title="Count how many times each line appears"
sort names.txt | uniq -c
```

**Output:**
```
      2 Alice
      2 Bob
      1 Charlie
```

The number shows how many times each name appeared.

### Show Only Duplicates

```bash title="Show only lines that appear more than once"
sort names.txt | uniq -d
```

**Output:**
```
Alice
Bob
```

### Show Only Unique Lines (Not Duplicated)

```bash title="Show lines that appear exactly once"
sort names.txt | uniq -u
```

**Output:**
```
Charlie
```

### Case-Insensitive Uniqueness

```bash title="Ignore case when checking duplicates"
sort -f names.txt | uniq -i
```

Treats "Alice" and "alice" as duplicates.

### Practical `uniq` Examples

**Find most common IP addresses in access log:**

```bash
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

1. Extract IPs (first column)
2. Sort them
3. Count occurrences
4. Sort by count (reverse numerical)
5. Show top 10

**Find duplicate lines in a file:**

```bash
sort file.txt | uniq -d
```

**Remove duplicates from a list:**

```bash
sort -u list.txt
```

Or:

```bash
sort list.txt | uniq > unique_list.txt
```

**Find how many unique visitors:**

```bash
awk '{print $1}' access.log | sort -u | wc -l
```

## Counting: The `wc` Command

`wc` stands for "word count" but counts lines, words, and characters.

### Basic Counting

```bash title="Count lines, words, characters"
wc file.txt
```

**Output:**
```
  42  215  1342 file.txt
```

- 42 lines
- 215 words
- 1342 characters (bytes)

### Count Lines Only

```bash title="Count lines"
wc -l file.txt
```

**Output:**
```
42 file.txt
```

**This is the most common use of `wc`.**

### Count Words Only

```bash title="Count words"
wc -w file.txt
```

### Count Characters Only

```bash title="Count characters"
wc -c file.txt
```

**Or bytes (usually the same):**

```bash
wc -m file.txt
```

### Count Multiple Files

```bash
wc -l *.txt
```

**Output:**
```
  42 file1.txt
  38 file2.txt
  55 file3.txt
 135 total
```

### Practical `wc` Examples

**Count files in directory:**

```bash
ls | wc -l
```

**Count how many users are logged in:**

```bash
who | wc -l
```

**Count processes:**

```bash
ps aux | wc -l
```

**Count errors in log:**

```bash
grep "ERROR" app.log | wc -l
```

**Count lines of code in project:**

```bash
find . -name "*.py" -exec wc -l {} + | tail -1
```

Shows total line count for all Python files.

**Count unique IPs in access log:**

```bash
awk '{print $1}' access.log | sort -u | wc -l
```

## Combining Sort, Uniq, and wc

The real power comes from combining these tools.

### Find Most Common Lines in File

```bash
sort file.txt | uniq -c | sort -rn | head -10
```

1. Sort lines
2. Count duplicates
3. Sort by count (reverse numerical)
4. Show top 10

**Example - most common HTTP status codes:**

```bash
awk '{print $9}' access.log | sort | uniq -c | sort -rn
```

**Output:**
```
   4532 200
   1847 404
    523 301
    187 500
```

### Find Unique Values and Count Them

```bash
cut -d ',' -f 2 users.csv | sort -u | wc -l
```

1. Extract second column (e.g., country)
2. Sort and get unique values
3. Count how many unique countries

### Identify Duplicate Entries

```bash
sort data.txt | uniq -d -c | sort -rn
```

Shows duplicates with counts, most frequent first.

### Calculate Percentages

```bash title="What percentage of log entries are errors?"
total=$(wc -l < app.log)
errors=$(grep -c "ERROR" app.log)
echo "scale=2; $errors * 100 / $total" | bc
```

### Top 10 Most Frequent Commands in History

```bash
history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10
```

**Output might show:**
```
    523 ls
    412 cd
    287 git
    203 grep
    156 vim
```

## Common Patterns and Workflows

### Analyzing Log Files

**Most common error messages:**

```bash
grep "ERROR" app.log | sort | uniq -c | sort -rn | head -10
```

**Requests per hour:**

```bash
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c
```

**Top 10 user agents:**

```bash
awk -F'"' '{print $6}' access.log | sort | uniq -c | sort -rn | head -10
```

### Data Analysis

**Count values in CSV column:**

```bash
cut -d',' -f3 data.csv | sort | uniq -c | sort -rn
```

**Find missing values:**

```bash
seq 1 100 > expected.txt
cut -d',' -f1 actual.csv | sort -n > actual_ids.txt
comm -23 expected.txt actual_ids.txt
```

Shows IDs present in expected but missing in actual.

### System Administration

**Most active users:**

```bash
last | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
```

**Most common SSH login attempts:**

```bash
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn
```

**Disk usage by directory:**

```bash
du -h --max-depth=1 | sort -h
```

## Performance Tips

**Large files:**

For multi-gigabyte files, `sort` can be slow and memory-intensive.

```bash title="Use temporary directory for sort"
sort -T /tmp largefile.txt
```

```bash title="Limit memory usage"
sort --parallel=4 -S 1G largefile.txt
```

**Skip sort if order doesn't matter:**

```bash
# Slow:
sort hugefile.txt | uniq -c

# Faster for counting unique occurrences (if order doesn't matter):
awk '{count[$0]++} END {for (line in count) print count[line], line}' hugefile.txt
```

## Common Mistakes

### Using `uniq` Without `sort`

```bash
uniq names.txt    # Only removes ADJACENT duplicates
```

**Correct:**

```bash
sort names.txt | uniq
```

### Forgetting `-n` for Numerical Sort

```bash
sort numbers.txt    # Alphabetical: 1, 10, 2, 20
```

**Correct:**

```bash
sort -n numbers.txt    # Numerical: 1, 2, 10, 20
```

### Wrong Column with `-k`

```bash
sort -k 2 data.txt    # Sorts by second field to end of line
```

**Better:**

```bash
sort -k 2,2 data.txt    # Sorts by second field only
```

### `wc -l` Counts Newlines

```bash
echo -n "test" | wc -l    # Returns 0 (no newline at end)
```

Files without trailing newline show one less line than expected.

## Quick Reference

| Command | What It Does | Common Use |
|---------|--------------|------------|
| `sort file` | Sort lines alphabetically | Organize data |
| `sort -n` | Sort numerically | Sort numbers correctly |
| `sort -r` | Reverse sort | Largest/last first |
| `sort -u` | Sort and remove duplicates | Unique sorted list |
| `sort -k N` | Sort by Nth column | Sort structured data |
| `uniq` | Remove adjacent duplicates | After `sort` |
| `uniq -c` | Count occurrences | Frequency analysis |
| `uniq -d` | Show only duplicates | Find repeated lines |
| `uniq -u` | Show only unique | Find non-repeated lines |
| `wc -l` | Count lines | File/output size |
| `wc -w` | Count words | Word count |
| `wc -c` | Count bytes | File size |

## Practice Exercises

**Exercise 1: Sort and deduplicate**

```bash
echo -e "apple\nbanana\napple\ncherry\nbanana" | sort | uniq
```

**Exercise 2: Count occurrences**

```bash
echo -e "red\nblue\nred\ngreen\nblue\nred" | sort | uniq -c | sort -rn
```

**Exercise 3: Find top 5 largest files**

```bash
du -h * | sort -h -r | head -5
```

**Exercise 4: Analyze command history**

```bash
history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10
```

## Key Takeaways

- **`sort`** organizes lines (alphabetically, numerically, by column)
- **`uniq`** requires sorted input to work correctly
- **`sort -u`** is faster than `sort | uniq` for simple deduplication
- **`wc -l`** counts lines (most common use of `wc`)
- **Combine them** for powerful data analysis pipelines
- **`uniq -c`** is essential for frequency analysis
- **Always use `-n` for numerical sort** (not alphabetical)
- **These tools shine when piped together**

Data analysis on Linux doesn't require complex tools. These three simple commands - `sort`, `uniq`, `wc` - handle 80% of organizing, deduplicating, and counting tasks.

Master them, and you'll process data faster than spreadsheets ever could.

Let's keep building.
