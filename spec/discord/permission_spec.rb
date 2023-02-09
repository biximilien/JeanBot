require "discord"
require "discord/permission"

describe Discord::Permission do
  describe "#ADMINISTRATOR" do
    it "returns the administrator permission" do
      expect(Discord::Permission::ADMINISTRATOR).to eq(8)
    end
  end
end
