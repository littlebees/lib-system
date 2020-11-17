require 'rails_helper'

RSpec.describe User, type: :model do
  describe "association" do
    it { should belong_to(:role) }
  end
end
