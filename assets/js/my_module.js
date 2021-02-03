var selectedSlideObj, parentsObj,this_obj;
var touchStartX, touchStartY; //点击目标的xy坐标
var movedDir; //移动的距离x
var DLETET_LEFT = 83;
var Xflag =false;
var Yflag =false;
var X;//模型长
var Y;//模型宽
var Z;//模型高
var material;//模型材料消耗
var size;//模型大小
var moduleName; //模型名称
var exeTimeStr; //打印时间
$( function () {
	//getLocalAppSTL();
	//getSDsTL();
} );
function showCurrentModule(type){
	$(".swiper-wrapper").each(function(){
		$(this)[0].style = '';
	})
	$(".active_menu").removeClass("active_menu");
	switch (type) {
		case 0:
			$(".mine .sec_btn").addClass("active_menu");
			$(".mine_content").show();
			$(".bought_content,.local_content").hide();
			break;
		case 1:
			$(".bought .sec_btn").addClass("active_menu");
			$(".bought_content").show();
			$(".mine_content,.local_content").hide();
			break;
		case 2:
			$(".local .sec_btn").addClass("active_menu");
			$(".local_content").show();
			$(".mine_content,.bought_content").hide();
			break;
	}
	$("#contentModule").html();
}

function thisParamInfo( type ,obj) {
	if (type == 0) {
	    var parent = $(obj).parents(".each_module");
	    X = parent.find(".X").val();
        Y = parent.find(".Y").val();
        Z = parent.find(".Z").val();
        material = parent.find(".material").val();
        size = parent.find(".size").val();
        moduleName = parent.find(".moduleName").val();
        exeTimeStr = parent.find(".exeTimeStr").val();
        $("#XYZ").text(X + " " + Y + " " + Z)
        $("#moduleSize").text(size)
        $("#useMaterial").text(material)
        $("#printDuration").text(exeTimeStr)
		$( ".module_param,.module_param_bg" ).show();
		if(exeTimeStr == "00:00:00"){
            $(".module_param .print_btn,.module_param .tip").hide();
            $(".note").show();
            return
        }
	}else if (type == 1){
//        var sendFlag = js.printerGcode(moduleName, 1);
        var moduleInfo= {"moduleName":moduleName,"type":1}
        webkit.messageHandlers.printerGcode.postMessage(moduleInfo)
//        if(sendFlag){
//            $( ".module_param,.module_param_bg" ).hide();
//             $(".outer_printbtn").show();
//        }
//         else{
//         }
//        后续操作后台掉方法printLocalStl()
    }
    else if (type == 2){

        $(".module_param,.module_param_bg" ).hide();
        $("#XYZ").text("");
        $("#moduleSize").text("");
        $("#useMaterial").text("");
        $("#printDuration").text("");
        $(".module_param .print_btn,.module_param .tip").show();
        $(".note").hide();
        //log("后台stl")
        //log(obj)
        getLocalAppSTL(obj);
	}
}
function printLocalStl(flag){
    if(flag>0){
        $( ".module_param,.module_param_bg" ).hide();
        $(".outer_printbtn").show();
    }
    else{
        alert("请重试")
    }
}
function thisSDParamInfo( type ,obj) {
	if (type == 0) {
	    var parent = $(obj).parents(".each_module");
        size = parent.find(".size").val();
        moduleName = parent.find(".moduleName").val();
        $("#moduleSize").text(size)
		$( ".sd_module_param,.module_param_bg" ).show();
	}else if (type == 1){
        var sendFlag = js.printerGcode(moduleName, 1);
        if(sendFlag){
            $( ".sd_module_param,.module_param_bg" ).hide();
             $(".outer_printbtn").show();
        }
         else{
         }
    }
    else if (type == 2){
        $(".sd_module_param,.module_param_bg" ).hide();
        $("#XYZ").text("");
        $("#moduleSize").text("");
        $("#useMaterial").text("");
        $("#printDuration").text("");
        $(".sd_module_param .print_btn,.sd_module_param .tip").show();
        $(".note").hide();
        //log("123")
        getLocalAppSTL(obj);
	}
}
function getLocalAppSTL(localStl){
    if(localStl.length<5){
        //log("no info")
        return
    }
    var data = eval('('+localStl+')')
	var stlListHTML = '';
	if(data && data !=null && data.length>0) {
		var stlList = data;
		for (var i in stlList) {
			stlListHTML += '<div class="each_module"><div class="each_module_wrapper clearfix swiper-container localStlSwiper"><div class="swiper-wrapper">';
            stlListHTML += '<div class="swiper-slide">';
            var imgSrc=(stlList[i].localImg).replace("Documents","tmp")
            stlListHTML += '<div class="col-xs-3"><img src="'+imgSrc+'" alt=""></div>';
            stlListHTML += '<div class="col-xs-9">';
            var name  =stlList[i].sourceStlName.split(".stl")[0];
            stlListHTML += '<div class="module_name">'+name+'</div>';
            stlListHTML += '<div class="module_time"><div class="info">创建时间: <span class="this_createTime">'+stlList[i].createTime+'</span></div></div>';
            stlListHTML += '<div class="module_size"><div class="info">打印尺寸(mm): <span class="this_createTime">'+stlList[i].length+" "+stlList[i].width+" "+stlList[i].height+'</span></div></div>';
            stlListHTML += '<div class="img_wrapper showHide first_child"><img src="../img/3dPrinting/btn_print.png" alt="" onclick="thisParamInfo(0,this)">';
            if(stlList[i].flag == 1) { // 0未上传 1上传
                stlListHTML += '<i style="font-style:normal;color:red;font-size:.1rem;position: absolute; left: 1rem; top: .1rem;">已存入SD卡</i>';
            }
            else if(stlList[i].exeTimeStr == "00:00:00"){
                stlListHTML += '<i style="font-style:normal;color:red;font-size:.1rem;position: absolute; left: 1rem; top: .1rem;">文件生成中，请稍等</i>';
            }
            stlListHTML += '</div>';
            stlListHTML += '</div></div>';
            stlListHTML += '<div class="swiper-slide delete_slide" onclick="deleteThisModule(this,\''+stlList[i].realStlName+'\')"><div class="delete">删除</div></div>';
            stlListHTML += '</div>';
            stlListHTML += '<input type="hidden" class="X" value="'+stlList[i].length+'">'
            stlListHTML += '<input type="hidden" class="Y" value="'+stlList[i].width+'">'
            stlListHTML += '<input type="hidden" class="Z" value="'+stlList[i].height+'">'
            stlListHTML += '<input type="hidden" class="material" value="'+stlList[i].material+'">'
            stlListHTML += '<input type="hidden" class="size" value="'+stlList[i].size+'">'
            stlListHTML += '<input type="hidden" class="exeTimeStr" value="'+stlList[i].exeTimeStr+'">'
            stlListHTML += '<input type="hidden" class="moduleName" value="'+stlList[i].realStlName+'">'
            stlListHTML += '</div></div>';
		}
	}
	else{
		stlListHTML+='<div class="no_module">您还没有创建模型哦<br><span onclick=" goPage(4) ">点击这里创建模型</span></div>'
	}
	$(".mine_content").html(stlListHTML)
    var swiper1 = new Swiper('.localStlSwiper', {
            slidesPerView: 'auto',
            spaceBetween: 0,
            freeMode: false,
            freeModeSticky : true,
            resistance:true,
            observer: true,
            observeParents: true
        });
}
function getSDsTL(){
	var data = js.getSdList() || null;
	var stlListHTML = '';
	if(data && data !=null && data.length>1) {
	    if(data.length>5){
		var stlList = eval('('+data+')');
		for (var i in stlList) {
			stlListHTML += '<div class="each_module"><div class="each_module_wrapper clearfix swiper-container sdStlSwiper"><div class="swiper-wrapper">';
            stlListHTML += '<div class="swiper-slide">';
            stlListHTML += '<div class="col-xs-12">';
            var name  =stlList[i].localGcodeName.split(".GCO")[0];
            stlListHTML += '<div class="module_name">'+name+'</div>';
            stlListHTML += '<div class="module_time"><div class="info">文件大小: <span class="this_createTime">'+stlList[i].size+'</span></div></div>';
            stlListHTML += '<div class="img_wrapper showHide first_child"><img src="../img/3dPrinting/btn_print.png" alt="" onclick="thisSDParamInfo(0,this)"></div>';
            stlListHTML += '</div></div>';
            stlListHTML += '<div class="swiper-slide delete_slide" onclick="deleteSDModule(this,\''+stlList[i].localGcodeName+'\')"><div class="delete">删除</div></div>';
            stlListHTML += '</div>';
            stlListHTML += '</div></div>';
		}
		}
		else if(data == "11"){
		    stlListHTML+='<div class="no_module">您没有连接打印机，请连接打印机</div>'
		}
	}
	else{
		stlListHTML+='<div class="no_module">您的SD卡中，还没有模型哦</div>'
	}
//	console.log(stlListHTML)
	$(".local_content").html(stlListHTML)
	var swiper2 = new Swiper('.sdStlSwiper', {
        slidesPerView: 'auto',
        spaceBetween: 0,
        freeMode: false,
        freeModeSticky : true,
        resistance:true,
        observer: true,
        observeParents: true
    });

}
var allModule,allModuleLength,eachModule;
function deleteThisModule(obj,name){
	var e = event || window.event || arguments.callee.caller.arguments[0];
	if ( e && e.stopPropagation ){
		e.stopPropagation();
	}else{ //ie
		window.event.cancelBubble = true;
	}
    $.dialog({
        type: 'confirm',
        showTitle: false,
        overlayClose:true,
        contentHtml: '<p class="red_note" style="word-break: break-word;text-align:center;">确定要删除该模型么?</p>',
        buttonText : {//按钮文本内容
            ok : '确定',
            cancel:'取消'
        },
        buttonClass : {
            ok:'removeThis_ok',
            cancel:'removeThis_cancel'
        },
        onClickOk : function(){
            allModule = $(obj).parents(".module_content");
            allModuleLength = $(obj).parents(".module_content").find(".each_module");
            eachModule = $(obj).parents(".each_module");
            $("#loading_data").show();
//            var deletedSuccFlag = js.deleteStl(name);
            //log("shanchu qian")
             webkit.messageHandlers.deleteStl.postMessage(name)
            
        },
        onClickCancel : function(){

        }
    });

}
function deletedAfter(deletedSuccFlag){
    //log("deleteFlag")
    log(deletedSuccFlag)
    if(deletedSuccFlag>0){
        if(allModuleLength.length>1){
            eachModule.remove();
        }
        else{
            if(allModule.hasClass("mine_content")){
                var stlListHTML='<div class="no_module">您还没有创建模型哦<br><span onclick=" goPage(4) ">点击这里创建模型</span></div>'
                $(".mine_content").html(stlListHTML);
            } else if(allModule.hasClass("mine_content")){
                var stlListHTML='<div class="no_module">您还没有购买哦，<span onclick=" goPage(2) ">点击这里浏览</span></div>'
                $(".bought_content").html(stlListHTML);
            }
            else if(allModule.hasClass("local_content")){
                var stlListHTML='<div class="no_module">您还没有本地模型哦</div>'
                $(".bought_content").html(stlListHTML);
            }
        }
        allModuleLength='';
        eachModule='';
        allModule='';
    }
    else{
        $(".note_error").show();
        setTimeout(function(){
            $(".note_error").hide();
        },1500)
        allModuleLength='';
        eachModule='';
        allModule='';
    }
    $("#loading_data").hide();

}
function deleteSDModule(obj,name){
	var e = event || window.event || arguments.callee.caller.arguments[0];
	if ( e && e.stopPropagation ){
		e.stopPropagation();
	}else{ //ie
		window.event.cancelBubble = true;
	}
    $.dialog({
        type: 'confirm',
        showTitle: false,
        overlayClose:true,
        contentHtml: '<p class="red_note" style="word-break: break-word;text-align:center;">确定要删除该模型么?</p>',
        buttonText : {//按钮文本内容
            ok : '确定',
            cancel:'取消'
        },
        buttonClass : {
            ok:'removeThis_ok',
            cancel:'removeThis_cancel'
        },
        onClickOk : function(){
            var allModule = $(obj).parents(".module_content");
            var allModuleLength = $(obj).parents(".module_content").find(".each_module");
            var eachModule = $(obj).parents(".each_module");
            $("#loading_data").show();
            var deletedSuccFlag = js.deleteStl(name);
            if(deletedSuccFlag){
                if(allModuleLength.length>1){
                    eachModule.remove();
                }
                else{
                    if(allModule.hasClass("mine_content")){
                        var stlListHTML='<div class="no_module">您还没有创建模型哦<br><span onclick=" goPage(4) ">点击这里创建模型</span></div>'
                        $(".mine_content").html(stlListHTML);
                    } else if(allModule.hasClass("mine_content")){
                        var stlListHTML='<div class="no_module">您还没有购买哦，<span onclick=" goPage(2) ">点击这里浏览</span></div>'
                        $(".bought_content").html(stlListHTML);
                    }
                    else if(allModule.hasClass("local_content")){
                        var stlListHTML='<div class="no_module">您还没有本地模型哦</div>'
                        $(".bought_content").html(stlListHTML);
                    }
                }
            }
            else{
                $(".note_error").show();
                setTimeout(function(){
                    $(".note_error").hide();
                },1500)
            }
            $("#loading_data").hide();
        },
        onClickCancel : function(){

        }
    });

}
function showTipDetail(type){
    if(type == 0){
        $(".tip_detail").show();
    }
    else if(type==1){
        $(".tip_detail").hide();
    }
}
