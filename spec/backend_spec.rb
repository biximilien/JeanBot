require "backend"

describe Backend do
  include Backend

  let(:server_id) { 123 }
  let(:user_id) { 456 }

  before do
    @redis = Redis.new(url: REDIS_URL)
    @redis.flushall
  end

  describe "#add_user_to_watch_list" do
    it "adds a user to the watch list" do
      add_user_to_watch_list(server_id, user_id)
      expect(@redis.smembers("server_#{server_id}_users")).to include(user_id.to_s)
    end
  end

  describe "#remove_user_from_watch_list" do
    it "removes a user from the watch list" do
      add_user_to_watch_list(server_id, user_id)
      remove_user_from_watch_list(server_id, user_id)
      expect(@redis.smembers("server_#{server_id}_users")).not_to include(user_id.to_s)
    end
  end

  describe "#get_watch_list_users" do
    it "returns the watch list users" do
      add_user_to_watch_list(server_id, user_id)
      expect(get_watch_list_users(server_id)).to include(user_id)
    end
  end

  describe "#add_server" do
    it "adds a server" do
      add_server(server_id)
      expect(@redis.smembers("servers")).to include(server_id.to_s)
    end
  end

  describe "#remove_server" do
    it "removes a server" do
      add_server(server_id)
      remove_server(server_id)
      expect(@redis.smembers("servers")).not_to include(server_id.to_s)
    end
  end

  describe "#get_servers" do
    it "returns the servers" do
      add_server(server_id)
      expect(get_servers).to include(server_id)
    end
  end

  after do
    @redis.flushall
  end
end
