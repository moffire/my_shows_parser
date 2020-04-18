require 'rspec'
require_relative 'spec_helper'
require_relative '../my_shows'


describe MyShows do
  fixtures_path = Dir.pwd + '/spec/fixtures/files/main.html'

  let(:ms_object) { MyShows.new('bad') }

  describe '#top_rated' do
    it 'should be eq Harley Quinn' do
      stub_const('MyShows::BASE_URL', fixtures_path)
      expect(ms_object.top_rated[:movie_title][:en_title]).to eq('Harley Quinn')
    end
  end

  describe '#movies_list' do
    it 'should be eq Breaking Bad' do
      allow(ms_object).to receive(:parse_html).and_return(Nokogiri::HTML(URI.open(fixtures_path)))
      expect(ms_object.movies_list[:movie_title][:en_title]).to eq('Breaking Bad')
    end
  end

end