defmodule Battleship.OpertionsTest do
  use ExUnit.Case
  alias Battleship.Operations

  describe "is_boat_available?(boat, boats, available_boats) Boat is available considers possible lengths given by game and already located boats" do
    test "Boat of length n, when no boats used, can be located if n is in available_boats" do
      assert Operations.is_boat_available?([{2, 3}], [], []) == false
      assert Operations.is_boat_available?([{2, 3}], [], [1]) == true
    end
    test "If I had only one boat of length n and I used it, it's not available" do
      assert Operations.is_boat_available?([{2, 3}], [[{2, 3}]], [1]) == false
      assert Operations.is_boat_available?([{2, 3}], [[{2, 3}]], [1, 1]) == true
    end
  end
  describe "is_boat_location_legal?(boat, boats) Checks if boat is valid and doesn't come across any located boat or adjacent cells" do
    test "Boats are not legal if they are out of grid. If no boats located, any boat on grid is legal" do
      assert Operations.is_boat_location_legal?([{10, 9}], []) == false
      assert Operations.is_boat_location_legal?([{1, 1}], []) == true
    end
    test "Boat is illegal if it's on top or adjacent to located boat" do
      assert Operations.is_boat_location_legal?([{1, 1}], [[{1, 1}]]) == false
      assert Operations.is_boat_location_legal?([{1, 1}], [[{1, 2}]]) == false
      assert Operations.is_boat_location_legal?([{1, 1}], [[{1, 3}]]) == true
    end
  end
  describe "all_boats_set?(boats, available_boats) Checks if we ran out of all available_boats because boats have all these lengths" do
    test "If I have available lengths m and n, all boats are set if in boats I have one of length n and other of m" do
      assert Operations.all_boats_set?([ [{1, 1}] ], [1, 2]) == false
      assert Operations.all_boats_set?([ [{1, 1}], [{1, 3}, {1, 4}] ], [1, 2] ) == true
    end
  end
  describe "is_shot_legal?(shot, shots) A shot is legal if it's unique and inside grid" do
    test "Shot is illegal if it's outside grid. If no shots yet, all valid shots are legal" do
      assert Operations.is_shot_legal?({10, 9}, []) == false
      assert Operations.is_shot_legal?({8, 7}, [] ) == true
    end
    test "This shot is illegal because it's repeated" do
      assert Operations.is_shot_legal?({6, 6}, [{6, 6}]) == false
    end
    test "This shot is legal because it's genuine and inside grid" do
      assert Operations.is_shot_legal?({6, 6}, [{7, 7}]) == true
    end
  end
  describe "hit?(shot, boats) Informs if shot hit a boat" do
    test "If there are no boats, it's never a hit" do
      assert Operations.hit?({3, 3}, []) == false
    end
    test "Otherwise, there's a hit if shot is a cell of one of the boats" do
      assert Operations.hit?({3, 3}, [[{1, 2}]]) == false
      assert Operations.hit?({3, 3}, [ [{3, 3}] ]) == true
    end
  end
  describe "is_game_end?(shots, boats) Checks if game ends because shots sank all boats" do
    test "If there are no boats game's always ended" do
      assert Operations.is_game_end?([{3, 3}], []) == true
    end
    test "If there are no shots, game ends iff there are no boats" do
      assert Operations.is_game_end?([], [ [{1, 1}] ]) == false
      assert Operations.is_game_end?([], []) == true
    end
    test "If boat cells are included in shots, game ends" do
      assert Operations.is_game_end?([{1, 3}], [ [{1, 1}], [{1, 3}] ]) == false
      assert Operations.is_game_end?([{1, 3}, {1, 1}], [ [{1, 1}], [{1, 3}] ]) == true
    end
  end
  describe "are_cells_valid?(cell1, celln) Checks if both cells are on grid" do
    test "Returns true only if BOTH elements of each cell are between 0 and 9" do
      assert Operations.are_cells_valid?({11, 0}, {3, 4}) == false
      assert Operations.are_cells_valid?({0, 0}, {7, 5}) == true
    end
  end
  describe "is_it_a_boat?(cell1, celln) Informs if two cells can form a boat" do
    test "Two cells are a boat if they are vertical or horizontal aligned" do
      assert Operations.is_it_a_boat?({1, 9}, {11, 5}) == false
      assert Operations.is_it_a_boat?({1, 9}, {11, 9}) == true
      assert Operations.is_it_a_boat?({1, 9}, {1, 5}) == true
    end
  end
  describe "are_sel_cells_intended_length?(length, cell1, celln) Checks if cell1 and celln IF THEY'RE A BOAT" do
    test "Check correct usage for vertical aligned cells" do
      assert Operations.are_sel_cells_intended_length?(5, {0, 0}, {7, 0}) == false
      assert Operations.are_sel_cells_intended_length?(8, {0, 0}, {7, 0}) == true
    end
    test "Check correct usage for horizontal aligned cells" do
      assert Operations.are_sel_cells_intended_length?(5, {0, 0}, {0, 7}) == false
      assert Operations.are_sel_cells_intended_length?(8, {0, 0}, {0, 7}) == true
    end
  end
  describe "create_boat(cell1, celln) Returns a boat from cell1 to celln in ascendent order IF THEY'RE A BOAT" do
    test "Check correct usage for vertical and horizontal aligned cells" do
      assert Operations.create_boat({3, 0}, {9, 0}) == for i <- 3 .. 9, do: {i, 0}
      assert Operations.create_boat({0, 3}, {0, 9}) == for j <- 3 .. 9, do: {0, j}
    end
  end
  describe "what_is_cell(cell, boats) Informs if cell is part of a boat" do
    test "Check that return of :water and :boat is adequate" do
      assert Operations.what_is_cell({3, 3}, [ [{1, 1}] ]) == :water
      assert Operations.what_is_cell({3, 3}, [ [{3, 3}] ]) == :boat
    end
  end
  describe "how_is_cell(cell, shots) Informs if there's a shot in cell" do
    test "Chech correct return of :hit and :unharmed" do
      assert Operations.how_is_cell({3, 3}, [{1, 1}]) == :unharmed
      assert Operations.how_is_cell({3, 3}, [{3, 3}]) == :hit
    end
  end
  describe "is_first_cell?(length, cell, boats) Helps predicting if there's a chance to locate legally a boat of length from cell" do
    test "If there are no boats, I can locate any length from any cell on grid" do
      assert Operations.is_first_cell?(5, {10, 9}, []) == false
      assert Operations.is_first_cell?(5, {3, 3}, []) == true
    end
    test "If cell is illegal given boats, it isn't a first cell for any length" do
      assert Operations.is_first_cell?(0, {6, 7}, [[{6, 6}]]) == false
    end
    test "If there's a boat cell length cells a way in any vertical or horizontal direction from cell it isn't a first cell" do
      assert Operations.is_first_cell?(3, {5, 5}, [ [{5, 3}], [{5, 7}], [{3, 5}], [{7, 5}]]) == false
      assert Operations.is_first_cell?(3, {5, 5}, [ [{5, 3}], [{5, 7}], [{3, 5}]]) == true
    end
  end
  describe "is_second_cell?(length_sel, sel_cell, cell, boats) If sel_cell and cell are legal boat of length_sel" do
    test "If sel_cell and cell aren't a boat, cell is never a second cell" do
      assert Operations.is_second_cell?(1, {0, 0}, {1, 1}, []) == false
    end
    test "If they're a boat but of length different than length_sel, cell is never a second cell" do
      assert Operations.is_second_cell?(1, {0, 0}, {0, 2}, []) == false
    end
    test "If cell is illegal given boats is never a second cell" do
      assert Operations.is_second_cell?(1, {0, 0}, {0, 1}, [[{0, 2}]] ) == false
    end
    test "If any cell from sel_cell to cell, distanced by length_sel, is illegal given boats, cell is not a second cell" do
      assert Operations.is_second_cell?(4, {0, 0}, {0, 3}, [ [{1, 2}] ]) == false
    end
    test "Sel_cell and cell are future_boat of length_sel, there are no boats or none of their illegal cells are in future_boat" do
      assert Operations.is_second_cell?(4, {0, 0}, {0, 3}, []) == true
      assert Operations.is_second_cell?(4, {0, 0}, {0, 3}, [ [{3, 3}] ]) == true
    end
  end
  describe "last_shot_result(shots, boats) Informs which was the result of last shot, the last of list of shots" do
    test "If there are no shots or no boats, it's always a miss (default value)" do
      assert Operations.last_shot_result( [], [ [{1, 1}] ]) == :miss
      assert Operations.last_shot_result( [{2, 2}], [] ) == :miss
    end
    test "If last shot was a boat cell but there are more alive cells in it, it's a hit" do
      assert Operations.last_shot_result( [{0, 0}, {2, 2}], [ [{1, 2}, {2, 2}] ]) == :hit
    end
    test "If last shot sunk a boat but there are more alive boats, it's a sunk" do
      assert Operations.last_shot_result( [{1, 2}, {2, 2}], [ [{1, 2}, {2, 2}], [{3, 3}, {3, 4}] ]) == :sunk
    end
    test "If last shot hit the last alive cell of boats, it's a end" do
      assert Operations.last_shot_result( [{1, 2}, {2, 2}], [ [{1, 2}, {2, 2}] ]) == :end
    end
  end
  describe "sunk_boats(shots, boats) Returns which boats were sunk by shots" do
    test "If there are no shots or no boats it returns a list with no boats" do
      assert Operations.sunk_boats( [], [ [{1, 2}, {2, 2}] ]) == []
      assert Operations.sunk_boats( [{1, 1}, {1, 2}], []) == []
    end
    test "It doesn't return hit but alive boats" do
      assert Operations.sunk_boats( [{1, 1}], [ [{1, 1}, {1, 2}] ]) == []
      assert Operations.sunk_boats( [{1, 1}, {1, 2}], [ [{1, 1}, {1, 2}] ] ) == [ [{1, 1}, {1, 2}] ]
    end
  end
end
