require "rails_helper"

RSpec.describe Api::MessagesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/messages").to route_to("api/messages#index", format: "json")
    end

    it "routes to #show" do
      expect(get: "/api/messages/1").to route_to("api/messages#show", id: "1", format: "json")
    end


    it "routes to #create" do
      expect(post: "/api/messages").to route_to("api/messages#create", format: "json")
    end

    it "routes to #update via PUT" do
      expect(put: "/api/messages/1").to route_to("api/messages#update", id: "1", format: "json")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/api/messages/1").to route_to("api/messages#update", id: "1", format: "json")
    end

    it "routes to #destroy" do
      expect(delete: "/api/messages/1").to route_to("api/messages#destroy", id: "1", format: "json")
    end
  end
end
