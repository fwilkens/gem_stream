RSpec.describe Follow::Follower do
  before do
    @version_count = 0
    @synced = false

    Follow.configure do |c|
      c.on_version = -> (version) { @version_count += 1 }
      c.on_synced = -> () { @synced = true }
    end
  end

  after do
    Timecop.return
  end

  context 'when new results are returned' do
    it 'calls the configured callback for each version' do
      start_time = Time.iso8601('2019-07-11T07:00:01-07:00')
      Timecop.travel start_time

      VCR.use_cassette('single_page') do
        Follow::Follower.follow_from(start_time)
        expect(@version_count).to eq(24)
      end
    end

    it 'pages through results if necessary' do
      start_time = Time.iso8601('2019-07-11T06:00:01-07:00')
      Timecop.travel start_time

      VCR.use_cassette('multi_page') do
        Follow::Follower.follow_from(start_time)
        expect(@version_count).to eq(58)
        puts @version_count
      end
    end
  end

  context 'when no results are returned' do
    context 'when the current time is approximately the same as the time we are syncing from' do
      it 'calls the configured callback for sync completion'
    end

    context 'when the current time is ahead of time we are syncing from' do
      it 'increments the time period and continues following'
    end
  end
end
