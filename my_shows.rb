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

  def top_rated(html)
    movies = {}
    series_list = html.xpath('/html/body/div[1]/div[4]/div/div')[0..1].css('a')
    series_list.each do |movie|
      ru_title = movie.css('.fsHeader').text
      movies[:"#{ru_title}"] = {
          en_title: movie.css('.cFadeLight').text,
          image_link: movie.search('._img').to_s[/(?<=\().+?(?=\))/],
          kp_link: movie['href']
      } end
    movies
  end
end

ms = MyShows.new('https://myshows.me/')
main_html = ms.main_page
puts ms.top_rated(main_html)