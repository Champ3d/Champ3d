z=0;
P1=[0 0 ];
P2=[1000 0];
d=5;

D1=P1+[0 d];
D2=P2+[0 d];




rnum=20;
xnode = linspace(D1(1), D2(1), rnum+1);
ynode = linspace(D1(2), D2(2), rnum+1);
znode = z*ones(size(ynode));


 wire02 = OxyStraightWire("P1",P1,"P2",P2,"z",z,"signI",1);
 A=wire02.getanode("node",[xnode;ynode;znode],"I",1);
 figure;
f_quiver([xnode;ynode;znode],A);
title("A");

xlabel('x');
ylabel('y');
axis equal;
