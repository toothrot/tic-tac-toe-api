module TicTacToe
  class Board
    WinningPositions = [
      [0,1,2],
      [3,4,5],
      [6,7,8],
      [0,4,8],
      [2,4,6],
      [0,3,6],
      [1,4,7],
      [2,5,8]
    ]

    def initialize(actions)
      @actions = actions
    end

    def to_a
      @actions.inject([nil]*9) do |output,action|
        output[action.position.to_i] = action.player
        output
      end
    end

    def winner
      WinningPositions.each do |pattern|
        candidate = to_a.values_at(*pattern).uniq
        if candidate.uniq.size == 1 && candidate.uniq.first
          return candidate.uniq.first
        end
      end
      nil
    end

    def full?
      to_a.compact.size >= 9
    end
  end
end
