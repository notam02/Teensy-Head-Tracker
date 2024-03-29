include <scadlib/teensy32.scad>
include <scadlib/pushbutton1.scad>
$fn=70;

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

spaceBetweenTwoBoards=pushb1HeightToPanel()+2;
electronicsHeight=teensy32Thickness()*2+spaceBetweenTwoBoards;
echo("inner height: ", electronicsHeight);

module headtrackerElectronics(){
	rotate([0,0,90]) translate([-6,-teensy32Width()/2,8]) pushbutton1();
	translate([0,8,spaceBetweenTwoBoards]) adabno055();
	teensy32(0,0);
}

outerWidth=30;
outerLen=53;
bnoWidth=21;

module pushB(){
		rotate([0,0,90]) translate([-8,-teensy32Width()/2,4]) pushbutton1();
}

lidPadding=1.5;

module bottom(){
	union(){
		// BOTTOM
		difference(){
			difference(){
				// The main / outer shape
				color("lightcyan") translate([-5,-14,-2]) cube([outerWidth,outerLen, electronicsHeight]);

				// The inner shape
				hull(){
					// This is what results in the "ledge" for the teensy
					color("orangered") translate([0,0,teensy32Thickness()*2.0])cube([max(bnoWidth, teensy32Width()),teensy32Len(), electronicsHeight]);
					pushB();

				}

				// Cutout teensy
				padding=1;
				color("orangered") translate([0,-padding,0])cube([teensy32Width()+padding,teensy32Len()+padding, electronicsHeight]);
				textCarve();
				translate([lidPadding,lidPadding,electronicsHeight-(lidHeight/2.0)])top();
				/* teensy32(padding=2, extraUsbLen=30); */
			}

			teensy32USBPlug(4,20);
		}

		// Bow
		translate([-5,-14,-electronicsHeight])
			difference(){
				cube([outerWidth,outerLen, electronicsHeight]);
				bowDia=115;
				rotate([90,0,90])translate([outerLen/2,-40,-8])cylinder(h=outerWidth*2,d=bowDia,center=false);
			}
	}
}

module textCarve(){
	textDepth=1;
	textSize=4;
	thisfont="SourceCodePro";
	rotate([90,0,90])
		translate([-5,electronicsHeight/2.0,outerWidth-textSize-textDepth])
			linear_extrude(textDepth) text("NOTAM <3 IEM", textSize, thisfont);
}

// TOP
lidHeight=3;
module top(){
	 subtractWidth=lidPadding*2;
	 subtractLength=lidPadding;

	 translate([0,0,-lidHeight])
		 difference(){
			 color("thistle")
				 translate([-5,-14,0])
				 cube([outerWidth-subtractWidth,outerLen-subtractLength, lidHeight]);

			 // Cutout for reset button
			 rotate([0,0,90])
				 translate([2.6,-teensy32Width()/2 + (subtractWidth/2),-lidHeight/2])
				 cylinder(h=lidHeight*2,d=3,center=false);

			 // Cutout for main button
			 rotate([0,0,90])
				 translate([-8,-teensy32Width()/2 + (subtractWidth/2),-lidHeight/2])
				 cylinder(h=lidHeight*2,d=7.0,center=false);

		 }

	 // Supports
		supportWidth = 2.5;
		supportDepth = 2.5;
		supportHeigt = electronicsHeight - teensy32Thickness() - 5; // - 5 is kinda arbitrary
		distanceFromFront = 3.6;

		// Front right
		translate([0,teensy32Len()-distanceFromFront, -supportHeigt-lidHeight]) cube([supportWidth, supportDepth, supportHeigt], center=false);

		// Front left
		translate([teensy32Width()-supportWidth,teensy32Len()-distanceFromFront, -supportHeigt-lidHeight]) cube([supportWidth, supportDepth, supportHeigt], center=false);

		// Back left
		translate([teensy32Width()-supportWidth,0, -supportHeigt-lidHeight]) cube([supportWidth, supportDepth, supportHeigt], center=false);

		// Back right
		translate([0,0, -supportHeigt-lidHeight]) cube([supportWidth, supportDepth, supportHeigt], center=false);

}

// Uncomment to see debugging electronics
/* bottom(); */
/* translate([50,0,electronicsHeight-lidHeight]) top(); */
/* #headtrackerElectronics(); */
