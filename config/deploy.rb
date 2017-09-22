
before "deploy:update_code" do
  roundsman.run_list "recipe[queueitup]"
end