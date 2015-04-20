$required = ENV['REQUIRED'].chomp('"').reverse.chomp('"').reverse.split(" ")
$optional = ENV['OPTIONAL'].chomp('"').reverse.chomp('"').reverse.split(" ")
$emailf = ENV['EMAILF'].chomp('"').reverse.chomp('"').reverse.split(" ")
$botcatch = ENV['BOTCATCH'].chomp('"').reverse.chomp('"').reverse.split(" ")

# non-Drupal config
# $required = ["name","email","subject"] # all required fields (use anchor tag NAME attribute)
# $optional = ["message","reason"] # all optional fields (use anchor tag NAME attribute)
# $emailf = ["email"] # list any fields you want to validate for correct email format (use anchor tag NAME attribute)
# $botcatch = ["empty"] # if this field is filled out, we will know the form was submitted by a bot and it should be killed (use anchor tag NAME attribute)

# Drupal config
$f_to = ENV['F_TO'].chomp('"').reverse.chomp('"').reverse.split()
$f_from = ENV['F_FROM'].chomp('"').reverse.chomp('"').reverse
$f_subject = ENV['F_SUBJECT'].chomp('"').reverse.chomp('"').reverse
$f_body = ENV['F_BODY'].chomp('"').reverse.chomp('"').reverse.split(" ")

# non-Drupal config
# $f_to = ["info@misdepartment.com"] # hard-coded destination addresses or destination address form field (can be an array) (use anchor tag NAME attribute)
# $f_from = "email" # user's email address form field (use anchor tag NAME attribute)
# $f_subject = "subject" # hard-coded subject or subject form field (use anchor tag NAME attribute)
# $f_body = ["reason","message"] # all form fields that need to go into the email body (use anchor tag NAME attribute)

$fieldarray = ENV['FIELDARRAY'].chomp('"').reverse.chomp('"').reverse.to_sym

$send_via = ENV['SEND_VIA'].chomp('"').reverse.chomp('"').reverse.to_sym
$smtp_address = ENV['SMTP_ADDRESS'].chomp('"').reverse.chomp('"').reverse
$smtp_port = ENV['SMTP_PORT'].chomp('"').reverse.chomp('"').reverse
$smtp_user = ENV['SMTP_USER'].chomp('"').reverse.chomp('"').reverse
$smtp_pass = ENV['SMTP_PASS'].chomp('"').reverse.chomp('"').reverse
$smtp_auth = ENV['SMTP_AUTH'].chomp('"').reverse.chomp('"').reverse.to_sym
$smtp_domain = ENV['SMTP_DOMAIN'].chomp('"').reverse.chomp('"').reverse
