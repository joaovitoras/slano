class SessionTimeByDate
  attr_accessor :api, :branch, :repo_url

  DEFAULT_REPO_URL = 'ssh://git@github.com/redealumni/quero_bolsa'.freeze
  DEFAULT_BRANCH = 'next-release'.freeze

  def initialize(repo_url, branch)
    @api = Solano::Api.new
    @repo_url = repo_url || DEFAULT_REPO_URL
    @branch = branch || DEFAULT_BRANCH
  end

  def perform
    suites = api.user_suites(repo_url, branch)
    suite_id = suites['suites'][0]['id']
    sessions = api.sessions(suite_id)['sessions']

    to_chart_js_data(sessions)
  end

  private

  def to_chart_js_data(sessions)
    sessions = filter_sessions(sessions)
    sessions = select_values(sessions)
    sessions = group_by_date(sessions)
    sessions = avg_by_duration(sessions)
    sessions = sort_by_date(sessions)
    chart_js_data(sessions)
  end

  def filter_sessions(sessions)
    last_month = DateTime.current - 1.month

    sessions.select do |session|
      DateTime.parse(session['start_time']) >=
        last_month &&
        session['status'] == 'passed'
    end
  end

  def select_values(sessions)
    sessions.map do |session|
      {
        start_time: Date.parse(session['start_time']),
        duration: session['duration'] / 60
      }
    end
  end

  def group_by_date(sessions)
    groupped_values = {}

    sessions.each do |session|
      groupped_values[session[:start_time]] ||= []
      groupped_values[session[:start_time]] << session[:duration]
    end

    groupped_values
  end

  def avg_by_duration(sessions)
    sessions.map do |k, v|
      {
        k.to_s => (v.inject { |sum, el| sum + el }.to_f / v.size).round(2)
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
          label: 'duration avg by date',
          borderColor: 'rgb(3, 169, 244)',
          backgroundColor: 'rgba(3, 169, 244, 0.5)',
          data: sessions.values
        }
      ]
    }
  end
end
