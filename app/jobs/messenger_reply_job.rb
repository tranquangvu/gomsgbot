class MessengerReplyJob < ApplicationJob
  include HTTParty
  base_uri 'https://graph.facebook.com/v2.6'
  queue_as :default

  def perform(message_data)
    response = self.class.post("/me/messages", {
      headers: {
        "Content-Type" => "application/json"
      },
      query: {
        access_token: ENV['PAGE_ACCESS_TOKEN']
      },
      body: message_data.to_json
    })
  end
end
