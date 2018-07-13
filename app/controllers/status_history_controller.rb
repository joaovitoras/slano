class StatusHistoryController < ApplicationController
  def sessions_status_by_date
    result = SessionStatusByDate.new(params[:repo_url], params[:branch]).perform
    render json: result
  end

  def broken_tests
    result = BrokenTests.new(params[:repo_url], params[:branch]).perform
    render json: result
  end
end
