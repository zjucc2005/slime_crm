window.addUserToProject = function(){
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