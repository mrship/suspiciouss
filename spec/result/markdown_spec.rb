require 'spec_helper'

describe Suspiciouss::Result::Markdown do

  let(:result) { {'filename.css' => ['error1']} }

  subject { described_class.new(result).format }

  describe '#format' do

    it { expect(subject).to eq " - Check file filename.css for:\n```\nerror1```\n" }
  end
end
