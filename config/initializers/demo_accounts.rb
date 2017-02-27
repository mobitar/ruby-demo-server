raw_accounts = ENV["DEMO_ACCOUNTS"].split(",")
accounts = raw_accounts.map do |raw|
  comps = raw.split(":")
  email = comps[0]
  pw = comps[1]
  {:email => email, :password => pw}
end

DEMO_ACCOUNTS = accounts
DEMO_ACCOUNTS_IP_WHITELIST = ENV["DEMO_ACCOUNTS_IP_WHITELIST"].split(",")

puts "Demo Accounts: #{DEMO_ACCOUNTS}, #{DEMO_ACCOUNTS_IP_WHITELIST}"
