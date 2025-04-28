#include "pieces_module.hpp"
#include "ChessBoard.hpp"
#include "Transform.hpp"
#include <iostream>

int main() {
    /* ------------ 8-Queens check (unchanged) ------------ */
    auto solutions = ChessBoard::findAllQueenPlacements();
    std::cout << "8-Queens found: " << solutions.size() << '\n';
    for (const auto& row : solutions.front()) {
        for (char c : row) std::cout << c << ' ';
        std::cout << '\n';
    }
    std::cout << '\n';

    /* ------------ Transform tests (3 × 3 ints) ---------- */
    std::vector<std::vector<int>> m   = {{1,2,3},
                                         {4,5,6},
                                         {7,8,9}};

    auto r90   = Transform::rotate(m);
    auto vFlip = Transform::flipAcrossVertical(m);
    auto hFlip = Transform::flipAcrossHorizontal(m);

    auto print = [](const auto& mat) {
        for (const auto& row : mat) {
            for (const auto& val : row) std::cout << val << ' ';
            std::cout << '\n';
        }
        std::cout << '\n';
    };

    std::cout << "Original:\n";            print(m);
    std::cout << "Rotated 90° CW:\n";      print(r90);
    std::cout << "Vertical flip:\n";       print(vFlip);
    std::cout << "Horizontal flip:\n";     print(hFlip);

    auto boards  = ChessBoard::findAllQueenPlacements();
    auto classes = ChessBoard::groupSimilarBoards(boards);

    std::cout << "Total solutions  : " << boards.size()   << '\n'  // 92
              << "Distinct classes : " << classes.size() << '\n';  // 12

    std::cout << "Class sizes      : ";
    for (const auto& c : classes) std::cout << c.size() << ' ';     // 8 8 8 8 8 8 8 4 4 4 8 8
    std::cout << '\n';

    return 0;
}
