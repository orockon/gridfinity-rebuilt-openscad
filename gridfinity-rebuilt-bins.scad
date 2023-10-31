include <gridfinity-rebuilt-utility.scad>

// ===== INFORMATION ===== //
/*
 IMPORTANT: rendering will be better for analyzing the model if fast-csg is enabled. As of writing, this feature is only available in the development builds and not the official release of OpenSCAD, but it makes rendering only take a couple seconds, even for comically large bins. Enable it in Edit > Preferences > Features > fast-csg
 the magnet holes can have an extra cut in them to make it easier to print without supports
 tabs will automatically be disabled when gridz is less than 3, as the tabs take up too much space
 base functions can be found in "gridfinity-rebuilt-utility.scad"
 examples at end of file

 BIN HEIGHT
 the original gridfinity bins had the overall height defined by 7mm increments
 a bin would be 7*u millimeters tall
 the lip at the top of the bin (3.8mm) added onto this height
 The stock bins have unit heights of 2, 3, and 6:
 Z unit 2 -> 7*2 + 3.8 -> 17.8mm
 Z unit 3 -> 7*3 + 3.8 -> 24.8mm
 Z unit 6 -> 7*6 + 3.8 -> 45.8mm

https://github.com/kennetek/gridfinity-rebuilt-openscad

*/

// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
grid_dimensions_1 = 1;  
// number of bases along y-axis   
grid_dimensions_2 = 1;  
// bin height. See bin height information and "gridz_define" below.  
gridz = 3.5;

/* [Compartments] */
// number of X Divisions (set to zero to have solid bin)
divx = 1;
// number of y Divisions (set to zero to have solid bin)
divy = 1;

/* [Height] */
// determine what the variable "gridz" applies to based on your use case
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 0; 
// snap gridz height to nearest 7mm increment
enable_zsnap = false;

/* [Features] */
// the type of tabs
style_tab = 5; //[0:Full,1:Auto,2:Left,3:Center,4:Right,5:None]
// how should the top lip act
style_lip = 2; //[0: Regular lip, 1:remove lip subtractively, 2: remove lip and retain height]
// scoop weight percentage. 0 disables scoop, 1 is regular scoop. Any real number will scale the scoop. 
scoop = 0; //[0:0.1:1]
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = false;

/* [Base] */
style_hole = 0; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0; 


// ===== IMPLEMENTATION ===== //

show_bin = true;
show_lid = false;
hinge_diam = 4;
hinge_hole = 2;
hinge_gap = .4;

function pick_longer(x,y) = (x>=y) ? x : y;
function pick_shorter(x,y) = (x<y) ? x : y;

/* [Hidden] */
gridx = pick_longer(grid_dimensions_1,grid_dimensions_2);
gridy = pick_shorter(grid_dimensions_1,grid_dimensions_2);

module horizontal_hinge(l, diam, rot) {
    //translate([0,0,diam/2])
    rotate(rot)
    cylinder(h=l,d=diam,center=true);
}

function hing_len() = ((gridx * l_grid)/1.75);

function hinge_rot() = [0,90,0];

module relocate_hinge(diam) {
        translate([0, ((gridy*l_grid)/2)-(diam/2)-.25,height(gridz+1, gridz_define, style_lip, enable_zsnap)-h_base-hinge_gap+1])
        children();
}

module cylinder_hinge() {
    diam=hinge_diam;
    translate([0,0,diam/2]){    
        hinge_length = hing_len();
        echo(gridy);
        hinge_l2 = hinge_length/3;
        if(show_bin){
            horizontal_hinge(hinge_l2, diam, hinge_rot());
            translate([0,0,-(diam/2)-hinge_gap]){       
                rotate([0,-90,0])
    translate([0,-(diam/2),0])
    linear_extrude((hinge_l2),center=true)
    polygon([
    [-diam,diam],
    [diam/2+hinge_gap,diam],
    [diam/2+hinge_gap,0],
    [0,0],
    ]);
            }
        }
        if(show_lid)
        {
            translate([hinge_l2,0,0]){
            horizontal_hinge(hinge_l2, diam, hinge_rot());
            translate([-hinge_l2/2,-(diam/2),0])
            cube([hinge_l2,diam,(diam/2)+hinge_gap]);
            }
            translate([-hinge_l2,0,0]){ 
            horizontal_hinge(hinge_l2, diam, hinge_rot());
                translate([-hinge_l2/2,-(diam/2),0])
            cube([hinge_l2,diam,(diam/2)+hinge_gap]);
            }
        }
}
}

difference(){
union(){
if (show_bin) {
color("tomato") {
difference(){
union(){
gridfinityInit(gridx, gridy, height(gridz, gridz_define, 0, enable_zsnap), height_internal, lip = 0) {

    if (divx > 0 && divy > 0)
    cutEqual(n_divx = divx, n_divy = divy, style_tab = style_tab, scoop_weight = scoop);
}
gridfinityBase(gridx, gridy, l_grid, div_base_x, div_base_y, style_hole, only_corners=only_corners);
}
relocate_hinge(hinge_diam)
translate([-(hing_len()/2),-2,-hinge_gap])
cube([hing_len(),hinge_diam,hinge_diam]);
relocate_hinge(hinge_diam)
translate([-((gridx*l_grid)/2),-2,hinge_gap])
cube([(gridx*l_grid),hinge_diam,hinge_hole]);
}
}
}

if (show_lid) {
difference(){
union(){
translate([0, 0,  height(gridz, gridz_define, style_lip, enable_zsnap)]){
color("green") {
gridfinityInit(gridx, gridy, height(1, gridz_define, 0, enable_zsnap), height_internal,lip=0) {

    if (divx > 0 && divy > 0)
    cutEqual(n_divx = divx, n_divy = divy, style_tab = style_tab, scoop_weight = scoop);
}
}
}
}
relocate_hinge(hinge_diam)
translate([-(hing_len()/2),-2,hinge_gap])
cube([hing_len(),hinge_diam,hinge_diam]);
}
}
relocate_hinge(hinge_diam){
cylinder_hinge();
}
}

relocate_hinge(hinge_diam){
translate([0,0,2])
rotate(hinge_rot())
cylinder(h=hing_len()*2,d=hinge_hole,center=true);
}
}
