require 'rails_helper'

RSpec.describe Librarian, type: :model do
  describe "association" do
    it { should have_one(:user) }
  end
end
