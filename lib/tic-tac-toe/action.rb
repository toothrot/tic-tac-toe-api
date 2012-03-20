module TicTacToe
  class Action < Model
    persist :player,:game_id,:created_at,:position
    validate :is_valid_move_on_create?
    validates_numericality_of 'position', :greater_than_or_equal_to => 0, :less_than_or_equal_to => 8, :only_integer => true

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
      if action.valid?
        action.save
        redis.rpush("#{Game.redis_namespace}:#{action.attributes["game_id"]}:actions", action.attributes["id"])
        redis.zadd("#{redis_namespace}_ids", action.attributes["created_at"], action.attributes["id"])
      end
      action
    end

    def game
      @game ||= Game.find(attributes["game_id"])
    end

    def position
      attributes["position"]
    end

    def player
      attributes["player"].to_s
    end

    private

    def player_order
      game.players.index do |gp|
        gp["id"] == player
      end
    end

    def is_valid_move_on_create?
      errors.add(:base, "Game over") if game.status != "in_progress"
      errors.add(:base, "Duplicate Move") if game.actions.any? {|a| a.position == attributes["position"] }
      errors.add(:base, "Bad player name") if game.players.none? { |gp| gp["id"] == player }
      errors.add(:base, "It's not your turn") if game.actions.size % 2 != player_order
      true
    end
  end
end
