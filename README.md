BELOW IS FROM MR BONES

rbemail
===========

FIXME (describe your package)

Features
--------

* FIXME (list of features and unsolved problems)

Examples
--------

    FIXME (code sample of usage)

Requirements
------------

* FIXME (list of requirements)

Install
-------

* FIXME (sudo gem install, anything else)

Author
------

Original author: FIXME (author's name)

Contributors:

* FIXME (contributor 1?)
* FIXME (contributor 2?)

License
-------

(The MIT License) FIXME (different license?)

Copyright (c) 2015 FIXME (author's name)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Rbemail

## Motivation
On a quest for developing double-static websites (sites that are comprised of static files as well as being served statically through a CDN), it became necessary to develop a small script that will live on an external STMP server, accept input from form fields displayed on the website, and send mail. PHP was deemed too insecure, so it's written in Ruby using Sinatra for development and testing, and Pony for sending mail.

## What it does
When a user fills out the mail form, it sends mail to the destination email address as configured in the config.rb file

## How it works
When a user fills out the mail form, it takes the form fields, checks to ensure required fields are filled out, and checks the email address using a basic Regex formatter to make sure it at least looks like an email address.  Then, if all is good, it submits the form via Pony to an external SMTP server.  If all is not good, it pops back error messages using ***JSON and AJAX and requires resubmission of the form***

## How to use it
Fill out the form and click send

### External Dependencies
Ruby 2.1.2

Gems:
Pony
Mail
Mime-Types
Sinatra (dev only)
Shotgun (dev only)

# STOPPED HERE - KEEP WORKING BELOW

## Reference implementation

### Managing services

#### [Web Server]
- Run on Amazon S3 bucket behind CloudFront
- Staging site has a very fast cache invalidation time

### Production Implementation

#### Where is this thing?
- Production: [http://pollingplaces.democrats.org](http://pollingplaces.democrats.org)
- Staging: [http://pollingplaces-stage.democrats.org](http://pollingplaces-stage.democrats.org)

## For developers

To use environment variables:
. <(sed '/^export/!s/^/export /' "lib/environment_variables.list")


For deployment - change environment_variables.list as follows (this is an example for syntax)

REQUIRED="your_name your_e_mail_address subject" <- all required fields (use anchor tag NAME attribute)
OPTIONAL="message reason_for_contact" <- all optional fields (use anchor tag NAME attribute)
EMAILF="your_e_mail_address" <- list any fields you want to validate for correct email format (use anchor tag NAME attribute)
BOTCATCH="empty" <- if this field is filled out, we will know the form was submitted by a bot and it should be killed (use anchor tag NAME attribute)

F_TO="info@misdepartment.com" <- hard-coded destination addresses or destination address form field (can be an array) (use anchor tag NAME attribute)
F_FROM="your_e_mail_address" <- users email address form field (use anchor tag NAME attribute)
F_SUBJECT="subject" <- hard-coded subject or subject form field (use anchor tag NAME attribute)
F_BODY="reason_for_contact message" <- all form fields that need to go into the email body (use anchor tag NAME attribute)

loops through all "submitted" form fields based on Drupal weird form names as submitted["actual name"]
this is only necessary for Drupal; if using a form without a field array, leave this line out

FIELDARRAY="submitted"


### Deployment
1. Developer pushes to develop branch
2. Jenkins fires and attempts to merge in from origin/master, in case there are changes there
3. Jenkins uploads to pollingplaces-stage S3

  > If any of that fails, it'll stop - and we get notification in polling-places slack the whole time
4. When the developer gets a success, the developer checks http://pollingplaces-stage.democrats.org to make sure everything works OK
5. Once it's confirmed to be ok on stage, I can go into Jenkins and manually push the button to upload to production S3
6. Jenkins uploads and also merges back into master to make sure all branches are in sync (also, leaderboard points go here!)

  > Again, notifications here - if it fails, it'll stop
7. Developer checks live site at http://pollingplaces.democrats.org.s3-website-us-east-1.amazonaws.com to make sure everything's okay
8. Cache gets invalidated (or can be force-invalidated through FTP client or Slack /aws command) on CloudFront to see changes at the main domain

Additional documentation, including a full write up of the project prepared by Mike Jensen can be found here: https://docs.google.com/document/d/1m-Ad80cQlCSLEBxXHU8lvTo-3mvgWbFZI7r5q_Gjfsc/edit

## Contributors

M - Nick Gaw
O - Kate Klemp
C - James Villarrubia, Mike Jensen
H - Sunil Chopra
A - Andrew Brown
