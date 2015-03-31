// Drupal form submit for reference
// <input id="edit-submit" name="op" value="Send Message" class="form-submit" type="submit">

var $ = jQuery;
var formID = "#webform-client-form-21";  // ID of your contact form
var successText = "Thank you, someone will be in touch with you shortly." // Message to display on success
var valError1 = "This field is required." // Message to display on required field error
var valError2 = "This is not the correct format for this field." // Message to display on incorrect format field error

$( function() {


  // create an error message
  function createError(loc,msg) {
    $(loc).addClass("error");
    if ($(loc).next().is("div.errorDiv")) {
      $(".errorDiv").text(msg);
    } else {
      $(loc).after("<div class='errorDiv'>" + msg + "</div>");
    }
  }

  // remove error message if form input is valid
  function removeError(loc) {
    $(loc).removeClass("error");
    if ($(loc).next().is("div.errorDiv")) {
      $(".errorDiv").remove();
    }
  }

  // change view on success
  function successView(msg) {
    $(formID).after("<div class='successDiv'>" + msg + "</div>")
    $(formID).hide();
  }


  $(formID).submit(function(event) {

    // prevent click from refreshing page
    event.preventDefault();

    // remove all old error DIVs
    $(event.target).find("input, select, textarea, radio, checkbox").each(function(){
      removeError(this);
    });

    // ajax call
    $.ajax({
      url: "http://localhost:9393/",
      type: "POST",
      data: $(formID).serialize(),
      success: function(data) {
        var success = true;
        // loop through submitted data to apply or remove error class and div
        $.each(data, function(i,field) {
          // get field by fieldname
          var nameSearch = "[name*=" + field.fieldname + "]";


          // different error codes for formpass; 0 is pass, 1 is missing, 2 is invalid format
          switch(field.formpass) {
            case 0:
              removeError(nameSearch);
              break;
            case 1:
              createError(nameSearch,valError1);
              break;
            case 2:
              createError(nameSearch,valError2);
              break;
            default:
              console.log("Something went wrong, field " + field.fieldname + "is missing");
          }
          if (field.formpass != 0) {
            success = false;
          }
        })
        if (success == true) {
          successView(successText);
        }
      }
    });
  });
});
