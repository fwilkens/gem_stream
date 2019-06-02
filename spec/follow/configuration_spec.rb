require 'spec_helper'

RSpec.describe Follow::Configuration do
  it 'allows a proc to be specified as the event for a new gem version' do
    Follow.configure do |c|
      c.on_version = -> (version) { puts version.inspect }
    end

    expect(Follow.configuration.on_version).to be_kind_of(Proc)
  end

  it 'allows a proc to be specified as the event when entirely synced' do
    Follow.configure do |c|
      c.on_synced = -> () { puts "synced!" }
    end

    expect(Follow.configuration.on_synced).to be_kind_of(Proc)
  end

  it 'allows an api call interval to be specified' do
    Follow.configure do |c|
      c.api_call_interval = 0.1
    end

    expect(Follow.configuration.api_call_interval).to eq(0.1)
  end
end
