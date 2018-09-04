
require 'rails_helper'
require 'helpers/zip_maker'
require 'tempfile'

RSpec.describe Package, type: :model do
  it 'is valid' do
    expect(create(:package)).to be_valid
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
    let(:package_url) { 'http://www.example.com/some-package' }

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
        package_url: package_url,
        file: zip_path
      )
    end

    it { is_expected.to be_valid }

    context 'when the package_url has not been set' do
      let(:package_url) { nil }
      it { is_expected.not_to be_valid }
    end

    context 'when the package attributes have not been set' do
      let(:package_attributes) { nil }
      it { is_expected.not_to be_valid }
    end

    context 'when the package name have not been set' do
      let(:package_attributes) { { name: '' } }
      it { is_expected.not_to be_valid }
    end
  end
end

