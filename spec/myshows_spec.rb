require 'rspec'
require_relative 'spec_helper'
require_relative '../my_shows'


describe MyShows do

  fixtures_path = Dir.pwd + '/spec/fixtures/files/'

  describe '#top_rated' do
    let(:ms_object) { MyShows.new }

    it 'en_title should be eq Harley Quinn' do
      stub_const('MyShows::BASE_URL', fixtures_path + 'top_rated.htm')
      expect(ms_object.top_rated[:movie_title][:en_title]).to eq('Harley Quinn')
    end
  end

end