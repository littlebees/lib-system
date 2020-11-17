require 'rails_helper'

RSpec.describe Reader, type: :model do
  describe "association" do
    it { should have_one(:user) }
    it { should have_many(:copies).through(:tickets) }
  end
end
