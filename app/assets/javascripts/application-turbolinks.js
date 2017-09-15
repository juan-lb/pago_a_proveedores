//= require turbolinks

$(document).on('page:load', ready);

$(document).on('page:fetch', function(){ $('#page-wrapper').addLoader(); });