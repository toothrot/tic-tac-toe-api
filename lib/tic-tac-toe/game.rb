module TicTacToe
  class Game < Model
    persist :id,:status,:players,:created_at

    def self.create(attributes)
      game = self.new
      game.attributes = {:players => attributes["players"]}
      game.attributes[:status] = "in_progress"
      game.attributes[:id] = ::UUID.generate
      game.attributes[:created_at] = Time.now.utc.to_i
      game.save
      redis.zadd("#{redis_namespace}_ids", game.attributes[:created_at], game.attributes[:id])
      game
    end

    def players
      attributes[:players]
    end
  end
end
