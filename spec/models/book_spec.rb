require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "association" do
    it { should have_many(:copies) }
  end
end
