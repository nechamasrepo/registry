var ready;
ready = function() {
  $("tr.search-results-row").click(function(event) {
    event.preventDefault();
    var buttonUrl = $(this).find("a").attr("href");
    window.location = buttonUrl;
 });
};

$(document).ready(ready);
$(document).on('page:load', ready);