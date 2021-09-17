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

spaceBetweenTwoBoards=18;
electronicsHeight=teensy32Thickness()*2+spaceBetweenTwoBoards;

module headtrackerElectronics(){
	rotate([0,0,90]) translate([-6,-teensy32Width()/2,8]) pushbutton1();
	translate([0,8,spaceBetweenTwoBoards]) adabno055();
	teensy32(0,0);
}

outerWidth=30;
outerLen=53;
bnoWidth=21;

module pushB(){
		rotate([0,0,90]) translate([-8,-teensy32Width()/2,8]) pushbutton1();
}

// BOTTOM
difference(){
	difference(){
		// The main / outer shape
		color("lightcyan") translate([-5,-14,-2]) cube([outerWidth,outerLen, electronicsHeight]);

		// The inner shape
		hull(){
			color("orangered") cube([max(bnoWidth, teensy32Width()),teensy32Len(), electronicsHeight]);
			pushB();

		}

		textCarve();
		/* teensy32(padding=2, extraUsbLen=30); */
	}

	teensy32USBPlug(3,20);

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
translate([50,0,0]) difference(){
	color("thistle")
		translate([-5,-14,-2])
		cube([outerWidth,outerLen, lidHeight]);

	// Cutout for reset button
	rotate([0,0,90])
		translate([2.6,-teensy32Width()/2,-lidHeight])
		cylinder(h=lidHeight*2,d=3,center=false);

	// Cutout for main button
	rotate([0,0,90])
		translate([-8,-teensy32Width()/2,-lidHeight])
		cylinder(h=lidHeight*2,d=6.75,center=false);
}

#headtrackerElectronics();
