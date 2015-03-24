// Drupal form submit for reference
// <input id="edit-submit" name="op" value="Send Message" class="form-submit" type="submit">

$('#webform-client-form-21').submit(function(event) {
  event.preventDefault();
  var request = $.ajax({
    url: "http://localhost:9393/",
    type: "POST",
    dataType: "json",
    data: $('#webform-client-form-21').serialize()
  });

  request.done(function(msg) {
    var myClass = "thisIsMyClass";
    var div = $("<div>Here</div>").addClass(myClass);


    msg.map(function (field) {
      if (field.formpass == false) {
        $("input[name=submitted\\[" + field.fieldname + "\\]]").addClass("error");
      } else {
        $("input[name=submitted\\[" + field.fieldname + "\\]]").removeClass("error");
      }
    });


  });

  request.fail(function(jqXHR, textStatus) {
    alert( "Request failed: " + textStatus );
  });
  return false;
});
