# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'cgi/util'

class MyShows

  def get_html(query = nil)
    main_page_url = 'https://myshows.me'
    if query.nil?
      Nokogiri::HTML(open(main_page_url))
    else
      encoded_query = CGI.escape(query)
      Nokogiri::HTML(open(main_page_url + "/search/?q=#{encoded_query}"))
    end
  end

  def top_rated(html)
    movies = {}
    series_list = html.xpath('/html/body/div[1]/div[4]/div/div')[0..1].css('a')
    series_list.each do |movie|
      ru_title = movie.css('.fsHeader').text
      movies[:"#{ru_title}"] = {
          en_title: movie.css('.cFadeLight').text,
          image_link: movie.search('._img').to_s[/(?<=\().+?(?=\))/],
          description: movie['href']
      }
    end
    movies
  end
end

ms = MyShows.new
puts ms.get_html('во все')