class ChatController < ApplicationController
    # the query set to check text input with
    $QUERIES = [
        "what's the weather tomorrow in",
        "weather tomorrow in",
        "weather tomorrow",
        "what's the weather in",
        "weather in",
        "weather"
    ]

    # the URL of icons used with the Dark Sky api
    # Icon attribution: https://www.flaticon.com/authors/smashicons & https://www.flaticon.com/authors/freepik
    $WEATHER = {
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

    # used to get the coordinates and name of a location passed in using the Google Maps API
    # called from messages
    # @param location [String] the name of the location the user asked for
    # @output [Hash] a hash with keys of coords and address with the respective information. They will be empty if the location doesn't exist.
    def loc_json(location)
        map_res = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=AIzaSyD7W7v5psM8TDJwUV2WxsPkoYRtByh07Y0")
        if map_res['results'].empty?
            return {coords: {}, address: ""}
        else
            map = JSON.parse(map_res.body)
            return {coords: map['results'][0]['geometry']['location'], address: map['results'][0]['formatted_address']}
        end
    end

    # used to get the weather from Dark Sky
    # called from messages
    # @param loc [Hash] a hash from the Google Maps API with the location data
    # @output weather [Hash] a hash from Dark Sky with the weather data
    def weather_json(loc)
        weather_res = HTTParty.get("https://api.darksky.net/forecast/8b4d5ca925446f9db4f7d7d0aac8b40c/#{loc['lat']},#{loc['lng']}")
        weather = JSON.parse(weather_res.body)
        return weather
    end

    # used to get images for the icons passed in by Dark Sky
    # called from messages
    # @param icon [String] the icon name passed in from darksky. Must be one of the accepted icons from the API
    # @output [String] returns a url for the icon
    def icon(icon)
        return $WEATHER[icon]
    end

    # generate actual response to speaker
    # @param address [String] location of the weather
    # @param weather [Hash] Hash table of parsed JSON of information
    # @param tomorrow [Boolean] whether you want the current weather or the weather tomorrow
    def weather_response(address, weather, tomorrow=false)
        if tomorrow
            data = weather['daily']['data'][1]
            return "Tomorrow, the weather in <b>#{address}</b> is <i>#{data['summary'].downcase}</i>, with a temperature low of #{data['temperatureMin']}°F (feeling like #{data['apparentTemperatureMin']}°F) and a temperature high of #{data['temperatureMax']}°F (feeling like #{data['apparentTemperatureMax']}°F). There is a #{data['precipProbability'].to_f*100}% chance of rain.<BR><BR>
            Have a good day!"
        else
            return "Currently, the weather in <b>#{address}</b> is <i>#{weather['currently']['summary'].downcase}</i>, with a temperature of #{weather['currently']['temperature']}°F (feeling like #{weather['currently']['apparentTemperature']}°F). There is a #{weather['currently']['precipProbability'].to_f*100}% chance of rain.<BR><BR>
            Today, expect <i>#{weather['hourly']['summary'].downcase}</i><BR>
            Over the week, expect <i>#{weather['daily']['summary'].camelize(:lower)}</i><BR><BR>
            Have a good day!"
        end
    end

    # the main function to handle input
    # params are already passed in automatically
    # @output [Hash] the reply, following the lessenger API
    def messages()
        user = params[:user_id]
        messages = []
        if params[:name]
            messages << {type: 'text', text: "Hello, #{params[:name]}!"}
            messages << {type: 'rich', html: "<img src='https://m.popkey.co/b02639/pDgKO.gif'>"}
        end
        if params[:text]
            msg = params[:text]
            location = ""
            reply = ""
            $QUERIES.each_with_index do |q, ind|
                tomorrow = q.include?('tomorrow')
                next unless location == ""
                if msg.include?(q)
                    parse = msg.split(q).each{|phrase| phrase.strip}
                    location = parse[-1]
                    # grab coordinates
                    coords = loc_json(location)
                    if coords[:coords].empty?
                        reply = "Sorry, that location (#{location}) doesn't seem to exist. Try again?"
                        messages << {type: 'rich', html: reply}
                        next
                    else
                        loc = coords[:coords]
                        address = coords[:address]
                    end
                    # grab weather
                    weather = weather_json(loc)
                    # write out the response
                    messages << {
                        type: 'rich',
                        html: "<iframe src='#{icon(weather['currently']['icon'])}'></iframe>"
                    }
                    reply = weather_response(address, weather, tomorrow)
                    messages << {type: 'rich', html: reply}
                end
            end
            if reply.empty? # parrot back what you say unless you're asking about weather
                reply = "<i>#{msg}</i>"
                messages << {type: 'rich', html: reply}
            end
        end
        render json: {
            success: 'success',
            messages: messages
        }
    end
end
