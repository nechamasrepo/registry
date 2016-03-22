var ready;
ready = function() {
    // Sort
    $('#sort-by').on('keyup change', function(event){
      var value = event.target.value;
      if (value != '')
        Turbolinks.visit(window.location.pathname+"?sort_by="+value);
      else
        Turbolinks.visit(window.location.pathname);
    });
  
    // Item Image Immediate Display
    $("#item_image_url").on('blur input', function (event){
      var url = $(this).val();
      $("#image-view").attr("src", url);
     }); 
     
    // scrape cache
    var cache = {};
  
    // Scrape
    $("#scrape-form").submit(function (event) {
      event.preventDefault();
      var url = $(this).find("input[name=url]").val();
      
      // empty the form with blank data
      fillInForm({
        "url": "",
        "title": "",
        "price": "",
        "images": [
        ""
      ]});
      
      // stop and just open the modal if they didn't put in a url
      if (url.trim().length == 0) {
        $('#newItemModal').modal('show');
        return false;
      }
      
      // add http if nessessary
      url = url.indexOf('http') == 0 ? url : 'http://'+url;
      
      
      // catch the invalid url
      if (!validURL(url)) {
        alert("Please enter a valid url");
        return false;
      }
           
      // check if its in the cache - if it is then pass that data and stop
      if (cache[url] != null) {
        fillInForm(cache[url]);
        $('#newItemModal').modal('show');
        return false;
      }
        
      // if there is actually something to scrape...
      // make the button loading
      var $button = $(this).find('button').button('loading');
      // start the loading bar
//       Turbolinks.ProgressBar.start();
      
      // run scrape code
      $.ajax({
        method:"GET",
        url: "/scrape?url="+url,
        timeout: 3000000 //take out 2 zeros and change number
      })
      .done(function(data){
        // save the data to a cache if at least the title was found
        if (data.title.length > 0)
          cache[url] = data;
        
        console.log(data);
        // put in the data
        fillInForm(data);
      })
      .error(function(){
        $('#item_link').val(url);
      })
      .always(function(){
        // show modal in either case
        $('#newItemModal').modal('show');
        
        // reset things
//         Turbolinks.ProgressBar.done();

        $button.button('reset');
      });
      // load into modal
    });
};

function fillInForm(data) {
  $('#item_name').val(data.title);
  $('#item_link').val(data.url);
  $('#item_price').val(data.price);
  $("#item_needed").val(1);
  $("#item_image_url").val(data.images[0]).blur();
}

function validURL(str) {
//   var urlregex = /^(https?|ftp):\/\/([a-zA-Z0-9.-]+(:[a-zA-Z0-9.&%$-]+)*@)*((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}|([a-zA-Z0-9-]+\.)*[a-zA-Z0-9-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(:[0-9]+)*(\/($|[a-zA-Z0-9.,?'\\+&%$#=~_-]+))*$/;
    var urlregex = /^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$/;
    return urlregex.test(str);
}

$(document).ready(ready);
$(document).on('page:load', ready);