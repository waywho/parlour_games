require "rails_helper"

RSpec.describe Api::GameSessionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/game_sessions").to route_to("api/game_sessions#index", format: "json")
    end

    it "routes to #show" do
      expect(get: "/api/game_sessions/1").to route_to("api/game_sessions#show", id: "1", format: "json")
    end


    it "routes to #create" do
      expect(post: "/api/game_sessions").to route_to("api/game_sessions#create", format: "json")
    end

    it "routes to #update via PUT" do
      expect(put: "/api/game_sessions/1").to route_to("api/game_sessions#update", id: "1", format: "json")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/api/game_sessions/1").to route_to("api/game_sessions#update", id: "1", format: "json")
    end

    it "routes to #destroy" do
      expect(delete: "/api/game_sessions/1").to route_to("api/game_sessions#destroy", id: "1", format: "json")
    end
  end
end
