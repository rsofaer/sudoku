require 'rubygems'
require 'pp'
require 'ruby-debug'
require 'json'
class SudokuState
  def initialize rows
    @rows = rows
  end

  def row(i)
    @rows[i - 1]
  end

  def col(j)
    @rows.map{|r| r[j-1]}
  end

  def cell(i, j)
    row(i)[j-1]
  end

  def set_cell(i, j, n)
    i = i-1
    j = j-1
    @rows[i][j] = n
  end

  def block_range(i_or_j)
    if i_or_j <=3
      (0..2)
    elsif i_or_j <= 6
      (3..5)
    else
      (6..8)
    end
  end

  def box(i, j)
    box_rows = @rows[block_range(i)]
    box_rows.map{|r| r[block_range(j)]}.flatten
  end

  def nums_remaining(i, j)
    possibilities = [1,2,3,4,5,6,7,8,9]
    possibilities = possibilities - row(i)
    possibilities = possibilities - col(j)
    possibilities = possibilities - box(i,j)
    possibilities
  end

  def zeros
    result = []
    @rows.each_with_index do |row, row_idx|
      i = row_idx + 1
      row.each_with_index do |num, col_idx|
        j = col_idx + 1
        result << [i,j] if num == 0
      end
    end
    result
  end

  def basic_solve
    still_changing = true
    while still_changing
      still_changing = false
      zeros.each do |c|
        possibilities = nums_remaining(c[0],c[1])
        if possibilities.count == 0
          return "inconsistent state"
        elsif possibilities.count == 1
          still_changing = true
          set_cell(c[0], c[1], possibilities.first)
        end
      end
    end
    @rows
  end

  def solved?
    self.zeros.empty?
  end

  def clone
    self.class.new JSON.parse(@rows.to_json)
  end
  def spec_solve
    b_solved = self.clone.basic_solve
    if b_solved == "inconsistent state"
      return "inconsistent state"
    end
    state = SudokuState.new(b_solved)
    return state if state.solved?
    /*
      Let R be the entries in b_solved having two or more possible values
      for each entry e in R
        let V be the possible values for E
        for each value v in V
          push state on the stack of saved states
          new_state = state.clone.set_cell(e, v)
          newer_state = new_state.spec_solve
          if newer_state.solved?
            return newer_state
          end
          pop state
        end
      end
      */
  end
end
basic_solvable = [[0,0,0, 0,0,0, 0,0,7],
                  [7,0,4, 0,0,0, 8,9,3],
                  [0,0,6, 8,0,2, 0,0,0],

                  [0,0,7, 5,2,8, 6,0,0],
                  [0,8,0, 0,0,6, 7,0,1],
                  [9,0,3, 4,0,0, 0,8,0],

                  [0,0,0, 7,0,4, 9,0,0],
                  [6,0,0, 0,9,0, 0,0,0],
                  [4,5,9, 0,0,0, 1,0,8]]
s = SudokuState.new(basic_solvable)
pp s.basic_solve
