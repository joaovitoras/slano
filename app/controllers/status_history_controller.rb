class StatusHistoryController < ApplicationController
  def data
    result = SessionStatusByDate.new(params[:repo_url], params[:branch]).perform
    render json: result
  end
end
