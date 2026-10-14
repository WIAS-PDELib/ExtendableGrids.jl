//
// Copied and distributed with permission from
// https://www.math.univ-paris13.fr/~cuvelier/software/gmshgeo.html
// 

DefineConstant[
  N = {10, Name "Input/1Points "}
];
L=1;
h=L/N; 

Point (1) = {0, 0, 0, h};
Point (2) = {L, 0, 0, h};
Point (3) = {L, L, 0, h};
Point (4) = {0, L, 0, h};
Point (5) = {0, 0, L, h};
Point (6) = {L, 0, L, h};
Point (7) = {L, L, L, h};
Point (8) = {0, L, L, h};
Line (1)  = {1, 2};
Line (2)  = {2, 3};
Line (3)  = {3, 4};
Line (4)  = {4, 1};
Line (5)  = {5, 6};
Line (6)  = {6, 7};
Line (7)  = {7, 8};
Line (8)  = {8, 5};
Line (9)  = {1, 5};
Line (10) = {2, 6};
Line (11) = {3, 7};
Line (12) = {4, 8};

Line Loop(13) = {3, 12, -7, -11};
Plane Surface(4) = {13};
Line Loop(15) = {4, 9, -8, -12};
Plane Surface(1) = {15};
Line Loop(17) = {5, -10, -1, 9};
Plane Surface(3) = {17};
Line Loop(19) = {3, 4, 1, 2};
Plane Surface(5) = {19};
Line Loop(21) = {11, -6, -10, 2};
Plane Surface(2) = {21};
Line Loop(23) = {7, 8, 5, 6};
Plane Surface(6) = {23};
Surface Loop(25) = {4, 5, 1, 3, 6, 2};
Volume(1) = {25};

Physical Line(1) = {1};
Physical Line(2) = {2};
Physical Line(3) = {3};
Physical Line(4) = {4};
Physical Line(5) = {5};
Physical Line(6) = {6};
Physical Line(7) = {7};
Physical Line(8) = {8};
Physical Line(9) = {9};
Physical Line(10) = {10};
Physical Line(11) = {11};
Physical Line(12) = {12};
Physical Surface(1) = {1};
Physical Surface(4) = {4};
Physical Surface(5) = {5};
Physical Surface(2) = {2};
Physical Surface(6) = {6};
Physical Surface(3) = {3};
Physical Volume(1) = {1};
Physical Point(101) = {1};
Physical Point(102) = {2};
Physical Point(103) = {3};
Physical Point(104) = {4};
Physical Point(201) = {5};
Physical Point(202) = {6};
Physical Point(203) = {7};
Physical Point(204) = {8};
