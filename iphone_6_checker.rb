# install gems with:
#
# gem install mail
# gem install httparty
#
# usage: ruby iphone_6_checker.rb mailusername mailpassword emailaddress_of_recipient
#
# example: ruby iphone_6_checker.rb user1 pass1 notify@example.com
#
# will send an amail to notify@example.com whenever there's a free iphone model in berlin or oberhausen
# check the reserveration page combo box options for different citites
# check the json_url for other models, use google to identify the models


require 'mail'
require 'httparty'

stores = {"R358" => "Berlin", "R403" => "Oberhausen"}
model = "MG4A2ZD/A" # 128GB Space Grey
json_url = "https://reserve.cdn-apple.com/DE/de_DE/reserve/iPhone/availability.json"
order_url = "https://reserve.cdn-apple.com/DE/de_DE/reserve/iPhone/availability"

if ARGV[0].nil? || ARGV[1].nil? || ARGV[2].nil?
  puts "add missing arguments"
  puts "ruby iphone_6_checker.rb mailusername mailpassword emailaddress_of_recipient"
  exit
end

mail_user = ARGV[0]
password  = ARGV[1]
recipient = ARGV[2]

options = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => 'mbpr',
  :user_name            => mail_user,
  :password             => password,
  :authentication       => 'plain',
  :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end


response = HTTParty.get(json_url)
avail =  JSON.parse(response.to_json)


time = Time.at(avail['updated']/1000)

success = !stores.keys.any?{|s| avail[s][model] }

if success
  message = "Iphone 6 available:\n"
  stores.keys.each{|s|
    message += "#{stores[s]}: #{avail[s][model]}\n"
  }
  message += "Time: #{time}\n"
  message += "URL: #{order_url}\n"

  Mail.deliver do
    to recipient
    from recipient
    subject "iphone available!"
    body message
  end
end
