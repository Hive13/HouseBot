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
offset_w =2;

linesensor_spacing = 18;
linesensor_depth = 23;
frame_wheel_d = 36;
wheel_clearance = 15;
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
			//   cube([10, 10, frame_h]);
			 //  translate(v=[5, 5, 0]) {
			//	   cylinder(r = 2, h=frame_h);
			 //  }
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
			//	cube([motor_w, frame_d -(frame_wheel_d + linesensor_depth-1), batterypack_h + micro_h]);
			 // }
			  //translate(v = [frame_w-motor_w-2,frame_wheel_d+1,frame_h +bpack2_h]) {
			//	cube([motor_w, frame_d -(frame_wheel_d + linesensor_depth-1), batterypack_h + micro_h]);
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
   cube([batterypack_w, batterypack_d, batterypack_h]);
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
	   cube([motor_w, motor_d, motor_h]);
	  // Lip
	translate(v = [0, -(lip_d-motor_d)/2, lip_dist_from_bottom_motor]) {
		cube([lip_w, lip_d, lip_h]);
          }
	// wheel
         translate(v = [motor_w,motor_d/2,motor_d/2]) {
	    rotate(a = [90, 0, 90]) {
		cylinder(r = wheel_radius, h = wheel_thickness);
	    }
	}
      }
  }
}

module holder (){

translate(v = [0,frame_wheel_d+1,frame_h]) {
				cube([frame_w, frame_d -(frame_wheel_d + linesensor_depth)-2,batterypack_h + bpack2_h + micro_h]);// replace batterypack_h + bpack2_h + micro_h by motor_d-1+offset_w
			  }
}

module lower_holder (){

translate(v = [0,frame_wheel_d+1,frame_h]) {
				cube([frame_w, frame_d -(frame_wheel_d + linesensor_depth)-2,motor_d-1+offset_w]);// replace batterypack_h + bpack2_h + micro_h by motor_d-1+offset_w
			  }
}



//translate(v =[0,0,6]) {
difference(){
	holder();
	lower_holder();
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

}
























//****************** NOT USED**********************//

//max base
//cube([max_w, max_d, 1]);
/*
// Right Tire
translate(v = [max_w-2, 12, -1]) {//too close to axis
	rotate(a = [250, 180, 0]) {
		motor();
	}
}
// Left Tire
translate(v = [2, 5, 22]) {
	rotate(a = [290, 0, 0]) {
		motor();
	}
}

translate(v = [(frame_w + bpack2_d) /2,frame_d-bpack2_w,frame_h+6]) {
  rotate([0,0,90]) {
	  bpack2();
  }
}

translate(v = [(frame_w + batterypack_d) / 2, frame_d-batterypack_w, frame_h+6+bpack2_h+wheel_clearance]) {
  rotate([0,0,90]) {
	batterypack();
  }
}


*/