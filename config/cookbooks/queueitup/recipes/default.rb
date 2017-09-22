# Set hostname

include_recipe 'hostname::default'

docker_service 'daemon' do
    action [:create, :start]
end
