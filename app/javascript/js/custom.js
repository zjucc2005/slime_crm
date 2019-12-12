// import all custom js files
import './custom.candidate'
import './jquery.datetimepicker'


// ----------------------------------------------------------------------
$(document).ready(function(){
    setTimeout("$('.alert').css('display','none')",5000);
});

// select all checkbox
window.selectAll = function(ele, name){
    name = name || 'uids';
    const target = $('input:checkbox[name=' + name + ']');
    for(var i=0; i<target.length; i++){
        target[i].checked = ele.checked;
    }
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