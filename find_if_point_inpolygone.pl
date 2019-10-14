use strict;
use warnings;
use 5.010;
use List::Util qw[min max];

#Check if point is inside polygon

#check if points aligned
sub is_on_segment {
    my $px = $_[0];
	my $py = $_[1]; 
	my $rx = $_[2]; 
	my $ry = $_[3];
	my $qx = $_[4]; 
	my $qy = $_[5]; 
    my $onSegment = 0;
    if ($qx <= max($px, $rx) && $qx >= min($px, $rx) && $qy <= max($py, $ry) && $qy >= min($py, $ry)) {
        $onSegment = 1; 
    }
    return $onSegment; 
}

# To find orientation of ordered triplet (p, q, r). 
# 0 --> p, q and r are colinear 
# 1 --> Clockwise 
# 2 --> Counterclockwise 
sub find_orientation { 
	my $px = $_[0];
	my $py = $_[1]; 
	my $qx = $_[2]; 
	my $qy = $_[3];
	my $rx = $_[4]; 
	my $ry = $_[5];
	my $orientation = 0; #colinear
    my $slope_calculation = ($qy - $py) * ($rx - $qx) - ($ry - $qy) * ($qx - $px); 
	
    if ($slope_calculation > 0){
		$orientation = 1
	}
	if ($slope_calculation < 0){
		$orientation = 2
	}
	return $orientation;
}

sub do_intersect{ 
	my $px = $_[0];
	my $py = $_[1]; 
	my $qx = $_[2]; 
	my $qy = $_[3];
	my $rx = $_[4]; 
	my $ry = $_[5];
	my $sx = $_[6]; 
	my $sy = $_[7];
	
	
    # Find the four orientations
    my $o1 = find_orientation($px,$py,$qx,$qy,$rx,$ry); 
    my $o2 = find_orientation($px,$py,$qx,$qy,$sx,$sy); 
    my $o3 = find_orientation($rx,$ry,$sx,$sy,$px,$py); 
    my $o4 = find_orientation($rx,$ry,$sx,$sy,$qx,$qy); 
	
	my $intersection = 0;
	
    # General case 
    if ($o1 != $o2 && $o3 != $o4){
        $intersection = 1; 
	}
    # Special Cases 
    # p, q and r are colinear and r lies on segment pq 
    if ($o1 == 0 && is_on_segment($px,$py, $rx,$ry, $qx,$qy)){ 
		$intersection = 1;
	}
  
    # p, q and r are colinear and s lies on segment pq 
    if ($o2 == 0 && is_on_segment($px,$py, $sx,$sy, $qx,$qy)){ 
		$intersection = 1;
	}
  
    # r, s and p are colinear and p lies on segment rs
    if ($o3 == 0 && is_on_segment($rx,$ry, $px,$py, $sx,$sy)){
		$intersection = 1;  
	}
  
    # r, s and q are colinear and q lies on segment rs 
    if ($o4 == 0 && is_on_segment($rx,$ry, $qx,$qy, $sx,$sy)){
		$intersection = 1;
	}
  
    return $intersection;
} 

sub is_inside{ 
	my $number_vertices = $_[0];
	my $pnt_x = $_[1];
	my $pnt_y = $_[2];
	my $poly_x_ref = $_[3] ;
	my $poly_y_ref = $_[4] ;
	
    # There must be at least 3 vertices in the polygon
    if ($number_vertices < 3){
		return 0; 
	}	
  
    # Create a point for line segment from p to infinite 
    my $pnt_inf_x = 1000;
	my $pnt_inf_y = $pnt_y; 	
  
    # Count intersections of the above line with sides of polygon 
    my $count = 0;
	my $i = 0; 
    do
    { 
        my $next = ($i+1)%$number_vertices; 
  
        # Check if the line segment from 'p' to 'extreme' intersects 
        # with the line segment from 'polygon[i]' to 'polygon[next]' 
        if (do_intersect($poly_x_ref->[$i],$poly_y_ref->[$i],$poly_x_ref->[$next],$poly_y_ref->[$next],$pnt_x,$pnt_y,$pnt_inf_x,$pnt_inf_y)) 
        { 
            # If the point 'p' is colinear with line segment 'i-next', 
            # then check if it lies on segment. If it lies, return true, 
            # otherwise false 
            if (find_orientation($poly_x_ref->[$i],$poly_y_ref->[$i],$poly_x_ref->[$next],$poly_y_ref->[$next],$pnt_x,$pnt_y) == 0){ 
               return is_on_segment($poly_x_ref->[$i],$poly_y_ref->[$i], $poly_x_ref->[$next],$poly_y_ref->[$next], $pnt_x,$pnt_y); 
			}
            $count++; 
        } 
        $i = $next; 
    } while ($i != 0); 
  
    # Return true if count is odd, false otherwise 
    return $count%2 == 1;
} 


#test

#polygone points array

my @poly_x = (0, 1, 1, 0.5, 0);
my $poly_x_ref = \@poly_x;
my @poly_y = (0, 0, 1, 2, 1);
my $poly_y_ref = \@poly_y;

#showing the polygon to the user
print "polygon x values: \n"; 
print "@poly_x\n";
print "polygon y values: \n"; 
print "@poly_y\n";

print "Enter the coordinates of the points to see if it is inside the polygon\n";
#the point we want to test
print "point x : "; 
my $pnt_x = <STDIN>; 
print "point y : "; 
my $pnt_y = <STDIN>; 

my $number_vertices = @poly_x;
my $point_inside = is_inside($number_vertices, $pnt_x, $pnt_y, $poly_x_ref, $poly_y_ref);

if ($point_inside){
	print "The point is inside the polygone";
}
else{
	print "The point is not inside the polygone";
}




