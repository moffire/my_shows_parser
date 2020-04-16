require 'logger'
require 'nokogiri'
require 'open-uri'
require 'cgi/util'

module Logging
  class << self

    def logger
      @logger ||= Logger.new(STDOUT)
    end

  end

  def logger
    Logging.logger
  end

end

class MyShows
  include Logging

  BASE_URL = 'https://myshows.me'.freeze

  attr_accessor :query

  def initialize(query = nil)
    @query = query
  end

  def parse_html(url = '')
    Nokogiri::HTML(URI.open(BASE_URL + url))
  rescue StandardError
    logger.error 'Error 404. Page not found.'
    nil
  end

  # hash of searched series or top rated movies if no query
  def movies_list
    return top_rated if query.nil?

    content = {}
    encoded_query = CGI.escape(@query)
    html = parse_html("/search/?q=#{encoded_query}")
    all_series = html.css('table.catalogTable').search('tr')
    all_series[1...-1].each do |movie|
      ru_title = movie.css('td > a')[0].text
      content[:"#{ru_title}"] = {
        en_title: movie.css('td > .catalogTableSubHeader')[0].text,
        link: movie.css('td > a')[0]['href'],
        movie_id: movie.css('td > a')[0]['href'][/\d+/],
        watchers: movie.css('td')[2].text,
        seasons: movie.css('td')[4].text,
        year: movie.css('td')[5].text
      }
    end
    content
  rescue NoMethodError
    logger.error "Can't apply selectors in '#{__method__}' method. DOM structure apparently was changed."
  end

  def seasons(movie_id)
    seasons_list = {}

    html = parse_html("/view/#{movie_id}/")
    # list of all seasons
    html.css('.col8 > form > .row[itemprop="season"]').reverse_each do |season|
      season_number = season.css('.flat > a')[0].text
      special_series_counter = 1

      season.css('.widerCont > .infoList > li').reverse_each do |series|
        series_number = series.css('._numb').text
        if series_number.empty?
          series_number = "#{special_series_counter} спец"
          special_series_counter += 1
        end

        seasons_list["#{season_number}, #{series_number} серия"] = {
          series_name: series.css('._name').text,
          series_date: series.css('._date').text
        }
      end
    end
    seasons_list
  rescue NoMethodError
    logger.error "Can't apply selectors in '#{__method__}' method. DOM structure apparently was changed."
  end

  # top rated movies from main page
  def top_rated
    top_rated_list = {}
    html = parse_html
    # list of all movies
    # html.xpath('/html/body/div[1]/div[4]/div/div').[](0..1).css('a').each do |movie|
    html.css('.landing > .container > .row > .col3 > a').each do |movie|
      ru_title = movie.css('.fsHeader').text
      top_rated_list[:"#{ru_title}"] = {
        en_title: movie.css('.cFadeLight').text,
        image_link: movie.search('._img').to_s[/(?<=\().+?(?=\))/],
        description: movie['href']
      }
    end
    top_rated_list
  rescue NoMethodError
    logger.error "Can't apply selectors in '#{__method__}' method. DOM structure apparently was changed."
  end

end
puts MyShows.new.top_rated