require 'azure_mgmt_network'

# set the proxy if it exists as a cloud var
Utils.set_proxy(node.workorder.payLoad.OO_CLOUD_VARS)

# get platform resource group and availability set
include_recipe 'azure::get_platform_rg_and_as'

cloud_name = node.workorder.cloud.ciName
lb_service = nil
if !node.workorder.services['lb'].nil? && !node.workorder.services['lb'][cloud_name].nil?
  lb_service = node.workorder.services['lb'][cloud_name]
end

OOLog.fatal('Missing lb service! Cannot continue.') if lb_service.nil?

cred_hash = {
    tenant_id: lb_service[:ciAttributes][:tenant_id],
    client_secret: lb_service[:ciAttributes][:client_secret],
    client_id: lb_service[:ciAttributes][:client_id],
    subscription_id: lb_service[:ciAttributes][:subscription]
}
tenant_id = lb_service[:ciAttributes][:tenant_id]
client_id = lb_service[:ciAttributes][:client_id]
client_secret = lb_service[:ciAttributes][:client_secret]
subscription_id = lb_service[:ciAttributes][:subscription]

platform_name = node.workorder.box.ciName
resource_group_name = node['platform-resource-group']
plat_name = platform_name.gsub(/-/, '').downcase
lb_name = "lb-#{plat_name}"

public_ip_name = Utils.get_component_name('lb_publicip', node.workorder.rfcCi.ciId)

credentials = Utils.get_credentials(tenant_id, client_id, client_secret)

lb_svc = AzureNetwork::LoadBalancer.new(cred_hash)
begin
  lb_svc.delete(resource_group_name, lb_name)
rescue => e
  OOLog.fatal(e.message)
end

pip_svc = AzureNetwork::PublicIp.new(cred_hash)
begin
  pip_svc.delete(resource_group_name, public_ip_name)
rescue => e
  OOLog.fatal(e.message)
end
