module Solano
  class Api
    PAGE_SIZE = 1

    def initialize
      @client   = Solano::Client.new
      @endpoint = ENV['TDDIUM_API_ENDPOINT']
    end

    def user_suites(repo_url , branch)
      @client.get(url("/suites/user_suites"), {'repo_url' => repo_url, 'branch' => branch})
    end

    def sessions(suite_id , limit = 600)
      @client.get(url("/sessions"), {suite_id: suite_id, limit: limit})
    end

    def test_executions(session_id)
      @client.get(url("/sessions/#{session_id}/test_executions/query"), {})
    end

    def url(path)
      @endpoint + path
    end
  end
end
