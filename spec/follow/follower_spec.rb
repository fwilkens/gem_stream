RSpec.describe Follow::Follower do
  context 'when new results are returned' do
    it 'calls the configured callback for each version'
    it 'pages through results if necessary'
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
