//window.cardTemplate = function(){
//    var uids = $("input[name='uids[]']:checked");
//    if(uids.length === 0){
//        alert('请至少选择一位专家');
//    }else{
//        var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
//        //window.location.href = '/candidates/card_template?' + params;
//        window.open('/candidates/card_template?' + params);
//    }
//};

window.cardTemplate = function(card_template_id, uid){
    if(card_template_id){
        if(uid){
            var params = 'uids[]=' + uid;
        }else{
            var uids = $("input[name='uids[]']:checked");
            if(uids.length === 0){
                alert('请至少选择一位专家');
                return
            }else{
                var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
            }
        }
        params += '&card_template_id=' + card_template_id;
        window.location.href = '/candidates/gen_card?' + params;
        //window.open('/candidates/gen_card?' + params);
    }else{
        alert('参数错误');
    }
};

window.expertTemplate = function(project_id){
    var uids = $("input[name='uids[]']:checked");
    if(uids.length === 0){
        alert('请至少选择一位专家');
    }else{
        var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
        if(project_id){
            params += '&project_id=' + project_id;
        }
        window.location.href = '/candidates/expert_template?' + params;
    }
};

window.showPhoneLocation = function(obj_id){
    var obj = $('#' + obj_id);
    if(obj.val()){
        $.ajax({
            url: '/location_data/show_phone_location?',
            type: 'get',
            data: { phone: obj.val() },
            dataType: 'json',
            success: function(data){
                console.log(data);
                if(data.status === '0'){
                    $('#' + obj_id + '_location').text([data.city, data.type].join(', '));
                    var city = $('#candidate_city');
                    if(!city.val()){
                        city.val(data.city);
                    }
                }
            }
        })
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
};