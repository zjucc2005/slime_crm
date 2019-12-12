window.genCandidateCard = function(){
    var uids = $("input[name='uids']:checked");
    if(uids.length === 0){
        alert('请至少选择一位候选人');
    }else{
        var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
        window.location.href = '/candidates/gen_card?' + params;
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
    $('#candidate_phone1').parent().show();
    $('.phone-add-btn').hide();
};
window.delCandidatePhone = function(){
    $('#candidate_phone1').val('').parent().hide();
    $('.phone-add-btn').show();
};
window.addCandidateEmail = function(){
    $('#candidate_email1').parent().show();
    $('.email-add-btn').hide();
};
window.delCandidateEmail = function(){
    $('#candidate_email1').val('').parent().hide();
    $('.email-add-btn').show();
};