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
motor_h = 58;
motor_d = 20;
lip_w = motor_w;
lip_h = 18;
lip_d = 25;
lip_dist_from_bottom_motor = 40;
tire_distance = 9;
cfr_rad=4;

linesensor_spacing = 18;
linesensor_depth = 23;
frame_wheel_d = 36;
wheel_clearance = 12;
backwall_thickness = 15;



module motor() {
  //color([127,0,127,255]) {
     //union() {
	  // cube([motor_w, motor_d, motor_h]);
	  // Lip
	//translate(v = [0,-(lip_d-motor_d)/2 , lip_dist_from_bottom_motor]) {
	//	cube([lip_w, lip_d, lip_h]);
          //}
	// wheel
	//translate(v = [motor_w,motor_d/2,motor_d/2]) {
	//   rotate(a = [90, 0,90]) {
	//	cylinder(r = wheel_radius, h = wheel_thickness);
	 //   }
	//}
      //}
 // }
//intersection() {
//cube([2*cfr_rad,motor_d,motor_h]);
//translate(v=[cfr_rad,cfr_rad,0]){
	difference(){
		cube([cfr_rad,cfr_
		cylinder(r=cfr_rad,h=motor_h);}
		}
//}

module both_motor(){
// Right Tire 
//translate(v = [max_w-2, 0, -motor_d]) {
//rotate(a = [270, 180, 0]) {
//motor();
//}
//}
// Left Tire
//translate(v = [2, 12, 22]) {
//rotate(a = [270, 0, 0]) {
motor();
//}
//}
}

both_motor();