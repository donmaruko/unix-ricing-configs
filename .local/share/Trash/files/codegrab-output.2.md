# Project Structure

```
p5-donmaruko/
├── pieces/
│   ├── Bishop.cpp
│   ├── Bishop.hpp
│   ├── ChessPiece.cpp
│   ├── ChessPiece.hpp
│   ├── King.cpp
│   ├── King.hpp
│   ├── Knight.cpp
│   ├── Knight.hpp
│   ├── Pawn.cpp
│   ├── Pawn.hpp
│   ├── Queen.cpp
│   ├── Queen.hpp
│   ├── Rook.cpp
│   └── Rook.hpp
├── ChessBoard.cpp
├── ChessBoard.hpp
├── Makefile
├── Transform.cpp
├── Transform.hpp
├── main.cpp
└── pieces_module.hpp
```

# Project Files

## File: `pieces/Bishop.cpp`

```cpp
#include "Bishop.hpp"

/**
 * @brief Default Constructor.
 * @post Sets piece_size_ to 3 and type to "BISHOP"
 */
Bishop::Bishop() : ChessPiece() { setSize(3); setType("BISHOP"); }

/**
 * @brief Parameterized constructor.
 * @param color: The color of the Bishop.
 * @param row: 0-indexed row position of the Bishop.
 * @param col: 0-indexed column position of the Bishop.
 * @param movingUp: Flag indicating whether the Bishop is moving up.
 */
Bishop::Bishop(const std::string& color, const int& row, const int& col, const bool& movingUp)
    : ChessPiece(color, row, col, movingUp, 3, "BISHOP") {}

bool Bishop::canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const {
    // Not on the board
    if (getRow() == -1 || getColumn() == -1) { return false; }

    // Out of bounds target
    if (target_row < 0 || target_row >= BOARD_LENGTH || target_col < 0 || target_col >= BOARD_LENGTH) { return false; }

    ChessPiece* target_piece = board[target_row][target_col];
    if (target_piece && target_piece->getColor() == getColor()) { return false; }

    int dx = target_row - getRow();
    int dy = target_col - getColumn();

    // Not a diagonal line or they lie on the same cell.
    bool not_diagonal = std::abs(dx) != std::abs(dy);
    bool no_movement = (dx == 0) && (dy == 0);
    if (not_diagonal || no_movement) { return false; }

    // Get sign of offsets: -1 if target is to the left or down, 1 if to the right or up.
    int row_offset = dx / std::abs(dx);
    int col_offset = dy / std::abs(dy);

    // Iterate from the target space to the original space and check if there is any obstructing ChessPiece

    while ((dx -= row_offset) != 0 && (dy -= col_offset) != 0) {
        if (board[getRow() + dx][getColumn() + dy]) {
            return false;
        }
    }

    return true;
}

```

## File: `pieces/Bishop.hpp`

```cpp
#pragma once

#include <iostream>
#include "ChessPiece.hpp"

/**
 * @brief Bishop class inheriting from ChessPiece.
 */
class Bishop : public ChessPiece {
public:
    /**
     * @brief Default Constructor for Bishop. 
     * @post Sets piece_size_ to 3 and type to "BISHOP"
     */
    Bishop();

    /**
     * @brief Parameterized constructor.
     * @param color: The color of the Bishop.
     * @param row: 0-indexed row position of the Bishop.
     * @param col: 0-indexed column position of the Bishop.
     * @param movingUp: Flag indicating whether the Bishop is moving up on the board.
     */
    Bishop(const std::string& color, const int& row = -1, const int& col = -1, const bool& movingUp = false);

    bool canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const override;
};
```

## File: `pieces/ChessPiece.cpp`

```cpp
#include "ChessPiece.hpp"

/**
 * @brief Default Constructor : All values 
 * Default-initializes all private members.  
 * Booleans are default-initialized to False. 
 * Default color : "BLACK"
 * Default row & columns: -1 (ie. represents that it has not been put on the board yet)
 * Default type: "NONE"
 * Default size: 0
 */
ChessPiece::ChessPiece() : color_{"BLACK"}, row_{-1}, column_{-1}, movingUp_{false}, piece_size_{0}, type_{"NULL"}, has_moved_{false} {} 

/**
* @brief Parameterized constructor.
* @param : A const reference to the color of the Chess Piece (a string). Set the color "BLACK" if the provided string contains non-alphabetic characters. 
*     If the string is purely alphabetic, it is converted and stored in uppercase
* @param : The 0-indexed row position of the Chess Piece (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
* @param : The 0-indexed column position of the Chess Piece (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
* @param : A flag indicating whether the Chess Piece is moving up on the board, or not (as a const reference to a boolean). Default value false if not provided.
* @post : The private members are set to the values of the corresponding parameters. 
*   If either of row or col are out-of-bounds and set to -1, the other is also set to -1 (regardless of being in-bounds or not).
*   Default piece_size: 0
*   Default type: "NONE"
*/
ChessPiece::ChessPiece(const std::string& color, const int& row, const int& col, const bool& movingUp, const int& size, const std::string& type) :
    color_{"BLACK"}, row_{-1}, column_{-1}, movingUp_{movingUp}, piece_size_{size}, type_{type}, has_moved_{false} {
        // Check for fully alphabetical string & override "BLACK" if valid color
        setColor(color);
        
        // Set row / col if within board dimensions
        setRow(row);
        // If the row was valid, then we see if col is too.
        if (row_ != -1) { setColumn(col); }
    }

/**
 * @brief Gets the color of the chess piece.
 * @return The string value stored in color_
 */
std::string ChessPiece::getColor() const { 
    return color_; 
}

/**
 * @brief Sets the color of the chess piece.
 * @param color A const string reference, representing the color to set the piece to. 
 *     If the string contains non-alphabetic characters, the value is not set (ie. nothing happens)
 *     If the string is alphabetic, then all characters are converted and stored in uppercase
 * @post The color_ member variable is updated to the parameter value in uppercase
 * @return True if the color was set sucessfully. False otherwise.
 */
bool ChessPiece::setColor(const std::string& color) {
    std::string uppercase = "";
    for (size_t i = 0; i < color.size() && std::isalpha(color[i]); i++) {
        uppercase += std::toupper(color[i]);
    } 

    // If all param characters are successfully converted to uppercase, we use it
    if (uppercase.size() == color.size()) { 
        color_ = std::move(uppercase); 
        return true;
    }

    return false;
}

/**
 * @brief Gets the row position of the chess piece.
 * @return The integer value stored in row_
 */
int ChessPiece::getRow() const {
    return row_;
}

/**
 * @brief Sets the row position of the chess piece 
 * @param row The new row of the piece as an integer
 *  If the supplied value is outside the board dimensions [0, BOARD_LENGTH), the ChessPiece is considered to be taken off the board, and its row AND column are set to -1 instead.
 */
void ChessPiece::setRow(const int& row) {
    if (row < 0 || row >= BOARD_LENGTH) {
        row_ = -1;
        column_ = -1;
        return ;
    }
    
    row_ = row;
}

/**
 * @brief Gets the column position of the chess piece.
 * @return The integer value stored in column_
 */
int ChessPiece::getColumn() const {
    return column_;
}

/**
 * @brief Sets the column position of the chess piece 
 * @param row A const reference to an integer representing the new column of the piece 
 *  If the supplied value is outside the board dimensions [0, BOARD_LENGTH), the ChessPiece is considered to be taken off the board, and its row AND column are set to -1 instead.
 */
void ChessPiece::setColumn(const int& column) {
    if (column < 0 || column >= BOARD_LENGTH) {
        row_ = -1;
        column_ = -1;
        return ;
    }
    
    column_ = column;
}

/**
 * @brief Gets the value of the flag for if a chess piece is moving up
 * @return The boolean value stored in movingUp_
 */
bool ChessPiece::isMovingUp() const {
    return movingUp_;
}

/**
 * @brief Sets the movingUp flag of the chess piece 
 * @param flag A const reference to an boolean representing whether the piece is now moving up or not
 */
void ChessPiece::setMovingUp(const bool& flag) {
    movingUp_ = flag;
}

    /**
     * @brief Displays the chess piece's information in the following format, if it is considered on the board (ie. its row and col are not -1):
     * <COLOR> PIECE at (row, col) is moving <UP / DOWN>\n
     * 
     * Otherwise an alternative format is used:
     * <COLOR> PIECE is not on the board\n
     * @note "\n" just means endline in this case. Please use "std::endl," don't hardcode "\n".
     */
void ChessPiece::display() const {
    if (row_ == -1 || column_ == -1) {
        std::cout << color_ << " piece is not on the board" << std::endl;
        return; 
    }

    std::cout << color_ << " piece at " << "(" << row_ << ", " << column_ << ") is moving " 
        << (movingUp_ ? "UP" : "DOWN") << std::endl;
}

/**
* @brief Getter for the piece_size_ data member
*/
int ChessPiece::size() const {
    return piece_size_;
}

/**
* @brief Getter for the type_ data member
*/
std::string ChessPiece::getType() const {
    return type_;
}

/**
 * @brief Setter for the size_ data member
 */
void ChessPiece::setSize(const int& size)  {
    piece_size_ = size;
}


/**
 * @brief Setter for the type_ data member
 */
void ChessPiece::setType(const std::string& type) {
    type_ = type;
}

/**
* @brief Sets a ChessPiece's `has_moved_` member to true
*/
void ChessPiece::flagMoved() {
    has_moved_ = true;
}

/**
* @brief Determines whether a ChessPiece has moved on the board
* @return The value stored in the `has_moved_` member
*/
bool ChessPiece::hasMoved() const {
    return has_moved_;
}
```

## File: `pieces/ChessPiece.hpp`

```cpp
/**
 * @class ChessPiece
 * @brief Represents a generic chess piece.
 * 
 * This class serves as the base class for all chess pieces.
 */

#pragma once
#include <iostream>
#include <cctype>
#include <vector>

class ChessPiece {
   protected:
      static const int BOARD_LENGTH = 8; // A constant value representing the number of rows & columns on the chessboard

   private:
      std::string color_;  // An uppercase, alphabetic string representing the color of the chess piece.

      /** Consider an 8x8 grid with the following indexing:
         *  7 | * * * * * * * *
         *  6 | * * * * * * * *
         *  5 | * * * * * * * *
         *  4 | * * * * * * * *
         *  3 | * * * * * * * *
         *  2 | * * * * * * * *
         *  1 | * * * * * * * *
         *  0 | * * * * * * * *
         *    +---------------
         *      0 1 2 3 4 5 6 7
      */


      int row_;               // An integer corresponding to the row position of the chess piece
      int column_;            // An integer corresponding to the column position of the chess piece
      bool movingUp_;         // A boolean representing whether the piece is moving up the board (in reference to the visual above)
      int piece_size_;        // An integer representing the size of the current chess piece
      std::string type_;      // A string representing the type of the current chess piece
      bool has_moved_;

   protected:
      /**
       * @brief Setter for the size_ data member
       */
      void setSize(const int& size);

      /**
       * @brief Setter for the type_ data member
       */
      void setType(const std::string& type);

   public:

   // =============== Constructors ===============
   
   /**
    * @brief Default Constructor : All values 
    * Default-initializes all private members.  
    * Booleans are default-initialized to False. 
    * Default color : "BLACK"
    * Default row & columns: -1 (ie. represents that it has not been put on the board yet)
    * Default piece_size: 0
    */
   ChessPiece();

     /**
    * @brief Parameterized constructor.
    * @param : A const reference to the color of the Chess Piece (a string). Set the color "BLACK" if the provided string contains non-alphabetic characters. 
    *     If the string is purely alphabetic, it is converted and stored in uppercase
    * @param : The 0-indexed row position of the Chess Piece (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
    * @param : The 0-indexed column position of the Chess Piece (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
    * @param : A flag indicating whether the Chess Piece is moving up on the board, or not (as a const reference to a boolean). Default value false if not provided.
    * @post : The private members are set to the values of the corresponding parameters. 
    *   If either of row or col are out-of-bounds and set to -1, the other is also set to -1 (regardless of being in-bounds or not).
    *   Default piece_size: 0
    */
   ChessPiece(const std::string& color, const int& row = -1, const int& col = -1, const bool& movingUp = false, const int& size = 0, const std::string& type="NONE");

   // =============== Getters and Setters ===============

   /**
    * @brief Gets the color of the chess piece.
    * @return The value stored in color_
    */
   std::string getColor() const;

   /**
    * @brief Sets the color of the chess piece.
    * @param color A const string reference, representing the color to set the piece to. 
    *     If the string contains non-alphabetic characters, the value is not set (ie. nothing happens)
    *     If the string is alphabetic, then all characters are converted and stored in uppercase
    * @post The color_ member variable is updated to the parameter value in uppercase
    * @return True if the color was set. False otherwise.
    */
   bool setColor(const std::string& color);

   /**
    * @brief Gets the row position of the chess piece.
    * @return The integer value stored in row_
    */
   int getRow() const;

   /**
    * @brief Sets the row position of the chess piece 
    * @param row A const reference to an integer representing the new row of the piece 
    *  If the supplied value is outside the board dimensions [0, BOARD_LENGTH), the ChessPiece is considered to be taken off the board, and its row AND column are set to -1 instead.
    */
   void setRow(const int& row);

   /**
    * @brief Gets the column position of the chess piece.
    * @return The integer value stored in column_
    */
   int getColumn() const;

   /**
    * @brief Sets the column position of the chess piece 
    * @param row A const reference to an integer representing the new column of the piece 
    *  If the supplied value is outside the board dimensions [0, BOARD_LENGTH), the ChessPiece is considered to be taken off the board, and its row AND column are set to -1 instead.
    */
   void setColumn(const int& column);

   /**
    * @brief Gets the value of the flag for if a chess piece is moving up
    * @return The boolean value stored in movingUp_
    */
   bool isMovingUp() const;

   /**
    * @brief Sets the movingUp flag of the chess piece 
    * @param flag A const reference to an boolean representing whether the piece is now moving up or not
    */
   void setMovingUp(const bool& flag);

   /**
    * @brief Displays the chess piece's information in the following format, if it is considered on the board (ie. its row and col are not -1):
    * <COLOR> piece at (row, col) is moving <UP / DOWN>\n
    * 
    * Otherwise an alternative format is used:
    * <COLOR> piece is not on the board\n
    * @note "\n" just means endline in this case. Please use "std::endl," don't hardcode "\n".
    */
   void display() const;

   /**
    * @brief Getter for the piece_size_ data member
    */
   int size() const;

   /**
    * @brief Getter for the type_ data member
    */
   std::string getType() const;
   
   /**
     * @brief Determines whether the ChessPiece can move to the specified target position on the board.
     * @note This function is pure virtual, so its implementation will 
     *       be left to its derived classes
     * 
     * @return True if the ChessPiece can move to the specified position; false otherwise.
     */
   virtual bool canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const = 0;

   /**
    * @brief Determines whether a ChessPiece has moved on the board
    * @return The value stored in the `has_moved_` member
    */
   bool hasMoved() const;

   /**
    * @brief Sets a ChessPiece's `has_moved_` member to true
    */
   void flagMoved();
};
```

## File: `pieces/King.cpp`

```cpp
#include "King.hpp"

/**
 * @brief Default Constructor.
 * @post Sets piece_size_ to 4 and type to "KING"
 */
King::King() : ChessPiece() { setSize(4); setType("KING"); }

/**
 * @brief Parameterized constructor.
 * @param color: The color of the King.
 * @param row: 0-indexed row position of the King.
 * @param col: 0-indexed column position of the King.
 * @param movingUp: Flag indicating whether the King is moving up.
 */
King::King(const std::string& color, const int& row, const int& col, const bool& movingUp)
    : ChessPiece(color, row, col, movingUp, 4, "KING") {}

bool King::canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const {
    // Check for bounds and on_board
    if (getRow() == -1 || getColumn() == -1) { return false; } 
    if (target_row < 0 || target_row >= BOARD_LENGTH || target_col < 0 || target_col >= BOARD_LENGTH) { return false; } 

    ChessPiece* target_piece = board[target_row][target_col];
    if (target_piece && target_piece->getColor() == getColor()) { return false; }

    return (target_row != getRow() || target_col != getColumn() ) &&  
        (std::abs(target_row - getRow()) <= 1 && std::abs(target_col - getColumn()) <= 1);
}
```

## File: `pieces/King.hpp`

```cpp
#pragma once

#include <iostream>
#include <vector>
#include "ChessPiece.hpp"


/**
 * @brief King class inheriting from ChessPiece.
 */
class King : public ChessPiece {
public:
    /**
     * @brief Default Constructor for King. 
     * @post Sets piece_size_ to 4 and type to "KING"
     */
    King();

    /**
     * @brief Parameterized constructor.
     * @param color: The color of the King.
     * @param row: 0-indexed row position of the King.
     * @param col: 0-indexed column position of the King.
     * @param movingUp: Flag indicating whether the King is moving up on the board.
     */
    King(const std::string& color, const int& row = -1, const int& col = -1, const bool& movingUp = false);

    bool canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const override;
};
```

## File: `pieces/Knight.cpp`

```cpp
#include "Knight.hpp"

/**
 * @brief Default Constructor.
 * @post Sets piece_size_ to 3 and type to "KNIGHT"
 */
Knight::Knight() : ChessPiece() { setSize(3); setType("KNIGHT"); }

/**
 * @brief Parameterized constructor.
 * @param color: The color of the Knight.
 * @param row: 0-indexed row position of the Knight.
 * @param col: 0-indexed column position of the Knight.
 * @param movingUp: Flag indicating whether the Knight is moving up.
 */
Knight::Knight(const std::string& color, const int& row, const int& col, const bool& movingUp)
    : ChessPiece(color, row, col, movingUp, 3, "KNIGHT") {}

bool Knight::canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const {
    // Not on the board
    if (getRow() == -1 || getColumn() == -1) { return false; }

    // Out of bounds target
    if (target_row < 0 || target_row >= BOARD_LENGTH || target_col < 0 || target_col >= BOARD_LENGTH) { return false; }

    ChessPiece* target_piece = board[target_row][target_col];
    if (target_piece && target_piece->getColor() == getColor()) { return false; }

    int abs_dx = std::abs(getRow() - target_row);
    int abs_dy = std::abs(getColumn() - target_col);

    // Check for an L-shape move pattern
    return (abs_dx == 1 && abs_dy == 2) || (abs_dx == 2 && abs_dy == 1);
}
```

## File: `pieces/Knight.hpp`

```cpp
#pragma once

#include <iostream>
#include <vector>
#include "ChessPiece.hpp"


/**
 * @brief Knight class inheriting from ChessPiece.
 */
class Knight : public ChessPiece {
public:
    /**
     * @brief Default Constructor for Knight. 
     * @post Sets piece_size_ to 3 and type to "KNIGHT"
     */
    Knight();

    /**
     * @brief Parameterized constructor.
     * @param color: The color of the Knight.
     * @param row: 0-indexed row position of the Knight.
     * @param col: 0-indexed column position of the Knight.
     * @param movingUp: Flag indicating whether the Knight is moving up on the board.
     */
    Knight(const std::string& color, const int& row = -1, const int& col = -1, const bool& movingUp = false);

    bool canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const override;
};
```

## File: `pieces/Pawn.cpp`

```cpp
#include "Pawn.hpp"

/**
 * @brief Default Constructor. All boolean values are default initialized to false.
 * @note Remember to default construct the base-class as well
 * @post Sets the piece_size_ member to 1. Sets the type to "PAWN"
 */
Pawn::Pawn() : ChessPiece() { setSize(1); setType("PAWN"); }

/**
* @brief Parameterized constructor.
* @param : A const reference to the color of the Pawn (a string). Set the color "BLACK" if the provided string contains non-alphabetic characters. 
*     If the string is purely alphabetic, it is converted and stored in uppercase
* @param : The 0-indexed row position of the Pawn (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
* @param : The 0-indexed column position of the Pawn (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
* @param : A flag indicating whether the Pawn is moving up on the board, or not (as a const reference to a boolean). Default value false if not provided.
* @post : The private members are set to the values of the corresponding parameters. 
*   If either of row or col are out-of-bounds and set to -1, the other is also set to -1 (regardless of being in-bounds or not).
*   The piece_size_ member is set to 1
*   The type member is set to "PAWN"
*/
Pawn::Pawn(const std::string& color, const int& row, const int& col, const bool& movingUp) :
    ChessPiece(color, row, col, movingUp, 1, "PAWN") {}

/**
 * @brief Determines whether a Pawn can perform a adouble jump or not.
 * @return The value stored in has_moved_
 */
bool Pawn::canDoubleJump() const {
    return !hasMoved();
}

/**
 * @brief Determines if this pawn can be promoted to another piece
 *     A pawn can be promoted if its row has reached the farthest row it can move up (or down) to. This is determined by the board size and the Piece's movingUp_ member.
 *
 *     EXAMPLE: If a pawn is movingUp and the board has 8 rows, then it can promoted only if it is in the 7th row (0-indexed)
 * @return True if this pawn can be promoted. False otherwise.
 */
bool Pawn::canPromote() const {
    return (isMovingUp() && getRow() == BOARD_LENGTH - 1) || 
        (!isMovingUp() && getRow() == 0);
}

// Either two forward, or diagonal to capture piece
bool Pawn::canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const {
    // Not on the board 
    if (getRow() == -1 || getColumn() == -1) { return false; } 

    // Out of bounds target
    if (target_row < 0 || target_row >= BOARD_LENGTH || target_col < 0 || target_col >= BOARD_LENGTH) { return false; };

    ChessPiece* target_piece = board[target_row][target_col];
    if (target_piece && target_piece->getColor() == getColor()) { return false; }


    int direction = isMovingUp() ? 1 : -1;
    bool can_move_straight = 
        (!target_piece && getColumn() == target_col) && // Is moving straight (and there is noe obstructing piece)
        ((getRow() + direction == target_row) || (canDoubleJump() && getRow() + direction * 2 == target_row)); // Is moving by 1 or 2 rows (depending on the canDoubleJump flag)


    bool can_capture_diagonal =
        (target_piece && std::abs(getColumn() - target_col) == 1) && // Moving along some diagonal
        (getRow() + direction == target_row); // Moving along a diagonal they are facing


    return can_move_straight || can_capture_diagonal;
}
```

## File: `pieces/Pawn.hpp`

```cpp
#pragma once

#include <iostream>
#include <cstdlib>
#include <vector>
#include "ChessPiece.hpp"

class Pawn : public ChessPiece {
    public:
        /**
         * @brief Default Constructor. All boolean values are default initialized to false.
         * @note Remember to construct the base-class as well
         */
        Pawn();

        /**
        * @brief Parameterized constructor.
        * @param : A const reference to the color of the Pawn (a string). Set the color "BLACK" if the provided string contains non-alphabetic characters. 
        *     If the string is purely alphabetic, it is converted and stored in uppercase.
        *     NOTE: We do not supply a default value for color, the first parameter. Notice that if we do, we override the default constructor.
        * @param : The 0-indexed row position of the Pawn (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
        * @param : The 0-indexed column position of the Pawn (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
        * @param : A flag indicating whether the Pawn is moving up on the board, or not (as a const reference to a boolean). Default value false if not provided.
        * @post : The private members are set to the values of the corresponding parameters. 
        *   If either of row or col are out-of-bounds and set to -1, the other is also set to -1 (regardless of being in-bounds or not).
        */
        Pawn(const std::string& color, const int& row = -1, const int& col = -1, const bool& movingUp = false);

        /**
         * @brief Gets the value of the flag for the Pawn can double jump
         * @return The boolean value stored in double_jumpable_
         */
        bool canDoubleJump() const;


        /**
         * @brief Determines if this pawn can be promoted to another piece
         *     A pawn can be promoted if its row has reached the farthest row it can move up (or down) to. This is determined by the board size and the Piece's movingUp_ member.
         *
         *     EXAMPLE: If a pawn is movingUp and the board has 8 rows, then it can promoted only if it is in the 7th row (0-indexed)
         * @return True if this pawn can be promoted. False otherwise.
         */
        bool canPromote() const;

        bool canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const override;
};
```

## File: `pieces/Queen.cpp`

```cpp
#include "Queen.hpp"

/**
 * @brief Default Constructor.
 * @post Sets piece_size_ to 9 and type to "QUEEN"
 */
Queen::Queen() : ChessPiece() { setSize(4); setType("QUEEN"); }

/**
 * @brief Parameterized constructor.
 * @param color: The color of the Queen.
 * @param row: 0-indexed row position of the Queen.
 * @param col: 0-indexed column position of the Queen.
 * @param movingUp: Flag indicating whether the Queen is moving up.
 */
Queen::Queen(const std::string& color, const int& row, const int& col, const bool& movingUp)
    : ChessPiece(color, row, col, movingUp, 4, "QUEEN") {}

bool Queen::canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const {
    // Not on the board
    if (getRow() == -1 || getColumn() == -1) { return false; }

    // Out of bounds target
    if (target_row < 0 || target_row >= BOARD_LENGTH || target_col < 0 || target_col >= BOARD_LENGTH) { return false; }

    ChessPiece* target_piece = board[target_row][target_col];
    if (target_piece && target_piece->getColor() == getColor()) { return false; }

    int dx = target_row - getRow();
    int dy = target_col - getColumn();

    // Must move either straight or diagonal
    bool no_movement = (dx == 0) && (dy == 0);
    bool not_straight = dx != 0 && dy != 0;
    bool not_diagonal = std::abs(dx) != std::abs(dy);
    
    if (no_movement || (not_straight && not_diagonal)) { return false; }

    // EDIT BELOW.
    // Get sign of offsets: -1 if target is to the left or down, 0 if on the same vert/horizontal line, 1 if to the right or up.
    int row_offset = (dx) ? dx / std::abs(dx) : 0;
    int col_offset = (dy) ? dy / std::abs(dy) : 0;

    // Iterate from the target space to the original space and check if there is any obstructing Chess Piece
    while ((dx -= row_offset) != 0 && (dy -= col_offset) != 0) {
        if (board[getRow() + dx][getColumn() + dy]) {
            return false;
        }
    }

    return true;
}

```

## File: `pieces/Queen.hpp`

```cpp
#pragma once

#include <iostream>
#include <vector>
#include "ChessPiece.hpp"


/**
 * @brief Queen class inheriting from ChessPiece.
 */
class Queen : public ChessPiece {
public:
    /**
     * @brief Default Constructor for Queen. 
     * @post Sets piece_size_ to 4 and type to "QUEEN"
     */
    Queen();

    /**
     * @brief Parameterized constructor.
     * @param color: The color of the Queen.
     * @param row: 0-indexed row position of the Queen.
     * @param col: 0-indexed column position of the Queen.
     * @param movingUp: Flag indicating whether the Queen is moving up on the board.
     */
    Queen(const std::string& color, const int& row = -1, const int& col = -1, const bool& movingUp = false);

    bool canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const override;
};
```

## File: `pieces/Rook.cpp`

```cpp
#include "Rook.hpp"

/**
 * @brief Default Constructor. By default, Rooks have 3 available castle moves to make
 * @note Remember to default construct the base-class as well
 * @post Sets the piece_size_ member to 1. Sets the type to "PAWN"
 */
Rook::Rook() : ChessPiece(), castle_moves_left_{3} { setSize(2); setType("ROOK"); }

/**
* @brief Parameterized constructor. Rememeber to use the arguments to construct the underlying ChessPiece.
* @param : A const reference to the color of the Rook (a string). Set the color "BLACK" if the provided string contains non-alphabetic characters. 
*     If the string is purely alphabetic, it is converted and stored in uppercase
* @param : The 0-indexed row position of the Rook (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
* @param : The 0-indexed column position of the Rook (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
* @param : A flag indicating whether the Rook is moving up on the board, or not (as a const reference to a boolean). Default value false if not provided.
* @param : An integer representing how many castle moves it can make. Default to 3 if no value provided. If a negative value is provided, 0 is used instead.
* @post : The private members are set to the values of the corresponding parameters. 
*   If either of row or col are out-of-bounds and set to -1, the other is also set to -1 (regardless of being in-bounds or not).
*   The piece_size_ member is set to 1
*   The type member is set to "PAWN"
*/
Rook::Rook(const std::string& color, const int& row, const int& col, const bool& movingUp, const int& castle_moves_capacity) :
    ChessPiece(color, row, col, movingUp, 2, "ROOK"), castle_moves_left_{ std::max(0, castle_moves_capacity) } {}

/**
 * @brief Gets the value of the castle_moves_left_
 * @return The integer value stored in castle_moves_left_
 */
int Rook::getCastleMovesLeft() const {
    return castle_moves_left_;
}

/**
 * @brief Determines if this rook can castle with the parameter Chess Piece
 *     This rook can castle with another piece if:
 *        1. It has more than 0 castle moves available
 *        2. Both pieces share the same color
 *        3. Both pieces are considered on-the-board (no -1 rows or columns) and laterally adjacent (ie. they share the same row and their columns differ by at most 1)
 * @param ChessPiece A chess piece with which the rook may / may not be able to castle with
 * @return True if the rook can castle with the given piece. False otherwise.
 */
bool Rook::canCastle(const ChessPiece& target) const {
    // Ensure there are castle moves available & the pieces share color
    if (castle_moves_left_ == 0 || getColor() != target.getColor()) { return false; }

    // Ensure both pieces are on the board
    if (getRow() < 0 || getColumn() < 0 || target.getRow() < 0 || target.getColumn() < 0) { return false; }

    // Ensure they are in the same row or columns differ by at most 1 next to each other
    if (getRow() != target.getRow() || std::abs(getColumn() - target.getColumn()) > 1) { return false; }

    return true;
}

bool Rook::canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const {
    // Not on the board 
    if (getRow() == -1 || getColumn() == -1) { return false; } 
    // Out of bounds target
    if (target_row < 0 || target_row >= BOARD_LENGTH || target_col < 0 || target_col >= BOARD_LENGTH) { return false; };
    

    // Account for castle in ChessBoard move()
    ChessPiece* target_piece = board[target_row][target_col];
    if (target_piece) {
        if (target_piece->getColor() == getColor()) { return false; }
        if (canCastle(*target_piece)) { return true; } // It can only castle if it is adjacent anyway
    }
    
    // Get the difference between the current position and the target position
    // -,0,+  -->  represents left, no movement, right
    int row_difference = target_row - getRow(); 
    // -,0,+  -->  represents down, no movement, up
    int col_difference = target_col - getColumn(); 

    // Same cell OR not a horizontal / vertical line
    bool stays_in_same_position = (row_difference == 0) && (col_difference == 0);
    bool moves_straight = (row_difference == 0) || (col_difference == 0);
    if (stays_in_same_position || !moves_straight) { return false; }

    // Find what direction we should step 
    int increment_row = 0;
    int increment_col = 0;
    if (row_difference > 0) { increment_row = 1; }  // Moving right
    if (row_difference < 0) { increment_row = -1; } // Moving left

    if (col_difference > 0) { increment_col = 1; }  // Moving up
    if (col_difference < 0) { increment_col = -1; } // Moving down
    
    // Iterate from the original space to target space and check if there is any obstructing Chess Piece
    int temp_row = getRow();
    int temp_col = getColumn();

    while (temp_row != target_row || temp_col != target_col) {
        temp_row += increment_row;
        temp_col += increment_col;
        if (board[temp_row][temp_col]) { return false; }
    }

    return true;
}

```

## File: `pieces/Rook.hpp`

```cpp
#pragma once

#include <iostream>
#include <algorithm>
#include <vector>
#include "ChessPiece.hpp"


class Rook : public ChessPiece {
    private: 
        int castle_moves_left_; // Default to 3

    public:
        /**
         * @brief Default Constructor. By default, Rooks have 3 available castle moves to make
         * @note Remember to default construct the base-class as well
         */
        Rook();

        /**
        * @brief Parameterized constructor. Rememeber to use the arguments to construct the underlying ChessPiece.
        * @param : A const reference to the color of the Rook (a string). Set the color "BLACK" if the provided string contains non-alphabetic characters. 
        *     If the string is purely alphabetic, it is converted and stored in uppercase
        *     NOTE: We do not supply a default value for color, the first parameter. Notice that if we do, we override the default constructor.
        * @param : The 0-indexed row position of the Rook (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
        * @param : The 0-indexed column position of the Rook (as a const reference to an integer). Default value -1 if not provided, or if the value provided is outside the board's dimensions, [0, BOARD_LENGTH)
        * @param : A flag indicating whether the Rook is moving up on the board, or not (as a const reference to a boolean). Default value false if not provided.
        * @param : An integer representing how many castle moves it can make. Default to 3 if no value provided.
        * @post : The private members are set to the values of the corresponding parameters. 
        *   If either of row or col are out-of-bounds and set to -1, the other is also set to -1 (regardless of being in-bounds or not).
        */
        Rook(const std::string& color, const int& row = -1, const int& col = -1, const bool& movingUp = false, const int& castle_move_capacity = 3);

    
       /**
         * @brief Determines if this rook can castle with the parameter Chess Piece
         *     This rook can castle with another piece if:
         *        1. It has more than 0 castle moves available
         *        2. Both pieces share the same color
         *        3. Both pieces are considered on-the-board (no -1 rows or columns) and laterally adjacent (ie. they share the same row and their columns differ by at most 1)
         * @param ChessPiece A chess piece with which the rook may / may not be able to castle with
         * @return True if the rook can castle with the given piece. False otherwise.
         */
        bool canCastle(const ChessPiece& target) const;
        

        /**
         * @brief Gets the value of the castle_moves_left_
         * @return The integer value stored in castle_moves_left_
         */
        int getCastleMovesLeft() const;

        /**
         * If it is adjacent, see if it can castle with the piece. 
         * If it is non-adj. 
         */
        bool canMove(const int& target_row, const int& target_col, const std::vector<std::vector<ChessPiece*>>& board) const override;
};
```

## File: `ChessBoard.cpp`

```cpp
#include "ChessBoard.hpp"

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

/**
 * @brief Finds all possible solutions to the 8-queens problem.
 * 
 * @return A vector of CharacterBoard objects, 
 *         each representing a unique solution 
 *         to the 8-queens problem.
 */
std::vector<ChessBoard::CharacterBoard> ChessBoard::findAllQueenPlacements() {
    // empty board of pointers
    std::vector<std::vector<ChessPiece*>> board(BOARD_LENGTH, std::vector<ChessPiece*>(BOARD_LENGTH, nullptr));
    std::vector<Queen*> placedQueens;
    std::vector<CharacterBoard> allBoards;
    queenHelper(0, board, placedQueens, allBoards);
    return allBoards;
}

/**
 * @brief Helper function to find all possible placements of queens on the board.
 * 
 * Uses recursive backtracking to explore all possible placements of queens on the board.
 *
 * @param row The current row to place a queen.
 * @param board The current state of the board.
 * @param placedQueens A vector of pointers to the placed queens.
 * @param allBoards A vector to store all valid board configurations.
 */
void ChessBoard::queenHelper(
    const int& col,
    std::vector<std::vector<ChessPiece*>>& board,
    std::vector<Queen*>& placedQueens,
    std::vector<CharacterBoard>& allBoards
) {
    if (col == BOARD_LENGTH) {
        // convert to CharacterBoard
        CharacterBoard result(BOARD_LENGTH, std::vector<char>(BOARD_LENGTH, '.'));
        for (Queen* q : placedQueens) { // place queens on the board
            result[q->getRow()][q->getColumn()] = 'Q'; // place queen
        }
        allBoards.push_back(result);
        return;
    }

    // here we try to place a queen in each row of the current column
    for (int row = 0; row < BOARD_LENGTH; ++row) {
        bool safe = true;
        for (Queen* q : placedQueens) { // check if this position is safe
            if (!q->canMove(row, col, board)) { // this position is not safe
                safe = false; // this position is not safe
                break;
            }
        }
        if (!safe) continue;

        // place a new queen
        Queen* qptr = new Queen("WHITE", row, col);
        board[row][col] = qptr; // place the queen on the board
        placedQueens.push_back(qptr); // add to the list of placed queens

        // recurse to next column
        queenHelper(col + 1, board, placedQueens, allBoards); // try next column

        // backtrack: remove queen
        placedQueens.pop_back(); // remove from the list of placed queens
        board[row][col] = nullptr; // remove from the board
        delete qptr;
    }
}
```

## File: `ChessBoard.hpp`

```cpp
/**
 * @class ChessBoard
 * @brief Represents an 8x8 board of Chess Pieces used to play chess
 */

#pragma once

#include <vector>
#include "pieces_module.hpp"

class ChessBoard {
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
        static void queenHelper(
            const int& col,
            std::vector<std::vector<ChessPiece*>>& board,
            std::vector<Queen*>& placedQueens,
            std::vector<CharacterBoard>& allBoards
        );

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
#include "Transform.hpp"

/**
 * @brief Rotates a square matrix 90 degrees clockwise.
 * @pre The input 2D vector must be square 
 *      (ie. the number of cells per row equals the number of columns)
 * 
 * @param matrix A const reference to a 2D vector of objects of type T
 * @return A new 2D vector representing the rotated matrix
 */
template <typename T>
std::vector<std::vector<T>> Transform::rotate(const std::vector<std::vector<T>>& matrix) {
    // your code here.
    return {};
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
std::vector<std::vector<T>> Transform::flipAcrossVertical(const std::vector<std::vector<T>>& matrix) {
    // your code here
    return {};
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
std::vector<std::vector<T>> Transform::flipAcrossHorizontal(const std::vector<std::vector<T>>& matrix) {
    // your code here
    return {};
}
```

## File: `Transform.hpp`

```cpp
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

int main() {
    return 0;
}
```

## File: `pieces_module.hpp`

```cpp
#include "pieces/ChessPiece.hpp"
#include "pieces/Pawn.hpp"
#include "pieces/Rook.hpp"
#include "pieces/Queen.hpp"
#include "pieces/King.hpp"
#include "pieces/Bishop.hpp"
#include "pieces/Knight.hpp"
```

