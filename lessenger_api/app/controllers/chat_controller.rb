class ChatController < ApplicationController
    # used to get images for the icons passed in by darksky
    # @param icon [String] the icon name passed in from darksky. Must be one of the accepted icons from the API
    # @output [String] returns a url for the icon
    def icon(icon)
        weather = {
            'clear-day' => 'https://image.flaticon.com/icons/svg/136/136723.svg',
            'clear-night' => 'https://image.flaticon.com/icons/svg/414/414942.svg',
            'rain' => 'https://image.flaticon.com/icons/svg/578/578339.svg',
            'snow' => 'https://image.flaticon.com/icons/svg/275/275722.svg',
            'sleet' => 'https://image.flaticon.com/icons/svg/136/136711.svg',
            'wind' => 'https://image.flaticon.com/icons/svg/136/136712.svg',
            'fog' => 'https://image.flaticon.com/icons/svg/414/414927.svg',
            'cloudy'=> 'https://image.flaticon.com/icons/svg/136/136701.svg',
            'partly-cloudy-day' => 'https://image.flaticon.com/icons/svg/136/136716.svg',
            'partly-cloudy-night' => 'https://image.flaticon.com/icons/svg/136/136719.svg',
            'hail' => 'https://image.flaticon.com/icons/svg/290/290428.svg',
            'thunderstorm' => 'https://image.flaticon.com/icons/svg/136/136729.svg',
            'tornado' => 'https://image.flaticon.com/icons/svg/284/284431.svg'
        }
        return weather[icon]
    end

    # the main function to handle input
    # params are already passed in automatically
    # @output [Hash] the reply, following the lessenger API
    def messages()
        queries = [
            "what's the weather in",
            "weather in",
            "weather"
        ]
        user = params[:user_id]
        messages = []
        if params[:name]
            # @users[user] = params[:name]
            messages << {type: 'text', text: "Hello, #{params[:name]}!"}
            messages << {type: 'rich', html: "<img src='https://m.popkey.co/b02639/pDgKO.gif'>"}
            puts "#{messages}".green
        end
        if params[:text]
            msg = params[:text]
            reply = "<i>#{msg}</i>" # parrot back what you say unless you're asking about weather
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
                    messages << {
                        type: 'rich',
                        html: "<iframe src='#{icon(weather['currently']['icon'])}'></iframe>"
                    }
                    reply = "Currently, the weather in <b>#{city}</b> is <i>#{weather['currently']['summary'].downcase}</i>, with a temperature of #{weather['currently']['temperature']}°F (feeling like #{weather['currently']['apparentTemperature']}°F). There is a #{weather['currently']['precipProbability'].to_f*100}% chance of rain.<BR><BR>
                    Today, expect <i>#{weather['hourly']['summary'].downcase}</i><BR>
                    Over the week, expect <i>#{weather['daily']['summary'].camelize(:lower)}</i><BR><BR>
                    Have a good day!"
                end
            end
            messages << {type: 'rich', html: reply}
        end
        render json: {
            success: 'success',
            messages: messages
        }
    end
end
