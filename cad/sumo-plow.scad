/* Hive13 SumoBot Plow */
/* aka Mr. Plow */
plowwidth = 98;
plowheight = 37;
plowdepth = 16;
sonicwidth = 47;
sonicdepth = 20; // Used to cut out the back

module sonicsensor() {
   cube([sonicwidth,sonicdepth,23]);
   translate(v = [15.5,-3,-9]) {
	   cube([14,sonicdepth+3,10]);
   }
   translate(v = [10, 1, 10]) {
	   rotate(a = [90,0,0]) {
		   cylinder(r = 9, h=16);
   	}
   }
   translate(v = [35, 1, 10]) {
	   rotate(a = [90,0,0]) {
		   cylinder(r = 9, h=16);
   	}
   }
   // Screw holes
   translate(v = [2,1,2]) {
	rotate(a = [90,0,0]) {
	   cylinder(r = 1, h=3);
	}
  }
   translate(v = [43,1,18]) {
	rotate(a = [90,0,0]) {
	   cylinder(r = 1, h=3);
	}
  }
}

module linesensor() {
		cube([36, 12, 10]);

/* Remvoe screw hole 
	translate(v = [14,5,10]) {
		cylinder(r = 1,5, h=2);
	}
*/

}

module plow() {

//difference() {

	cube([plowwidth,plowdepth,plowheight]);

   // add lip for line sensor
  // translate(v = [2,plowdepth,10]){
//	   cube([12, 8,2]);
  // }
   //translate(v = [plowwidth-14,plowdepth,10]){
//	   cube([12, 8,2]);
   //}

/*  Remove curve - not working well 
	rotate(a = [0,90,0]) {
		translate(v = [-4, 0, -1]) {
			cylinder(r =4, h=plowwidth+2);
		}
	}
	translate(v = [-1, -6, 4]) {
		cube([plowwidth+2,10,40]);
	}
}
*/
}


// Main Object Section
// Lay on front for printing
rotate(a = [90,0,0]) {
difference() {
	plow();


	//translate(v = [14, 4, 0]) {
	//	rotate(a = [0, 0, 90]) {
	//		linesensor();
	//	}
	//}
	//translate(v = [plowwidth-2, 4, 0]) {
	//	rotate(a = [0, 0, 90]) {
	//		linesensor();
	//	}
	//}

	rotate(a = [0,180,0]) {
		translate(v = [-sonicwidth-2, 10, -plowheight+2]) {
			sonicsensor();
		}
	}


	rotate(a = [0, 180, 0]) {
		translate(v = [-plowwidth+2, 10, -plowheight+2]) {
			sonicsensor();
		}
	}

	// Remove un-needed plastic
	translate(v = [0, 4, 0]) {
		cube([plowwidth, 20, 10]);
	}
	translate(v = [2,10,plowheight-25]) {
		cube([plowwidth-4, 20, 23]);
	}

}
}



