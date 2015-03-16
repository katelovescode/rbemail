########################################
# LIST ALL FORM FIELDS BELOW
########################################

$required = ["your_name","your_e_mail_address","subject"] # all required fields (use anchor tag NAME attribute)
$optional = ["message","reason_for_contact"] # all optional fields (use anchor tag NAME attribute)
$botcatch = ["empty"] # if this field is filled out, we will know the form was submitted by a bot and it should be killed (use anchor tag NAME attribute)

########################################
# PONY FIELD MAPPING
########################################

$f_to = "info@misdepartment.com" # hard-coded destination address or field name (use anchor tag NAME attribute)
$f_from = "your_e_mail_address" # form user's email address field (use anchor tag NAME attribute)
$f_subject = "subject" # email subject field (use anchor tag NAME attribute)
$f_body = ["reason_for_contact","message"] # all body fields (use anchor tag NAME attribute)

########################################
# SPECIAL FORM FIELD NAME CONFIGURATIONS
########################################

# loops through all "submitted" form fields based on Drupal weird form names as submitted["actual name"]
# this is only necessary for Drupal; if using other fields, comment this out
$fieldarray = :submitted
