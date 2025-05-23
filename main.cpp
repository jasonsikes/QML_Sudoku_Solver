#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "solver.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    
    // Register the SudokuSolver class
    qmlRegisterType<SudokuSolver>("SudokuSolver", 1, 0, "SudokuSolver");
    
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("QML_Sudoku_Solver", "Main");

    return app.exec();
}
