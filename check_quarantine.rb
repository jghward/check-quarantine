require 'watir-webdriver'
require 'headless'
require 'net/smtp'

LOGIN_URL = "https://accounts.google.com/login#identifier"
QUARANTINE_URL = "https://email-quarantine.google.com/adminreview"
LOGIN_EMAIL = ""
LOGIN_PASSWORD = ""

SENDER_NAME = ""
SENDER_EMAIL = ""
RECEIVER_NAME = ""
RECEIVER_EMAIL = ""
EMAIL_SUBJECT = "Quarantined emails #{Time.now}"

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
table = browser.tables[1]

if table.rows.length > 1
  msg = "From: #{SENDER_NAME} <#{SENDER_EMAIL}>\n"
  msg << "To: #{RECEIVER_NAME} <#{RECEIVER_EMAIL}>\n"
  msg << "Subject: #{EMAIL_SUBJECT}\n\n"
  msg << "#{table.rows.length-1} emails are currently in quarantine.\n"
  table.rows.each do |r|
    msg << "---------------\n"
    msg << "#{r.text}\n"
  end
  msg << QUARANTINE_URL
  puts msg
  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message(msg, "#{SENDER_EMAIL}", "#{RECEIVER_EMAIL}")
  end
end

browser.close
headless.destroy
