// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
//= require bootstrap
Turbolinks.enableProgressBar();

var ready;
ready = function(){
  // tooltips
  $('[data-toggle="tooltip"]').tooltip();
  
// Modal
  $('#newFulfillmentModal').on('show.bs.modal', function (event) {
    // when modal is opened
      var button = $(event.relatedTarget); // Button that triggered the modal
      var itemName = button.data('item-name');
      var id = button.data('item-id'); // Extract info from data-* attributes
      // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
      // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
      var modal = $(this);
      modal.find('#fulfillment_item_id').val(id);
      modal.find('.modal-title b').text(itemName);
    // open new window with link
      var link = button.data('link');
      var width = 620;
      var height = 430;
      var left = window.innerWidth/2 - width/2 + window.screenX;
      var top = screen.height - height - 110;
      window.open(link,'_blank', 'height='+height+', width='+width+', left='+left+', top='+top);    
  });

};

$(document).ready(ready);
$(document).on('page:load', ready);
