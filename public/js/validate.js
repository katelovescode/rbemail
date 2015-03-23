// Drupal form submit for reference
// <input id="edit-submit" name="op" value="Send Message" class="form-submit" type="submit">

$('#webform-client-form-21').submit(function(event) {
    event.preventDefault();
    var myreq = $.ajax({
        type:"POST",
        url:"http://localhost:9393/",
        dataType:"text",
        data:$('#webform-client-form-21').serialize()
    });
    myreq.done(function() {
        alert("done");
    });
    myreq.always(function() {
        alert("always");
    });
});
