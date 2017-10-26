Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"], scope: "user:email"
end


# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"],
#    {:client_options => {:ssl => {:ca_file => ‘/usr/lib/ssl/certs/ca-certificates.crt’}}}
# end
