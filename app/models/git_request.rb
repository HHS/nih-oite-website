class GitRequest
  attr_reader :params
  def initialize(params)
    @params = params
  end

  def approve_publish?
    params[:labels].first.match?(/pending_publish$/)
  end
end
