RSpec.describe GemStream::Follower do
  before do
    @version_count = 0
    @synced = false

    GemStream.configure do |c|
      c.on_version = -> (version) { @version_count += 1 }
      c.on_synced = -> () { @synced = true }
    end
  end

  after do
    Timecop.return
  end

  context 'when new results are returned' do
    it 'calls the configured hook for each version' do
      start_time = Time.iso8601('2019-07-11T07:00:01-07:00')
      Timecop.travel start_time

      VCR.use_cassette('single_page') do
        GemStream::Follower.follow_from(start_time)
      end

      expect(@version_count).to eq(24)
    end

    it 'calls the on_synced hook once up-to-date' do
      start_time = Time.iso8601('2019-07-11T07:00:01-07:00')
      Timecop.travel start_time

      VCR.use_cassette('single_page') do
        GemStream::Follower.follow_from(start_time)
      end

      expect(@synced).to eq(true)
    end

    it 'pages through results if necessary' do
      start_time = Time.iso8601('2019-07-11T06:00:01-07:00')
      Timecop.travel start_time

      VCR.use_cassette('multi_page') do
        GemStream::Follower.follow_from(start_time)
      end

      expect(@version_count).to eq(58)
    end
  end
end
