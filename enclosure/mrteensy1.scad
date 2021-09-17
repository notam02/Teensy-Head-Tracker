include <scadlib/teensy32.scad>
include <scadlib/pushbutton1.scad>

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

	cube([pcbw, pcblen, pcbthick]);
}

module headtrackerElectronics(){
	teensyw=17.7;
	spaceBetweenTwoBoards=12;
	translate([teensyw-21,8,spaceBetweenTwoBoards]) adabno055();
	teensy32();
	rotate([0,0,90]) translate([-6,-teensyw/2,8]) pushbutton1();
}

headtrackerElectronics();
