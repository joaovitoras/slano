class SessionStatusByDate
  attr_accessor :api, :branch, :repo_url

  STATUSES = ["passed", "failed", "setupfailed"]
  DEFAULT_REPO_URL = "ssh://git@github.com/redealumni/quero_bolsa"
  DEFAULT_BRANCH = "next-release"

  def initialize(repo_url, branch)
    @api = Solano::Api.new
    @repo_url = repo_url || DEFAULT_REPO_URL
    @branch = branch || DEFAULT_BRANCH
  end

  def perform
    suites = api.user_suites(self.repo_url, self.branch)
    suite_id = suites["suites"][0]["id"]
    sessions = api.sessions(suite_id)["sessions"]

    to_chart_js_data(sessions)
  end

  private

  def to_chart_js_data(sessions)
    sessions = filter_sessions(sessions)
    sessions = select_values(sessions)
    sessions = group_by_date(sessions)
    sessions = count_by_status(sessions)
    sessions = sort_by_date(sessions)
    sessions = chart_js_data(sessions)
  end

  def filter_sessions(sessions)
    last_month = DateTime.current - 1.month

    sessions.select do |session|
      DateTime.parse(session["start_time"]) >= last_month &&
      STATUSES.include?(session["status"])
    end
  end

  def select_values(sessions)
    sessions.map do |session|
      {
        start_time: Date.parse(session["start_time"]),
        status: session["status"]
      }
    end
  end

  def group_by_date(sessions)
    groupped_values = {}

    sessions.each do |session|
      groupped_values[session[:start_time]] ||= []
      groupped_values[session[:start_time]] << session[:status]
    end

    groupped_values
  end

  def count_by_status(sessions)
     sessions.map do |k, _v|
      {
        k.to_s =>
          STATUSES.map do |status|
            sessions[k].count(status)
          end
      }
    end.inject(:merge)
  end

  def sort_by_date(sessions)
    sessions.sort.to_h
  end

  def chart_js_data(sessions)
    {
      labels: sessions.keys,
      datasets: [
        {
          label: 'passed',
          borderColor: "rgb(164, 198, 26)",
          backgroundColor: "transparent",
          data: sessions.map {|_k, v| v[0]},
        },
        {
          label: 'failed',
          borderColor: "rgb(255, 99, 132)",
          backgroundColor: "transparent",
          data: sessions.map {|_k, v| v[1]},
        },
        {
          label: 'setupfailed',
          borderColor: "rgb(255, 205, 86)",
          backgroundColor: "transparent",
          data: sessions.map {|_k, v| v[2]},
        }
      ]
    }
  end
end
