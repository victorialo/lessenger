# Lessenger
Hipmunk weather chatbot

By: Victoria Lo

## Features
* Named greeting with gif
* Fancy images to correlate with the weather
* Will accept any reasonable request with the word `weather` or `weather in`
* Simple summary for the rest of the week as well
* Whatever else you say to it, it will repeat back to you

## To start up server:
* Navigate to /lessenger_api
* `bundle install` (if you haven't already)
* `rails s -p 9000`
* Go to the client and chat away!

## To use (client):
Visit `http://hipmunk.github.io/hipproblems/lessenger/` on your browser.

## Notes
The majority of the relevant code is in `lessenger_api/app/controllers/chat_controller.rb`.