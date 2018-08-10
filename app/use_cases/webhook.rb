class Webhook
  attr_accessor :api, :pull_request, :sender
  DEFAULT_REPO_URL = "ssh://git@github.com/redealumni/quero_bolsa"

  def initialize(params)
    payload = JSON.parse(params[:payload] || "{}").with_indifferent_access
    Rails.logger.info("parametros #{payload}")
    Rails.logger.info(payload[:pull_request])
    @api = Solano::Api.new
    @pull_request = payload[:pull_request]
    @sender = payload[:sender]
  end

  def perform
    return Rails.logger.info("status: sem pr") unless pull_request.present?
    return Rails.logger.info("status: merged") unless merged?
    return Rails.logger.info("status: não é na branch default") unless default_branch?

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
    return :session_failed if last_session["status"] != "passed"
  end

  def notify_avoid_suite
    notify("Eu fiz merge do #{pr_link} sem rodar build no solano :john_armless:")
  end

  def notify_session_failed
    notify("Eu fiz merge do #{pr_link} com build falhando no solano :smiling_imp:")
  end

  def pr_link
    "<#{pull_request[:html_url]}|PR##{pull_request[:number]}>"
  end

  def notify(message)
    RestClient.post(ENV['SLACK_WEBHOOK_URL'], {
      text: message, icon_url: sender["avatar_url"], username: sender["login"]
    }.to_json)
  end
end
