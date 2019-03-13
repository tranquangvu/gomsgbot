class MessengerReceiverService
  attr_accessor :entry, :sender_id

  VALID_MESSAGE_TYPE     = ['text', 'quick_reply', 'attachments']
  VALID_MESSAGING_EVENTS = ['optin', 'message', 'delivery', 'postback', 'account_linking', 'surge_confirmation']
  ANWSER_PAYLOADS        = ['CONFIRM_RIDE', 'CANCEL_RIDE', 'DISPLAY_BOOKMARK_TO_SELECT', 'SELECT_PRODUCT', 'SELECT_PAYMENT_METHOD', 'SELECT_BOOKMARK']

  def initialize(entry)
    @entry     = entry
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

  private

  def send_message(message)
    MessengerReplyJob.perform_now(Messenger::SendApi.message(recipient_id: sender_id, message: message))
  end

  def received_message(event)
    begin
      type = (event[:message].stringify_keys.keys & VALID_MESSAGE_TYPE).first
      send("#{type}_message_handler", event[:message][type])
    rescue Exception => e
      Rails.logger.error "[ERROR]: #{e}"
    end
  end

  def quick_reply_message_handler(quick_reply)
    payload = quick_reply[:payload]

    begin
      destroy_undone_progress unless anwser_payload?(payload)
      send payload.downcase
    rescue Exception => e
      Rails.logger.error "[ERROR]: #{e}"
    end
  end

  def text_message_handler(text)
    case text
    when 'hi', 'hello'
      start
    when 'bye'
      bye
    else
      send_message MessengerReplyTemplate.unknow
    end
  end

  def bye
    send_message MessengerReplyTemplate.bye
  end

  def start
    send_message MessengerReplyTemplate.welcome
  end

  def get_started
    @user = User.create(messenger_id: sender_id)
    @user.create_conversation

    send_message MessengerReplyTemplate.welcome
  end

  def attachments_message_handler(attachments); end

  def received_postback(event); end

  def received_account_linking(event); end

  def received_optin(event); end

  def received_delivery(event); end

  def received_surge_confirmation(event); end
end
