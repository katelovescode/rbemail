# Rbemail

## Motivation
On a quest for developing double-static websites (sites that are comprised of static files as well as being served statically through a CDN), it became necessary to develop a small script that will live on an external STMP server, accept input from form fields displayed on the website, and send mail. PHP was deemed too insecure, so it's written in Ruby using Sinatra for development and testing, and Pony for sending mail.

## What it does
When a user fills out the mail form, it sends mail to the destination email address as configured in the environment_variables.list file

## How it works
When a user fills out the mail form, it takes the form fields, checks to ensure required fields are filled out, and checks the email address using a basic Regex formatter to make sure it at least looks like an email address.  Then, if all is good, it submits the form via Pony to an external SMTP server.  If all is not good, it pops back error messages using JSON and AJAX and requires resubmission of the form

## How to use it
Fill out the form and click send

### External Dependencies
Ruby 2.1.2

Gems:
- sinatra
- sinatra-cross_origin
- pony
- mail
- mime-types
- json
- shotgun (dev only)

## Reference implementation

Drupal module uses JS & AJAX to call to the rbemail script to validate and send data from a contact form (in our case, the Drupal site will be turned into static files on deployment, so this module allows for email to be sent with an external mail program, rather than through the Drupal site's database and server).

### Managing services

#### [CLIENT SIDE]
#### [MAIL SERVER]

### Production Implementation

#### Where is this thing?

(Email server, I'm assuming)

## For developers

Set up dev environment:
1. Develop your form using html
2. Clone rbemail to your local machine
3. `bundle install`
4. Configure `environment_variables.list` based on your specific form fields
5. Add ENV variables to your local session (if done this way, you must do this every time you run the app in a new shell) with the following command (Ubuntu 14.10 - ymmv): `. <(sed '/^export/!s/^/export /' "lib/environment_variables.list")`
7. Configure client-side (see `public/examples` for some implementation examples based on different client-side environments)
8. Install and run a local SMTP server/mock server (e.g. FakeSMTP)
9. Fire up the app (inside the project directory) using shotgun: `shotgun lib/rbemail.rb`
10. Navigate to `localhost` (or wherever your form is) and test it out

### Deployment
1. Clone rbemail to your mail server
2. Configure `environment_variables.list`
3. Run environment variables `sed` command as listed above
4. Configure SMTP ***(Need help on this, don't know this step yet)***
5. Configure and run rbemail for live server ***(Need help on this, don't know this step yet)***
6. Configure client-side to interact (see `public/examples` for some implementation examples based on different client-side environments)
7. Test
8. Enjoy!


## Contributors

- **M**anager - Ian Reynolds
- **O**wner   - Kate Klemp
- **C**onsulted - Sunil Chopra
- **H**elper    - #ruby-lang irc channel :)
- **A**pprover  - Sunil Chopra
