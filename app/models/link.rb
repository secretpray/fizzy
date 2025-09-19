class Link
  UNFURLERS = [
    FizzyUnfurler,
    BasecampUnfurler
  ]

  attr_reader :uri, :metadata

  def self.unfurl(url, **options)
    new(url).unfurl(**options)
  end

  def initialize(url)
    @uri = URI.parse(url)
    @metadata = nil
  end

  def unfurl(**options)
    options[:user] = Current.user unless options.key?(:user)
    unfurler = UNFURLERS.find { |unfurler| unfurler.unfurls?(uri) }

    if unfurler
      @metadata = unfurler.new(uri, **options).unfurl
    end

    self
  end
end
