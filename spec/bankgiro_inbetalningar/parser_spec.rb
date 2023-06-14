# -*- coding: utf-8 -*-
require_relative '../spec_helper'

module BankgiroInbetalningar
  RSpec.describe Parser do
    context "parsing sample file 4" do
      let(:data) { data_from_file('BgMaxfil4.txt') }
      let(:parser) { Parser.new(data) }
      let(:result) { parser.run ; parser.result }

      context "with non Latin-1 data" do
        let(:data) { data_from_file('BgMaxfil4.txt').encode("UTF-8") }

        it "handles that fine" do
          expect(result.payments[1].payer.name).to include "Olles färg"
        end
      end

      it "returns valid results" do
        expect(result).to be_valid
      end

      it "finds 4 deposits" do
        expect(result.deposits.count).to eq 4
      end
      it "finds 9 payments" do
        expect(result.payments.count).to eq 9
      end

      context "simplest OCR payment" do
        let(:payment) { result.payments[5] }
        it "has one reference" do
          expect(payment.reference_type).to eq 2
          expect(payment.raw_references).to eq ['535765']
          expect(payment.references).to eq ['535765']
          expect(payment.currency).to eq 'SEK'
          expect(payment.cents).to eq 500_00
          expect(payment.raw).to eq "200000000000                   535765000000000000050000230000000000230          \r\n"
        end
        it "has a date" do
          expect(payment.date).to eq Date.civil(2004,5,25)
        end
        it "has a number" do
          expect(payment.number).to eq "000000000023"
        end
      end

      context "simple OCR payment with address" do
        let(:payment) { result.payments[1] }
        let(:payer) { payment.payer }
        it "has one reference" do
          expect(payment.references).to eq  ['524967']
          expect(payment.currency).to eq 'SEK'
          expect(payment.cents).to eq 1900_00
          expect(payment.sender_bgno).to eq 97012333
        end
        it "has a payer (in UTF-8!)" do
          expect(payer.name).to eq "Olles färg AB"
          expect(payer.street).to eq 'Lillagatan 3'
          expect(payer.postal_code).to eq '12345'
          expect(payer.city).to eq "Storåker"
          expect(payer.country).to be_nil
          # TODO: talk to BGC and see if they really meant this org_no to have 9 digits.
          expect(payer.org_no).to eq  550000432
        end
      end

      context "OCR payment with several references and text" do
        let(:payment) { result.payments[0] }
        it "has four references" do
          expect(payment.references).to contain_exactly(*%w[665869 657775 665661 665760])
        end
        it "has text" do
          expect(payment.text).to eq "Betalning med extra refnr 665869 657775 665661\n665760"
        end
      end

      context "OCR payment with two good references, one bad and one revert" do
        let(:payment) { result.payments[6] }
        it "has three references" do
          expect(payment.references).to match_array %w[7495575 695668 8988777]
        end
      end

    end

    context "parsing a broken sample file 4" do
      let(:data) { data_from_file('BgMaxfil4_broken.txt') }
      let(:parser) { Parser.new(data) }
      let(:result) { parser.run }

      it "returns invalid results" do
        expect(result).not_to be_valid
      end

      it "reports the payments count as being off" do
        expect(result.errors).to include("Found 9 payments but expected 8")
      end

      it "reports the deposits count as being off" do
        expect(result.errors).to include("Found 4 deposits but expected 5")
      end
    end

    # It's an easy mistake to upload a BGMAX PDF instead of TXT.
    context "parsing a file that isn't BGMAX at all" do
      let(:data) { data_from_file('not_bgmax_at_all.pdf') }
      let(:parser) { Parser.new(data) }
      let(:result) { parser.run }

      it "returns invalid results" do
        expect(result).not_to be_valid
      end

      it "reports the format as being wrong" do
        expect(result.errors).to include("Doesn't look like a BGMAX file at all.")
      end
    end
  end
end
