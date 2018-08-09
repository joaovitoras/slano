class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Webhook.new(params).perform
    head :ok
  end
end
