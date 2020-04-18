require 'rspec'
require_relative 'spec_helper'
require_relative '../my_shows'


describe MyShows do
  let(:ms_object) { MyShows.new('bad') }

  before(:each) do
    allow(ms_object).to receive(:parse_html).and_return(html_path)
  end

  def html_path
    path = Dir.pwd + '/spec/fixtures/files/main.html'
    Nokogiri::HTML(URI.open(path))
  end

  it 'should return first movie title' do
    expect(ms_object.top_rated[:movie_title][:en_title]).to eq('Harley Quinn')
  end

  it 'should return searched movie title' do
    expect(ms_object.movies_list[:movie_title][:en_title]).to eq('Breaking Bad')
  end

  it 'should count a number of series in the season' do
    expect(ms_object.seasons(187).keys.count).to eq(4)
  end
end