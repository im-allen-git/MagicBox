
var dragObj;
var selectedDragObj;
var selectedDragObjFlag;
var maxW, maxH;
var shapesEventL = document.getElementById( "childWrapper" );
var shapesMain = document.getElementById( "shapes" );
var movedDir; //拖拽距离
var dragedFlag = false;
var listShapes = [];
var listLDraw = [];
var listSTL = [];
var saveFlag = false;

// var mobile = /Android|webOS|iPhone|iPad|BlackBerry/i.test( navigator.userAgent );
var mobile = true;
var container = document.getElementById( 'container' ); //
var twoPointTouchFlag = false;
var pointOneFlag, pointTwoFlag, touchScale;
var camera, scene, renderer;
var directionalLight, spotLight;
var cameraZoom = 1;
var outlinePass, composer, effectFXAA, renderPass;
var plane;
var gridHelper, gradGroundMesh, gradGroundMesh1;
var mouse, raycaster, isShiftDown = false;
var controls;
var mouseHelper, mouseHelperMaterial;
var controlsMoved = false;
var objects = [];
var currentObj; //当前形状
var currentObjMaterial = new THREE.MeshLambertMaterial( { color: 0xdddddd } );
var currentShapeType;
var currentColorFlag = 0;
var currentObjMesh; //当前obj mesh
var shapeHelperObjects = [];
var shapesObj = []; //所有的当前已放置的obj
var currentAllObjs = []; //所有的当前已放置的obj
var transformControl;
var WORK_SPACE_SIZE = 100;
var SHAPE_SIZE = 10;
var LIMIT_SIZE = 4;
var tcX, tcY, tcZ, tcScale, tcScaleY; //当前对象的xyz值
var tcScaleYPosition, tcScaleYPositionFlag; //tcScaleYPosition: 改变大小之前位置；tcScaleYPosition: 改变大小之前是否贴住工作台
var transformControlModeType = 1;
var transformControlMove = false;
var transformDragFlag = true;
var focusedTransformObj;
var textTR = '当前状态:<br>移动';
var textSC = '当前状态:<br>改变大小';
var textRO = '当前状态:<br> 旋转';
var intersectsSelect = [];
var intersection = {
	intersects: false,
	point: new THREE.Vector3(),
	normal: new THREE.Vector3()
};
var allOperation = [];//all the operated operation(undo)
var redoOperation = [];//all the redo operation
var eachObjectInfo = {};//每一个对象的每一个步骤；
var eachRedoObjectInfo = {};//每一个对象的每一个步骤；
var shootedFlag = false;

var stlGeoFlag = 0; //0 geo; 1 stl 2, localStl
//LDraw
var lDrawModul;
var lDrawModulGUI;
var lDrawGuiData = {
	smoothNormals: true,
	separateObjects: true,
	constructionStep: 0,
	noConstructionSteps: "无步骤"
};
//LDraw  end
var currentModule = 0; //0:基础模型 1：lego
var goHomeFlag = false;//是否是点击首页
var deleteObjFlag = false;//是否点击了删除

var mouse = new THREE.Vector2();
var modifier = new THREE.BendModifier();
var fontObj;
var exporter = new THREE.STLExporter(); //导出工具  exporter tool
var nameValidate;
var userName;
var model_ring;
var model_longmao;
var model_shudi;
var model_heart;
var currentModelStl=0;
var checkNameFlag=false;//名字检测是否通过
$( function () {
	var swiper = new Swiper( '.swiper-container', {
		freeMode: false,
		freeModeSticky: true,
		// loop:true,
		observer: true,//修改swiper自己或子元素时，自动初始化swiper
		observeParents: true,//修改swiper的父元素时，自动初始化swiper
		navigation: {
			nextEl: '.swiper-button-next',
			prevEl: '.swiper-button-prev',
		},
		on: {
			slideChangeTransitionEnd: function(){
				log(this.activeIndex);//切换结束时，告诉我现在是第几个slide
				currentModelStl = this.activeIndex;
			},

		},
	} );
	init();
	render();
} );
function checkName() {
	var name = $("#modelName").val();
	userName = name;
	if(name){
		showLoading();
		$("#title").text("选择定制模型")
		$(".name_wrapper").hide();
		$(".modules_slides").show(200);
		loadSTL(1);
		checkNameFlag=true;
	}
	else{
		$(".validate_name").show();
		nameValidate = setTimeout(function(){
			$(".validate_name").hide();
		},2000)
	}
}
function clearTimeoutFn() {
	clearTimeout(nameValidate)
	$(".validate_name").hide();
	$("#modelName").focus();
}
function confirmPrint(){
	if(currentModelStl == 0){
		// saveString(model_ring,userName+".stl")
		saveString(model_heart,userName+"-heart.stl")
	}
	else if(currentModelStl == 1){
		saveString(model_longmao,userName+"longmao.stl")
	}
	else if(currentModelStl == 2){
		saveString(model_shudi,userName+"-shudi.stl")
	}
}
//main
function init() {
	renderer = new THREE.WebGLRenderer( { antialias: true, alpha: true, preserveDrawingBuffer: true} );
	renderer.setPixelRatio( ( window.devicePixelRatio ) ? window.devicePixelRatio : 1 );
	renderer.setSize( window.innerWidth, window.innerHeight );
	renderer.shadowMap.enabled = true;
	renderer.autoClear = false;
	renderer.setClearColor( 0x000000, 0.0 );
	container.appendChild( renderer.domElement );

	camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 10000 );
	// camera.position.set( 0, 200, 350 ); //正面
	camera.position.set( 83, 71, 124); //45°
	camera.lookAt( 0, 0, 0 );

	scene = new THREE.Scene();
	// scene.background = new THREE.Color( 0xf0f0f0 );
	// scene.background = new THREE.Color( 0xf8f8f9 );
	// scene.background = new THREE.Color( 0xffffff );
	// scene.userData.outlineEnabled = true;
	// scene.add( new THREE.AxesHelper( 50 ) ); //坐标位置辅助线 Coordinate system

	// roll-over helpers

	var rollOverGeo = new THREE.BoxBufferGeometry( SHAPE_SIZE, SHAPE_SIZE, SHAPE_SIZE );
	mouseHelperMaterial = new THREE.MeshBasicMaterial( { color: 0xff0000, opacity: 0.5, transparent: true } );
	mouseHelper = new THREE.Mesh( rollOverGeo, mouseHelperMaterial );
	if (! mobile) {
		scene.add( mouseHelper );
	}

	raycaster = new THREE.Raycaster();
	mouse = new THREE.Vector2();

	var geometry = new THREE.PlaneBufferGeometry( WORK_SPACE_SIZE, WORK_SPACE_SIZE );
	geometry.rotateX( - Math.PI / 2 );

	plane = new THREE.Mesh( geometry, new THREE.MeshBasicMaterial( { color: 0xe5e4df, visible: true } ) );
	plane.name = "plane";
	plane.receiveShadow = true;
	plane.castShadow = true;
	scene.add( plane );
	objects.push( plane );

	// grid

	gridHelper = new THREE.GridHelper( WORK_SPACE_SIZE, 20, 0x999999, 0xc999999 );
	// gridHelper = new THREE.GridHelper( 300, 6, 0x999999, 0xc999999 );
	gridHelper.name = 'GridHelper';
	scene.add( gridHelper );

	gradGroundMesh = new THREE.Mesh( new THREE.BoxBufferGeometry( WORK_SPACE_SIZE, .8, WORK_SPACE_SIZE ), new THREE.MeshLambertMaterial( { color: 0xffffff } ) );
	gradGroundMesh.position.y = - .8;
	gradGroundMesh.name = 'GridHelper';
	gradGroundMesh.receiveShadow = true;
	gradGroundMesh.castShadow = true;
	scene.add( gradGroundMesh );
	gradGroundMesh1 = new THREE.Mesh( new THREE.BoxBufferGeometry( WORK_SPACE_SIZE, 3, WORK_SPACE_SIZE ), new THREE.MeshLambertMaterial( { color: 0xffc869 } ) );
	gradGroundMesh1.position.y = - 2.5;
	gradGroundMesh1.name = 'GridHelper';
	gradGroundMesh1.receiveShadow = true;
	gradGroundMesh1.castShadow = true;
	scene.add( gradGroundMesh1 );
	//grid end

	// lights
	var ambientLight = new THREE.AmbientLight( 0x606060, 1 ); //0x606060
	scene.add( ambientLight );
	directionalLight = new THREE.DirectionalLight( 0xFFFFFF, 1.3 );
	directionalLight.position.set( 1, 0.75, 0.5 ).normalize();
	// dirLightHeper = new THREE.DirectionalLightHelper( directionalLight, 215 );//光源辅助线
	// scene.add( dirLightHeper );
	scene.add( directionalLight );

	container.addEventListener( 'resize', onWindowResize, false );
	window.addEventListener( 'resize', onWindowResize, false );
	getFont();
	animate();
	onWindowResize();
}

function animate() {
	requestAnimationFrame( animate );
	renderer.render( scene, camera );
	// stats.update();
}

function onWindowResize() {
	var controlBoardWidth = $( "#shapes" ).hasClass( "shapes_close" ); //left decal side width
	if (controlBoardWidth) {
		camera.aspect = ( window.innerWidth ) / window.innerHeight;
		renderer.setSize( window.innerWidth, window.innerHeight );
		composer.setSize( window.innerWidth, window.innerHeight );
		effectFXAA.uniforms['resolution'].value.set( 1 / window.innerWidth, 1 / window.innerHeight );

	} else {
		camera.aspect = ( window.innerWidth - 100 ) / window.innerHeight;
		renderer.setSize( window.innerWidth - 100, window.innerHeight );
	}
	camera.updateProjectionMatrix();

}

function render() {

	renderer.render( scene, camera );

}

/**
 * 清空当前obj对象的缓存
 * @param mesh  mesh对象
 * */
function clearCache( currentMesh ) {
	currentMesh.geometry.dispose();
	currentMesh.material.dispose();
}
function checkIntersection( event ) {
	var x, y;
	if (event.changedTouches) {
		x = event.changedTouches[0].pageX;
		y = event.changedTouches[0].pageY;
	} else {
		x = event.clientX;
		y = event.clientY;
	}
	mouse.x = ( x / window.innerWidth ) * 2 - 1;
	mouse.y = - ( y / window.innerHeight ) * 2 + 1;

	var controlBoardWidth = $( "#shapes" ).hasClass( "shapes_close" ); //left decal side width
	if (! controlBoardWidth) {
		mouse.x = ( x / ( window.innerWidth - 100 ) ) * 2 - 1;
		mouse.y = - ( y / window.innerHeight ) * 2 + 1;
	}
	if (! plane) return;
	raycaster.setFromCamera( mouse, camera );
	raycaster.intersectObject( plane, false, intersectsSelect );
	if (intersectsSelect.length > 0) {
		var p = intersectsSelect[0].point;
		mouseHelper.position.set( 0, 0, 0 );
		mouseHelper.position.copy( p );  //copy intersection position to mouseHelper
		intersection.point.copy( p );
		/*1.克隆旧的法线 2.旧法线乘以模型的世界矩阵得到归一化后的法线 3.和一个标量相乘，放大10倍。 4.加上点击点的坐标，进行平移。*/
		var n = intersectsSelect[0].face.normal.clone();
		n.transformDirection( plane.matrixWorld );
		n.multiplyScalar( 10 );
		n.add( intersectsSelect[0].point );

		intersection.normal.copy( intersectsSelect[0].face.normal );
		mouseHelper.lookAt( n );

		var sceneChilds = raycaster.intersectObjects( scene.children ); //get all objects in the current position of your mouse;
		if (sceneChilds.length > 1) {
			if (sceneChilds && ( sceneChilds[0].object.name == "shapes" || sceneChilds[0].object.name == "shapes_text" || sceneChilds[0].object.name == "stl" || sceneChilds[0].object.name == "stlLocal" )) {
				transformControl.detach( transformControl.object );
				transformControl.attach( sceneChilds[0].object );
			} else if (sceneChilds[0].object.name == "plane") {
				transformControl.detach( transformControl.object );
				transformControl.attach( sceneChilds[0].object );
			}
		}
		intersection.intersects = true;
		intersectsSelect.length = 0;

	} else {
		intersection.intersects = false;

		var sceneChilds = raycaster.intersectObjects( scene.children ); //get all objects in the current position of your mouse;
		if (sceneChilds.length > 0) {
			if (sceneChilds && ( sceneChilds[0].object.name == "shapes" || sceneChilds[0].object.name == "shapes_text" || sceneChilds[0].object.name == "stl" || sceneChilds[0].object.name == "stlLocal"  )) {
				transformControl.detach( transformControl.object );
				transformControl.attach( sceneChilds[0].object );
			} else if (sceneChilds[0].object.name == "plane") {
				transformControl.detach( transformControl.object );
				transformControl.attach( sceneChilds[0].object );
			}
		}
	}
	render();
}

// 导出相关
function exportMoudle( type , name,thisSTL) { //type 0: ASCII 1: GLTF
		scene.remove( mouseHelper );
		clearCache( gridHelper );
		scene.remove( gridHelper );
		clearCache( gradGroundMesh );
		scene.remove( gradGroundMesh );
		clearCache( gradGroundMesh1 );
		scene.remove( gradGroundMesh1 );
		clearCache( plane );
		scene.remove( plane );
		camera.position.set( 67, 57, 101 ); //45°
		camera.lookAt( 0, 0, 0 );
		// scene.rotateOnAxis( new THREE.Vector3( 1, 0, 0 ), -90 * ( Math.PI / 2 ) );
		animate();
		//threejs Y-up, 别的事Z-up,所以到处之前要旋转
		scene.rotation.set( Math.PI / 2, 0, 0 );
		scene.updateMatrixWorld();
		//end
		var nameStr = name;
		if (nameStr) {
			// exporter = new THREE.STLExporter(); //导出工具  exporter tool
			var result = exporter.parse( scene );
			if(thisSTL==0){
				model_ring = result;
				log("get model_ring result")
			} else if(thisSTL==1){
				model_longmao = result;
				log("get model_longmao result")
			}else if(thisSTL==2){
				model_shudi = result;
				log("get model_shudi result")
			}
			log("clean前：")
			log(scene.children)
			clearObjects();
			log("clean后：")
			log(scene.children)
			log("thisStl down:"+thisSTL)
			// saveString( result, nameStr + '.stl' );
			// saveAsImage(nameStr,result );
			// successFlag = true;

		}
/*
		scene.add( gridHelper );
		scene.add( gradGroundMesh );
		scene.add( gradGroundMesh1 );
		scene.add( plane );*/
		//threejs Y-up, 别的事Z-up,所以到处之前要旋转
		scene.rotation.set( 0, 0, 0 );
		scene.updateMatrixWorld();
	if(thisSTL==0){
		loadSTL(1)
	} else if(thisSTL==1){
		loadSTL(2);
	}else if(thisSTL==2){
		$("#es6Next").trigger("click")
	}
		//end
}

function save( blob, filename ) {
	var link = document.createElement( 'a' );
	link.style.display = 'none';
	link.className = 'saveFile';
	document.body.appendChild( link );
	link.href = URL.createObjectURL( blob );
	link.download = filename;
	link.click();
}

function saveString( text, filename ) {
	// log( new Blob( [ text ]))
	save( new Blob( [text], { type: 'text/plain' } ), filename );
}

function clearObjects(){
	// 保存成功，清空当前项目
	objects.forEach( function ( d ) {
		clearCache( d );
		scene.remove( d );
	} );
}
// 导出相关 end
//camera 方向

async function loadSTL( thisSTL, name ) {
	var file,fontSize;
	switch (thisSTL) {
		case 0:
			file = '../models/stl/ascii/3dPrinting/ring.stl';
			break;
		case 1:
			file = '../models/stl/ascii/3dPrinting/longmao.stl';
			break;
		case 2:
			file = '../models/stl/ascii/3dPrinting/shudi.stl';
			break;
		default:
			file = '../models/stl/ascii/3dPrinting/ring.stl';
	}

	var loader = new THREE.STLLoader();
	await loader.load( file, function ( geometry ) {
		currentObj = geometry;
		log(currentObj)
		var voxelMaterial = currentObjMaterial.clone();
		var voxel = new THREE.Mesh( currentObj, voxelMaterial );
		// voxel.rotation.set( Math.PI / 2, 0, 0 );
		voxel.rotation.x = -Math.PI/2;
		voxel.position.set( 0, 0, 0 );
		// voxel.position.divideScalar( SHAPE_SIZE*2.5 ).floor().multiplyScalar( SHAPE_SIZE*2.5 ).addScalar( SHAPE_SIZE*2.5/2 );
		voxel.name = "stl";
		voxel.scale.set(1,1,1)
		if(thisSTL==2){
			voxel.scale.set(.9,.9,.9)
		}
		voxel.receiveShadow = true;
		voxel.castShadow = true;
		objects.push( voxel );
		scene.add( voxel );
		creatModifiedName(userName,thisSTL)
	} );
}
//main end
function getFont(){
	var loader = new THREE.FontLoader();
	loader.load( '../css/font/other/SimHei_Regular.json', function ( font ) {
		fontObj = font;
		log("get Font")
	})
}
function creatModifiedName(name,thisSTL){
	var fontSize = 5;
	if(thisSTL == 0) {//戒指
		fontSize = 4;
	}
	/*var loader = new THREE.FontLoader();
	loader.load( '../css/font/other/SimHei_Regular.json', function ( font ) {*/
	if(fontObj) {
		log( "name::" + name )
		var currentWord = name.toUpperCase();
		log( "currentWord::" + currentWord )
		var textGeo = new THREE.TextGeometry( currentWord, {
			font: fontObj,
			size: fontSize,
			height: 1.2,
			curveSegments: 22,
			bevelEnabled: false
		} );
		textGeo.computeBoundingBox();
		textGeo.computeVertexNormals();
		var centerOffset = - 0.5 * ( textGeo.boundingBox.max.x - textGeo.boundingBox.min.x ); //位置，使其居中 centerOffset
		textGeo.translate( centerOffset, - 0, 0 );//坐标中心位置
		var textMaterial = new THREE.MeshPhongMaterial( { color: 0xff0000, specular: 0xffffff, flatShading: true } );
		var mesh = new THREE.Mesh( textGeo, textMaterial );
		mesh.receiveShadow = true;
		mesh.castShadow = true;
		if (thisSTL == 0) {//戒指
			mesh.rotation.y = Math.PI / 2; // 文字反转
			mesh.rotation.x = Math.PI / 2;
			mesh.position.x = 11.88;
			mesh.position.y = 12.61;
			mesh.position.z = - 1.99;
			var direction = new THREE.Vector3( 0, 0, - 1 );
			var axis = new THREE.Vector3( 0, 1, 0 );
			var angle = Math.PI / 6;
			modifier.set( direction, axis, angle ).modify( mesh.geometry );
		} else if (thisSTL == 1) { //龙猫
			mesh.rotation.y = Math.PI; // 文字反转180
			mesh.rotation.x = ( Math.PI / 2 ) / 8;
			mesh.position.y = 14;
			mesh.position.z = - 13;
			var direction = new THREE.Vector3( 0, 0, - 1 );
			var axis = new THREE.Vector3( 0, 1, 0 );
			var angle = Math.PI / 6;
			modifier.set( direction, axis, angle ).modify( mesh.geometry );
		} else if (thisSTL == 2) { //竖笛
			mesh.rotation.y = - Math.PI / 2; // 文字反转90
			mesh.rotation.x = Math.PI / 2; // 文字反转90
			mesh.position.x = - 5.4;
			mesh.position.y = 71;
			mesh.position.z = 4.9;
			var direction = new THREE.Vector3( 0, 0, - 1 );
			var axis = new THREE.Vector3( 0, 1, 0 );
			var angle = Math.PI / 40;
			modifier.set( direction, axis, angle ).modify( mesh.geometry );
		}
		objects.push( mesh );
		scene.add( mesh )
		// camera.position.set(7,37,49)
		// camera.lookAt( 0, 0, 0 );
		exportMoudle( 0, name, thisSTL )
	}
	// } );
}

