
require 'rails_helper'
require 'helpers/zip_maker'
require 'tempfile'

RSpec.describe Package, type: :model do
  it 'is valid' do
    expect(build(:package)).to be_valid
  end

  describe '::build_from_zip' do
    let(:zip_temp_file) { Tempfile.new(['anvil-test-package', '.zip']) }
    let(:zip_path) { zip_temp_file.path }
    let(:metadata_content) do {
      type: 'package',
      attributes: package_attributes
    } end
    let(:package_attributes) do {
      name: 'test-package'
    } end

    before do
      Helpers::ZipMaker.with_metadata(zip_path, **metadata_content)
    end
    after do
      zip_temp_file.close
      zip_temp_file.unlink
    end

    subject do
      described_class.build_from_zip(
        user: build(:user),
        category: build(:category),
        package_url: 'www.example.com/random-url',
        file: zip_path
      )
    end

    it { is_expected.to be_valid }
  end
end

