window.addUserToProject = function(uid){
    if(uid){
        window.location.href = '/projects/add_users?uids[]=' + uid;
    }else{
        var uids = $("input[name='uids[]']:checked");
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
    }
};

window.addExpertToProject = function(uid){
    if(uid){
        window.location.href = '/projects/add_experts?uids[]=' + uid;
    }else{
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

window.exportFinanceExcel = function(mode){
    var uids = $("input[name='uids[]']:checked");
    if(!['en', 'cn'].includes(mode)){
        alert('参数错误');
        return false;
    }
    if(uids.length === 0){
        alert('请至少选择一个条目');
    }else{
        var params = uids.map(function(){ return 'uids[]=' + this.value }).get().join('&');
        params = params + '&mode=' + mode;
        window.location.href = '/finance/export_finance_excel?' + params;
    }
};