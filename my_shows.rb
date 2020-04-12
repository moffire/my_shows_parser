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

  # parse list of top rated movies from main page
  def top_rated(html)
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

  # parse list of searched series
  def series_list(html)
    series = {}
    all_series = html.css('table.catalogTable').search('tr')
    all_series[1...-1].each do |movie|
      ru_title = movie.css('td > a')[0].text
      series[:"#{ru_title}"] = {
        en_title: movie.css('td > .catalogTableSubHeader')[0].text,
        link: movie.css('td > a')[0]['href'],
        watchers: movie.css('td')[2].text,
        seasons: movie.css('td')[4].text,
        year: movie.css('td')[5].text
      }
    end
    series
  end

end

ms = MyShows.new
puts ms.series_list(ms.get_html('главный'))