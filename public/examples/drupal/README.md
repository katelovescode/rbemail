# Drupal module configuration instructions

In `rbemail.module`, configure the form ID, success message, and error messages.  Set both the "mailServer" and $form['#action'] variables to the location of the rbemail server.  Change the second function name from "rbemail_form_webform_client_form_21_alter" to "rbemail_form_YOUR_FORM_ID_alter".
