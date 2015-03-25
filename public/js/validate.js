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
