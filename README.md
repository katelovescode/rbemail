# Rbemail

## Motivation
On a quest for developing double-static websites (sites that are comprised of static files as well as being served statically through a CDN), it became necessary to develop a small script that will live on an external STMP server, accept input from form fields displayed on the website, and send mail. PHP was deemed too insecure, so it's written in Ruby using Sinatra for development and testing, and Pony for sending mail.

## What it does
When a user fills out the mail form, it sends mail to the destination email address as configured in the environment_variables.list file

## How it works
When a user fills out the mail form, it takes the form fields, checks to ensure required fields (as specified in environment_variables.list) are filled out, and checks the email address using a basic Regex formatter to make sure it at least looks like an email address.  Then, if all is good, it submits the form via Pony to an external SMTP server.  If all is not good, it pops back error messages using JSON and AJAX and requires resubmission of the form

## How to use it
Front-end users fill out the website form and click send

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
- rspec (dev & test only)
- rack-test (dev & test only)
- mailcatcher (dev & test only)
- dotenv

## Reference implementation

### Drupal Site
Our current site is written in Drupal.  We are maintaining a Drupal backend but having a static front end (served behind a CDN - "double static") is far more preferable than leaving a database backend exposed to the client side.  Therefore, we have our Drupal site on a staging server, which generates static site content and pushes it to a production server.  Rbemail is currently implemented as a Drupal module, so the client-side code that calls to the rbemail instance is embedded in the static content that is generated by the backend static site generation process.

### Managing services

#### [CLIENT SIDE]
The Drupal module uses JS & AJAX to call to the rbemail script to validate and send data from a contact form (in our case, the Drupal site will be turned into static files on deployment, so this module allows for email to be sent with an external mail program, rather than through the Drupal site's database and server).

#### [MAIL SERVER]
The SMTP mail server for our current configuration is Amazon SES.  We created new SES credentials, and verified the sender email and the domain on which rbemail will be used.  We configured the environment_variables.list file to include the AWS SES server name, port, user and pass, and the website domain we'll be using this app on.

#### [RBEMAIL SERVER]
The rbemail instance is run in a cluster of Docker containers.  
<p style="color:red;font-size:18px">TODO: Sunil - please expand on this.</p>

### Production Implementation

#### Where is this thing?

Rbemail currently lives on a cluster of Docker containers
<p style="color:red;font-size:18px">TODO: Sunil - please expand on this.</p>

## For developers

Set up dev environment:  
1. Develop your form using html or erb views  
1. Clone **rbemail** to your local machine  
1. `cd path/to/rbemail`  
1. If you're using rvm, a gemset should automatically generate  
1. `bundle install`  
1. Using your text editor of choice, configure `.env.development` with your specific form fields:  
  * FIELDARRAY: only necessary if your form fields are in an array, like the example below:
    ```
  <input name="example_fieldarray[example_name]" />
  ```

  If your fields are not in this format, set `FIELDARRAY = ""`
  * REQUIRED: a list of all required fields in your form, separated by spaces

  * OPTIONAL: a list of all optional fields in your form, separated by spaces

    > Note: all of your form fields (except BOTCATCH) must be in either REQUIRED or OPTIONAL, or the script will exit with an error; this is the only developer error passed.  All other errors are passed into the data to be dealt with using JS or your preferred front-end handler

  * EMAILF: put any field names here that contain emails you want to check for format (usually just the sender's email)

  * BOTCATCH: if you have a hidden field that should **not** be filled out and is used to catch bot form fills, put the field name here, otherise set `BOTCATCH = ""`

  * F_TO: this can be either a hard-coded email address, a list of email addresses separated by spaces, or a the field name in the form if the user will be selecting or entering email addresses manually

  * F_FROM: this can be either one hard-coded email address, or the field name in the form if the user will be manually entering their "from" email

  * F_SUBJECT: this can be either the hard-coded subject line (e.g. "Contact Form from Website"), or the field name in the form if the user will be manually entering a subject

  * F_BODY: this is a list of field names that should be included in the body of the email, separated by spaces.  The app will output them into the body with the field name prettified & prepended, like the example below:
  ```
  Example Name: Joe McGee  
  Example Message: Hey guys, nice website.  
  Example Rating: 4
  ```
  **PONY CONFIG FIELDS**

  * SEND_VIA: standard is smtp (must be in lowercase) - for additional options and their specific configurations, see the Pony gem documentation at https://github.com/benprew/pony

  * SMTP_ADDRESS: address of your smtp server (if using mailcatcher as included in the **rbemail** app, use `"localhost"`)

  * SMTP_PORT: port used for your smtp server (use `"1025"` with mailcatcher)

  * SMTP_USER & SMTP_PASS: username & password for your smtp server (use `""` for both with mailcatcher)

  * SMTP_AUTH: smtp authorization method (use `"plain"` with mailcatcher)

  * SMTP_DOMAIN: your domain name (use anything with mailcatcher)

1. Configure client-side *(see `public/examples` for some implementation examples based on different client-side environments)*  
  > **FOR SIMPLE DEVELOPMENT**  

  >With Sinatra already installed, you can use erb views to serve your form.  Just add a Sinatra get method such as the following to `rbemail.rb`, before the `post` method:
  ```
  # if developing a form
  get '/' do
    erb :index
  end
  ```
  Then create your form in `views/index.erb` - currently, there is no method to change the view after post; in our Drupal example under "public", the Drupal module handles this.  If you want to redirect the view after post, you'll need another erb command at the end of the post method

1. Navigate to the project directory and run mailcatcher: `mailcatcher`  
1. Fire up the app inside the project directory using shotgun: `shotgun config.ru`  
1. Navigate to `localhost:9393` (or wherever your form is) and test it out (to test from the command line instead, with no view in place, use one of the `curl` commands in the .env.development file as a template for testing)  
1. Navigate to `localhost:1025` to view caught mails sent from your form  
1. For testing, run `bundle exec rspec`  

### Deployment
1. Develop your form using html or erb views  
1. Clone **rbemail** to your local machine  
1. `cd path/to/rbemail`  
1. If you're using rvm in your production environment, a gemset should automatically generate  
1. `bundle install`  
1. Using your text editor of choice, configure `.env.development` with your specific form fields (see dev environment instructions for explanation)  
<p style="color:red;font-size:18px">TODO: Sunil - please expand on this - docker implementation? etc.  Phusion Passenger?</p>
1. Configure client-side to interact (see `public/examples` for some implementation examples based on different client-side environments)  
1. Test  
1. Enjoy!  


## Contributors

- **M**anager - Ian Reynolds
- **O**wner   - Kate Klemp
- **C**onsulted - Sunil Chopra
- **H**elper    - #ruby-lang irc channel :)
- **A**pprover  - Sunil Chopra
