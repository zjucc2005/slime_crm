window.cardTemplate = function(){
    var uids = $("input[name='uids[]']:checked");
    if(uids.length === 0){
        alert('请至少选择一位专家');
    }else{
        var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
        //window.location.href = '/candidates/card_template?' + params;
        window.open('/candidates/card_template?' + params);
    }
};

window.expertTemplate = function(){
    var uids = $("input[name='uids[]']:checked");
    if(uids.length === 0){
        alert('请至少选择一位专家');
    }else{
        var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
        window.location.href = '/candidates/expert_template?' + params;
    }
};

window.clipboard = function(element){
    selectText(element);
    document.execCommand('copy');
};

// select text from tag
function selectText(element) {
    var text = document.getElementById(element);
    if (document.body.createTextRange) {
        var range = document.body.createTextRange();
        range.moveToElementText(text);
        range.select();
    } else if (window.getSelection) {
        var selection = window.getSelection();
        var range = document.createRange();
        range.selectNodeContents(text);
        selection.removeAllRanges();
        selection.addRange(range);
        /*if(selection.setBaseAndExtent){
         selection.setBaseAndExtent(text, 0, text, 1);
         }*/
    } else {
        alert("none");
    }
}

window.addCandidatePhone = function(){
    $('#candidate_phone1').parent().parent().show();
    $('.phone-add-btn').parent().parent().hide();
};
window.delCandidatePhone = function(){
    $('#candidate_phone1').parent().parent().hide();
    $('.phone-add-btn').parent().parent().show();
};
window.addCandidateEmail = function(){
    $('#candidate_email1').parent().parent().show();
    $('.email-add-btn').parent().parent().hide();
};
window.delCandidateEmail = function(){
    $('#candidate_email1').parent().parent().hide();
    $('.email-add-btn').parent().parent().show();
};