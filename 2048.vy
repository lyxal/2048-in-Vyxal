# 2048 in Vyxal
# Author: lyxal
# Written 9th June 2022
# Based on a video that implemented 2048 using redstone in minecraft lol
# https://www.youtube.com/watch?v=gYAc7yl2KY8

`UP` →_UP
`DOWN` →_DOWN
`LEFT` →_LEFT
`RIGHT` →_RIGHT

@compress:cells:direction| #|
  #{
  →cells:  the current board state
  →direction: the direction to move the tiles.
  ←return: the board with all tiles moved as far as possible in that direction
  }#
  
  4ʁ:Ẋs →all_coords # Used as a list of multi-dimensional indices: [row, col]
  ⟨ ⟩ →dir_vec # Which way the target cell is 
  ⟨ ⟩ →target_coords # The cells to iterate over
  
  # Consider the up direction first
  ←direction ←_UP = [
    ⟨ 1N | 0 ⟩ →dir_vec # up a row
    ←all_coords 4ȯ →target_coords # All coords except top row, starting from bottom.
  ]
  
  ←direction ←_DOWN = [
    ⟨ 1 | 0 ⟩ →dir_vec
    ←all_coords 4NẎ →target_coords # All coords except bottom row, starting from top.
  ]  

  ←direction ←_LEFT = [
    ⟨ 0 | 1N ⟩ →dir_vec
    ←all_coords 4ẇ∩ḢÞf →target_coords # Transpose, remove left-most cell and flatten one layer
    # All coords except left column, starting from right column
  ]
  
   ←direction ←_RIGHT = [
    ⟨ 0 | 1 ⟩ →dir_vec
    ←all_coords 4ẇ∩ṪÞf →target_coords # Transpose, remove left-most cell and flatten one layer
    
  ]
  ⟨ ⟩ →last_state
  { ←cells ←last_state ≠ |
    ←cells →last_state # Store the last state of the cells before moving
    ←target_coords (pos| # Loop over all indices that aren't in the top row
        ←pos ←dir_vec + →next_cell # Calculate the cell above pos
        ←cells ←pos Þi →cell_value
        ←cells ←next_cell Þi 0 = [ # If the cell above pos is 0 (empty)
          ←cells ←next_cell hi ←next_cell t ←cell_value Ȧ # Set the position in the corresponding row
          ←cells $ ←next_cell h $ Ȧ →cells # Place the row into the board
          ←cells ←pos hi ←pos t 0 Ȧ # Replace the item in the original row
          ←cells $ ←pos h $ Ȧ →cells # Place that row into the board
        ]
    )
  }
  
  ←cells
;

@merge:cells:direction| #|
  #{
   →cells:  the current board state
   →direction: the direction the tiles have moved.
   ←return: the board with all possible tiles merged in that direction
  }#
  
  # Determine direction
  # Next cell = this cell + next cell if this cell == next cell
  # this cell = 0 if merged
  
  4ʁ:Ẋs →all_coords # Used as a list of multi-dimensional indices: [row, col]
  ⟨ ⟩ →dir_vec # Which way the target cell is 
  ⟨ ⟩ →target_coords # The cells to iterate over
  
  # Consider the up direction first
  ←direction ←_UP = [
    ⟨ 1N | 0 ⟩ →dir_vec # up a row
    ←all_coords 4ȯṘ →target_coords # All coords except top row, starting from bottom.
  ]
  
  ←direction ←_DOWN = [
    ⟨ 1 | 0 ⟩ →dir_vec
    ←all_coords 4NẎ →target_coords # All coords except bottom row, starting from top.
  ]  

  ←direction ←_LEFT = [
    ⟨ 0 | 1N ⟩ →dir_vec
    ←all_coords 4ẇ∩ḢÞf →target_coords # Transpose, remove left-most cell and flatten one layer
    # All coords except left column, starting from right column
  ]
  
   ←direction ←_RIGHT = [
    ⟨ 0 | 1 ⟩ →dir_vec
    ←all_coords 4ẇ∩ṪÞfṘ →target_coords # Transpose, remove left-most cell and flatten one layer
  ]
  
  ←target_coords (pos|
    ←pos ←dir_vec + →next_cell # Calculate the cell next to pos in direction
    ←cells ←pos Þi →cell_value # Get the value of this cell
    ←cells ←next_cell Þi →next_value # Get the value of this cell
    ←cell_value ←next_value =
    ←all_coords ←pos c∧  [ # If cells are same, and there hasn't already been a merge
      ←cells ←next_cell hi ←next_cell t ←cell_value d Ȧ # Set the position in the corresponding row
      ←cells $ ←next_cell h $ Ȧ →cells # Place the row into the board
      ←cells ←pos hi ←pos t 0 Ȧ # Replace the item in the original row
      ←cells $ ←pos h $ Ȧ →cells # Place that row into the board
      ←all_coords ←pos o →all_coords # Remove from all coords
    ]
  )
  ←cells
;

@insert_new_number:cells| #|
  #{
    →cells:  the current board state
    ←return: the board with a new number inserted into an empty slot.
    90% chance of being 2, 10% of being 4.
    -1 if no empty spots
  }#

  4ʁ:Ẋs →all_coords
  ←all_coords '←cells n Þi 0 =; :L # Get all the coordinates of empty spots.
  [℅ →target_coord|uX] # If the empty spots are empty, return -1. Otherwise, choose a random square
  
  9 2 ẋ 4 J ℅ →new_value # Get the value to insert into the new spot

  ←cells ←target_coord hi ←target_coord t ←new_value Ȧ
  ←cells $ ←target_coord h $ Ȧ
;

# Main gameplay loop

14 0 ẋ 2 J 2 J Þ℅ 4ẇ →board

`Welcome to 2048. Your goal is to get the highest number by merging tiles.`,

{
    `\n`, ←board ƛvS7↳;⁋ , `\n`,
    `` →direction { `udlr`f ←direction c¬ | # While the user doesn't input a valid direction
      `Enter move (u - up, d - down, l - left, r - right): `₴
      ?: →direction
      `udlr`f$c¬ [`Please enter a letter from udlr and try again.`,]
    }
    
    ⟨ ←_UP | ←_DOWN | ←_LEFT | ←_RIGHT ⟩ `udlr` ←direction ḟi →direction
    
    ←direction ←board @compress;
    ←direction $ @merge;
    ←direction $ @compress;
    
    @insert_new_number; : u⁼ [X] →board
}

`You lost. Sorry about that.`,
