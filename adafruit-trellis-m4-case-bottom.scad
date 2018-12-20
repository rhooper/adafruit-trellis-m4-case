$fn=36;

$corner_diameter=10;
$num_x = 8;
$num_y = 4;
$notch_width = 40;
$notch_top_padding = 2.5;
$edge_gap = 2;
$deep_notch_depth = 28;
$reset_x = 120-16;
$reset_y = 60-23;
$reset_hole_size = 4;
$edge_padding = 0.2;

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


module deep_notch(depth, width, height) {
    notch_depth=$corner_diameter/2 + 28;
       
    translate([depth/2-($notch_width/2), width-$deep_notch_depth, 0]) 
        cube([$notch_width, $deep_notch_depth, height]);
}


module board_guide(width, depth, height) {
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
        translate([-$edge_padding, -$edge_padding, 0])
        cube([120.8, 60.8, height]);
    }
}


module board_support(width, depth, height) {
    // TODO cross-beams for other board dimensions than 4x8
    // TODO cutouts for solder joints

    difference() {
        // Surface + Ridge
        translate([-1, -1, 0])
            cube([depth+2, width+2, height+1]);
        // Connector cutout
        notch(depth, width, height+1);
        deep_notch(depth, width, height+1);
        // Board support ridge
        translate([5, 5, 0])
            cube([depth-10, width-10, height+1]);
        // Board area
        translate([-0.5, -0.5, height])
            cube([depth+1, width+1, 1]);
    }
}


module lower_plate(width, depth, height) {
    difference() {
        // Surface
        minkowski() {
            cube([depth, width, height]);
            cylinder(h=0.0000001, d1=$corner_diameter, 
                     d2=$corner_diameter);
        }
        // Connector cutout
        notch(depth, width, height);
        deep_notch(depth, width, height);
        // Reduce volume
        translate([5, 5, 0])
            cube([depth-10, width-10, height]);
        
    }
}

module bottom(width, depth, height) {
    difference() {
        // Surface
        minkowski() {
            cube([depth, width, height]);
            cylinder(h=0.0000001, d1=$corner_diameter, 
                     d2=$corner_diameter);
        }
        // Connector cutout
        notch(depth, width, height);     
        // Reset button
        translate([$reset_x, $reset_y, 0]) 
            cylinder(h=height, d1=$reset_hole_size, 
                               d2=$reset_hole_size);
    }
}


module outer_wall(width, depth, height) {
    difference() {
        // Surface
        minkowski() {
            cube([depth, width, height]);
            cylinder(h=0.0000001, d1=$corner_diameter, 
                     d2=$corner_diameter);
        }
        // Surface
        translate([$edge_gap/2+$edge_padding, 
                   $edge_gap/2+$edge_padding, 0])
        minkowski() {
            cube([depth-$edge_gap-($edge_padding*2), 
                  width-$edge_gap-($edge_padding*2), height]);
            cylinder(h=0.0000001, d1=$corner_diameter, 
                     d2=$corner_diameter);
        }
        notch(depth, width, height);
    }
}

module reset_guard(width, depth, height) {
    translate([$reset_x, $reset_y, 0]) 
    difference() {
        cylinder(h=height, d1=$reset_hole_size+2, d2=$reset_hole_size+2);
        cylinder(h=height, d1=$reset_hole_size, d2=$reset_hole_size);
    }
}

module snap_ridge(depth, width) {
    intersection() {
        translate([0,0,-0.1]) minkowski() {
            hull() {
                cylinder(h=depth/2, d1=0.5, d2=0.5);
                translate([width, 0, 0])
                    cylinder(h=depth/2, d1=0.5, d2=0.5);
            }
            sphere(d=0.9);
        }
        hull() {
            cylinder(h=depth, d1=1.5, d2=1.5);
            translate([width, 0, 0])
                cylinder(h=depth, d1=1.5, d2=1.5);
        }
    }
}

module ridges(width, depth) {
    padding = $edge_padding * 2;
    width = width + padding;
    depth = depth + padding;
    length = 8;
    offset = 21;
    translate([depth-offset-length, -$edge_gap-padding*2-1, 0])
        rotate([-90,0,0]) snap_ridge(padding*2, length);
    translate([offset, -$edge_gap-padding*2-1, 0])
        rotate([-90,0,0]) snap_ridge(padding*2, length);
    translate([depth-offset-length, width+$edge_gap+1+padding, 0])
        rotate([90,0,0]) snap_ridge(padding*2, length);
    translate([offset, width+$edge_gap+1+padding, 0])
        rotate([90,0,0]) snap_ridge(padding*2, length);
}

width = $num_y * 15;
depth = $num_x * 15;
render() {
translate([0,0,-6])     board_support(width, depth, 3);
translate([0,0,-9])     lower_plate(width, depth, 3);
translate([0,0,-10.5])  bottom(width, depth, 1.5);
translate([0,0,-6])     outer_wall(width, depth, 6.8);
translate([0,0,-9])     reset_guard(width, depth, 3.5);
translate([0,0,-1])   ridges(width, depth);
}