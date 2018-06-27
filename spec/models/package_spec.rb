
require 'rails_helper'

RSpec.describe Package, type: :model do
  it 'is valid' do
    expect(build(:package)).to be_valid
  end

  describe '::build_from_zip' do
    subject do
      described_class.build_from_zip(
        user: build(:user),
        category: build(:category),
        package_url: 'www.example.com/random-url',
        file: file_fixture('alces/clusterware-tips/2.0.0-dev.zip')
      )
    end

    it { is_expected.to be_valid }
  end
end

