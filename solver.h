#ifndef HELLO_H
#define HELLO_H

#include <QObject>
#include <QVariantList>

class SudokuSolver : public QObject {
    Q_OBJECT
public:
    explicit SudokuSolver(QObject *parent = nullptr) : QObject(parent) {}

public slots:
    void solve(const QVariantList &board);

signals:
    void solutionFound(const QVariantList &solution);
    void noSolutionFound();
};

#endif // HELLO_H 