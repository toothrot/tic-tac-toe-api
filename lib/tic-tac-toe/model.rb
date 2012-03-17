module TicTacToe
  class Model
    extend ActiveModel::Naming
    include ActiveModel::Validations
    attr_accessor :attributes

    def initialize(attributes = {})
      @attributes = attributes
    end

    def self.redis
      @redis ||= Redis.new
    end

    def self.redis_namespace
      model_name.plural
    end

    def self.persisted_attributes()
      @persisted_attributes || []
    end

    def self.persist(*keys)
      @persisted_attributes ||= []
      @persisted_attributes.concat(keys)
    end

    def self.find(id)
      new(Yajl::Parser.parse(redis.get("#{redis_namespace}:#{id}")))
      rescue Yajl::ParseError
        nil
    end

    def self.find_all(options = {})
      limit = options[:limit] || 10
      ids = redis.zrevrangebyscore("#{redis_namespace}_ids", Time.now.utc.to_i, 0, :limit => [0,limit])
      ids.map { |id| find(id) }
    end

    def redis
      self.class.redis
    end

    def save
      redis.set("#{self.class.redis_namespace}:#{attributes[:id]}", to_json)
    end
 
    def to_model
      self
    end

    def to_hash
      attributes
    end

    def to_json
      Yajl::Encoder.encode(to_hash)
    end
 
    def read_attribute_for_validation(key)
      @attributes[key]
    end
  end
end
