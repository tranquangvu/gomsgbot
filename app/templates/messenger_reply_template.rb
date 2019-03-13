class MessengerReplyTemplate
  class << self

    def introduce_myself
      {
        text: 'I’m Cocoon(bot)! I can find your perfect room in under a minute. Call me by commands: `start over`, `hi`, `find a room`, `bye`',
        quick_replies: [
          Messenger::SendApi.quick_reply(title: 'Get started', payload: 'START_OVER'),
          Messenger::SendApi.quick_reply(title: 'Find a room', payload: 'FIND_ROOM')
        ]
      }
    end

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
      { text: 'Thanks for using our service. See you later!' }
    end

    def question(question)
      {
        text: question[:content],
        quick_replies: question[:options].map { |option| Messenger::SendApi.quick_reply(title: option[:content], payload: option[:payload]) }
      }
    end

    def link_to_result
      {
        attachment: Messenger::SendApi.button_template(
          text: 'Your room request was sent. Please check it on below page',
          buttons: [
            Messenger::SendApi.button(type: 'web_url', title: 'Go', url: ENV['HOST'])
          ]
        )
      }
    end

    def unknow
      { text: "Sorry! I don't know what you mean. Call me by commands: `start over`, `hi`, `find a room`, `bye`" }
    end

  end
end
