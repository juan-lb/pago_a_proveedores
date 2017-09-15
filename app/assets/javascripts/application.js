// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require app.flash_message
//= require plugins/jQueryUI/jquery-ui.min.js
//= require plugins/tablesorter/jquery.tablesorter.js
//= require plugins/tablesorter/jquery.tablesorter.widgets.js
//= require plugins/tablesorter/jquery.tablesorter.pager.js
//= require plugins/input-mask/jquery.inputmask.js
//= require plugins/input-mask/jquery.inputmask.date.extensions.js
//= require plugins/input-mask/jquery.inputmask.extensions.js
//= require plugins/sparkline/jquery.sparkline.js
//= require plugins/jvectormap/jquery-jvectormap-1.2.2.min.js
//= require plugins/jvectormap/jquery-jvectormap-world-mill-en.js
//= require plugins/knob/jquery.knob.js
//= require plugins/daterangepicker/moment.js
//= require plugins/daterangepicker/daterangepicker.js
//= require plugins/slimScroll/jquery.slimscroll.min.js
//= require plugins/datatables/jquery.dataTables.min.js
//= require plugins/select2/select2.full.min.js
//= require plugins/bootbox/bootbox.min.js
//= require select
//= require chartkick

//= require input_with_formulas
//= require init
//= require utilities

//= require payment_group
//= require fake_payment_group
//= require refund_payment_group
//= require payment_groups
//= require statistics
//= require fund_flow
//= require coming_entries
//= require profile
//= require home
//= require international_payment_group
//= require best_in_place
//= require admin/bootstrap/js/bootstrap.js
//= require plugins/datatables/dataTables.bootstrap.min
//= require plugins/datepicker/bootstrap-datepicker.js
//= require plugins/multiple-emails/multiple-emails.js
//= require admin/dist/js/app.js
//= require plugins/big/big.min.js
//= require morris
//= require jquery-readyselector
//= require retention
//= require service_registers
//= require agency_payments
//= require operators


//Resolve conflict in jQuery UI tooltip with Bootstrap tooltip
$.widget.bridge('uibutton', $.ui.button);

ready = function() {

    if ( !$.fn.dataTable.isDataTable( '#initialize_example1_table' )) {
      initialize_example1_table();
    }

    //Tooltip initializer
    $('[data-toggle="tooltip"]').tooltip();


    $("a[href='" + window.location.pathname + "']").parent().addClass('active');

};


jQuery.fn.addLoader = function(){
  this.html('<div class="loading-bar"><i class="fa fa-spinner fa-pulses" alt="Loading..." id="ajax-loader" title="Loading..." /></div>');
}

function filter_operator_disabled(){
  $("#filter_operator_id").prop("disabled", true);
  $("#operator_filter_operator_id").prop("disabled", true);
}

function initialize_example1_table() {
    $('#example1').DataTable( {
        initComplete: function () {
            this.api().columns().every( function () {
                var column = this;
                var select = $('<select><option value=""></option></select>')
                    .appendTo( $(column.footer()).empty() )
                    .on( 'change', function () {
                        var val = $.fn.dataTable.util.escapeRegex(
                            $(this).val()
                        );

                        column
                            .search( val ? '^'+val+'$' : '', true, false )
                            .draw();
                    } );

                column.data().unique().sort().each( function ( d, j ) {
                    select.append( '<option value="'+d+'">'+d+'</option>' )
                } );
            } );
        }
    } );
}

$(document).on('ready turbolinks:load', ready);

jQuery.fn.animate_deletion  = function(){
  this.animate({backgroundColor: "#00c0ef"}, 0.5).fadeOut('fast', function(){ $(this).remove()} ) }
