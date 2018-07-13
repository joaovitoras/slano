class BrokenTests
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
    last_session = api.sessions(suite_id, 10)["sessions"].first
    tests = api.test_executions(last_session["id"])["session"]["tests"]

    find_broken_tests(tests)
  end

  private

  def find_broken_tests(tests)
    tests = filter_broken_tests(tests)
    get_test_names(tests)
  end

  def filter_broken_tests(tests)
    tests.select {|test| test["status"] == "failed"}
  end

  def get_test_names(tests)
    tests.map {|test| test["test_name"]}
  end
end
