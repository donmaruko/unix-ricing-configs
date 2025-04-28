# Project Structure

```
p5-donmaruko/
├── ChessBoard.cpp
├── ChessBoard.hpp
├── Makefile
├── Transform.cpp
├── Transform.hpp
└── main.cpp
```

# Project Files

## File: `ChessBoard.cpp`

```cpp
/*
Author: Don Suhanda
Course: CSCI-235
Date: Apr 23 2025
Instructor: Gennady Maryash
Assignment: Project 5
File: ChessBoard.cpp

*/

#include "ChessBoard.hpp"
#include "Transform.hpp"

/**
    * Default constructor. 
    * @post The board is setup with the following restrictions:
    * 1) board is initialized to a 8x8 2D vector of ChessPiece pointers
    *      - ChessPiece derived classes are dynamically allocated and constructed as follows:
    *          - Pieces on the BOTTOM half of the board are set to have color "BLACK"
    *          - Pieces on the UPPER half of the board are set to have color "WHITE"
    *          - Their row & col members reflect their position on the board
    *          - All pawns on the BOTTOM half are flagged to be moving up.
    *          - All pawns on the BOTTOM half are flagged to be NOT moving up.
    *          - All other parameters are default initialized (this includes moving_up for non-Pawns!)
    *   
    *      - Pawns (P), Rooks(R), Bishops(B), Kings(K), Queens(Q), and Knights(N) are placed in the following format (ie. the standard setup for chess):
    *          
    *          7 | R N B K Q B N R
    *          6 | P P P P P P P P
    *          5 | * * * * * * * *
    *          4 | * * * * * * * *
    *          3 | * * * * * * * *
    *          2 | * * * * * * * *
    *          1 | P P P P P P P P
    *          0 | R N B K Q B N R
    *              +---------------
    *              0 1 2 3 4 5 6 7
    *      
    *          (With * denoting empty cells)
    * 
    * 2) playerOneTurn is set to true.
    * 3) p1_color is set to "BLACK", and p2_color is set to "WHITE"
    */
ChessBoard::ChessBoard() 
    : playerOneTurn{true}, p1_color{"BLACK"}, p2_color{"WHITE"}, board{std::vector(8, std::vector<ChessPiece*>(8)) } {
        // Allocate pieces

        auto add_mirrored = [this] (const int& i, const std::string& type) {
            if (type == "PAWN") {
                board[1][i] = new Pawn(p1_color, 1, i, true);
                board[6][i] = new Pawn(p2_color, 6, i);
            } else if (type == "ROOK") {
                board[0][i] = new Rook(p1_color, 0, i);
                board[7][i] = new Rook(p2_color, 7, i);
            } else if (type == "KNIGHT") {
                board[0][i] = new Knight(p1_color, 0, i);
                board[7][i] = new Knight(p2_color, 7, i);            
            } else if (type == "BISHOP") {
                board[0][i] = new Bishop(p1_color, 0, i);
                board[7][i] = new Bishop(p2_color, 7, i);
            } else if (type == "KING") {
                board[0][i] = new King(p1_color, 0, i);
                board[7][i] = new King(p2_color, 7, i);
            } else if (type == "QUEEN") {
                board[0][i] = new Queen(p1_color, 0, i);
                board[7][i] = new Queen(p2_color, 7, i);
            }
        };

        std::vector<std::string> inner_pieces = {"ROOK", "KNIGHT", "BISHOP", "KING", "QUEEN", "BISHOP", "KNIGHT", "ROOK"};
        for (size_t i = 0; i < BOARD_LENGTH; i++) {
            add_mirrored(i, "PAWN");
            add_mirrored(i, inner_pieces[i]);
        }
    }

/**
 * @brief Constructs a ChessBoard object with a given board configuration and player turn.
 * 
 * @param instance A 2D vector representing a board state, where each element is a pointer to a ChessPiece.
 * @param p1Turn A boolean indicating whether it's player one's turn. True for player one, false for player two.
 * 
 * @post Initializes the board layout, sets player one's color to "BLACK" and player two's color to "WHITE".
 */
ChessBoard::ChessBoard(const std::vector<std::vector<ChessPiece*>>& instance, const bool& p1Turn)
 : playerOneTurn{p1Turn}, p1_color{"BLACK"}, p2_color{"WHITE"}, board{instance}{}

/**
 * @brief Gets the ChessPiece (if any) at (row, col) on the board
 * 
 * @param row The row of the cell
 * @param col The column of the cell
 * @return ChessPiece* A pointer to the ChessPiece* at the cell specified by (row, col) on the board
 */
ChessPiece* ChessBoard::getCell(const int& row, const int& col) const {
    return board[row][col];
}

/**
 * @brief Destructor. 
 * @post Deallocates all ChessPiece pointers stored on the board at time of deletion. 
 */
ChessBoard::~ChessBoard() {
    for (int i = 0; i < BOARD_LENGTH; i++) {
        for (int j = 0; j < BOARD_LENGTH; j++) {
            if (!board[i][j]) { continue; }
            delete board[i][j];
            board[i][j] = nullptr;
        }
    }
}

std::vector<ChessBoard::CharacterBoard>
ChessBoard::findAllQueenPlacements()
{
    // Empty 8×8 board
    std::vector<std::vector<ChessPiece*>> board(
        BOARD_LENGTH, std::vector<ChessPiece*>(BOARD_LENGTH, nullptr));

    std::vector<Queen*> placedQueens;           // live queen objects
    std::vector<CharacterBoard> allBoards;      // finished solutions

    queenHelper(0, board, placedQueens, allBoards);

    // (safety)  – should already be clean, but just in case:
    for (Queen* q : placedQueens) delete q;

    return allBoards;
}

void ChessBoard::queenHelper(
    int col,
    std::vector<std::vector<ChessPiece*>>& board,
    std::vector<Queen*>& placedQueens,
    std::vector<CharacterBoard>& allBoards)
{
if (col == BOARD_LENGTH) {                          // 8 queens placed!
    CharacterBoard snapshot(BOARD_LENGTH,
                            std::vector<char>(BOARD_LENGTH, '.'));

    for (Queen* q : placedQueens)
        snapshot[q->getRow()][q->getColumn()] = 'Q';

    allBoards.push_back(std::move(snapshot));
    return;
}

for (int row = 0; row < BOARD_LENGTH; ++row) {
    bool safe = true;
    for (Queen* q : placedQueens) {
        if (q->canMove(row, col, board)) {          // threatened square
            safe = false;
            break;
        }
    }
    if (!safe) continue;

    // ---- place queen ---------------------------------------------------
    Queen* newQ = new Queen("WHITE", row, col);      // colour irrelevant
    board[row][col] = newQ;
    placedQueens.push_back(newQ);

    queenHelper(col + 1, board, placedQueens, allBoards);

    // ---- back-track ----------------------------------------------------
    placedQueens.pop_back();
    board[row][col] = nullptr;
    delete newQ;
}
}

/* =======================================================================
 *  Helpers for grouping similar boards
 * =====================================================================*/
namespace {

    using CB = ChessBoard::CharacterBoard;
    
    /* Flatten a board into a string so we can compare/equality-check easily */
    std::string toKey(const CB& b)
    {
        std::string key;
        key.reserve(b.size() * b.size());
        for (auto& row : b)
            for (char c : row) key += c;
        return key;
    }
    
    /* Return all 8 transforms:
     *   rotations 0/90/180/270, each flipped vertically and horizontally     */
    std::vector<CB> transforms(const CB& src)
    {
        CB r0   = src;
        CB r90  = Transform::rotate(r0);
        CB r180 = Transform::rotate(r90);
        CB r270 = Transform::rotate(r180);
    
        std::vector<CB> out;
        out.reserve(8);
    
        for (const CB& r : {r0, r90, r180, r270}) {
            out.push_back(r);  
            out.push_back(Transform::flipAcrossVertical(r));
            out.push_back(Transform::flipAcrossHorizontal(r));
        }
        return out;
    }
    
    /* Smallest lexicographic key among the 8 transforms → canonical form */
    std::string canonicalKey(const CB& b)
    {
        std::string best = toKey(b);
        for (const CB& t : transforms(b))
            best = std::min(best, toKey(t));
        return best;
    }
    
    } // unnamed namespace
    /* ---------------------------------------------------------------------*/
    
    std::vector<std::vector<ChessBoard::CharacterBoard>>
    ChessBoard::groupSimilarBoards(const std::vector<CharacterBoard>& boards)
    {
        std::vector<std::string>                    keys;    // canonical keys
        std::vector<std::vector<CharacterBoard>>    buckets; // parallel array
    
        for (const auto& b : boards) {
            std::string k = canonicalKey(b);
    
            // linear search (92 items ⇒ trivial cost)
            auto it = std::find(keys.begin(), keys.end(), k);
    
            if (it == keys.end()) {                    // new bucket
                keys.push_back(k);
                buckets.push_back({b});
            } else {                                   // existing bucket
                std::size_t idx = std::distance(keys.begin(), it);
                buckets[idx].push_back(b);
            }
        }
        return buckets;
    }
    
```

## File: `ChessBoard.hpp`

```cpp
/*
Author: Don Suhanda
Course: CSCI-235
Date: Apr 23 2025
Instructor: Gennady Maryash
Assignment: Project 5
File: ChessBoard.hpp

*/

/**
 * @class ChessBoard
 * @brief Represents an 8x8 board of Chess Pieces used to play chess
 */

#pragma once

#include <vector>
#include "pieces_module.hpp"

class ChessBoard {
    public:
        /**
         * Default constructor. 
         * @post The board is setup with the following restrictions:
         * 1) board is initialized to a 8x8 2D vector of ChessPiece pointers
         *      - ChessPiece derived classes are dynamically allocated and constructed as follows:
         *          - Pieces on the BOTTOM half of the board are set to be "moving up" | of color "BLACK"
         *          - Pieces on the UPPER half of the board are set to be NOT "moving up"| of color "WHITE"
         *          - Their row & col members reflect their position on the board
         *          - All other parameters are default initialized.
         *   
         *      - Pawns (P), Rooks(R), Bishops(B), Kings(K), Queens(Q), and Knights(N) are placed in the following format (ie. the standard setup for chess):
         *          
         *          7 | R N B K Q B N R
         *          6 | P P P P P P P P
         *          5 | * * * * * * * *
         *          4 | * * * * * * * *
         *          3 | * * * * * * * *
         *          2 | * * * * * * * *
         *          1 | P P P P P P P P
         *          0 | R N B K Q B N R
         *              +---------------
         *              0 1 2 3 4 5 6 7
         *      
         *          (With * denoting empty cells)
         * 
         * 2) playerOneTurn is set to true.
         * 3) p1_color is set to "BLACK", and p2_color is set to "WHITE"
         */
        ChessBoard();

        /**
         * @brief Constructs a ChessBoard object with a given board configuration and player turn.
         * 
         * @param instance A 2D vector representing a board state, where each element is a pointer to a ChessPiece.
         * @param p1Turn A boolean indicating whether it's player one's turn. True for player one, false for player two.
         * 
         * @post Initializes the board layout, sets player one's color to "BLACK" and player two's color to "WHITE".
         */
        ChessBoard(const std::vector<std::vector<ChessPiece*>>& board, const bool& p1Turn);

        /**
         * @brief Gets the ChessPiece (if any) at (row, col) on the board
         * 
         * @param row The row of the cell
         * @param col The column of the cell
         * @return ChessPiece* A pointer to the ChessPiece* at the cell specified by (row, col) on the board
         */
        ChessPiece* getCell(const int& row, const int& col) const;

        /**
         * @brief Destructor. 
         * @post Deallocates all ChessPiece pointers stored on the board at time of deletion. 
         */
        ~ChessBoard();

        // Alias for readability
        typedef std::vector<std::vector<char>> CharacterBoard;

        /**
         * @brief Finds all possible solutions to the 8-queens problem.
         * 
         * @return A vector of CharacterBoard objects, 
         *         each representing a unique solution 
         *         to the 8-queens problem.
        */
        static std::vector<CharacterBoard> findAllQueenPlacements();

        /**
         * @brief Groups similar chessboard configurations by transformations.
         * 
         * This function organizes a list of chessboard configurations into groups of similar boards, 
         * where similarity is defined as being identical under a 
         *      1) Rotation (clockwise: 0°, 90°, 180°, 270°)
         *      2) Followed by a flip across the horizontal or vertical axis
         * 
         * @param boards A const ref. to a vector of `CharacterBoard` objects, each representing a chessboard configuration.
         * 
         * @return A 2D vector of `CharacterBoard` objects, 
         *         where each inner vector is a list of boards 
         *         that are transformations of each other.
         */
        static std::vector<std::vector<CharacterBoard>>
        groupSimilarBoards(const std::vector<CharacterBoard>& boards);

    private:
        // Define board size (8x8)
        static const int BOARD_LENGTH = 8;
        
        bool playerOneTurn; 
        
        std::string p1_color;
        std::string p2_color;

        std::vector<std::vector<ChessPiece*>> board;

        /**
         * @brief A STATIC helper function for recursively solving the 8-queens problem.
         * 
         * This function places queens column by column, checks for valid placements,
         * and stores all valid board configurations in the provided list.
         * 
         * @param col A const reference to aninteger representing the current column being processed.
         * @param board A (non-const) reference to a 2D vector of ChessPiece*, representing the current board configuration
         * @param placedQueens A (non-const) reference to a vector storing Queen*, which represents the queens we've placed so far
         * @param allBoards A (non-const) reference to a vector of CharacterBoard objects storing all the solutions we've found thus far
         */
        static void queenHelper(int col,
            std::vector<std::vector<ChessPiece*>>& board,
            std::vector<Queen*>& placedQueens,
            std::vector<CharacterBoard>& allBoards);

};
```

## File: `Makefile`

```makefile
CXX = g++
CXXFLAGS = -std=c++17 -g -Wall -O2

PROG ?= main

# Source directories
PIECES_DIR = pieces

# Chess piece objects
PIECE_OBJS = \
	$(PIECES_DIR)/Bishop.o \
	$(PIECES_DIR)/ChessPiece.o \
	$(PIECES_DIR)/King.o \
	$(PIECES_DIR)/Knight.o \
	$(PIECES_DIR)/Pawn.o \
	$(PIECES_DIR)/Queen.o \
	$(PIECES_DIR)/Rook.o

# Core game objects
CORE_OBJS = ChessBoard.o

# Main program objects
MAIN_OBJS = main.o

# Aggregate objects
OBJS = $(MAIN_OBJS) $(CORE_OBJS) $(PIECE_OBJS)

mainprog: $(PROG)

.cpp.o:
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(PROG): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS)

clean:
	rm -rf $(PROG) *.o *.out \
		$(PIECES_DIR)/*.o \

rebuild: clean main
```

## File: `Transform.cpp`

```cpp
/*
Author: Don Suhanda
Course: CSCI-235
Date: Apr 23 2025
Instructor: Gennady Maryash
Assignment: Project 5
File: Transform.cpp

*/


#include "Transform.hpp"

namespace Transform {

/**
 * @brief Rotates a square matrix 90 degrees clockwise.
 * @pre The input 2D vector must be square 
 *      (ie. the number of cells per row equals the number of columns)
 * 
 * @param matrix A const reference to a 2D vector of objects of type T
 * @return A new 2D vector representing the rotated matrix
 */
template <typename T>
std::vector<std::vector<T>>
rotate(const std::vector<std::vector<T>>& matrix)
{
    const std::size_t n = matrix.size();            // assumes square
    std::vector<std::vector<T>> out(n, std::vector<T>(n));

    for (std::size_t i = 0; i < n; ++i)
        for (std::size_t j = 0; j < n; ++j)
            out[j][n - 1 - i] = matrix[i][j];       // (row,col) → (col, n-1-row)

    return out;
}

/**
 * @brief Swaps the elements of a square matrix across its vertical axis of symmetry
 * @pre The input 2D vector must be square 
 *      (ie. the number of cells per row equals the number of columns)
 * 
 * @param matrix A const reference to a 2D vector of objects of type T
 * @return A new 2D vector representing the transformed matrix
 */
template <typename T>
std::vector<std::vector<T>>
flipAcrossVertical(const std::vector<std::vector<T>>& matrix)
{
    const std::size_t n = matrix.size();
    std::vector<std::vector<T>> out(n, std::vector<T>(n));

    for (std::size_t i = 0; i < n; ++i)
        for (std::size_t j = 0; j < n; ++j)
            out[i][n - 1 - j] = matrix[i][j];       // swap columns

    return out;
}

/**
 * @brief Swaps the elements of a square matrix across its horizontal axis of symmetry
 * @pre The input 2D vector must be square 
 *      (ie. the number of cells per row equals the number of columns)
 * 
 * @param matrix A const reference to a 2D vector of objects of type T
 * @return A new 2D vector representing the transformed matrix
 */
template <typename T>
std::vector<std::vector<T>>
flipAcrossHorizontal(const std::vector<std::vector<T>>& matrix)
{
    const std::size_t n = matrix.size();
    std::vector<std::vector<T>> out(n, std::vector<T>(n));

    for (std::size_t i = 0; i < n; ++i)
        for (std::size_t j = 0; j < n; ++j)
            out[n - 1 - i][j] = matrix[i][j];       // swap rows

    return out;
}

} 
```

## File: `Transform.hpp`

```cpp
/*
Author: Don Suhanda
Course: CSCI-235
Date: Apr 23 2025
Instructor: Gennady Maryash
Assignment: Project 5
File: Transform.hpp

*/


/**
 * @namespace Transform
 * @brief Defines the interface for rotations & reflections of a square 2D Vector
 */

#pragma once 
#include <vector>
#include <algorithm>
namespace Transform {
    /**
     * @brief Rotates a square matrix 90 degrees clockwise.
     * @pre The input 2D vector must be square 
     *      (ie. the number of cells per row equals the number of columns)
     * 
     * @param matrix A const reference to a 2D vector of objects of type T
     * @return A new 2D vector representing the rotated matrix
     */
    template <typename T>
    std::vector<std::vector<T>> rotate(const std::vector<std::vector<T>>& matrix);
    
    /**
     * @brief Swaps the elements of a square matrix across its vertical axis of symmetry
     * @pre The input 2D vector must be square 
     *      (ie. the number of cells per row equals the number of columns)
     * 
     * @param matrix A const reference to a 2D vector of objects of type T
     * @return A new 2D vector representing the transformed matrix
     */
    template <typename T>
    std::vector<std::vector<T>> flipAcrossVertical(const std::vector<std::vector<T>>& matrix);
    
    /**
     * @brief Swaps the elements of a square matrix across its horizontal axis of symmetry
     * @pre The input 2D vector must be square 
     *      (ie. the number of cells per row equals the number of columns)
     * 
     * @param matrix A const reference to a 2D vector of objects of type T
     * @return A new 2D vector representing the transformed matrix
     */
    template <typename T>
    std::vector<std::vector<T>> flipAcrossHorizontal(const std::vector<std::vector<T>>& matrix);
};

#include "Transform.cpp"
```

## File: `main.cpp`

```cpp
#include "pieces_module.hpp"
#include "ChessBoard.hpp"
#include "Transform.hpp"
#include <iomanip>   // for std::setw, prettier output

// helper to dump a square matrix
template <typename T>
void printMatrix(const std::vector<std::vector<T>>& m, const std::string& label)
{
    std::cout << label << ":\n";
    for (auto& row : m) {
        for (auto& x : row) std::cout << std::setw(3) << x;
        std::cout << '\n';
    }
    std::cout << '\n';
}

int main() {
    std::cout << ChessBoard::findAllQueenPlacements().size() << '\n';

    std::vector<std::vector<int>> m{{1,2,3},{4,5,6},{7,8,9}};
    auto r = Transform::rotate(m);
    auto v = Transform::flipAcrossVertical(m);
    auto h = Transform::flipAcrossHorizontal(m);

    printMatrix(m, "Original");
    printMatrix(r, "Rotated 90° CW");
    printMatrix(v, "Flip Vertical");
    printMatrix(h, "Flip Horizontal");

    auto all     = ChessBoard::findAllQueenPlacements();
    auto grouped = ChessBoard::groupSimilarBoards(all);

    std::cout << "# raw boards  = " << all.size()     << '\n'
            << "# equivalence = " << grouped.size() << '\n';   // should be 12

}

```

