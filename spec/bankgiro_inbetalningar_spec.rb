require_relative 'spec_helper'

RSpec.describe BankgiroInbetalningar do
  describe ".parse" do
    context "parsing a minimal file" do
      subject { BankgiroInbetalningar.parse(fixture_path('minimal.txt')) }

      it "finds the timestamp" do
        expect(subject.timestamp).to eq "2004 05 25 173035 010331".gsub(' ','').to_i
      end
      it "finds 1 deposit" do
        expect(subject.deposits.count).to eq 1
      end
      it "finds 1 payment" do
        expect(subject.deposits.first.payments.count).to eq 1
      end
    end
  end

  describe ".parse_data" do
    context "parsing a minimal file" do
      let(:data) { data_from_file('minimal.txt') }
      subject { BankgiroInbetalningar.parse_data(data) }

      it "finds the timestamp" do
        expect(subject.timestamp).to eq "2004 05 25 173035 010331".gsub(' ','').to_i
      end
      it "finds 1 deposit" do
        expect(subject.deposits.count).to eq 1
      end
      it "finds 1 payment" do
        expect(subject.deposits.first.payments.count).to eq 1
      end
    end
  end
end
