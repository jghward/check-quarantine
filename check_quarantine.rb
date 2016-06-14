require 'watir-webdriver'
require 'headless'
require 'net/smtp'
require 'hipchat'

#Google Apps settings
LOGIN_URL      = 'https://accounts.google.com/login#identifier'
QUARANTINE_URL = 'https://email-quarantine.google.com/adminreview'
LOGIN_EMAIL    = ''
LOGIN_PASSWORD = ''

#Email notification settings
SEND_EMAIL     = false
SENDER_NAME    = ''
SENDER_EMAIL   = ''
RECEIVER_NAME  = ''
RECEIVER_EMAIL = ''
EMAIL_SUBJECT  = "Quarantined emails #{Time.now}"

#Hipchat notification settings
SEND_HIPCHAT_NOTIFICATION = false
API_TOKEN                 = ''
ROOM_ID                   = ''
USERNAME                  = 'QuarantineBot'
COLOR                     = 'yellow'# 'red', 'yellow', 'green', 'purple', 'random'

#Print results to stdout
PRINT_RESULTS = true

def send_email(msg)
  email = "From: #{SENDER_NAME} <#{SENDER_EMAIL}>\n"
  email << "To: #{RECEIVER_NAME} <#{RECEIVER_EMAIL}>\n"
  email << "Subject: #{EMAIL_SUBJECT}\n\n"
  email << msg
  Net::SMTP.start('localhost') do |smtp|
  smtp.send_message(email, "#{SENDER_EMAIL}", "#{RECEIVER_EMAIL}")
  end
end

def send_hipchat_notification(msg)
  client = HipChat::Client.new(API_TOKEN, :api_version => 'v2')
  client[ROOM_ID].send(USERNAME, msg)
end

headless = Headless.new
headless.start
browser = Watir::Browser.new
browser.goto(LOGIN_URL)
browser.text_field(:id, 'Email').set(LOGIN_EMAIL)
browser.button(:id, 'next').click
browser.text_field(:id, 'Passwd').wait_until_present
browser.text_field(:id, 'Passwd').set(LOGIN_PASSWORD)
browser.button(:id, 'signIn').click
browser.goto(QUARANTINE_URL)
Watir::Wait.while { browser.text.match(/Loading \.\.\./) }
sleep 3
table = browser.tables[1]

if table.rows.length > 1
  msg = "#{table.rows.length-1} emails are currently in quarantine.\n"
  table.rows.each do |r|
    msg << "---------------\n"
    msg << "#{r.text}\n"
  end
  msg << QUARANTINE_URL
  puts msg if PRINT_RESULTS
  send_email(msg) if SEND_EMAIL
  send_hipchat_notification(msg) if SEND_HIPCHAT_NOTIFICATION
end

browser.close
headless.destroy
