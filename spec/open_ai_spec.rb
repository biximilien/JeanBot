require "open_ai"

describe OpenAI do
  include OpenAI

  describe "#sentiment_analysis" do
    it "returns a string" do
      expect(sentiment_analysis("I love you")).to be_a(String)
    end

    it "returns a string with a sentiment" do
      expect(sentiment_analysis("I love you")).to match(/Positive|Negative|Neutral/)
    end

    context "when the sentiment is positive" do
      it "returns a string with a sentiment" do
        expect(sentiment_analysis("I love you")).to match(/Positive/i)
      end
    end

    context "when the sentiment is negative" do
      it "returns a string with a sentiment" do
        expect(sentiment_analysis("I hate you")).to match(/Negative/i)
      end
    end

    context "when the sentiment is neutral" do
      it "returns a string with a sentiment" do
        expect(sentiment_analysis("I am neutral")).to match(/Neutral/i)
      end
    end
  end
end
