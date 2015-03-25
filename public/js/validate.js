// Drupal form submit for reference
// <input id="edit-submit" name="op" value="Send Message" class="form-submit" type="submit">

$( function() {

  $('#webform-client-form-21').submit(function(event) {

    // prevent click from refreshing page
    event.preventDefault();

    // ajax call
    $.ajax({
      url: "http://localhost:9393/",
      type: "POST",
      dataType: "json",
      data: $('#webform-client-form-21').serialize(),
      success: function(data) {


        /* Somewhere in the conditionals of these functions, there are inconsistencies.
        Submit a blank form; existing data should report an error code 1 for name, email and subject.
        This creates the .errorDiv with text "error code 1", and applies the .error class to the input field, coloring it red
        If you fill in name and submit again, it should remove the .errorDiv and .error class
        If you empty the name and submit again, it will apply the .error class, but it will not re-create the .errorDiv
        This appears to happen in all fields; if they are submitted correctly once, they cannot create the .errorDiv if they are emptied

        Also, if you fill in a correct email, then switch to an incorrect email, the error code text should change from 1 to 2 (this is desired behavior)
        Please verify that's still happening after troubleshooting
        */

        // create an error message
        function createError(location,errormsg) {
          $(location).addClass("error");
          if ($(location).next().is("div.errorDiv")) {
            $(".errorDiv").text(errormsg);
          } else {
            $(location).after("<div class='errorDiv'>" + errormsg + "</div>");
          }
        }

        // remove error message if form input is valid
        function removeError(location) {
          $(location).removeClass("error");
          if ($(location).next().is("div.errorDiv")) {
            $(".errorDiv").remove();
          }
        }

        // loop through submitted data to apply or remove error class and div
        $.each(data, function(i,field) {

          var nameSearch = "[name*=" + field.fieldname + "]";

          switch(field.formpass) {
            case 0:
              console.log(field.fieldname + ": good to go");
              removeError(nameSearch);
              break;
            case 1:
              console.log(field.fieldname + ": error code 1");
              removeError(nameSearch);
              createError(nameSearch,"error code " + field.formpass);
              break;
            case 2:
              console.log(field.fieldname + ": error code 2");
              removeError(nameSearch);
              createError(nameSearch,"error code " + field.formpass);
              break;
            default:
              console.log("Something went wrong, field " + field.fieldname + "is missing");
          }
        })
      }
    });
  });
});
