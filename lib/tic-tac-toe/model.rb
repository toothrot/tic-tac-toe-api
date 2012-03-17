module TicTacToe
  class Model
    extend ActiveModel::Naming
    include ActiveModel::Validations
    attr_accessor :attributes

    def initialize(attributes = {})
      @attributes = attributes
    end

    def self.redis
      uri = URI.parse(ENV["REDISTOGO_URL"]) if ENV["REDISTOGO_URL"]
      if uri
        @redis ||= Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      else
        @redis ||= Redis.new
      end
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
      offset = options[:offset] || 0
      ids = redis.zrevrangebyscore("#{redis_namespace}_ids", Time.now.utc.to_i, 0, :limit => [offset,limit])
      ids.map {|id| find(id) }
    end

    def redis
      self.class.redis
    end

    def save
      hash_to_save = self.class.persisted_attributes.inject({}) do |hash,key|
        hash[key.to_s] = attributes[key.to_s]
        hash
      end
      redis.set("#{self.class.redis_namespace}:#{attributes["id"]}", Yajl::Encoder.encode(hash_to_save))
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
