require "rails_helper"

RSpec.describe CopiesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/copies").to route_to("copies#index")
    end

    it "routes to #show" do
      expect(get: "/copies/1").to route_to("copies#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/copies").to route_to("copies#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/copies/1").to route_to("copies#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/copies/1").to route_to("copies#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/copies/1").to route_to("copies#destroy", id: "1")
    end
  end
end
