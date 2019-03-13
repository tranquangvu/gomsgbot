module Conversationable

  def user
    @user ||= User.find_by(messenger_id: sender_id)
  end

  def conversation
    @conversation ||= user.conversation
  end

  def current_question
    @current_question ||= Question.all.find { |q| q[:id] == conversation.current_question_id }
  end

  def next_question
    return first_question unless current_question
    @next_question ||= Question.all.find { |q| q[:id] == current_question[:id] + 1 }
  end

  def first_question
    @first_question ||= Question.all.first
  end

  def last_question
    @last_question || Question.all.last
  end

end

module MessageReceiverHandler

  def received_message(event)
    begin
      type = (event[:message].stringify_keys.keys & ['text', 'quick_reply', 'attachments']).first
      send("#{type}_message_handler", event[:message][type])
    rescue Exception => e
      Rails.logger.error "[ERROR]: #{e}"
    end
  end

  def quick_reply_message_handler(quick_reply)
    begin
      postback_handler(quick_reply[:payload])
    rescue Exception => e
      Rails.logger.error "[ERROR]: #{e}"
    end
  end

  def text_message_handler(text)
    return start if text[/hi|hello/]
    return bye if text[/bye/]
    return find_room_with_question(current_question, next_question) if text == 'find a room'
    unknow
  end

  def received_postback(event)
    begin
      postback_handler(event[:postback][:payload])
    rescue Exception => e
      Rails.logger.error "[ERROR]: #{e}"
    end
  end

  def postback_handler(payload)
    case payload
    when 'GET_STARTED'
      get_started
    when 'START_OVER'
      start_over
    when 'INTRODUCE_MYSELF'
      introduce_myself
    when 'FIND_ROOM'
      find_room_with_question(current_question, first_question)
    else
      Question.action_payloads.include?(payload) ? find_room_with_question(current_question, next_question) : unknow
    end
  end

  def received_account_linking(event); end

  def received_optin(event); end

  def received_delivery(event); end

  def received_surge_confirmation(event); end

end

module MessageReplyHandler

  def send_message(message)
    MessengerReplyJob.perform_now(Messenger::SendApi.typing_on(recipient_id: sender_id))
    MessengerReplyJob.perform_now(Messenger::SendApi.message(recipient_id: sender_id, message: message))
    MessengerReplyJob.perform_now(Messenger::SendApi.typing_off(recipient_id: sender_id))
  end

  def bye
    send_message MessengerReplyTemplate.bye
  end

  def start
    send_message MessengerReplyTemplate.welcome
  end

  def start_over
    conversation.update(current_question_id: nil)
    start
  end

  def get_started
    @user = User.find_or_create_by(messenger_id: sender_id)
    @user.create_conversation unless @user.conversation
    start
  end

  def introduce_myself
    send_message MessengerReplyTemplate.introduce_myself
  end

  def find_room_with_question(current_question, next_question)
    if current_question && current_question[:id] == last_question[:id]
      send_message MessengerReplyTemplate.link_to_result
    else
      conversation.update(current_question_id: next_question[:id])
      send_message MessengerReplyTemplate.question(next_question)
    end
  end

  def unknow
    send_message MessengerReplyTemplate.unknow
  end

end

class MessengerService
  include Conversationable
  include MessageReceiverHandler
  include MessageReplyHandler

  attr_accessor :entry, :sender_id

  VALID_MESSAGING_EVENTS = ['optin', 'message', 'delivery', 'postback', 'account_linking', 'surge_confirmation']

  def initialize(entry)
    @entry = entry
    @sender_id = entry.first[:messaging].first[:sender][:id]
  end

  def reply
    entry.each do |page_entry|
      page_entry[:messaging].each do |messaging_event|
        begin
          send("received_#{(messaging_event.stringify_keys.keys & VALID_MESSAGING_EVENTS).join}", messaging_event)
        rescue Exception => e
          Rails.logger.error "[ERROR]: Webhook received unknown messaging envent: #{e}"
        end
      end
    end
  end

end
