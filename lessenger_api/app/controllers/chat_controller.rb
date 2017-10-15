class ChatController < ApplicationController
    # @users = {}
    def messages()
        puts "#{params}"
        user = params[:user_id]
        if params[:name]
            # @users[user] = params[:name]
            m = {type: 'text', text: "Hello, #{params[:name]}!"}
        end
        if params[:text]
            msg = params[:text]
            m = {type: 'text', text: msg}
        end
        messages = [m]
        render json: {
            success: 'success',
            messages: messages
        }
    end
end
