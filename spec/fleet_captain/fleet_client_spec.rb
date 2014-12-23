require 'spec_helper'

describe FleetCaptain::FleetClient do
  #include_context 'ssh connection established'
  
  let(:fleet_client) {
    FleetCaptain::FleetClient.new('ec2-54-146-31-143.compute-1.amazonaws.com', key_file: '~/.ssh/bork-knife-ec2.pem')
  }

  let(:expected) {
    {"action"=>"get", 
     "node"=>{"key"=>"/_coreos.com/fleet/unit", 
              "dir"=>true, 
              "nodes"=>[
                {"key"=>"/_coreos.com/fleet/unit/e55c0aeb44ba0b68004ceb8a200e685194448b45",
                 "value"=>"{\"Raw\":\"[Unit]\\nDescription=Hello World\\n\\n[Service]\\nExecStart=/bin/bash -c \\\"while true; do echo \\\\\\\"Hello, world\\\\\\\"; sleep 1; done\\\"\\n\"}",
                 "modifiedIndex"=>633, 
                 "createdIndex"=>633}], 
              "modifiedIndex"=>633, 
              "createdIndex"=>633}}
  }


  it 'connects to the fleet actual via ssh tunnel', :vcr do
    expect(fleet_client.list).to eq expected
  end

  it 'raises a connection error if the ssh tunnel cannot be established' do
    allow(fleet_client).to receive(:establish_ssh_tunnel!) do
      raise 'fatal'
    end

    expect { fleet_client.list }.to raise_error FleetCaptain::FleetClient::ConnectionError
  end

  describe 'connecting to the fleet', :live do
    it 'can retrieve a list of machines' do
      require 'pry'; binding.pry
      expect(fleet_client.machines.length).to be 3
    end
  end
end
