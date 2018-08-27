class Webhook
  attr_accessor :api, :pull_request, :sender
  DEFAULT_REPO_URL = "ssh://git@github.com/redealumni/quero_bolsa"

  def initialize(params)
    payload = JSON.parse(params[:payload] || "{}").with_indifferent_access
    @api = Solano::Api.new
    @pull_request = payload[:pull_request]
    @sender = payload[:sender]
  end

  def perform
    return log_status("Sem PR") unless pull_request.present?
    return log_status("Não é merged") unless merged?
    return log_status("Não é merge na branch default") unless default_branch?
    return log_status("Revert") if revert?

    status = solano_status
    send("notify_#{status}") if status.present?
  end

  private

  def merged?
    pull_request[:merged]
  end

  def default_branch?
    pull_request[:base][:ref] == pull_request[:head][:repo][:default_branch]
  end

  def revert?
    (pull_request[:title] =~ /(R|r)evert/).to_i > 0
  end

  def solano_status
    branch = pull_request[:head][:ref]

    suites = api.user_suites(DEFAULT_REPO_URL, branch)["suites"]

    return :avoid_suite if suites.blank?
    last_session_status(suites)
  end

  def last_session_status(suites)
    suite_id = suites[0]["id"]
    last_session = api.sessions(suite_id, 1)["sessions"].first

    return :avoid_suite if last_session.blank?
    return :session_failed if ['failed', 'error'].include? last_session["status"]
  end

  def notify_avoid_suite
    notify("Eu fiz merge do #{pr_link} sem rodar build no solano :john_armless:")
  end

  def notify_session_failed
    notify("Eu fiz merge do #{pr_link} com build que não passou no solano :smiling_imp:")
  end

  def pr_link
    "<#{pull_request[:html_url]}|PR##{pull_request[:number]}>"
  end

  def notify(message)
    RestClient.post(ENV['SLACK_WEBHOOK_URL'], {
      text: message, icon_url: sender["avatar_url"], username: sender["login"]
    }.to_json)
  end

  def log_status(message)
    Rails.logger.info("Status: #{message}")
  end
end
