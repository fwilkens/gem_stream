require 'spec_helper'

RSpec.describe Follow::Configuration do
  before do
    Follow.configuration = nil
  end

  context 'the on_version hook' do
    it 'can be configured to be a proc' do
      Follow.configure do |c|
        c.on_version = -> (version) { puts version.inspect }
      end

      expect(Follow.configuration.on_version).to be_kind_of(Proc)
    end

    it 'cannot be configured as something other than a proc' do
      expect{
        Follow.configure do |c|
          c.on_version = 'not a proc'
        end
      }.to raise_error(ArgumentError)
    end
  end

  context 'the on_synced hook' do
    it 'can be configured to be a proc' do
      Follow.configure do |c|
        c.on_synced = -> () { puts "synced!" }
      end

      expect(Follow.configuration.on_synced).to be_kind_of(Proc)
    end

    it 'cannot be configured as something other than a proc' do
      expect{
        Follow.configure do |c|
          c.on_synced = 'not a proc'
        end
      }.to raise_error(ArgumentError)
    end
  end

  context 'the api call interval' do
    it 'can be configured as low as Rubygems.org allows' do
      Follow.configure do |c|
        c.api_call_interval = 0.1
      end

      expect(Follow.configuration.api_call_interval).to eq(0.1)
    end

    it 'cannot be configured beyond what Rubygems.org allows' do
      expect{
        Follow.configure do |c|
          c.api_call_interval = 0.05
        end
      }.to raise_error(ArgumentError)
    end

    it 'has a default value when unconfigured' do
      expect(Follow.configuration.api_call_interval).to eq(1.0)
    end
  end
end
