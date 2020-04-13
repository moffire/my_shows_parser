require 'nokogiri'
require 'open-uri'
require 'cgi/util'

class MyShows

  MAIN_PAGE_URL = 'https://myshows.me'

  attr_accessor :query

  def initialize(query = nil)
    @query = query
  end

  # top rated movies from main page
  def top_rated
    html = Nokogiri::HTML(URI.open(MAIN_PAGE_URL))
    top_rated_list = {}
    movies_list = html.xpath('/html/body/div[1]/div[4]/div/div')[0..1].css('a')
    movies_list.each do |movie|
      ru_title = movie.css('.fsHeader').text
      top_rated_list[:"#{ru_title}"] = {
        en_title: movie.css('.cFadeLight').text,
        image_link: movie.search('._img').to_s[/(?<=\().+?(?=\))/],
        description: movie['href']
      }
    end
    top_rated_list
  end

  # hash of searched series or top rated movies if no query
  def movies_list
    if @query.nil?
      top_rated
    else
      content = {}
      encoded_query = CGI.escape(@query)
      html = Nokogiri::HTML(URI.open(MAIN_PAGE_URL + "/search/?q=#{encoded_query}"))
      all_series = html.css('table.catalogTable').search('tr')
      all_series[1...-1].each do |movie|
        ru_title = movie.css('td > a')[0].text
        content[:"#{ru_title}"] = {
          en_title: movie.css('td > .catalogTableSubHeader')[0].text,
          link: movie.css('td > a')[0]['href'],
          watchers: movie.css('td')[2].text,
          seasons: movie.css('td')[4].text,
          year: movie.css('td')[5].text
        }
      end
      content
    end
  end

end

ms = MyShows.new
puts ms.movies_list.keys