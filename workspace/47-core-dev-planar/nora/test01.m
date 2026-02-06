close all
clear all
clc

% ---
l = 10e-3;
d = [0 0 1e-3];
P1 = [0 0 0];
P2 = [l 0 0];
D1 = P1 + d;
D2 = P2 + d;
% --- div P
nbpP = 1000;
dP12 = zeros(3,nbpP);
for i = 1:3
    dP12(i,:) = linspace(P1(i),P2(i),nbpP);
end
% --- center
dP12 = (dP12(:,1:end-1) + dP12(:,2:end)) ./ 2;
lP12 = norm(P2-P1) / nbpP;

% --- div D
nbpD = 100;
dD12 = zeros(3,nbpD);
for i = 1:3
    dD12(i,:) = linspace(D1(i),D2(i),nbpD);
end
lD12 = linspace(0,norm(D2-D1),nbpD);
% ---
mu0 = 4*pi*1e-7;
I = 1;

A = zeros(1,nbpD);
for i = 1:nbpD
    dR = dP12 - dD12(:,i);
    A(i) = sum(mu0*I/4/pi * lP12 .* 1./abs(vecnorm(dR)));
end

% ---
figure
plot3(dP12(1,:),dP12(2,:),dP12(3,:)); hold on
plot3(dD12(1,:),dD12(2,:),dD12(3,:));

figure
plot(lD12,A); hold on;

%%

wire02 = OxyStraightWire("P1",P1(1:2),"P2",P2(1:2),"z",0,"signI",1);
A2 = wire02.getanode("node",dD12,"I",1);

figure;
f_quiver(dD12,A2);

%%
figure
plot(lD12,A,'DisplayName','Biot-Savart Num'); hold on;
plot(lD12,vecnorm(A2),'DisplayName','Formule'); hold on;

%%
figure
plot(lD12,vecnorm(A2)./A,'DisplayName','Formule'); hold on;



