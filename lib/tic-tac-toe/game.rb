module TicTacToe
  class Game < Model
    persist :id,:status,:players,:created_at

    def self.create(attributes)
      game = self.new("status" => "in_progress",
                      "id" => ::UUID.generate,
                      "created_at" => Time.now.utc.to_i,
                      "players" => attributes["players"])
      game.save
      redis.zadd("#{redis_namespace}_ids", game.attributes["created_at"], game.attributes["id"])
      game
    end

    def status
      if board.winner || board.full?
        attributes["status"] = "ended"
      else
        attributes["status"] = "in_progress"
      end
    end

    def players
      attributes["players"]
    end

    def actions
      @actions ||= Action.find_all_by_game_id(attributes["id"])
    end

    def to_hash
      status
      attributes.merge("board" => board.to_a, "winner" => board.winner)
    end

    def board
      Board.new(actions)
    end
  end
end
