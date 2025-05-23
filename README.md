# README

This is a simple Sudoku solver that uses a backtracking algorithm to solve the puzzle. It is written in C++ using Qt and QML.

## How to build

1. Clone the repository
2. Open the project in Qt Creator
3. Build the project

## How to use

1. Fill the grid with the known values
2. Click the solve button
3. The solution will be displayed in the grid

## How it works

The solver uses a smarter-than-average backtracking algorithm to solve the puzzle. Instead of brute-forcing each combination, candidates for each space are eliminated when values are chosen. The end result is that the solver is able to solve the puzzle in a reasonable amount of time. On my M2 Macbook Air, it takes less than a half-second to solve the most difficult puzzles..

## License

This is released under the 2-clause BSD license. Enjoy!