require 'nokogiri'
require 'open-uri'

class MyShows
  attr_accessor :url

  def initialize(url)
    @url = url
  end

  def main_page
    Nokogiri::HTML(open(self.url))
  end

end
