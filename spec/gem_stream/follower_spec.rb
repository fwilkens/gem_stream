RSpec.describe GemStream::Follower do
  class Handler
    class << self
      attr_accessor :synced
      attr_accessor :version_count
    end
  end

  FakeResponse = Struct.new(:code)

  before do
    Handler.synced = false
    Handler.version_count = 0

    GemStream.configure do |c|
      c.on_version = -> (version) { Handler.version_count += 1 }
      c.on_synced = -> () { Handler.synced = true }
    end
  end

  after do
    Timecop.return
  end

  context 'when new results are returned' do
    it 'calls the configured hook for each version, then synced' do
      start_time = Time.iso8601('2019-07-11T07:00:01-07:00')
      Timecop.travel start_time

      VCR.use_cassette('single_page') do
        GemStream::Follower.follow_from(start_time)
      end

      expect(Handler.version_count).to eq(24)
      expect(Handler.synced).to eq(true)
    end

    it 'pages through results if necessary' do
      Handler.synced = false
      Handler.version_count = 0

      start_time = Time.iso8601('2019-07-11T06:00:01-07:00')
      Timecop.travel start_time

      VCR.use_cassette('multi_page') do
        GemStream::Follower.follow_from(start_time)
      end

      expect(Handler.version_count).to eq(58)
      expect(Handler.synced).to eq(true)
    end
  end

  context 'when an error is encountered in the Rubygems api' do
    before do
      allow(Net::HTTP).to receive(:get_response).and_return(FakeResponse.new('500'))
    end

    it 'raises an api error' do
      start_time = Time.iso8601('2019-07-11T07:00:01-07:00')
      Timecop.travel start_time
      expect{GemStream::Follower.follow_from(start_time)}.to raise_error(GemStream::ApiError)
    end

    it 'saves the start_time of the time frame it was in' do
      start_time = Time.iso8601('2019-07-11T07:00:01-07:00')
      Timecop.travel start_time
      follower = GemStream::Follower.new(start_time)
      begin
        follower.follow
      rescue GemStream::ApiError
        expect(follower.synced_up_to_time).to eq(start_time)
      end
    end

  end
end
