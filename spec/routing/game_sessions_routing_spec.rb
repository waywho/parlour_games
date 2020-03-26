require "rails_helper"

RSpec.describe GameSessionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/game_sessions").to route_to("game_sessions#index")
    end

    it "routes to #show" do
      expect(get: "/game_sessions/1").to route_to("game_sessions#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/game_sessions").to route_to("game_sessions#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/game_sessions/1").to route_to("game_sessions#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/game_sessions/1").to route_to("game_sessions#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/game_sessions/1").to route_to("game_sessions#destroy", id: "1")
    end
  end
end
