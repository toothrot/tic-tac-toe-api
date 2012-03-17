module TicTacToe
  class Game < Model
    persist :id,:status,:players

    def self.create(attributes)
      game = self.new
      game.attributes = {:players => attributes["players"]}
      game.attributes[:status] = "in_progress"
      game.attributes[:id] = ::UUID.generate
      game.save
      game
    end

    def players
      attributes[:players]
    end
  end
end
