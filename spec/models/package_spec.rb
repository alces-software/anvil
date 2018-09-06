
require 'rails_helper'
require 'helpers/zip_maker'
require 'tempfile'

RSpec.describe Package, type: :model do
  it 'is valid' do
    expect(create(:package)).to be_valid
  end

  it 'defaults to the uncategorised category' do
    uncategorised = Category.find_by(name: 'Uncategorised')
    expect(create(:package).category).to eq(uncategorised)
  end

  it 'can explicitly set a category' do
    category = create(:category)
    package = create(:package, category: category)
    expect(package.category).to eq(category)
  end

  it 'has a factory method that automatically creates a zip file' do
    package = create(:package)
    expect(File.exist?(package.zip_file_path)).to be true
  end

  it 'can be built without a zip file' do
    package = nil
    expect do
      package = build(:package, zip_file_path: nil)
    end.not_to raise_error
    expect(package.zip_file_path).to be_nil
  end

  shared_context 'package:zip-file-subject' do
    let(:zip_temp_file) { Tempfile.new(['anvil-test-package', '.zip']) }
    let(:zip_path) { zip_temp_file.path }
    let(:metadata_content) do {
      type: zip_type,
      attributes: package_attributes
    } end
    let(:zip_type) { 'package' }
    let(:package_attributes) do {
      name: 'test-package',
      version: '0.0.1'
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
  end

  describe '::build_from_zip' do
    include_context 'package:zip-file-subject'

    let(:update_object) do
      subject.save!
      described_class.find_by(name: subject.name)
    end

    it 'is invalid without the installer script' do
      expect(subject).not_to be_valid
    end

    context 'with the installer' do
      before { Helpers::ZipMaker.with_installer(zip_path) }

      it { is_expected.to be_valid }

      context 'when updated without the zip file' do
        before do
          update_object.zip_file_path = nil
          update_object.save
        end

        it 'skips the zip file checks' do
          expect(update_object).to be_valid
        end
      end

      context 'when updated with a missing zip file' do
        before do
          update_object.zip_file_path = '/some/missing/file.zip'
          update_object.save
        end

        it 'runs the zip validation' do
          expect(update_object).not_to be_valid
        end
      end

      context 'when the package_url has not been set' do
        let(:package_url) { nil }
        it { is_expected.not_to be_valid }
      end

      context 'when the package attributes have not been set' do
        let(:package_attributes) { nil }
        it { is_expected.not_to be_valid }
      end

      context 'when the package version has not been set' do
        let(:package_attributes) { {
          name: 'random', version: ''
        } }
        it { is_expected.not_to be_valid }
      end

      context 'when the package name has not been set' do
        let(:package_attributes) { {
          name: '', version: '0.0.1'
        } }
        it { is_expected.not_to be_valid }
      end

      ['name', 'version'].each do |method|
        context "when the record '#{method}' does not match the zip" do
          it 'is invalid' do
            subject.public_send("#{method}=", 'some-random-value')
            expect(subject).not_to be_valid
          end
        end
      end

      context 'when the zip file is not of type package' do
        let(:zip_type) { 'something-random' }
        it { is_expected.not_to be_valid }
      end
    end
  end

  describe '::where_zip' do
    let(:query) do
      described_class.where_zip(file: subject.zip_file_path)
    end

    subject { create(:package) }

    context 'when the record exists' do
      before { subject.save!.freeze }

      it 'returns a realtion' do
        expect(query).to be_a(ActiveRecord::Relation)
      end

      it 'is the only relation' do
        expect(query.length).to be 1
        expect(query.first).to eq(subject)
      end

      context 'when a different user adds the package' do
        let(:other_user) { create(:user, name: 'someone else') }
        let(:other_package) do
          build(:package,
                 zip_file_path: subject.zip_file_path,
                 user: other_user)
        end

        before { other_package.save! }

        it 'returns both entries' do
          expect(query).to include(subject)
          expect(query).to include(other_package)
        end
      end
    end
  end
end

