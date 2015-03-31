// Drupal form submit for reference
// <input id="edit-submit" name="op" value="Send Message" class="form-submit" type="submit">

var $ = jQuery;

$( function() {


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


  $('#webform-client-form-21').submit(function(event) {

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
      data: $('#webform-client-form-21').serialize(),
      success: function(data) {

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
              createError(nameSearch,"error code " + field.formpass);
              break;
            case 2:
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
