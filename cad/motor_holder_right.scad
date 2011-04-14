/* Hive13 SumoBot Chassis/Frame */ 

// The front plow takes up a depth of 16.
// Some space is used for linesensor screw holes ~14mm

max_w = 98;
max_d = 98 - 16;

batterypack_w = 63;
batterypack_h = 15;
batterypack_d = 49;

bpack2_w = 54;
bpack2_h = 11;
bpack2_d = 31;

micro_w = 70;
micro_h = 15; // We just go to the top of the shield
micro_d = 54;

frame_w = max_w;
frame_h = 3;
frame_d = max_d;

// tire + motor thickness ~30 
wheel_radius = 15.5;
wheel_thickness = 14;
motor_w =14;
motor_h = 54;
motor_d = 20;
lip_w = motor_w;
lip_h = 18;
lip_d = 25;
lip_dist_from_bottom_motor = 36;
tire_distance = 9;
offset_w =2;
wheel_position=10; 
clearance_ground=2;

tab_plow_d=10;// tab to connect to screw in with the plow
linesensor_spacing = 18;
linesensor_depth = 23;
frame_wheel_d = 36;
wheel_clearance = 17;
backwall_thickness = 15;

module baseframe() {
difference() {
union() {
cube([frame_w, frame_d, frame_h]);
// mounting tabs
translate(v=[(frame_w - bpack2_d) /2, frame_d, 0]) {
difference() {
cube([bpack2_d,10 , frame_h+6]);
translate(v=[5, 5, 0]) {
cylinder(r = 2, h=frame_h+6);
}
translate(v=[bpack2_d-5, 5, 0]) {
cylinder(r = 2, h=frame_h+6);
}
}
}
//translate(v=[frame_w-linesensor_spacing-10, frame_d, 0]) {
//difference() {
// cube([10, 10, frame_h]);
// translate(v=[5, 5, 0]) {
// cylinder(r = 2, h=frame_h);
// }
//}
// }
// Wheel/Motor holder block
difference() // subtract out overhangs and wire section
{//Motor holder both sides.....
translate(v = [0,frame_wheel_d+1,frame_h]) {
cube([frame_w, frame_d -(frame_wheel_d + linesensor_depth)-2,motor_d-1+offset_w]);// replace batterypack_h + bpack2_h + micro_h by motor_d -1
}
// Removes space over motors
// translate(v = [2,frame_wheel_d+1,frame_h +bpack2_h]) {
// cube([motor_w, frame_d -(frame_wheel_d + linesensor_depth-1), batterypack_h + micro_h]);
// }
//translate(v = [frame_w-motor_w-2,frame_wheel_d+1,frame_h +bpack2_h]) {
// cube([motor_w, frame_d -(frame_wheel_d + linesensor_depth-1), batterypack_h + micro_h]);
// }
// Remove area over batterypacks
translate(v = [(frame_w + batterypack_d) / 2, frame_d-batterypack_w, frame_h+bpack2_h+wheel_clearance]) {
rotate([0,0,90]) {
batterypack();
}
}

translate(v = [(frame_w + bpack2_d) /2,frame_d-bpack2_w,frame_h]) {
rotate([0,0,90]) {
//bpack2();
cube([bpack2_w, bpack2_d, bpack2_h+wheel_clearance]);
}
}
translate(v = [(frame_w - micro_d) / 2, frame_d-batterypack_w, frame_h+bpack2_h+batterypack_h+wheel_clearance]) {
cube([micro_d, batterypack_w, 40]);
}

}
// Backwall
translate(v=[(frame_w + bpack2_d+10) /2-bpack2_d,frame_d-bpack2_w-backwall_thickness-2,frame_h]) {
cube([bpack2_d-10, backwall_thickness, bpack2_h+wheel_clearance]);
}
// Backwall second piece
translate(v = [(frame_w + bpack2_d)/2-bpack2_d,10,frame_h]) {
cube([bpack2_d, 7, bpack2_h+micro_h+batterypack_h]);
}
} // union


// Remove linesensor area
translate(v = [0,frame_d-linesensor_depth,0]) {
cube([linesensor_spacing, linesensor_depth, frame_h]);
}
translate(v = [frame_w - linesensor_spacing,frame_d-linesensor_depth,0]) {
cube([linesensor_spacing, linesensor_depth, frame_h]);
}
// Remove tires
translate(v = [0,0,0]) {
cube([motor_w + wheel_thickness + 4, frame_wheel_d, frame_h]);
}
translate(v = [frame_w-motor_w-wheel_thickness-4,0,0]) {
cube([motor_w + wheel_thickness + 4, frame_wheel_d, frame_h]);
}
// Remove unneeded space in the back
translate(v =[(frame_w + bpack2_d-5) /2-bpack2_d,0,0]) {
cube([bpack2_d+10, 10, frame_h]);
}
// Remove a hole for power switch
translate(v = [frame_w-linesensor_spacing-15,frame_d-linesensor_depth,0]) {
cube([15, 23, frame_h]);
}
// This one is mainly for looks
translate(v = [linesensor_spacing,frame_d-linesensor_depth,0]) {
cube([15, 23, frame_h]);
}
// Remove the wheels
// Right Tire
translate(v = [max_w-2, 7,-motor_d+22+offset_w]) {
rotate(a = [270, 180, 0]) {
motor();
}
}
// Left Tire
translate(v = [2, 7, 22+offset_w]) {
rotate(a = [270, 0, 0]) {
motor();
}
}

} // difference
}

module batterypack() {
color([0, 127, 127, 255]) {
cube(size=[batterypack_d, batterypack_w, batterypack_h],center=true);
}
}

module bpack2() {
color([127,127,0,255]) {
cube([bpack2_w, bpack2_d, bpack2_h]);
}
}

module micro() {
cube([micro_w, micro_d, micro_h]);
}

module motor() {
color([0,0,0,255]) {
union() {
cube(size=[motor_w, motor_h, motor_d], center = true );
// Lip
translate(v = [0, lip_dist_from_bottom_motor-lip_h, 0]) {//[0, -(lip_d-motor_d)/2, lip_dist_from_bottom_motor]
cube(size=[lip_w, lip_h, lip_d],center=true);
}
// wheel
translate(v = [-motor_w,-(motor_h-wheel_position)/2,0]) {//[motor_w,motor_d/2,motor_d/2]
rotate(a = [0, 90, 0]) {
cylinder(r = wheel_radius, h = wheel_thickness, center=true);
}
}
}
}
}


//
//translate(v =[0,0,6]) {
//baseframe();
//}

// NEW START WITH CENTERED DESIGN //

rotate(a=[0,180,0]){
difference(){
union(){
//motor top holder 
translate(v=[0,12,frame_h/2+(bpack2_h+wheel_clearance)/2]){
cube(size=[frame_w,motor_h-lip_h-wheel_radius-wheel_position+lip_h,bpack2_h+wheel_clearance], center=true);}
}//union end
//start removing 
//motors
translate(v=[(frame_w-motor_w)/2-3,0,wheel_radius-frame_h/2-clearance_ground]){
rotate(a=[0,0,0]){
motor();}}
mirror ([1,0,0]) {
translate(v=[(frame_w-motor_w)/2-3,0,wheel_radius-frame_h/2-clearance_ground]){
rotate(a=[0,0,0]){
motor();}}}
// big battery
translate(v=[0,0,frame_h/2+(bpack2_h+micro_h+batterypack_h)/2+batterypack_h]){
batterypack();}
//center piece between wheels
translate(v=[0,0,frame_h/2+ (bpack2_h+wheel_clearance)/2]){
cube(size=[bpack2_d+1, bpack2_w, bpack2_h+wheel_clearance],center=true);}
//motor holder
translate(v=[0,12,(motor_d+frame_h)/2]){
cube(size=[frame_w,motor_h-lip_h-wheel_radius-wheel_position+lip_h,motor_d], center=true);}// replace batterypack_h + bpack2_h + micro_h by motor_d -1
mirror ([1,0,0]) {
translate(v=[(frame_w-motor_w)/2-3,0,wheel_radius-frame_h/2-clearance_ground]){
cube(size=[50,55,50],center=true);}}
}//difference end
}//rotate end



