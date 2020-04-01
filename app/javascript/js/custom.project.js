window.addUserToProject = function(){
    var uids = $("input[name='uids[]']:checked");
    //var from_source = $('#from_source').val();
    if(uids.length === 0){
        alert('请至少选择一位用户');
    }else{
        var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
        var project_id = $('#project_id').val();
        if(project_id){
            params = params + '&project_id=' + project_id;
        }
        window.location.href = '/projects/add_users?' + params;
    }
};

window.addExpertToProject = function(){
    var uids = $("input[name='uids[]']:checked");
    if(uids.length === 0){
        alert('请至少选择一位专家');
    }else{
        var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
        var project_id = $('#project_id').val();
        if(project_id){
            params = params + '&project_id=' + project_id;
        }
        window.location.href = '/projects/add_experts?' + params;
    }
};

window.batchUpdateChargeStatus = function(s){
    var uids = $("input[name='uids[]']:checked");
    if(uids.length === 0){
        alert('请至少选择一个条目');
    }else{
        var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
        params = params + '&status=' + s;
        window.location.href = '/finance/batch_update_charge_status?' + params;
    }
};

window.batchUpdatePaymentStatus = function(s){
    var uids = $("input[name='uids[]']:checked");
    if(uids.length === 0){
        alert('请至少选择一个条目');
    }else{
        var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
        params = params + '&status=' + s;
        window.location.href = '/finance/batch_update_payment_status?' + params;
    }
};