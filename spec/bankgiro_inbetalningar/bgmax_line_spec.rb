require_relative '../spec_helper'

module BankgiroInbetalningar
  class Tk00 < BgmaxLine
    field :currency, 3..5, 'A:h'
    field :cents, 6..11, 'N:h0'
    field :flag, 12, 'N:-'
  end

  RSpec.describe BgmaxLine do
    it "knows its children" do
      expect(BgmaxLine.parsers['00']).to eq(Tk00)
    end

    context "fields" do
      subject { Tk00.new("00SEK0001234") }

      it "can be strings" do
        expect(subject.currency).to eq('SEK')
      end

      it "can be a 0-padded number" do
        expect(subject.cents).to eq 123
      end

      it 'can be a numeric flag' do
        expect(subject.flag).to eq 4
      end
    end
  end
end
