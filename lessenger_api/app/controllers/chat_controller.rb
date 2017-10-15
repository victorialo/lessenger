class ChatController < ApplicationController
    # @users = {}
    def messages()
        puts "#{params}".red

        queries = [
            "what's the weather in",
            "weather in",
            "weather"
        ]
        user = params[:user_id]
        if params[:name]
            # @users[user] = params[:name]
            m = {type: 'text', text: "Hello, #{params[:name]}!"}
        end
        if params[:text]
            msg = params[:text]
            reply = msg # parrot back what you say unless you're asking about weather
            location = ""
            queries.each_with_index do |q, ind|
                next unless location == ""
                if msg.include?(q)
                    parse = msg.split(q).each{|phrase| phrase.strip}
                    puts "#{parse}".yellow
                    # if ind == 3
                    #     location = parse[-1]
                    # else
                    location = parse[-1]
                    # end
                    reply = location
                    puts "#{reply}".green
                end
            end
            puts "#{reply}".magenta
            m = {type: 'text', text: reply}
        end
        messages = [m]
        render json: {
            success: 'success',
            messages: messages
        }
    end
end
