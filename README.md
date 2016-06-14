# check-quarantine
Logs in and checks quarantine of a Google Apps account. Prints summary of quarantined messages quarantined messages to stdout. Optionally sends an email or Hipchat notification.

This script uses Watir-Webdriver in Headless mode since there is no API coverage of the quarantine functionality.

# dependencies
$ sudo apt-get install ruby-dev xvfb

$ sudo gem install watir-webdriver headless hipchat


an smtp server must be available for email notifications to work
