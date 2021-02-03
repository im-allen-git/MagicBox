// var container = $("#container");
var container = document.getElementById( 'container' );
var exporter; //文件导出
var decalMap={}; //贴图arr

var renderer, scene, camera, stats;
var mesh;
var raycaster;
var line;
var intersection = {
	intersects: false,
	point: new THREE.Vector3(),
	normal: new THREE.Vector3()
};
var mouse = new THREE.Vector2();
var intersects = [];
var defaultSTL = '../models/stl/ascii/luggage.stl';
var textureLoader = new THREE.TextureLoader();
var currentDecal; //当前贴图默认第一个
var decalDiffuse = textureLoader.load( decalMap[1] );
var decalNormal = textureLoader.load( decalMap[1] );
var decalMaterial = new THREE.MeshPhongMaterial( {
	specular: 0x444444,
	map: decalDiffuse,
	normalMap: decalNormal,
	normalScale: new THREE.Vector2( 1, 1 ),
	shininess: 30,
	transparent: true,
	depthTest: true,
	depthWrite: false,
	polygonOffset: true,
	polygonOffsetFactor: - 4,
	wireframe: false,
} );
var lastShootPostion;
var lastShootrotation;
var decals = [];
var removedDecals = [];
var currentObj=[];//当前主体 行李箱
var currentDecalObj=[];//当前主体的decal
var recentlyUsedDecal= new Array();//使用过的的decal
var mouseHelper;
var position = new THREE.Vector3();
var orientation = new THREE.Euler();
var size = new THREE.Vector3( 10, 10, 10 );
var dirLight, dirLightHeper, hemiLight, hemiLightHelper;
var params = {
	/*downloadSTL:function (){
		exportASCII();
	},*/
	minScale: 10,
	maxScale: 20,
	rotation: Math.PI / 4, // positive is counter-clockwise
	back: function () {
		removeLastDecals();
	},
	forward: function () {
		returnLastDecals();
	},
	clear: function () {

		removeDecals();

	}
};

$(function () {
	$(".show_more").click(function (  ) {
		$("#decals").toggleClass("close");
		$(".show_more").toggleClass("show_more_close");
		$(".map").toggleClass("map_btn_close");
	})
	$(".map").click(function(){
		$("#decals .top_nav div").removeClass("active");
		$("#decals .top_nav .map").addClass("active");
		$("#map_decals #map_wrapper").show();
		$("#map_decals #recently_wrapper").hide();
	})
	$(".recent").click(function(){
		$("#decals .top_nav div").removeClass("active");
		$("#decals .top_nav .recent").addClass("active");
		$("#map_decals #map_wrapper").hide();
		$("#map_decals #recently_wrapper").show();
	})
	getDecalMap();
	window.addEventListener( 'load', init );
})
function getDecalMap(){
	var imgPath = '../img/decals/';
	var totalNum = 51;
	for(var i=1;i<totalNum; i++){
		decalMap[i] = imgPath+i+'.png'
	}
	createMap("map_wrapper",decalMap);
	currentDecal=decalMap[1]; //当前贴图默认第一个
}
function init( file ) {

	renderer = new THREE.WebGLRenderer( { antialias: true } );
	renderer.setPixelRatio( window.devicePixelRatio );
	renderer.setSize( window.innerWidth, window.innerHeight);
	container.appendChild( renderer.domElement );

	/*stats = new Stats(); //网络帧数
	container.appendChild( stats.dom );*/

	// helper

	scene = new THREE.Scene();

	// sky + ground
	//sky
	scene.background = new THREE.Color( 0xcce0ff );
	scene.fog = new THREE.Fog( 0xcce0ff, 50, 1000 );
	// ground
	var loaderText = new THREE.TextureLoader();
	var groundTexture = loaderText.load( '../img/grasslight-big.jpg' );
	groundTexture.wrapS = groundTexture.wrapT = THREE.RepeatWrapping;
	groundTexture.repeat.set( 25, 25 );
	groundTexture.anisotropy = 1;
	groundTexture.encoding = THREE.sRGBEncoding;

	var groundMaterial = new THREE.MeshLambertMaterial( { map: groundTexture } );

	var meshGround = new THREE.Mesh( new THREE.PlaneBufferGeometry( 6000, 6000 ), groundMaterial );
	meshGround.position.y = - 50;
	meshGround.rotation.x = - Math.PI / 2;
	meshGround.receiveShadow = true;
	scene.add( meshGround );

	scene.add( new THREE.AxesHelper( 50 ) ); //坐标位置

	camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 1000 );
	camera.position.z = 120;
	camera.target = new THREE.Vector3();

	var controls = new THREE.OrbitControls( camera, renderer.domElement );
	controls.minDistance = 50; //设置相机距离原点的最近距离
	controls.maxDistance = 200;//设置相机距离原点的最远距离

	// exporter = new THREE.STLExporter(); //导出工具

	scene.add( new THREE.AmbientLight( 0xCDCDCD ) );//（环境光）

	// LIGHTS

	dirLight = new THREE.DirectionalLight( 0xffffff, .5 );
	// dirLight.color.setHSL( 0.1, 1, 0.95 );
	dirLight.position.set( 100, 0, 100 );
	scene.add( dirLight );
	/*dirLightHeper = new THREE.DirectionalLightHelper( dirLight, 10 );
	scene.add( dirLightHeper );*/

	dirLight = new THREE.DirectionalLight( 0xffffff, .5 );
	// dirLight.color.setHSL( 0.1, 1, 0.95 );
	dirLight.position.set( - 100, 0, - 100 );
	scene.add( dirLight );
	/*dirLightHeper = new THREE.DirectionalLightHelper( dirLight, 10 );
	scene.add( dirLightHeper );*/

	dirLight = new THREE.DirectionalLight( 0xCDCDCD, .13 );
	// dirLight.color.setHSL( 0.1, 1, 0.95 );
	dirLight.position.set( 0, - 30, 100 ); //箱子正面
	scene.add( dirLight );
	/*dirLightHeper = new THREE.DirectionalLightHelper( dirLight, 10 );
	scene.add( dirLightHeper );*/

	var geometry = new THREE.BufferGeometry();
	geometry.setFromPoints( [new THREE.Vector3(), new THREE.Vector3()] );

	var lineMaterial = new THREE.LineBasicMaterial( {
		color: 0xFF0000,
		linewidth: 1,
		linecap: 'round',
		linejoin: 'round'
	} );
	line = new THREE.Line( geometry, lineMaterial );
	scene.add( line );

	loadSTL(defaultSTL,decals);
	raycaster = new THREE.Raycaster();

	mouseHelper = new THREE.Mesh( new THREE.BoxBufferGeometry( 1, 1, 10 ), new THREE.MeshNormalMaterial() );
	mouseHelper.visible = false;
	scene.add( mouseHelper );

	window.addEventListener( 'resize', onWindowResize, false );

	var moved = false;

	controls.addEventListener( 'change', function () {

		moved = true;

	} );

	window.addEventListener( 'mousedown', function () {

		moved = false;

	}, false );

	window.addEventListener( 'mouseup', function () {

		checkIntersection();
		if (! moved && intersection.intersects) shoot(0);

	} );

	window.addEventListener( 'mousemove', onTouchMove );
	window.addEventListener( 'touchmove', onTouchMove );

	function onTouchMove( event ) {

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
		checkIntersection();

	}

	function checkIntersection() {

		if (! mesh) return;

		raycaster.setFromCamera( mouse, camera );
		raycaster.intersectObject( mesh, false, intersects );

		if (intersects.length > 0) {

			var p = intersects[0].point;
			mouseHelper.position.copy( p );
			intersection.point.copy( p );

			var n = intersects[0].face.normal.clone();
			n.transformDirection( mesh.matrixWorld );
			n.multiplyScalar( 10 );
			n.add( intersects[0].point );

			intersection.normal.copy( intersects[0].face.normal );
			mouseHelper.lookAt( n );

			var positions = line.geometry.attributes.position;
			positions.setXYZ( 0, p.x, p.y, p.z );
			positions.setXYZ( 1, n.x, n.y, n.z );
			positions.needsUpdate = true;

			intersection.intersects = true;

			intersects.length = 0;

		} else {

			intersection.intersects = false;

		}

	}

	initGUI();//右上角操作栏
	onWindowResize();
	animate(); //render 等

}

function loadSTL( file,decalMapArr ) {
	// ASCII file
	if (file) {
		file = file;
	} else {
		file = './models/stl/ascii/luggage.stl';
	}

	var loader = new THREE.STLLoader();
	loader.load( file, function ( geometry ) {
		var material = new THREE.MeshPhongMaterial( { color: 0x9B9EA1 } );
		mesh = new THREE.Mesh( geometry, material );
		//position
		mesh.position.set( 0, 0, 0 );
		mesh.rotation.set( 1.6, 0, 0);
		mesh.scale.set( .08, .08, .08 );
		mesh.castShadow = true;
		mesh.receiveShadow = true;
		scene.add( mesh );
		if(decalMapArr.length>0){
			for (var i in decalMapArr){
				scene.add( decalMapArr[i] );
			}
		}
	} );
}

function shoot(type,lastRotation,lastPosition) { //type:0 第一次点击 1，旋转贴图
	// 当前选择贴图替换
	var sameImgNum=0;
	for(var i in recentlyUsedDecal){
		if(recentlyUsedDecal[i] == currentDecal){
			sameImgNum++;
		}
	}
	if(sameImgNum == 0){
		recentlyUsedDecal.push(currentDecal);
	}
	decalDiffuse = textureLoader.load( currentDecal );
	decalNormal =  textureLoader.load( currentDecal );
	decalMaterial = new THREE.MeshPhongMaterial( {
		specular: 0x444444,
		map: decalDiffuse,
		normalMap: decalNormal,
		normalScale: new THREE.Vector2( 1, 1 ),
		shininess: 30,
		transparent: true,
		depthTest: true,
		depthWrite: false,
		polygonOffset: true,
		polygonOffsetFactor: - 4,
		wireframe: false
	} );
	// 当前选择贴图替换end
	if(type==1){
		position.copy( lastPosition );
		orientation.copy( lastRotation);
	}
	else{
		position.copy( intersection.point );
		orientation.copy( mouseHelper.rotation );
		lastShootPostion = position;
		lastShootrotation =orientation;
	}
	// if ( params.rotate ) orientation.z = Math.random() * 2 * Math.PI;

	// var scale = params.minScale + Math.random() * ( params.maxScale - params.minScale );
	var scale = params.minScale + ( params.maxScale - params.minScale );
	size.set( scale, scale, scale );
	var material = decalMaterial.clone();
	// material.color.setHex( Math.random() * 0xffffff );

	var m = new THREE.Mesh( new THREE.DecalGeometry( mesh, position, orientation, size ), material );
	decals.push( m );
	// currentDecalMap = decals;
	currentDecalObj = decals;
	// console.log("shoot : " + decals)
	scene.add( m );
	createMap("recently_wrapper",recentlyUsedDecal);
}

function animate() {

	requestAnimationFrame( animate );

	renderer.render( scene, camera );

	// stats.update();

}
function onWindowResize() {

	camera.aspect = window.innerWidth / window.innerHeight;
	camera.updateProjectionMatrix();

	renderer.setSize( window.innerWidth, window.innerHeight );

}

function removeDecals() {

	decals.forEach( function ( d ) {

		scene.remove( d );

	} );

	decals = [];

}

function removeLastDecals() {
	if (decals[decals.length - 1]) {
		scene.remove( decals[decals.length - 1] );
		removedDecals.push( decals[decals.length - 1] );
		decals.pop();
	}
}

function returnLastDecals() {
	if (removedDecals[removedDecals.length-1]) {
		decals.push( removedDecals[removedDecals.length-1] );
		scene.add( removedDecals[removedDecals.length-1] );
		removedDecals.pop();
	}
}
// 导出相关
function exportASCII() {
	var result = exporter.parse( mesh );
	var date= Date.parse(new Date());
	saveString( result, date+'.stl' );
}

function exportBinary() {
	var result = exporter.parse( mesh, { binary: true } );
	var date= new Date();
	saveArrayBuffer( result,  date+'.stl' );

}
var link = document.createElement( 'a' );
link.style.display = 'none';
document.body.appendChild( link );

function save( blob, filename ) {

	link.href = URL.createObjectURL( blob );
	link.download = filename;
	link.click();

}
function saveString( text, filename ) {

	save( new Blob( [ text ], { type: 'text/plain' } ), filename );

}

function saveArrayBuffer( buffer, filename ) {

	save( new Blob( [ buffer ], { type: 'application/octet-stream' } ), filename );

}
// 导出相关 end
// document.getElementsByClassName("each_decal").addEventListener('click', changeCurrentDecalModule(this));
function changeCurrentDecal(obj){
	// return function(obj){
	// console.log(img);
	$(".each_decal").removeClass("activeDecal");
	// $(obj).siblings().removeClass("activeDecal");
	$(obj).addClass("activeDecal");
	var img = $(obj).find("img").attr("src");
	/*var sameImgNum=0;
	for(var i in recentlyUsedDecal){
		if(recentlyUsedDecal[i] == img){
			sameImgNum++;
		}
	}
	if(sameImgNum == 0){
		recentlyUsedDecal.push(img);
	}*/
	currentDecal = img
	/*decalDiffuse = textureLoader.load( img );
	decalNormal =  textureLoader.load( img );
	decalMaterial = new THREE.MeshPhongMaterial( {
		specular: 0x444444,
		map: decalDiffuse,
		normalMap: decalNormal,
		normalScale: new THREE.Vector2( 1, 1 ),
		shininess: 30,
		transparent: true,
		depthTest: true,
		depthWrite: false,
		polygonOffset: true,
		polygonOffsetFactor: - 4,
		wireframe: false
	} );*/
	// }
}

function createMap(id,arr) {  //展示贴图，并赋予点击事件
	var reverseArr =[];
	if(id=="recently_wrapper"){
		if(arr.length > 0){
			$(".no_recently").remove();
			for(var i in arr){
				reverseArr.push(arr[i])
			}
			reverseArr=reverseArr.reverse();
		}
	}
	else{
		reverseArr = arr
	}
	// var map = document.getElementById(id);
	// map.innerHTML='';
	var reveseHTML =''
	for ( var m in reverseArr ) {
		/*var eachDecal = document.createElement( 'button' );
		var eachDecalImg = document.createElement( 'img' );
		eachDecalImg.setAttribute('src',reverseArr[m]);
		eachDecal.className = 'each_decal';
		eachDecal.appendChild(eachDecalImg);
		map.appendChild( eachDecal );
		eachDecal.addEventListener( 'click', changeCurrentDecal( reverseArr[m] ), false );*/
		var eachDecal;
		if(m==1 && id=="map_wrapper"){
			eachDecal = '<div class="each_decal activeDecal" onclick="changeCurrentDecal(this)"><img src="'+reverseArr[m]+'" alt=""></div>';

		}
		else{
			eachDecal = '<div class="each_decal" onclick="changeCurrentDecal(this)"><img src="'+reverseArr[m]+'" alt=""></div>';
		}
		reveseHTML+=eachDecal;
	}
	$("#"+id).html(reveseHTML)
}


function updateDecalTransform() {
	var lastDecal = decals[decals.length - 1];
	console.log("updateDecalTransform1 : " + decals);
	scene.remove(lastDecal);
	console.log("updateDecalTransform2 : " + decals);
	lastShootrotation.z=params.rotation;
	shoot(1,lastShootrotation,lastShootPostion);
	console.log("Update Decal Transform")
}

function initGUI(){
	var gui = new dat.GUI();
	// gui.add( params, 'downloadSTL' );
	gui.add( params, 'minScale', 1, 30 );
	gui.add( params, 'maxScale', 1, 30 );
	gui.add( params, 'rotation', - 3.5, 3.5 ).name( 'rotation' ).onChange( updateDecalTransform ); //.name( 'rotation' ).onChange( updateDecalTransform )
	gui.add( params, 'back' );
	gui.add( params, 'forward' );
	gui.add( params, 'clear' );
	gui.open();
}
