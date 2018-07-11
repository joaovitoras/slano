require 'test_helper'

class StatusHistoryControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get status_history_index_url
    assert_response :success
  end

end
