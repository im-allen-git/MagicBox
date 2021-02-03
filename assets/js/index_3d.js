var X;//模型长
var Y;//模型宽
var Z;//模型高
var material;//模型材料消耗
var size;//模型大小
var moduleName; //模型名称
var exeTimeStr; //打印时间
$( function () {
    
} );


function thisParamInfo( type ) {
	if (type == 0) {
        X = $(".swiper-slide-active").find(".X").val();
        Y = $(".swiper-slide-active").find(".Y").val();
        Z = $(".swiper-slide-active").find(".Z").val();
        material = $(".swiper-slide-active").find(".material").val();
        size = $(".swiper-slide-active").find(".size").val();
        moduleName = $(".swiper-slide-active").find(".moduleName").val();
        exeTimeStr = $(".swiper-slide-active").find(".exeTimeStr").val();
        $("#XYZ").text(X + " " + Y + " " + Z)
        $("#moduleSize").text(size)
        $("#useMaterial").text(material)
        $("#printDuration").text(exeTimeStr)
		$( ".module_param,.module_param_bg" ).show();
        $(".outer_printbtn").hide();
	} else if (type == 1){
//	    var sendFlag = js.printerGcode(moduleName, 0);
        var moduleInfo= {"moduleName":moduleName,"type":0}
        webkit.messageHandlers.printerGcode.postMessage(moduleInfo)
	    if(sendFlag){
	        $( ".module_param,.module_param_bg" ).hide();
            $(".outer_printbtn").show();
	    }
        else{
        }
	} else if (type == 2){
	    $( ".module_param,.module_param_bg" ).hide();
        $(".outer_printbtn").show();
	}
}

function getDefaultStl(localStl){
    //alert(1)
	// var localStl = JsBridge.getLocalStl("99");
    
    var data = eval('('+localStl+')')
//    log("index")
//    log(data)
	var slideHtml = ''
	for(var i in data){
		slideHtml += '<div class="swiper-slide"><div class="img_wrapper">'
		slideHtml += '<img src="'+data[i].localImg+'" alt="">'
		slideHtml += '<input type="hidden" class="X" value="'+data[i].length+'">'
		slideHtml += '<input type="hidden" class="Y" value="'+data[i].width+'">'
		slideHtml += '<input type="hidden" class="Z" value="'+data[i].height+'">'
		slideHtml += '<input type="hidden" class="material" value="'+data[i].material+'">'
		slideHtml += '<input type="hidden" class="size" value="'+data[i].size+'">'
		slideHtml += '<input type="hidden" class="exeTimeStr" value="'+data[i].exeTimeStr+'">'
		var gcode = data[i].localGcodeName.split("/localModules/")[1];
		slideHtml += '<input type="hidden" class="moduleName" value="'+gcode+'">'
		slideHtml += '</div></div>';
	}
	$(".swiper-wrapper").html(slideHtml);
	var swiper = new Swiper( '.swiper-container', {
		spaceBetween: 0,
		freeMode: false,
		freeModeSticky: true,
		direction: 'vertical',
		navigation: {
			nextEl: '.swiper-button-next',
			prevEl: '.swiper-button-prev',
		},

	} );
}


function sayHello(msg){
    alert(msg);
}
