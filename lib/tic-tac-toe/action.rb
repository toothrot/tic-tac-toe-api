module TicTacToe
  class Action < Model
    persist :player,:game_id,:created_at,:position

    def self.find_all_by_game_id(game_id)
      ids = redis.lrange("#{Game.redis_namespace}:#{game_id}:actions", 0, -1)
      ids.map {|id| find(id) }
    end

    def self.create(attributes)
      action = self.new("player" => attributes["player"],
                      "game_id" => attributes["game_id"],
                      "position" => attributes["position"],
                      "id" => ::UUID.generate,
                      "created_at" => Time.now.utc.to_i)
      if action.is_valid_move_on_create?
        action.save
        redis.rpush("#{Game.redis_namespace}:#{action.attributes["game_id"]}:actions", action.attributes["id"])
        redis.zadd("#{redis_namespace}_ids", action.attributes["created_at"], action.attributes["id"])
        action
      else
        false
      end
    end

    def game
      @game ||= Game.find(attributes["game_id"])
    end

    def position
      attributes["position"].to_i
    end

    def player
      attributes["player"].to_s
    end

    def player_order
      game.players.index do |gp|
        gp["id"] == player
      end
    end

    def is_valid_move_on_create?
      return false if game.status != "in_progress"
      return false if game.actions.any? {|a| a.position == attributes["position"] }
      return false if game.actions.size % 2 != player_order
      true
    end
  end
end
