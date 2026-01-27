close all
clear all
clc
%%
% ---
l = 10e-3;
d = [0 0 1e-3];
P1 = [0 0 0];
P2 = [l 0 0];
D1 = P1 + d;
D2 = P2 + d;
% --- div D
nbpD = 100;
dD12 = zeros(3,nbpD);
for i = 1:3
    dD12(i,:) = linspace(D1(i),D2(i),nbpD);
end
lD12 = linspace(0,norm(D2-D1),nbpD);
%%
%----- div arc

mu0 = 4*pi*1e-7;
I = 1;
R = 10e-3;                 
C = [0 0 0];               
theta1 = 0;                
theta2 = 90;             
nbpArc = 4000;            




alphak = linspace(theta1, theta2, nbpArc+1);          
alpha_mid = 0.5*(alphak(1:end-1) + alphak(2:end));    
xk = C(1) + R*cosd(alphak);
yk = C(2) + R*sind(alphak);
zk = C(3) + 0*alphak;

dlArc = [xk(2:end)-xk(1:end-1);yk(2:end)-yk(1:end-1);zk(2:end)-zk(1:end-1)];                      

rArc = [C(1) + R*cosd(alpha_mid);C(2) + R*sind(alpha_mid);C(3) + 0*alpha_mid]; 


% ---
mu0 = 4*pi*1e-7;
I = 1;

A_arc_an = zeros(3, nbpD);
for i = 1:nbpD
    dR = dD12(:,i) - rArc;
    dist = vecnorm(dR);
    A_arc_an(:,i) = sum(mu0*I/4/pi * dlArc ./abs(dist),2);
end


A_arc_an_norm=vecnorm(A_arc_an);



% ---

figure
f_quiver(dD12,A_arc_an);
title("A formule analytique arc");



%%
% --- div P
nbpP = 1000;
dP12 = zeros(3,nbpP);
for i = 1:3
    dP12(i,:) = linspace(P1(i),P2(i),nbpP);
end
% --- center
dP12 = (dP12(:,1:end-1) + dP12(:,2:end)) ./ 2;
lP12 = norm(P2-P1) / nbpP;


mu0 = 4*pi*1e-7;
I = 1;

A_segment_an = zeros(1,nbpD);
for i = 1:nbpD
    dR = dP12 - dD12(:,i);
    A_segment_an(i) = sum(mu0*I/4/pi * lP12 .* 1./abs(vecnorm(dR)));
end



figure
f_quiver(dD12,A_arc_an);
title("A formule analytique segment");


%%
figure
plot3(dD12(1,:),dD12(2,:),dD12(3,:),'o'); hold on
plot3(rArc(1,:), rArc(2,:), rArc(3,:),'*','color','k'); hold on
plot3(dP12(1,:),dP12(2,:),dP12(3,:),'*','color','k'); 
title("arc et segments");





%%

wire02 = OxyArcWire("z",C(3),"center",C,"phi1",theta1,"phi2",theta2,"r",R,"signI",1);
A_arc_num = wire02.getanode("node",dD12,"I",1);

figure;
f_quiver(dD12,A_arc_num);
title("A  Num arc");

%%
figure
plot(lD12,A_arc_an_norm,'DisplayName','Biot-Savart Num','color','r'); hold on;
plot(lD12,vecnorm(A_arc_num),'DisplayName','Formule','color','k'); hold on;
%plot(lD12,vecnorm(A_arc_num)./A_arc_an_norm,'DisplayName','Formule'); hold on;
title("Comparaison A arc");
%%
wire02 = OxyStraightWire("P1",P1(1:2),"P2",P2(1:2),"z",0,"signI",1);
A_segment_num = wire02.getanode("node",dD12,"I",1);

figure
plot(lD12,A_segment_an,'DisplayName','Biot-Savart Num'); hold on;
plot(lD12,vecnorm(A_segment_num),'DisplayName','Formule'); hold on;




%%
A_num=A_arc_num+A_segment_num;
A_an=[A_segment_an;zeros(size(A_segment_an));zeros(size(A_segment_an))] +A_arc_an;

figure
plot(lD12,vecnorm(A_num),'DisplayName','Biot-Savart Num','color','r'); hold on;
plot(lD12,vecnorm(A_an),'DisplayName','Formule','color','k'); hold on;

title("Comparaison A total");


figure;
f_quiver(dD12,A_num);
title("A  Num total");


figure;
f_quiver(dD12,A_an);
title("A  analytique total");



