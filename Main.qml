import QtQuick
import QtQuick.Controls
import SudokuSolver 1.0

Window {
    // Color definitions
    readonly property color lightBlockColor: "#f0f0f0"
    readonly property color darkBlockColor: "#d0d0d0"
    readonly property color focusColor: "#a0c0ff"
    readonly property color focusBorderColor: "#4080ff"
    readonly property color defaultBorderColor: "#808080"
    readonly property color errorTextColor: "#ff0000"

    // Dimension definitions
    readonly property int cellSize: 50
    readonly property int gridSpacing: 1
    readonly property int buttonWidth: 120
    readonly property int buttonHeight: 40
    readonly property int buttonSpacing: 10
    readonly property int mainSpacing: 20

    // Font definitions
    readonly property int cellFontSize: 20
    readonly property int buttonFontSize: 14
    readonly property int infoFontSize: 14

    // Border definitions
    readonly property int defaultBorderWidth: 1
    readonly property int focusBorderWidth: 2

    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    title: qsTr("Sudoku Solver")

    SudokuSolver {
        id: solver
        
        onSolutionFound: function(solution) {
            // Update the board with the solution
            for (let i = 0; i < solution.length; i++) {
                let cell = sudokuBoard.children[i]
                if (cell) {
                    cell.cellValue = solution[i]
                }
            }
            // Clear any previous error message
            infoLabel.text = ""
        }
        
        onNoSolutionFound: function() {
            infoLabel.text = "No solution found for this Sudoku puzzle"
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: mainSpacing

        // Sudoku Board
        Grid {
            id: sudokuBoard
            columns: 9
            spacing: gridSpacing

            // Create 81 cells (9x9)
            Repeater {
                model: 81

                Rectangle {
                    id: cell
                    width: cellSize
                    height: cellSize
                    color: {
                        // Alternate colors for 3x3 blocks
                        let row = Math.floor(index / 9)
                        let col = index % 9
                        let blockRow = Math.floor(row / 3)
                        let blockCol = Math.floor(col / 3)
                        let baseColor = (blockRow + blockCol) % 2 === 0 ? darkBlockColor : lightBlockColor
                        return activeFocus ? focusColor : baseColor
                    }
                    border.color: activeFocus ? focusBorderColor : defaultBorderColor
                    border.width: activeFocus ? focusBorderWidth : defaultBorderWidth

                    property string cellValue: ""
                    property int row: Math.floor(index / 9)
                    property int col: index % 9

                    Text {
                        id: cellText
                        anchors.fill: parent
                        anchors.margins: 2
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: cellFontSize
                        text: parent.cellValue
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            parent.forceActiveFocus()
                        }
                    }

                    Keys.onPressed: function(event) {
                        if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                            cellValue = event.text
                            infoLabel.text = ""
                        } else if (event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete) {
                            cellValue = ""
                            infoLabel.text = ""
                        } else if (event.key === Qt.Key_Left && col > 0) {
                            sudokuBoard.children[index - 1].forceActiveFocus()
                        } else if (event.key === Qt.Key_Right && col < 8) {
                            sudokuBoard.children[index + 1].forceActiveFocus()
                        } else if (event.key === Qt.Key_Up && row > 0) {
                            sudokuBoard.children[index - 9].forceActiveFocus()
                        } else if (event.key === Qt.Key_Down && row < 8) {
                            sudokuBoard.children[index + 9].forceActiveFocus()
                        }
                    }

                    Component.onCompleted: {
                        if (index === 0) {
                            forceActiveFocus()
                        }
                    }
                }
            }
        }

        // Buttons Column
        Column {
            spacing: buttonSpacing

            Button {
                text: "Solve"
                width: buttonWidth
                height: buttonHeight
                font.pixelSize: buttonFontSize
                onClicked: {
                    // Collect board data
                    let boardData = []
                    for (let i = 0; i < sudokuBoard.children.length; i++) {
                        let cell = sudokuBoard.children[i]
                        if (cell && cell.cellValue !== undefined) {
                            boardData.push(cell.cellValue || "0")
                        }
                    }
                    solver.solve(boardData)
                }
            }

            Button {
                text: "Clear"
                width: buttonWidth
                height: buttonHeight
                font.pixelSize: buttonFontSize
                onClicked: {
                    // Clear all cells
                    for (let i = 0; i < sudokuBoard.children.length; i++) {
                        let cell = sudokuBoard.children[i]
                        if (cell && cell.cellValue !== undefined) {
                            cell.cellValue = ""
                        }
                    }
                    // Set focus back to first cell
                    if (sudokuBoard.children[0]) {
                        sudokuBoard.children[0].forceActiveFocus()
                    }
                    // Clear the message
                    infoLabel.text = ""
                }
            }

            Text {
                id: infoLabel
                width: buttonWidth
                wrapMode: Text.WordWrap
                color: errorTextColor
                font.pixelSize: infoFontSize
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
