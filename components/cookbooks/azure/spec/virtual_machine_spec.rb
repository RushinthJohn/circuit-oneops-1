require 'json'
require 'fog/azurerm'
require 'chef'
require 'simplecov'
require File.expand_path('../../../azure_base/libraries/logger.rb', __FILE__)
SimpleCov.start

require File.expand_path('../../libraries/virtual_machine', __FILE__)

describe AzureCompute::VirtualMachine do
  before :each do
    credentials = {
      tenant_id: '<TENANT_ID>',
      client_secret: '<CLIENT_SECRET>',
      client_id: '<CLIENT_ID>',
      subscription_id: '<SUBSCRIPTION>'
    }
    @virtual_machine = AzureCompute::VirtualMachine.new(credentials)
    @server = Fog::Compute::AzureRM::Server.new(
      name: 'fog-test-server',
      location: 'West US',
      resource_group: 'fog-test-rg',
      vm_size: 'Basic_A0',
      storage_account_name: 'shaffanstrg',
      username: 'shaffan',
      password: 'Confiz=123',
      disable_password_authentication: false,
      network_interface_card_id: '/subscriptions/########-####-####-####-############/resourceGroups/shaffanRG/providers/Microsoft.Network/networkInterfaces/testNIC',
      publisher: 'Canonical',
      offer: 'UbuntuServer',
      sku: '14.04.2-LTS',
      version: 'latest',
      platform: 'Windows',
      service: @virtual_machine.compute_service
    )
  end

  describe '# test get_resource_group_vms method' do
    it 'returns virtual machines in a resource group' do
      allow(@virtual_machine.compute_service).to receive(:servers).and_return([])
      expect(@virtual_machine.get_resource_group_vms('test-rg')).to eq([])
    end

    it 'returns Fog-azure-rm servers object' do
      allow(@virtual_machine.compute_service).to receive(:servers).and_raise(RuntimeError.new)
      expect(@virtual_machine.get_resource_group_vms('test-rg')).to eq([])
    end
  end

  describe '# test get method' do
    it 'returns Fog-azure-rm servers object' do
      allow(@virtual_machine.compute_service).to receive_message_chain(:servers, :get).and_return(@server)
      expect(@virtual_machine.get('fog-test-rg', 'fog-test-server')).to eq(@server)
    end

    it 'returns Fog-azure-rm servers object' do
      allow(@virtual_machine.compute_service).to receive(:servers).and_raise(RuntimeError.new)
      expect { @virtual_machine.get('fog-test-rg', 'fog-test-server') }.to raise_error('no backtrace')
    end
  end

  describe '# test start method' do
    it 'returns Fog-azure-rm servers object' do
      allow(@virtual_machine.compute_service).to receive_message_chain(:servers, :get).and_return(@server)
      allow(@server).to receive(:start).and_return(true)
      expect(@virtual_machine.start('fog-test-rg', 'fog-test-server')).to eq(true)
    end

    it 'returns Fog-azure-rm servers object' do
      allow(@virtual_machine.compute_service).to receive_message_chain(:servers, :get).and_return(@server)
      allow(@server).to receive(:start).and_raise(RuntimeError.new)
      expect { @virtual_machine.start('fog-test-rg', 'fog-test-server') }.to raise_error('no backtrace')
    end
  end

  describe '# test restart method' do
    it 'returns Fog-azure-rm servers object' do
      allow(@virtual_machine.compute_service).to receive_message_chain(:servers, :get).and_return(@server)
      allow(@server).to receive(:restart).and_return(true)
      expect(@virtual_machine.restart('fog-test-rg', 'fog-test-server')).to eq(true)
    end

    it 'returns Fog-azure-rm servers object' do
      allow(@virtual_machine.compute_service).to receive_message_chain(:servers, :get).and_return(@server)
      allow(@server).to receive(:restart).and_raise(RuntimeError.new)
      expect { @virtual_machine.restart('fog-test-rg', 'fog-test-server') }.to raise_error('no backtrace')
    end
  end

  describe '# test power_off method' do
    it 'returns Fog-azure-rm servers object' do
      allow(@virtual_machine.compute_service).to receive_message_chain(:servers, :get).and_return(@server)
      allow(@server).to receive(:power_off).and_return(true)
      expect(@virtual_machine.power_off('fog-test-rg', 'fog-test-server')).to eq(true)
    end

    it 'returns Fog-azure-rm servers object' do
      allow(@virtual_machine.compute_service).to receive_message_chain(:servers, :get).and_return(@server)
      allow(@server).to receive(:power_off).and_raise(RuntimeError.new)
      expect { @virtual_machine.power_off('fog-test-rg', 'fog-test-server') }.to raise_error('no backtrace')
    end
  end
end
