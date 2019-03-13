class MessengerReplyTemplate
  class << self
    def welcome
      {
        text: 'Hey, I’m Cocoon(bot)! I can find your perfect room in under a minute',
        quick_replies: [
          Messenger::SendApi.quick_reply(title: 'Find a room', payload: 'FIND_ROOM'),
          Messenger::SendApi.quick_reply(title: 'Tell me about Cocoon', payload: 'INTRODUCE_MYSELF')
        ]
      }
    end

    def bye
      { text: 'Thanks for using service. See you later!' }
    end
  end
end
