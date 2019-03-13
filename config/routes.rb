Rails.application.routes.draw do
  get '/webhook',  to: 'webhook#verifier'
  post '/webhook', to: 'webhook#receiver'
end
