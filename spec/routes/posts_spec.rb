require 'spec_helper'
require './app.rb'

RSpec.describe 'App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "Post API Routes" do

    context 'POST #create' do

        let!(:user) { User.last }

        it "should create a new post" do
            params = {
                title: "Testing Post",
                description: "Testing Description"
            }

            expect { post "/api/v1/users/#{user.id}/posts", params }.to change(Post, :count).by(1)

            expect(last_response.status).to eq 201
        end

        context 'ERRORS #create' do

            it "should not create new post with empty title" do
                params = {
                    description: "Testing Description"
                }

                expect { post "/api/v1/users/#{user.id}/posts", params }.to change(Post, :count).by(0)

                expect(last_response.body).to include("Title Can't Be Blank!".to_json)

                expect(last_response.status).to eq 400
            end

            it "should not create new post with title of length < 5" do
                params = {
                    title: "Test",
                    description: "Testing Description"
                }

                expect { post "/api/v1/users/#{user.id}/posts", params }.to change(Post, :count).by(0)
            end

            it "should not create new post with title of length > 255" do
                params = {
                    title: "Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test",
                    description: "Testing Description"
                }

                expect { post "/api/v1/users/#{user.id}/posts", params }.to change(Post, :count).by(0)
            end

            it "should not create new post with empty description" do
                params = {
                    title: "Testing Post"
                }

                expect { post "/api/v1/users/#{user.id}/posts", params }.to change(Post, :count).by(0)

                expect(last_response.body).to include("Description Can't Be Blank!".to_json)

                expect(last_response.status).to eq 400
            end

        end

    end

    context 'POST #update' do

        let!(:user) { User.last }

        let!(:update_post) { user.posts.last }
        
        it "should update a post" do
            params = {
                title: "Update Post",
                description: "Testing Description"
            }

            put "/api/v1/users/#{user.id}/posts/#{update_post.id}", params

            expect(last_response.status).to eq 201

            update_post.reload

            params.keys.each do |key|
                expect(update_post.attributes[key.to_s]).to eq params[key]
            end
        end

        context 'ERRORS #update' do

            it "should not update post with empty title" do
                params = {
                    title: nil,
                    description: "Testing Description"
                }

                put "/api/v1/users/#{user.id}/posts/#{update_post.id}", params

                expect(last_response.body).to include("Title Can't Be Blank!".to_json)

                expect(last_response.status).to eq 400
            end

            it "should not update post with title of length < 5" do
                params = {
                    title: "Test",
                    description: "Testing Description"
                }

                put "/api/v1/users/#{user.id}/posts/#{update_post.id}", params
            end

            it "should not update post with title of length > 255" do
                params = {
                    title: "Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test",
                    description: "Testing Description"
                }

                put "/api/v1/users/#{user.id}/posts/#{update_post.id}", params
            end

            it "should not update post with empty description" do
                params = {
                    title: "Testing Post",
                    description: nil
                }

                put "/api/v1/users/#{user.id}/posts/#{update_post.id}", params

                expect(last_response.body).to include("Description Can't Be Blank!".to_json)

                expect(last_response.status).to eq 400
            end
        end

    end

    context 'POST #index' do

        let!(:user) { User.last }

        let!(:all_posts) { user.posts }

        it "sends all posts of user as json" do
            get "/api/v1/users/#{user&.id}/posts"

            expect(last_response.status).to eq 200
            
            expect(last_response.body).to include(all_posts.to_json)
        end

    end

    context 'POST #show' do

        let!(:user) { User.last }

        let!(:single_post) { user.posts.last }

        it "should send single post of user as json" do
            get "/api/v1/users/#{user&.id}/posts/#{single_post.id}"

            expect(last_response.status).to eq 200

            expect(last_response.body).to include(single_post.to_json)
        end

        context 'ERRORS #show' do

            it "should send user not found message as json" do
                get "/api/v1/users/12345/posts/#{single_post.id}"

                expect(last_response.status).to eq 400

                expect(last_response.body).to include("User Not Found!".to_json)
            end

            it "should send post not found message as json" do
                get "/api/v1/users/#{user&.id}/posts/12345"

                expect(last_response.status).to eq 400

                expect(last_response.body).to include("Post Not Found!".to_json)
            end

        end

    end

    context 'POST #delete' do

        let!(:user) { User.last }

        let!(:delete_post) { user.posts.last }

        it "should delete single post of user" do
            expect { delete "/api/v1/users/#{user.id}/posts/#{delete_post.id}" }.to change(Post, :count).by(-1)

            expect(last_response.status).to eq 201
        end

        context 'ERRORS #delete' do

            it "should send post not found message as json" do
                expect { delete "/api/v1/users/#{user.id}/posts/21343" }.to change(Post, :count).by(0)

                expect(last_response.status).to eq 400

                expect(last_response.body).to include("Post Not Found!".to_json)
            end

            it "should send post not found message as json" do
                expect { delete "/api/v1/users/123455/posts/#{delete_post.id}" }.to change(Post, :count).by(0)

                expect(last_response.status).to eq 400

                expect(last_response.body).to include("User Not Found!".to_json)
            end

        end

    end

  end

end