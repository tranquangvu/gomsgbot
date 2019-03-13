class WebhookController < ApplicationController
  def verifier
    if params['hub.mode'] == 'subscribe' && params['hub.verify_token'] == ENV['VERIFY_TOKEN']
      render plain: params['hub.challenge'], status: :ok
    else
      head :ok
    end
  end

  def receiver
    MessengerService.new(params[:entry]).reply if params[:object] == 'page'
    render json: nil, status: :ok
  end
end
