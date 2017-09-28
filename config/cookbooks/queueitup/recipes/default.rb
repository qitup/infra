# Set hostname
include_recipe 'hostname::default'

# Install and start docker service
docker_service 'daemon' do
    action [:create, :start]
end

include_recipe 'docker_compose::installation'