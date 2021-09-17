include </home/mads/code/scadlib/teensy32.scad>
include </home/mads/code/scadlib/pushbutton1.scad>
$fn=40;

module adabno055(){
	/* PCB */
	pcbw=21;
	pcbthick=1.6;
	pcblen=27;

	// PCB inputs. Probably not entirely precise
	for (i = [0:4]) {
		pinDia=1.9;
		pinSpacing=1.25;
		offsetFromEdge=6.16;
		color("red") translate([pinDia,offsetFromEdge+(i*(pinSpacing+pinDia)),pcbthick])circle(d=pinDia);
	}

	color("blue") cube([pcbw, pcblen, pcbthick]);
}

teensyw=17.7;
spaceBetweenTwoBoards=18;
electronicsHeight=1.6*2+spaceBetweenTwoBoards;

module headtrackerElectronics(){
	rotate([0,0,90]) translate([-6,-teensyw/2,8]) pushbutton1();
	translate([teensyw-21,8,spaceBetweenTwoBoards]) adabno055();
	teensy32();
}

outerWidth=30;
outerLen=53;
bnoWidth=21;

module pushB(){
		rotate([0,0,90]) translate([-8,-teensy32Width()/2,8]) pushbutton1();
}

// BOTTOM
difference(){
	// The main / outer shape
	color("green") translate([-5,-14,-2]) cube([outerWidth,outerLen, electronicsHeight]);

	// The inner shape
	hull(){
		color("orangered") cube([max(bnoWidth, teensy32Width()),teensy32Len(), electronicsHeight]);
		pushB();
	}

	teensy32(padding=2, extraUsbLen=20);
}

// TOP
lidHeight=3;
translate([50,0,0]) difference(){
	color("green")
		translate([-5,-14,-2])
		cube([outerWidth,outerLen, lidHeight]);

	rotate([0,0,90])
		translate([0,-teensy32Width()/2,-lidHeight])
		cylinder(h=lidHeight*2,d=6.75,center=false);
}

/* translate([50,0,0]) color("red") rotate([0,0,90]) translate([-8,-teensy32Width()/2,8]) cylinder(h=(lidHeight*2),d=6.75,center=false); */
		/* rotate([0,0,90]) translate([-6,-teensy32Width()/2,8]) pushbutton1(); */
/* teensy32(extraUsbLen=30); */

/* difference(){ */

/* union(){ */
/* 	rotate([0,0,90]) translate([-6,-teensyw/2,8]) pushbutton1(); */
/* 	translate([teensyw-21,8,spaceBetweenTwoBoards]) adabno055(); */
/* 	teensy32(); */
/* } */

/* } */
/* 	/1* translate([teensyw-21,8,spaceBetweenTwoBoards]) adabno055(); *1/ */
