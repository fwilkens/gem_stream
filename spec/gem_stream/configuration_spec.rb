require 'spec_helper'

RSpec.describe GemStream::Configuration do
  before do
    GemStream.configuration = nil
  end

  context 'the on_version hook' do
    it 'can be configured to be a proc' do
      GemStream.configure do |c|
        c.on_version = -> (version) { puts version.inspect }
      end

      expect(GemStream.configuration.on_version).to be_kind_of(Proc)
    end

    it 'cannot be configured as something other than a proc' do
      expect{
        GemStream.configure do |c|
          c.on_version = 'not a proc'
        end
      }.to raise_error(ArgumentError)
    end
  end

  context 'the on_synced hook' do
    it 'can be configured to be a proc' do
      GemStream.configure do |c|
        c.on_synced = -> () { puts "synced!" }
      end

      expect(GemStream.configuration.on_synced).to be_kind_of(Proc)
    end

    it 'cannot be configured as something other than a proc' do
      expect{
        GemStream.configure do |c|
          c.on_synced = 'not a proc'
        end
      }.to raise_error(ArgumentError)
    end
  end

  context 'the api call interval' do
    it 'can be configured as low as Rubygems.org allows' do
      GemStream.configure do |c|
        c.api_call_interval = 0.1
      end

      expect(GemStream.configuration.api_call_interval).to eq(0.1)
    end

    it 'cannot be configured beyond what Rubygems.org allows' do
      expect{
        GemStream.configure do |c|
          c.api_call_interval = 0.05
        end
      }.to raise_error(ArgumentError)
    end

    it 'has a default value when unconfigured' do
      expect(GemStream.configuration.api_call_interval).to eq(1.0)
    end
  end
end
