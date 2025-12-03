# Advent of Code

Swift solutions for [Advent of Code](https://adventofcode.com).

## Progress

| Year | Days Completed |
|------|----------------|
| 2015 | 25/25 ⭐ |
| 2016 | 7/25 |
| 2025 | 3/25 |

## Requirements

- Swift 6.0+

## Setup

Place the puzzle inputs in `Sources/Year20XX/Resources/` as `day-01.txt`, `day-02.txt`, etc.

## Running

```bash
swift run
```

Example output:
```
--- Day 03 ---
[Test Input]
  Part 1: 357
  Part 2: 3121910778619
--------------------
[Main Input]
  Part 1: 17435
  Part 2: 172886048065379
====================
```

## Structure

- `Sources/AoCCommon/` - Shared protocol and runner utilities
- `Sources/Year20XX/` - Solutions and puzzle inputs
- `Sources/App/` - Entry point

## Adding a New Day

1. Create `Sources/Year20XX/DayXX.swift` implementing `DaySolver`
2. Add input to `Sources/Year20XX/Resources/day-XX.txt`
3. Update `Sources/App/main.swift` to run the day

