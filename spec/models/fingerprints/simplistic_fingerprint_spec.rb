require 'spec_helper'

describe SimplisticFingerprint do
  context 'being created' do
    let(:backtrace) do
      Backtrace.create(:raw => [
        {
          "number"=>"17",
          "file"=>"[GEM_ROOT]/gems/activesupport/lib/active_support/callbacks.rb",
          "method"=>"_run__2497084960985961383__process_action__2062871603614456254__callbacks"
        },
        {
          "number"=>"18",
            "file"=>"[GEM_ROOT]/gems/activesupport/lib/active_support/stuff.rb",
            "method"=>"do_cool_stuff"
        }
      ])
    end
    let(:notice1) { Fabricate.build(:notice, :backtrace => backtrace) }
    let(:notice2) { Fabricate.build(:notice, :backtrace => backtrace_2) }

    context "with backtrace that has the same top-level line" do
      let(:backtrace_2) do
        backtrace
        backtrace.lines.last.method =  'do_other_stuff'
        backtrace.save
        backtrace
      end

      it "normalizes the fingerprint of generated methods" do
        expect(SimplisticFingerprint.generate(notice1, "api key")).to eql SimplisticFingerprint.generate(notice2, "api key")
      end
    end

    context "with backtrace that has a different top-level line" do
      let(:backtrace_2) do
        backtrace
        backtrace.lines.first.method =  'eat_delicious_soup'
        backtrace.save
        backtrace
      end

      it "normalizes the fingerprint of generated methods" do
        expect(LegacyFingerprint.generate(notice1, "api key")).not_to eql LegacyFingerprint.generate(notice2, "api key")
      end
    end
  end
end
