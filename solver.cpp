#include <iostream>
#include <QObject>
#include <QQmlEngine>
#include <QVariantList>
#include <set>
#include <array>

#include "solver.h"


// Helper functions:
int spaceForRowCol(int row, int col) {
    return row * 9 + col;
}

std::pair<int, int> rowColForSpace(int space) {
    return {space / 9, space % 9};
}

struct Space {
    char value;
    std::set<char> possibleValues;

    Space() : value(' '), possibleValues() {
        for (char c = '1'; c <= '9'; ++c) {
            possibleValues.insert(c);
        }
    }

    void setValue(char v) {
        if (value != ' ') {
            throw std::invalid_argument("Space already has a value");
        }
        value = v;
        possibleValues.clear();
    }

    void removePossibleValue(char v) {
        possibleValues.erase(v);
    }
};

struct Board {
    std::array<Space, 81> spaces;
    int remainingSpaces;

    Board() : remainingSpaces(81) {
        for (int i = 0; i < 81; ++i) {
            spaces[i] = Space();
        }
    }

    void setValueForSpace(char value, int space) {
        spaces[space].setValue(value);
        --remainingSpaces;

        // Remove the value from the possible values of all spaces in the same row, column, and block
        int row = space / 9;
        int col = space % 9;
        for (int i = 0; i < 9; ++i) {
            spaces[spaceForRowCol(row, i)].removePossibleValue(value);
            spaces[spaceForRowCol(i, col)].removePossibleValue(value);
        }
        for (int i = 0; i < 3; ++i) {
            for (int j = 0; j < 3; ++j) {
                spaces[spaceForRowCol(row / 3 * 3 + i, col / 3 * 3 + j)].removePossibleValue(value);
            }
        }
    }

    bool isSolved() const {
        return remainingSpaces == 0;
    }
};

std::ostream& operator<<(std::ostream& os, const Board& board) {
    for (int row = 0; row < 9; ++row) {
        if (row > 0 && row % 3 == 0) {
            os << "-------------------\n";
        }
        for (int col = 0; col < 9; ++col) {
            if (col > 0 && col % 3 == 0) {
                os << "|";
            }
            char value = board.spaces[spaceForRowCol(row, col)].value;
            os << (value == ' ' ? '.' : value) << " ";
        }
        os << "\n";
    }
    return os;
}

// Returns a new board with the solved spaces set.
// If no solution is found, returns an empty board.
Board solveIteration(Board &b) {
    // First, find every space with only one possible value and set it.
    for (int i = 0; i < 81; ++i) {
        Space &s = b.spaces[i];
        if (s.value == ' ') {
            if (s.possibleValues.size() == 1) {
                b.setValueForSpace(*s.possibleValues.begin(), i);
                i = 0;
            }
        }
    }

    if (b.isSolved()) {
        return b;
    }

    // Now, for each space with multiple possible values, find the space with the fewest possible values.
    int minSpace = -1;
    int minPossibleValues = 10;
    for (int i = 0; i < 81; ++i) {
        Space &s = b.spaces[i];
        if (s.value == ' ' && s.possibleValues.size() < minPossibleValues) {
            minSpace = i;
            minPossibleValues = s.possibleValues.size();
        }
    }

    if (minSpace == -1) {
        goto noSolution;
    }

    // Try each possible value for the space with the fewest possible values.
    for (char v : b.spaces[minSpace].possibleValues) {
        Board b2 = b;
        b2.setValueForSpace(v, minSpace);
        Board b3 = solveIteration(b2);
        if (b3.isSolved()) {
            return b3;
        }
    }

noSolution:
    Board retval;
    return retval;
}

void SudokuSolver::solve(const QVariantList &board) {
    Board b;
    for (int i = 0; i < board.size(); ++i) {
        char value = board[i].toString()[0].toLatin1();
        if (value != '0') {
            b.setValueForSpace(value, i);
        }
    }

    Board b2 = solveIteration(b);
    if (b2.isSolved()) {
        // Convert the solution back to QVariantList
        QVariantList solution;
        for (int i = 0; i < 81; ++i) {
            solution.append(QString(b2.spaces[i].value));
        }
        emit solutionFound(solution);
    } else {
        emit noSolutionFound();
    }
}
