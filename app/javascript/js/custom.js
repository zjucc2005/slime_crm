// import all custom js files
import './custom.candidate'
import './custom.project'
import './jquery.datetimepicker'


// DOMContentLoaded events ----------------------------------------------------------------------
$(document).on('turbolinks:load', function(){
    setTimeout("$('.alert').css('display','none')",5000);
    $('.datetimepicker').datetimePicker();
    $('.datepicker').datePicker();
    $('.select2').select2();
});

// select all checkbox
window.selectAll = function(ele, name){
    name = name || 'uids[]';
    const target = $('input:checkbox[name="' + name + '"]');
    target.each(function(){
        this.checked = ele.checked;
    });
    // for(var i=0; i<target.length; i++){
    //     target[i].checked = ele.checked;
    // }
};

$.fn.datePicker = function(){
    $(this).datetimepicker(
        {
            format: 'Y-m-d',
            timepicker: false,
            allowBlank: true
        }
    );
};

$.fn.datetimePicker = function(){
    $(this).datetimepicker(
        {
            format: 'Y-m-d H:i',
            timepicker: true,
            allowBlank: true
        }
    );
};