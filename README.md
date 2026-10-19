# Coal

Computer Organization & Assembly Language (COAL) assignments written in 16-bit x86 assembly for real-mode DOS.

**Name:** Muhammad Taha
**Roll No:** 25L-0930
**Assembler:** NASM
**Emulator:** DOSBox

---

## Repository Contents

| File | Description |
|------|-------------|
| `A2` | Packed-observation classifier (Normal / Suspicious / Attack) using shift-and-add multiplication |
| `A3` | Text viewport with paragraph wrapping, scrolling, search highlighting and a status bar |

> Rename the files above to match whatever you named them in the repo.

---

## Assignment 2: Packed Observation Classifier

A tiny linear classifier written without the `MUL` instruction. Each observation is a 16-bit word that packs three features. The program unpacks them, scores them against three weight sets, and predicts a class.

### Data

- `obs`: three packed 16-bit observations (`0x6552`, `0x2C91`, `0x7FA3`)
- `numObs`: number of observations (3)
- `weights`: for each class, `W1, W2, W3, Bias` (signed bytes)
  - Normal: `2, -3, -1, 10`
  - Suspicious: `1, 4, 2, 0`
  - Attack: `-2, 5, 4, -5`

### How it works

1. **Unpacking.** Each 16-bit word is split into three fields using shifts and rotates:
   - `x1` = top 6 bits, minus 20
   - `x2` = next 5 bits, minus 8
   - `x3` = last 5 bits, minus 16
2. **Scoring.** For each class, `score = W1*x1 + W2*x2 + W3*x3 + Bias`. Multiplication is done manually with a shift-and-add loop over 8 bits. Signs of the weight and the feature are handled separately (the weight's magnitude is used and the add/subtract is chosen from its sign, with the feature sign-extended to 16 bits).
3. **Prediction.** The class with the highest score wins and is stored in `predFlag`:
   - `1` = Normal
   - `2` = Suspicious
   - `3` = Attack

### Output (in memory)

| Variable | Meaning |
|----------|---------|
| `normScore[3]` | Normal score for each observation |
| `susScore[3]` | Suspicious score for each observation |
| `atkScore[3]` | Attack score for each observation |
| `predFlag[3]` | Predicted class for each observation (1/2/3) |

The program prints nothing. To verify results, inspect memory in a debugger (see below).

---

## Assignment 3: Text Viewport, Scroll and Search Highlight

A direct-video-memory (`0xB800`) text-mode program that draws a framed viewport, prints a wrapped paragraph inside it, scrolls the content, highlights every occurrence of a search word and reports the match count.

### Features

- **Clear screen** (`clrscr`): fills the 80x25 text screen with blank cells.
- **Viewport** (`viewport`): draws a double-line box (`═` and `║`) from column 8 to 71 and rows 3 to 21.
- **Title** (`printTitle`): prints the title string (`25L-0930`) centered in the top of the viewport using attribute `0x1E`.
- **Paragraph printing** (`printPara`): prints a null-terminated string starting at row 6, column 10. It handles newline characters (`10`) and wraps automatically after 60 characters per line, stopping before the bottom border.
- **Scroll** (`scroll`): scrolls a rectangular region up by `n` lines. Parameters (pushed in order): top, left, bottom, right, n. The vacated rows are blanked. The demo scrolls the region (row 6, col 9) to (row 20, col 70) up by 1 line.
- **Highlight** (`highlight`): scans the viewport for the search string (`Kabootar`) directly in video memory, changes the attribute of every match to `0xCE`, and increments a match counter.
- **Status bar** (`status`): prints `Total Matches Found: [N] | Viewport Status: ACTIVE` on row 23, converting the counter to decimal with `printNum`.

### Program flow

```
clrscr -> viewport -> printTitle -> printPara -> scroll -> highlight -> status -> exit
```

---

## Tools Used

- **NASM** to assemble the `.asm` files into DOS `.COM` programs
- **DOSBox** to run the programs

Both programs use `[org 0x0100]`, so they must be assembled as flat binary `.com` files.

---

## How to Run

### 1. Assemble with NASM

```
nasm assignment2.asm -o assignment2.com
nasm assignment3.asm -o assignment3.com
```

### 2. Run in DOSBox

Start DOSBox, then mount the folder containing your `.com` files and run them:

```
mount c C:\path\to\Coal
c:
assignment3.com
```

Assignment 3 will show the viewport, highlighted matches and the status bar, then exit to the DOS prompt.

### 3. Viewing Assignment 2 results

Assignment 2 produces no screen output, so inspect memory with a debugger such as AFD or DOS `debug`:

```
debug assignment2.com
-g e          ; run until label `e` (use the address of the exit label)
-d ds:0100    ; dump memory to see normScore, susScore, atkScore and predFlag
```

Alternatively, step through with a debugger and watch the `predFlag` values.

---

## Notes

- Both programs target 16-bit real mode and rely on DOS `int 0x21` (function `4Ch`) to terminate.
- Screen output in Assignment 3 writes directly to text-mode video memory, so it must be run in DOSBox (or real DOS), not a modern Windows console.

---

*Muhammad Taha | 25L-0930*
