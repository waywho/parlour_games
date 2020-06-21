require "rails_helper"

RSpec.describe Api::ChatroomsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/chatrooms").to route_to("api/chatrooms#index", format: "json")
    end

    it "routes to #show" do
      expect(get: "/api/chatrooms/1").to route_to("api/chatrooms#show", id: "1", format: "json")
    end


    it "routes to #create" do
      expect(post: "/api/chatrooms").to route_to("api/chatrooms#create", format: "json")
    end

    it "routes to #update via PUT" do
      expect(put: "/api/chatrooms/1").to route_to("api/chatrooms#update", id: "1", format: "json")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/api/chatrooms/1").to route_to("api/chatrooms#update", id: "1", format: "json")
    end

    it "routes to #destroy" do
      expect(delete: "/api/chatrooms/1").to route_to("api/chatrooms#destroy", id: "1", format: "json")
    end
  end
end
