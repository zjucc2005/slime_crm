// import all custom js files
import './custom.candidate'
import './custom.project'


// DOMContentLoaded events ----------------------------------------------------------------------
$(document).on('turbolinks:load', function(){
    setTimeout("$('.alert').css('display','none')",5000);
    $('.datetimepicker').datetimePicker();
    $('.datepicker').datePicker();
    if($('.select2-container').length){
        $('.select2-container').remove();  // turbolinks:reload + select2 重复加载bug修复
    }
    $('.select2').select2();
    $('input[type=number]').mousewheel(function(){
        disableMouseWheelScroll();  // 全局禁用 number 的滚轮
    })
});

// select all checkbox
window.selectAll = function(ele, name){
    name = name || 'uids[]';
    const target = $('input:checkbox[name="' + name + '"]');
    target.each(function(){
        this.checked = ele.checked;
    });
};

// ===== Date & Time picker =====
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

// form activate/deactivate
window.form_activate = function(field){
    let ele = $('#' + field);
    ele.attr('required', true);
    ele.parent().show();
};

window.form_deactivate = function(field){
    let ele = $('#' + field);
    ele.attr('required', false);
    ele.val('');
    ele.parent().hide();
};

window.form_show = function(field){
    let ele = $('#' + field);
    ele.parent().show();
};

window.form_hide = function(field){
    let ele = $('#' + field);
    ele.val('');
    ele.parent().hide();
};

// forbid mouse wheel scroll event
window.disableMouseWheelScroll = function(e){
    e = e || window.event;
    if(e.preventDefault) {
        // Firefox
        e.preventDefault();
        e.stopPropagation();
    } else {
        // IE
        e.cancelBubble=true;
        e.returnValue = false;
    }
    return false;
};