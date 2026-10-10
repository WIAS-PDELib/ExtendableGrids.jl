//
// Copied and distributed with permission from
// https://www.math.univ-paris13.fr/~cuvelier/software/gmshgeo.html
// 

N=20;
h = 1/N;
R=1.;
r=0.45;
// Center Points of big circle
Point(1) = {0, 0, 0, h}; 
Point(2) = {R, 0, 0, h};
Point(3) = {-R, 0, 0, h/2};
Point(4) = {0,R, 0, h};
Point(5) = {0,-R, 0, h};

Point(6) = {-r, 0, 0, h}; // center
Point(7) = {-r, r, 0, h}; 
Point(8) = {-r, -r, 0, h};
Point(9) = {-2*r, 0, 0, h/2};
Circle(1) = {2, 1, 4};
Circle(2) = {4, 1, 3};
Circle(3) = {3, 1, 5};
Circle(4) = {5, 1, 2};
Circle(5) = {1, 6, 7};
Circle(6) = {7, 6, 9};
Circle(7) = {9, 6, 8};
Circle(8) = {8, 6, 1};
Line Loop(9) = {1, 2, 3, 4};
Line Loop(10) = {5, 6, 7, 8};
Plane Surface(11) = {9, 10};
Physical Line(1) = {1, 2, 3, 4};
Physical Line(2) = {5, 6, 7, 8};
Physical Surface(1) = {11};
