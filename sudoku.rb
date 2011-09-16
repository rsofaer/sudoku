require 'rubygems'
require 'pp'
require 'ruby-debug'
require 'json'
require 'perftools'
class SudokuState
  def initialize rows
    #@@stop_after_a_while ||= 0
    @@failures ||= {}
    @nums_remaining ||= {}
    @rows = rows
    @cols = []
  end

  def row(i)
    @rows[i - 1]
  end

  def col(j)
    @cols[j] ||= @rows.map{|r| r[j-1]}
  end

  def cell(i, j)
    row(i)[j-1]
  end

  def set_cell(i, j, n)
    @nums_remaining = {}
    @cols[j] = nil
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
    @nums_remaining[[i,j]] ||= lambda {
      possibilities = [1,2,3,4,5,6,7,8,9]
      possibilities = possibilities - row(i)
      possibilities = possibilities - col(j)
      possibilities = possibilities - box(i,j)
      possibilities
    }.call
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

  def inconsistent?
    return  "inconsistent state" if @@failures[@rows.hash]
    if zeros.detect{|coords| nums_remaining(coords[0], coords[1]) == 0}
      @@failures[@rows.hash] = true
      return "inconsistent state"
    end
  end
  def basic_solve
    still_changing = true
    while still_changing
      still_changing = false
      zeros.each do |c|
        possibilities = nums_remaining(c[0],c[1])
        if possibilities.count == 0
          @@failures[@rows.hash] = true
          return "inconsistent state"
        elsif possibilities.count == 1
          still_changing = true
          set_cell(c[0], c[1], possibilities.first)
        end
      end
    end
    self
  end

  def solved?
    self.zeros.empty?
  end

  def clone
    self.class.new JSON.parse(@rows.to_json)
  end
  def spec_solve
    #@@stop_after_a_while += 1
    #return if @@stop_after_a_while > 10000
    b_solved = self.clone.basic_solve
    if b_solved == "inconsistent state" || b_solved.inconsistent?
      return "inconsistent state"
    end
    return b_solved if b_solved.solved?

    stack = []
    b_solved.zeros.each do |zero|
      i = zero[0]
      j = zero[1]

      v = nums_remaining(i,j)
      v.each do |num|
        new_state = self.clone
        new_state.set_cell(i, j, num)
        next if new_state.inconsistent?
        newer_state = new_state.spec_solve
        return newer_state if newer_state.instance_of?(SudokuState) && newer_state.solved?
      end
    end
=begin
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
=end
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

adv_solvable =  [[0,3,0, 0,0,0, 0,4,0],
                 [0,1,0, 0,9,7, 0,5,0],
                 [0,0,2, 5,0,8, 6,0,0],

                 [0,0,3, 0,0,0, 8,0,0],
                 [9,0,0, 0,0,4, 3,0,0],
                 [0,0,7, 6,0,0, 0,0,4],

                 [0,0,9, 8,0,5, 4,0,0],
                 [0,7,0, 0,0,0, 0,2,0],
                 [0,5,0, 0,7,1, 0,8,0]]
s = SudokuState.new(basic_solvable)
pp s.basic_solve

s = SudokuState.new(adv_solvable)

PerfTools::CpuProfiler.start("tmp/sudoku_profile") do
  solved = s.spec_solve
end

pp solved
