module teensy(){

	/* PCB */
	width=17.7;
	len=35.5;
	thick=1.6;
	color("green") cube([width,len,thick],false);

	/* Button */
	butWidth=4.5; butLen=3.2; butHeight=2.3;
	color("white")
		translate([(width-butWidth)/2.0, 2.6, thick])
		cube([butWidth, butLen, butHeight], false);

	/* USB */
	uwidth=8.5;
	uheight=3.3;
	ulen=8.5;
	color("grey")
		translate([(width-uwidth)/2.0, len-ulen+1, thick])
		cube([uwidth, ulen, uheight], false);
}

teensy();
