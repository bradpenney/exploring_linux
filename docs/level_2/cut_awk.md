# Text Extraction

!!! quote "Pulling out exactly what you need"

## The Extraction Problem

You've got structured data - CSV files, log files, configuration files, command output. You don't need all of it - just specific columns, specific fields, specific pieces.

**Two tools excel at extracting data:**

- **`cut`** - Simple, fast column extraction
- **`awk`** - Powerful programmable text processor

`cut` handles simple cases. `awk` handles everything else (and could replace `cut` entirely, but `cut` is faster for basic tasks).

## The Simple Tool: `cut`

`cut` extracts sections from each line of text.

### Extract by Character Position

```bash title="Get characters 1-5 from each line"
cut -c 1-5 file.txt
```

**Input:**
```
Hello World
Goodbye Moon
```

**Output:**
```
Hello
Goodb
```

**Extract specific characters:**

```bash
cut -c 1,3,5 file.txt     # Characters 1, 3, and 5
cut -c 1-3,7-9 file.txt   # Characters 1-3 and 7-9
cut -c 5- file.txt        # Character 5 to end of line
cut -c -5 file.txt        # Start to character 5
```

### Extract by Field (Column)

More useful than character positions - extract columns from structured data.

**Default delimiter is Tab:**

```bash title="Extract second field (tab-delimited)"
cut -f 2 file.txt
```

**Specify a different delimiter:**

```bash title="Extract second column from CSV"
cut -d ',' -f 2 data.csv
```

`-d ','` sets delimiter to comma.

**Extract multiple fields:**

```bash title="Get fields 1 and 3"
cut -d ',' -f 1,3 data.csv
```

**Extract range of fields:**

```bash
cut -d ',' -f 2-4 data.csv    # Fields 2, 3, 4
cut -d ',' -f 2- data.csv     # Field 2 to end
cut -d ':' -f 1 /etc/passwd   # First field (usernames)
```

### Practical `cut` Examples

**Extract usernames from /etc/passwd:**

```bash
cut -d ':' -f 1 /etc/passwd
```

**Output:**
```
root
daemon
bin
brad
...
```

**Extract IP addresses from log (assuming space-delimited, IP is first field):**

```bash
cut -d ' ' -f 1 access.log | sort -u
```

**Get email addresses from CSV (third column):**

```bash
cut -d ',' -f 3 users.csv
```

**Extract date from timestamp:**

```bash
echo "2024-12-14 10:30:45" | cut -d ' ' -f 1
# Output: 2024-12-14
```

**Extract filename from full path:**

```bash
echo "/home/brad/documents/report.txt" | cut -d '/' -f 5
# Output: report.txt
```

Better: use `basename`:

```bash
basename /home/brad/documents/report.txt
# Output: report.txt
```

### Limitations of `cut`

**`cut` has issues with:**

1. **Multiple delimiters** - Can't handle "field1    field2" (multiple spaces)
2. **Conditional logic** - Can't say "if field2 > 100, print field1"
3. **Calculations** - Can't sum, average, or compute
4. **Variable-width fields** - Struggles with aligned columns separated by spaces

**For these cases, use `awk`.**

## The Power Tool: `awk`

`awk` is a complete programming language for text processing. We'll cover the basics - enough to extract data effectively.

### Basic `awk` Structure

```bash
awk '{print $2}' file.txt
```

This prints the second field of each line.

**`$1`** = first field
**`$2`** = second field
**`$3`** = third field
**`$0`** = entire line
**`$NF`** = last field

### Extract Specific Fields

```bash title="Print second field"
awk '{print $2}' file.txt
```

**Input:**
```
Alice 25 Engineer
Bob 30 Designer
Charlie 28 Developer
```

**Output:**
```
25
30
28
```

**Print multiple fields:**

```bash title="Print first and third fields"
awk '{print $1, $3}' file.txt
```

**Output:**
```
Alice Engineer
Bob Designer
Charlie Developer
```

**Print with custom separator:**

```bash title="Separate with comma"
awk '{print $1","$3}' file.txt
```

**Output:**
```
Alice,Engineer
Bob,Designer
Charlie,Developer
```

### Change Field Delimiter

By default, `awk` splits on whitespace (spaces/tabs).

**Use custom delimiter:**

```bash title="CSV - comma delimiter"
awk -F ',' '{print $2}' data.csv
```

**Colon delimiter:**

```bash title="Extract usernames from /etc/passwd"
awk -F ':' '{print $1}' /etc/passwd
```

### Print Last Field

```bash title="Print last field regardless of number of fields"
awk '{print $NF}' file.txt
```

**Print second-to-last:**

```bash
awk '{print $(NF-1)}' file.txt
```

### Add Text and Formatting

```bash title="Add labels to output"
awk '{print "Name:", $1, "Age:", $2}' file.txt
```

**Output:**
```
Name: Alice Age: 25
Name: Bob Age: 30
Name: Charlie Age: 28
```

### Filter with Conditions

**Print lines where second field > 28:**

```bash
awk '$2 > 28 {print $0}' file.txt
```

**Output:**
```
Bob 30 Designer
```

**Print lines where first field equals "Alice":**

```bash
awk '$1 == "Alice" {print $0}' file.txt
```

**Print lines where field contains text:**

```bash
awk '$3 ~ /Dev/ {print $0}' file.txt
```

`~` is the regex match operator. This finds lines where field 3 contains "Dev".

### Calculations

**Sum a column:**

```bash title="Sum all values in second field"
awk '{sum += $2} END {print sum}' file.txt
```

If second field contains ages (25, 30, 28), this prints 83.

**Count lines:**

```bash
awk 'END {print NR}' file.txt
```

`NR` is "number of records" (line count).

**Average:**

```bash
awk '{sum += $2; count++} END {print sum/count}' file.txt
```

**Find maximum value:**

```bash
awk 'BEGIN {max=0} {if ($2 > max) max=$2} END {print max}' file.txt
```

### Practical `awk` Examples

**Extract IP addresses from Apache log:**

```bash
awk '{print $1}' access.log
```

**Find total traffic from log (assuming bytes are in field 10):**

```bash
awk '{sum += $10} END {print sum}' access.log
```

**Print lines longer than 80 characters:**

```bash
awk 'length($0) > 80' file.txt
```

**Extract unique usernames who failed login:**

```bash
awk '/Failed password/ {print $9}' /var/log/auth.log | sort -u
```

**Print every 10th line:**

```bash
awk 'NR % 10 == 0' file.txt
```

**Print line number and content:**

```bash
awk '{print NR, $0}' file.txt
```

**Extract fields 2-4:**

```bash
awk '{print $2, $3, $4}' file.txt
```

**Or using a loop:**

```bash
awk '{for (i=2; i<=4; i++) printf $i " "; print ""}' file.txt
```

### CSV Processing with `awk`

**Print second column from CSV:**

```bash
awk -F ',' '{print $2}' data.csv
```

**Remove quotes from CSV fields:**

```bash
awk -F ',' '{gsub(/"/, "", $2); print $2}' data.csv
```

**Print rows where price (field 3) > 100:**

```bash
awk -F ',' '$3 > 100 {print $0}' products.csv
```

**Calculate total price:**

```bash
awk -F ',' '{sum += $3} END {print sum}' products.csv
```

## Combining `cut` and `awk`

Sometimes you use both in a pipeline.

**Extract IPs, then filter unique:**

```bash
cut -d ' ' -f 1 access.log | sort -u
```

**Or with awk:**

```bash
awk '{print $1}' access.log | sort -u
```

**Extract username and calculate total space used:**

```bash
du -h ~/* | awk '{sum += $1; print $2, $1} END {print "Total:", sum}'
```

## When to Use Which

**Use `cut` when:**

- Simple field extraction
- Fixed delimiters
- No calculations needed
- Speed matters (cut is faster)

**Use `awk` when:**

- Multiple/variable delimiters
- Conditional logic needed
- Calculations required
- Complex formatting
- More than just extraction

**Example where `cut` fails but `awk` works:**

```bash
# File with inconsistent spacing:
Alice    25    Engineer
Bob 30  Designer
```

```bash
cut -d ' ' -f 2    # Gives inconsistent results
awk '{print $2}'   # Works correctly (splits on any whitespace)
```

## Advanced `awk` Patterns

### BEGIN and END Blocks

```bash
awk 'BEGIN {print "Starting..."} {print $1} END {print "Done!"}' file.txt
```

`BEGIN` runs before processing lines.
`END` runs after all lines processed.

### Multiple Conditions

```bash
awk '$2 > 25 && $3 == "Engineer" {print $1}' file.txt
```

Finds names where age > 25 AND role is Engineer.

### Built-in Variables

- `NR` - Current line number
- `NF` - Number of fields in current line
- `FS` - Field separator (input)
- `OFS` - Output field separator
- `RS` - Record separator (default: newline)
- `ORS` - Output record separator

**Example:**

```bash title="Number lines and show field count"
awk '{print NR, "fields:", NF, "content:", $0}' file.txt
```

### Field Reassignment

```bash title="Swap first two fields"
awk '{temp=$1; $1=$2; $2=temp; print}' file.txt
```

### Custom Output Field Separator

```bash title="Change output separator to comma"
awk 'BEGIN {OFS=","} {print $1, $2, $3}' file.txt
```

## Real-World Workflows

### Log Analysis

**Top 10 IPs by request count:**

```bash
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

**Average response time (field 10):**

```bash
awk '{sum += $10; count++} END {print sum/count}' access.log
```

**Requests per hour:**

```bash
awk '{print substr($4, 14, 2)}' access.log | sort | uniq -c
```

Extracts hour from timestamp like `[14/Dec/2024:10:30:45`.

### Data Processing

**Convert CSV to tab-delimited:**

```bash
awk -F ',' 'BEGIN {OFS="\t"} {$1=$1; print}' data.csv
```

`$1=$1` forces `awk` to rebuild the line with new separator.

**Extract and format:**

```bash
awk -F ',' '{printf "%-20s %10s\n", $1, $2}' data.csv
```

Left-align first field (20 chars), right-align second (10 chars).

### System Administration

**Find users with UID > 1000:**

```bash
awk -F ':' '$3 > 1000 {print $1, $3}' /etc/passwd
```

**Calculate total memory used:**

```bash
free -m | awk 'NR==2 {print "Used:", $3, "MB"}'
```

**Disk usage summary:**

```bash
df -h | awk '$5 > 80 {print $6, "is", $5, "full"}'
```

Alerts for filesystems > 80% full.

## Common Mistakes

### Using `cut` with Variable Whitespace

```bash
ps aux | cut -d ' ' -f 1    # Fails - multiple spaces between fields
```

**Correct:**

```bash
ps aux | awk '{print $1}'   # Works - awk handles multiple spaces
```

### Forgetting Field Separator in `awk`

```bash
awk '{print $2}' data.csv    # Wrong - uses space delimiter
```

**Correct:**

```bash
awk -F ',' '{print $2}' data.csv    # CSV needs comma delimiter
```

### Off-by-One Field Numbers

Fields are 1-indexed, not 0-indexed:

```bash
awk '{print $0}'    # Entire line
awk '{print $1}'    # First field (not zero!)
```

## Quick Reference

### `cut`

| Option | Meaning | Example |
|--------|---------|---------|
| `-c N` | Extract character N | `cut -c 5 file.txt` |
| `-c N-M` | Characters N through M | `cut -c 1-10 file.txt` |
| `-f N` | Extract field N | `cut -f 2 file.txt` |
| `-d 'X'` | Use X as delimiter | `cut -d ',' -f 2 file.csv` |
| `-f N,M` | Fields N and M | `cut -f 1,3 file.txt` |

### `awk`

| Pattern | Meaning | Example |
|---------|---------|---------|
| `$N` | Nth field | `awk '{print $2}'` |
| `$0` | Entire line | `awk '{print $0}'` |
| `$NF` | Last field | `awk '{print $NF}'` |
| `-F 'X'` | Set delimiter | `awk -F ',' '{print $1}'` |
| `NR` | Line number | `awk '{print NR, $0}'` |
| `condition {action}` | Conditional | `awk '$2 > 10 {print}'` |

## Practice Exercises

**Exercise 1: Extract usernames**

```bash
cut -d ':' -f 1 /etc/passwd
```

**Exercise 2: Sum numbers**

```bash
echo -e "10\n20\n30" | awk '{sum += $1} END {print sum}'
```

**Exercise 3: Filter and extract**

```bash
awk '$2 > 25 {print $1}' data.txt
```

**Exercise 4: Format output**

```bash
awk '{printf "%-10s %5d\n", $1, $2}' data.txt
```

## Key Takeaways

- **`cut`** is simple and fast for basic column extraction
- **`awk`** is powerful for complex text processing
- **Use `cut` for fixed delimiters, simple extraction**
- **Use `awk` for calculations, conditions, formatting**
- **`awk '{print $N}'`** extracts Nth field
- **`awk -F 'X'`** sets delimiter
- **`awk` handles multiple spaces automatically** (unlike `cut`)
- **`$0` = entire line, `$NF` = last field**

Text extraction is fundamental to Linux workflows. Logs, CSV files, command output - you constantly need to pull out specific pieces of information.

`cut` and `awk` make this trivial. Master them, and you'll process text data faster than any GUI tool could.

Let's keep building.
