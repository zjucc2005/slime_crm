// import all custom js files
import './candidate'
// import './company'


// ----------------------------------------------------------------------
$(document).ready(function(){
    setTimeout("$('.alert').css('display','none')",5000);
});

// select all checkbox
window.selectAll = function(ele, name){
    name = name || 'uids';
    const target = $('input:checkbox[name=' + name + ']');
    for(let i=0; i<target.length; i++){
        target[i].checked = ele.checked;
    }
};