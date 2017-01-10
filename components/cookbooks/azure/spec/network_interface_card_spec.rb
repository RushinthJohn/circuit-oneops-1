require 'json'
require 'fog/azurerm'
require 'simplecov'
require 'rest-client'
SimpleCov.start

require File.expand_path('../../libraries/public_ip', __FILE__)
require File.expand_path('../../libraries/network_interface_card', __FILE__)
require File.expand_path('../../libraries/virtual_network', __FILE__)
require File.expand_path('../../libraries/subnet', __FILE__)
require ::File.expand_path('../../../azure_base/libraries/logger', __FILE__)
require ::File.expand_path('../../../azure_base/libraries/utils', __FILE__)

describe AzureNetwork::NetworkInterfaceCard do
  before :each do
    token_provider = MsRestAzure::ApplicationTokenProvider.new('<TENANT_ID>', '<CLIENT_ID>', 'CLIENT_SECRET')
    credentials = MsRest::TokenCredentials.new(token_provider)
    subscription = '<SUBSCRIPTION-ID>'
    @azure_client = AzureNetwork::NetworkInterfaceCard.new(credentials, subscription)
    @azure_client.rg_name = @platform_resource_group
    @azure_client.ci_id = 'ci-id'

    @nic = Fog::Network::AzureRM::NetworkInterface.new
    @frntend_ip_config = Fog::Network::AzureRM::FrontendIPConfiguration.new

    @public_ip_response = Fog::Network::AzureRM::PublicIp.new(
      id: "/subscriptions/########-####-####-####-############/resourceGroups/{resource_group}/providers/Microsoft.Network/publicIPAddresses/{name}",
      name: "name",
      type: "Microsoft.Network/publicIPAddresses",
      location: "location"
    )

  end

  describe '# test define_nic_ip_config functionality' do
    it 'builds desired config successfully without public ip scenario' do
      expect(@azure_client.define_nic_ip_config('private', 'subnet-id')).to be_a Fog::Network::AzureRM::FrontendIPConfiguration
    end

    it 'builds desired config successfully with public ip scenario' do
      allow(@azure_client.publicip).to receive(:create_update).and_return(@public_ip_response)
      expect(@azure_client.define_nic_ip_config('public', 'subnet-id')).to be_a Fog::Network::AzureRM::FrontendIPConfiguration
    end
  end


  describe '#test build_network_profile functionality' do
    it ' build network profile when express route is not enabled' do

      # allow(@azure_client.virtual_network).to receive(:get).and_return('some-response')
      # allow(@azure_client.virtual_network).to receive(:exists?).and_return(true)
      # allow(@azure_client.virtual_network).to receive(:exists?).and_return(false)
      # allow(@azure_client.virtual_network).to receive(:create_update).and_return('some-response')
      # allow(@azure_client.subnet_cls).to receive(:get_subnet_with_available_ips).and_return('some-response')
      # allow(@azure_client.nsg).to receive(:get).and_return('some-response')
      #
      # expect(@azure_client.build_network_profile(false,
      #                                            @platform_resource_group,
      #                                            'pre_vnet',
      #                                            'network-address',
      #                                            ["1", "2", "5", "7"],
      #                                            ["1", "2", "5", "7"],
      #                                            'publicip',
      #                                            'sec-group')
      # ).not_to
    end

  end




  describe '# test define_network_interface functionality' do
    it 'builds desired obj successfully' do
      expect(@azure_client.define_network_interface(@frntend_ip_config)).to be_a Fog::Network::AzureRM::NetworkInterface
    end

    it 'checks output from given input in build desired obj' do
      @frntend_ip_config.name = 'nic'
      @nic.name = 'nic-ci-id'
      expect(@azure_client.define_network_interface(@frntend_ip_config)).to eq(@nic)
    end
  end

  describe '# test create_update functionality' do
    it 'creates successfully' do
      file_path = File.expand_path('network_interface_card_data.json', __dir__)
      file = File.open(file_path)
      nic_response = file.read

      allow(@azure_client.network_client).to receive_message_chain(:network_interfaces, :create).and_return(nic_response)
      expect(@azure_client.create_update(@nic)).to_not eq(nil)
    end

    it 'raises AzureOperationError exception' do
      allow(@azure_client.network_client).to receive_message_chain(:network_interfaces, :create)
                                                 .and_raise(MsRestAzure::AzureOperationError.new('Errors'))
      expect { @azure_client.create_update(@nic)}.to raise_error('no backtrace')

    end

    it 'raises a generic exception' do
      allow(@azure_client.network_client).to receive_message_chain(:network_interfaces, :create)
                                                 .and_raise(MsRest::HttpOperationError.new('Error'))
      expect { @azure_client.create_update(@nic) }.to raise_error('no backtrace')
    end
  end

  describe '#test get functionality' do
    it 'successfull case of get functionality' do
      file_path = File.expand_path('network_interface_card_data.json', __dir__)
      file = File.open(file_path)
      nic_response = file.read

      allow(@azure_client.network_client).to receive_message_chain(:network_interfaces, :get).and_return(nic_response)
      expect(@azure_client.get(@nic)).to_not eq(nil)
    end

    it 'raises AzureOperationError exception' do
      allow(@azure_client.network_client).to receive_message_chain(:network_interfaces, :get)
                                                 .and_raise(MsRestAzure::AzureOperationError.new('Errors'))
      expect { @azure_client.get(@nic)}.to raise_error('no backtrace')
    end

    it 'raises a generic exception' do
      allow(@azure_client.network_client).to receive_message_chain(:network_interfaces, :get)
                                                 .and_raise(MsRest::HttpOperationError.new('Error'))
      expect { @azure_client.get(@nic) }.to raise_error('no backtrace')
    end
  end


end
