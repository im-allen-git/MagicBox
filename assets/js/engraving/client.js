import * as THREE from "/build/three.module.js";
import { OrbitControls } from "/jsm/controls/OrbitControls";
import Stats from "/jsm/libs/stats.module";
import { GUI } from "/jsm/libs/dat.gui.module";
import CSG from "./utils/CSGMesh.js";
import { TWEEN } from "/jsm/libs/tween.module.min";
const scene = new THREE.Scene();
var light1 = new THREE.SpotLight();
light1.position.set(6.5, 7.5, 7.5);
light1.angle = Math.PI / 4;
light1.penumbra = 0.5;
scene.add(light1);
var light2 = new THREE.SpotLight();
light1.position.set(-6.5, 7.5, 7.5);
light2.angle = Math.PI / 4;
light2.penumbra = 0.5;
scene.add(light2);
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
camera.position.x = 0.5;
camera.position.y = 0.5;
camera.position.z = -2;
const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.target.z = -5;
const data = {
    text: "123"
};
const envTexture = new THREE.CubeTextureLoader().load([
    "img/px.png",
    "img/nx.png",
    "img/py.png",
    "img/ny.png",
    "img/pz.png",
    "img/nz.png"
]);
envTexture.mapping = THREE.CubeReflectionMapping;
const material = new THREE.MeshStandardMaterial({
    envMap: envTexture,
    metalness: 0.9,
    roughness: 0.1,
    color: 0xdaa520
});
const cylinderMesh1 = new THREE.Mesh(new THREE.CylinderBufferGeometry(6, 6, 1.5, 64, 1, false), material);
const cylinderMesh2 = new THREE.Mesh(new THREE.CylinderBufferGeometry(5, 5, 1.6, 64, 1, false), material);
cylinderMesh1.position.set(0, 0, 0);
cylinderMesh2.geometry.rotateX(-Math.PI / 2);
cylinderMesh2.position.set(0, 0, 0);
cylinderMesh2.geometry.rotateX(-Math.PI / 2);
const cylinderCSG1 = CSG.fromMesh(cylinderMesh1);
const cylinderCSG2 = CSG.fromMesh(cylinderMesh2);
const ringCSG = cylinderCSG1.subtract(cylinderCSG2);
const ringMesh = CSG.toMesh(ringCSG, new THREE.Matrix4());
let engravedMesh = new THREE.Mesh(ringMesh.geometry, material);
scene.add(engravedMesh);
let font;
const loader = new THREE.FontLoader();
loader.load("fonts/helvetiker_regular.typeface.json", function (f) {
    font = f;
    regenerateGeometry();
});
window.addEventListener("resize", onWindowResize, false);
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}
const raycaster = new THREE.Raycaster();
renderer.domElement.addEventListener("dblclick", onDoubleClick, false);
function onDoubleClick(event) {
    const mouse = {
        x: (event.clientX / renderer.domElement.clientWidth) * 2 - 1,
        y: -(event.clientY / renderer.domElement.clientHeight) * 2 + 1
    };
    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObject(engravedMesh, false);
    if (intersects.length > 0) {
        const p = intersects[0].point;
        new TWEEN.Tween(controls.target)
            .to({
            x: p.x,
            y: p.y,
            z: p.z
        }, 200)
            .easing(TWEEN.Easing.Cubic.Out)
            .start();
    }
}
const stats = Stats();
document.body.appendChild(stats.dom);
const gui = new GUI();
const deformFolder = gui.addFolder("Deform");
deformFolder.add(data, "text").onFinishChange(regenerateGeometry);
deformFolder.open();
function regenerateGeometry() {
    let newGeometry;
    newGeometry = new THREE.TextGeometry(data.text, {
        font: font,
        size: 1,
        height: 0.2,
        curveSegments: 2
    });
    newGeometry.center();
    let theta = 0;
    const angle = Math.PI / 16;
    if (angle !== 0) {
        for (let i = 0; i < newGeometry.vertices.length; i++) {
            let x = newGeometry.vertices[i].x;
            let y = newGeometry.vertices[i].y;
            let z = newGeometry.vertices[i].z;
            theta = x * angle;
            newGeometry.vertices[i].x = -(z - 1.0 / angle) * Math.sin(theta);
            newGeometry.vertices[i].y = y;
            newGeometry.vertices[i].z =
                (z - 1.0 / angle) * Math.cos(theta) + 1.0 / angle;
        }
    }
    newGeometry.translate(0, 0, -5);
    const textCSG = CSG.fromGeometry(newGeometry);
    const engravedCSG = ringCSG.subtract(textCSG);
    engravedMesh.geometry.dispose();
    engravedMesh.geometry = CSG.toMesh(engravedCSG, new THREE.Matrix4()).geometry;
}
var animate = function () {
    requestAnimationFrame(animate);
    controls.update();
    TWEEN.update();
    render();
    stats.update();
};
function render() {
    renderer.render(scene, camera);
}
animate();
