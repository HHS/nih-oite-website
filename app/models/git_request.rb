class GitRequest
  attr_reader :params
  def initialize(params)
    @params = params
  end

  def approve_publish?
    params[:labels].first.match?(/pending_publish$/)
  end

  def events_tree?
    params[:tree].any? { |tree| tree[:path].starts_with?("_events/") }
  end
end
