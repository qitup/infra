# Set hostname

hostname = "queueitup.prod"

file '/etc/hostname' do
  content "#{hostname}\n"
end

service 'systemd-logind' do
  action :restart
end

file '/etc/hosts' do
    content "127.0.0.1 localhost #{hostname}\n"
end

docker_service 'daemon' do
    action [:create, :start]
end
