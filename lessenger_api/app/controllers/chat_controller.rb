class ChatController < ApplicationController
    # @users = {}
    def messages()
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
                    location = parse[-1]
                    # grab coordinates
                    map_res = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=AIzaSyD7W7v5psM8TDJwUV2WxsPkoYRtByh07Y0")
                    map = JSON.parse(map_res.body)
                    if map_res['results'].empty?
                        reply = "Sorry, that location (#{location}) doesn't seem to exist. Try again?"
                        next
                    end
                    loc = map['results'][0]['geometry']['location']
                    city = map['results'][0]['formatted_address']
                    # grab weather
                    weather_res = HTTParty.get("https://api.darksky.net/forecast/8b4d5ca925446f9db4f7d7d0aac8b40c/#{loc['lat']},#{loc['lng']}")
                    weather = JSON.parse(weather_res.body)
                    # write out the response
                    reply = "Currently, the weather in #{city} is #{weather['currently']['summary'].downcase}, with a temperature of #{weather['currently']['temperature']}°F (feeling like #{weather['currently']['apparentTemperature']}°F). There is a #{weather['currently']['precipProbability'].to_f*100}% chance of rain.<BR><BR>
                    Today, expect #{weather['hourly']['summary'].downcase}<BR>
                    Over the week, expect #{weather['daily']['summary']}<BR><BR>
                    Have a good day!"
                end
            end
            m = {type: 'rich', html: reply}
        end
        messages = [m]
        render json: {
            success: 'success',
            messages: messages
        }
    end
end
