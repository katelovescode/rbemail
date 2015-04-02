var $ = jQuery;


$(function () {
    "use strict";
    var formID, successText, valError1, valError2;
    formID = Drupal.settings.rbemail.formID;  // ID of your contact form
    successText = Drupal.settings.rbemail.successText; // Message to display on success
    valError1 = Drupal.settings.rbemail.valError1; // Message to display on required field error
    valError2 = Drupal.settings.rbemail.valError2; // Message to display on incorrect format field error

    // create an error message
    function createError(loc, msg) {
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
        $(formID).after("<div class='successDiv'>" + msg + "</div>");
        $(formID).hide();
    }


    $(formID).submit(function (event) {

        // prevent click from refreshing page
        event.preventDefault();

        // remove all old error DIVs
        $(event.target).find("input, select, textarea, radio, checkbox").each(function () {
            removeError(this);
        });

        // ajax call
        $.ajax({
            url: "http://localhost:9393/",
            type: "POST",
            data: $(formID).serialize(),
            success: function (data) {
                var success = true;
                // loop through submitted data to apply or remove error class and div
                $.each(data, function () {
                    // get field by fieldname
                    var nameSearch = "[name*=" + this.fieldname + "]";
                    // different error codes for formpass; 0 is pass, 1 is missing, 2 is invalid format
                    switch (this.formpass) {
                    case 0:
                        removeError(nameSearch);
                        break;
                    case 1:
                        createError(nameSearch, valError1);
                        break;
                    case 2:
                        createError(nameSearch, valError2);
                        break;
                    default:
                        console.log("Something went wrong, field " + this.fieldname + "is missing");
                    }
                    if (this.formpass !== 0) {
                        success = false;
                    }
                });
                if (success === true) {
                    successView(successText);
                }
            }
        });
    });
});
