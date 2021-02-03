var currentStlName;
$( function () {
    getLocalAppSTL();
})

function getLocalAppSTL(){
	var data = js.getStlList() || null;
	// var data = ''
	var stlListHTML = '';
	if(data) {
	    var stlList = eval('('+data+')')
		var index = 0;
		stlListHTML += '<div class="child_title">请选择一个需要上传的模型</div>';
		for (var i in stlList) {
			if(index==0){
				stlListHTML += '<div class="each_stl clearfix index_'+index+' active_stl" onclick="choseStl(this)">';
				currentStlName=stlList[i].realStlName;
			}
			else{
				stlListHTML += '<div class="each_stl clearfix index_'+index+'" onclick="choseStl(this)">';
			}
			stlListHTML += '<input type="hidden" class="this_name" value="\''+stlList[i].realStlName+'\'">';
			stlListHTML += '<div class="img_wrapper"><img src="file://' + stlList[i].localImg + '"  class="drag sprint"></div>';
			var name  =stlList[i].sourceStlName.split(".stl")[0];
			stlListHTML += '<div class="name">' + name + '</div>';
			stlListHTML += '</div>';
			index++
		}
		$(".submit_wrapper").show();
	}
	else{
        stlListHTML ='<div class="no_module">您目前还没有模型<br><span onclick=" goPage(4) ">点击这里创建模型</span></div>'
		$(".submit_wrapper").hide();
	}
	$(".list_stl").html(stlListHTML)

}
function choseStl(obj){
	$(".active_stl").removeClass("active_stl");
	$(obj).addClass("active_stl");
	currentStlName = $(obj).find(".this_name").val();
}

function submitStl(){
    if(!currentStlName){
	    currentStlName = $(".active_stl").find(".this_name").val();
	}
	var  flag = js.sendGcode(currentStlName);
	// var  flag = false
	if(!flag){
		$(".note_error,.note_error_bg").show();
		setTimeout(function(){
			$(".note_error,.note_error_bg").hide();
		},2000)
	}
}
function goPage(type) {//type 1,我的模型 2 商城 3 模型库首页 4 创建模型 5 返回上一页
	if(type==1) {
		js.changeActive( "1" );//1,我的模型 2 商城 3 模型库首页 4 创建模型 5 返回上一页
	}
	else if(type==2) {
		js.changeActive( "2" );
	}
	else if(type==3) {
		js.changeActive( "3" );
	}
	else if(type==4) {
		js.changeActive( "4" );
	}
}
