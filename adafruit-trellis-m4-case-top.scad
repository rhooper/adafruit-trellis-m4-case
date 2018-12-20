$fn=36;

$corner_diameter=10;
$num_x = 8;
$num_y = 4;
$notch_width = 40;
$notch_top_padding = 2.5;
$edge_gap = 1.4;
$edge_width = 0.5;

module button_hole(height) {
    minkowski() {
        cube([9.4,9.4,height], center=true);
        cylinder(h=height, d1=1, d2=1);
    }
}

module buttons(num_x, num_y, height) {
    for (x = [0:num_x-1]) {
        for (y = [0:num_y-1]) {
            translate([x*15, y*15, 0])
                button_hole(height);
        }
    }
}

module notch(depth, width, height) {
    notch_depth=$corner_diameter/2;
    
    points = [
        [$notch_top_padding, 0, 0],
        [$notch_width + $notch_top_padding, 0, 0],
        [$notch_width + ($notch_top_padding * 2), notch_depth, 0],
        [0, notch_depth, 0],
        [$notch_top_padding, 0, height],
        [$notch_width + $notch_top_padding, 0, height],
        [$notch_width + ($notch_top_padding * 2), notch_depth, height],
        [0, notch_depth, height]
    ];
    faces = [
      [0,1,2,3],  // bottom
      [4,5,1,0],  // front
      [7,6,5,4],  // top
      [5,6,2,1],  // right
      [6,7,3,2],  // back
      [7,4,0,3]
    ]; // left
    
    translate([depth/2-$notch_top_padding-($notch_width/2), width, 0]) {
        polyhedron(points, faces);
    }
}

module top(num_x, num_y, height) {
    width = num_y * 15;
    depth = num_x * 15;
    difference() {
        // Surface
        minkowski() {
            cube([depth, width, height]);
            cylinder(h=0.0000001, d1=$corner_diameter, 
                     d2=$corner_diameter);
        }
        // Button cutouts
        translate([$corner_diameter/2+2.5, $corner_diameter/2+2.5, 0])
            buttons(num_x, num_y, height);
        // Connector cutout
        notch(depth, width, height);
    }
}

module board_guide(num_x, num_y, height) {
    width = num_y * 15;
    depth = num_x * 15; 
    edge_padding = $corner_diameter/2-$edge_gap-$edge_width;
    difference() {
        // Surface
        minkowski() {
            translate([$edge_gap, $edge_gap, 0])
            cube([depth-$edge_gap*2, width-$edge_gap*2, height]);
            cylinder(h=0.0000001, d1=$corner_diameter, 
                     d2=$corner_diameter);
        }
        // Connector cutout
        notch(depth, width, height);
        // Board area
        translate([-edge_padding/2, -edge_padding/2, 0])
            cube([depth + edge_padding, width + edge_padding, height]);
        // Snapfit grooves
        grooves($num_x, $num_y);
    }
}

module snap_groove(depth, width) {
    size=1.6;
    rotate([90,0,0]) {
        hull() {
            cylinder(h=depth, d1=size, d2=size);
            translate([width, 0, 0])
                cylinder(h=depth, d1=size, d2=size);
        }
        translate([0,0,depth/2])
        hull() {
            cylinder(h=depth, d1=size, d2=size);
            translate([width, 0, 0])
                cylinder(h=depth, d1=size, d2=size);
            translate([0,-4,0]) {
                cylinder(h=depth, d1=size, d2=size);
                translate([width, 0, 0])
                    cylinder(h=depth, d1=size, d2=size);
            }
        }
    }
}

module grooves(num_x, num_y) {
    depth = num_y * 15;
    width = num_x * 15;
    length = 10;
    offset = 20;
    left = width-offset-length;
    right = offset;
    top = -$edge_gap-$edge_width-1;
    bottom = depth+$edge_gap+$edge_width+1;
    translate([left, top, 4])     snap_groove(1, 10);
    translate([right, top, 4])    snap_groove(1, 10);
    translate([left, bottom, 4])  
        mirror([0,1,0]) snap_groove(1, 10);
    translate([right, bottom, 4]) 
        mirror([0,1,0]) snap_groove(1, 10);
}

rotate([0,180,0]) {
    top($num_x, $num_y, 6);
    translate([0,0,-6])
        board_guide($num_x, $num_y, 6);
}

