
require 'rails_helper'

RSpec.describe Package, type: :model do
  it 'is valid' do
    expect(build(:package)).to be_valid
  end
end

