$required = ENV['REQUIRED'].split(" ")
$optional = ENV['OPTIONAL'].split(" ")
$emailf = ENV['EMAILF'].split(" ")
$botcatch = ENV['BOTCATCH'].split(" ")

# non-Drupal config
# $required = ["name","email","subject"] # all required fields (use anchor tag NAME attribute)
# $optional = ["message","reason"] # all optional fields (use anchor tag NAME attribute)
# $emailf = ["email"] # list any fields you want to validate for correct email format (use anchor tag NAME attribute)
# $botcatch = ["empty"] # if this field is filled out, we will know the form was submitted by a bot and it should be killed (use anchor tag NAME attribute)

# Drupal config
$f_to = ENV['F_TO'].split()
$f_from = ENV['F_FROM']
$f_subject = ENV['F_SUBJECT']
$f_body = ENV['F_BODY'].split(" ")

# non-Drupal config
# $f_to = ["info@misdepartment.com"] # hard-coded destination addresses or destination address form field (can be an array) (use anchor tag NAME attribute)
# $f_from = "email" # user's email address form field (use anchor tag NAME attribute)
# $f_subject = "subject" # hard-coded subject or subject form field (use anchor tag NAME attribute)
# $f_body = ["reason","message"] # all form fields that need to go into the email body (use anchor tag NAME attribute)

$fieldarray = ENV['FIELDARRAY'].to_sym

$send_via = ENV['SEND_VIA']
$smtp_address = ENV['SMTP_ADDRESS']
$smtp_port = ENV['SMTP_PORT']
$smtp_user = ENV['SMTP_USER']
$smtp_pass = ENV['SMTP_PASS']
$smtp_auth = ENV['SMTP_AUTH'].to_sym
$smtp_domain = ENV['SMTP_DOMAIN']
