
;(function(win,$){
    var wrap, overlay, content, title, close, closeX,showClose, cancelBtn, okBtn, delBtn, settings, timer;
    var _renderDOM = function(){
        if( $('.dialog-wrap').length > 0){
            return;
        }

        clearTimeout(timer);
        settings.onBeforeShow();

        $('body').append( dialogWrapper = $('<div class="dialog-wrap '+ settings.dialogClass +'"></div>') );
        dialogWrapper.append(
            overlay = $('<div class="dialog-overlay"></div>'),
            content = $('<div class="dialog-content"></div>')
        );

        switch (settings.type){
            case 'alert' :
                if(settings.showClose){
                    content.append(
                        closeX = $('<span class="dialog-close del-close">X</span>')
                    );
                }
                if(settings.showTitle){
                    content.append(
                        title = $('<div class="dialog-content-hd"><h4 class="dialog-content-title">'+ settings.titleText +'</h4></div>')
                    );
                }
                content.append(
                    contentBd = $('<div class="dialog-content-bd">'+ settings.contentHtml +'</div>')
                );
                content.append(
                    contentFt = $('<div class="dialog-content-ft"></div>')
                );
                contentFt.append(
                    okBtn = $('<a class="dialog-btn dialog-btn-ok '+ settings.buttonClass.ok +'" href="javascript:;">'+ settings.buttonText.ok +'</a>')
                );
                break;

            case 'confirm' :
                if(settings.showClose){
                    content.append(
                        closeX = $('<span class="dialog-close del-close"></span>')
                    );
                }
                if(settings.showTitle){
                    content.append(
                        title = $('<div class="dialog-content-hd"><h4 class="dialog-content-title">'+ settings.titleText +'</h4></div>')
                    );
                }
                content.append(
                    contentBd = $('<div class="dialog-content-bd">'+ settings.contentHtml +'</div>')
                );
                content.append(
                    contentFt = $('<div class="dialog-content-ft"></div>')
                );
                contentFt.append(
                    cancelBtn = $('<a class="dialog-btn dialog-btn-cancel '+ settings.buttonClass.cancel +'" href="javascript:;">'+ settings.buttonText.cancel +'</a>'),
                    okBtn = $('<a class="dialog-btn dialog-btn-ok '+ settings.buttonClass.ok +'" href="javascript:;">'+ settings.buttonText.ok +'</a>')
                );
                break;

            case 'info' :
                var infoContent = settings.contentHtml || '<img class="info-icon" src="'+ settings.infoIcon +'" alt="'+ settings.infoText +'" /><p class="info-text">'+ settings.infoText +'</p>';
                content.append(
                    contentBd = $('<div class="dialog-content-bd">'+ infoContent +'</div>')
                );
                dialogWrapper.addClass('dialog-wrap-info');
                content.addClass('dialog-content-info');
                break;

            default :
                break;
        }

        setTimeout(function(){
            dialogWrapper.addClass('dialog-wrap-show');
            settings.onShow();
        }, 10);

    };

    var _bindEvent = function() {

        $(okBtn).on('click', function(e){
            settings.onClickOk();
            $.dialog.close();
            return false;
        });

        $(cancelBtn).on('click', function(e){
            settings.onClickCancel();
            $.dialog.close();
            return false;
        });

        // overlay clisk hide
        if( settings.overlayClose ){
            overlay.on('click', function(e){
                $.dialog.close();
            });
        }
        // content clisk hide
        /*if( settings.overlayClose ){
            content.on('click', function(e){
                $.dialog.close();
            });
        }*/

        // overlay clisk hide
        if( settings.showClose ){
            closeX.on('click', function(e){
                $.dialog.close();
                return false;
            });
        }
        // auto close, set autoClose and type isn't info
        if( settings.autoClose > 0 ){
            _autoClose();
        }

    };

    var _autoClose = function(){
        clearTimeout(timer);
        timer = window.setTimeout(function(){
            $.dialog.close();
        }, settings.autoClose);
    };



    /*
     * Public methods 
     */

    $.dialog = function(options) {
        settings = $.extend({}, $.fn.dialog.defaults, options);
        $.dialog.init();
        return this;
    };

    $.dialog.init = function(){
        _renderDOM();
        _bindEvent();
    };


    $.dialog.close = function(){
        settings.onBeforeClosed();
        dialogWrapper.removeClass('dialog-wrap-show');
        setTimeout(function(){
            dialogWrapper.remove();
            settings.onClosed();
        }, 200);
    };

    $.dialog.update = function(params) {
        if(params.infoText) {
            content.find('.info-text').html(params.infoText);
        }
        if(params.infoIcon) {
            content.find('.info-icon').attr('src', params.infoIcon);
        }
        if(params.autoClose>0){
            window.setTimeout(function(){
                $.dialog.close();
            }, params.autoClose);
        }
    };


    // 鎻掍欢
    $.fn.dialog = function(options){
        return this;
    };


    $.fn.dialog.defaults = {
        type : 'alert',     // 默认alert
        titleText : '自定义文本标题',//标题内容
        showTitle : false,//是否显示标题
        contentHtml : '',//内容区域
        dialogClass : '',//给弹框添加类名
        autoClose : 0,//几秒后自动消失
        overlayClose : false,//是否点击蒙版关闭
        showClose:false,//是否显示关闭按钮
        drag : false,
        buttonText : {//按钮文本内容
            ok : '',
            cancel : '',
        },
        buttonClass : {//按钮添加类名
            ok : '',
            cancel : '',
        },

        infoText : '',      // 提示信息文本
        infoIcon : '',      // 提示信息图片

        onClickOk : function(){},
        onClickCancel : function(){},

        onBeforeShow : function(){},
        onShow : function(){},
        onBeforeClosed : function(){},
        onClosed : function(){}//关闭执行的函数
    }

})(window, window.Zepto || window.jQuery);