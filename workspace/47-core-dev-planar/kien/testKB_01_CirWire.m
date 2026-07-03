close all
clear all
clc

% ---
l = 10e-3;
d = [0 5e-3 5e-3];
P1 = [0 0 0];
P2 = [l 0 0];

r = 10e-3;
phi0 = 0;
phi1 = phi0 - 15;
phi2 = phi0 + 15;

D1 = [0 -5*l  0] + d;
D2 = [0 +5*l  0] + d;

% --- div P
nbpP = 1000;
dP12 = zeros(3,nbpP);
dphi = linspace(phi1,phi2,nbpP);
dP12(1,:) = r .* cosd(dphi);
dP12(2,:) = r .* sind(dphi);
% --- center
lP12 = vecnorm(dP12(:,2:end) - dP12(:,1:end-1));
dP12 = (dP12(:,1:end-1) + dP12(:,2:end)) ./ 2;

% --- div D
nbpD = 10000;
dD12 = zeros(3,nbpD);
for i = 1:3
    dD12(i,:) = linspace(D1(i),D2(i),nbpD);
end
lD12 = linspace(0,norm(D2-D1),nbpD);
% ---
mu0 = 4*pi*1e-7;
I = 1;

tic
A = zeros(1,nbpD);
for i = 1:nbpD
    dR = dP12 - dD12(:,i);
    A(i) = sum(mu0*I/4/pi * lP12 .* 1./abs(vecnorm(dR)));
end
toc
%% ---
% figure
% plot3(dP12(1,:),dP12(2,:),dP12(3,:)); hold on
% plot3(dD12(1,:),dD12(2,:),dD12(3,:));

%%
% figure
% plot(lD12,A); hold on;

%%

% wire02 = OxyStraightWire("P1",P1(1:2),"P2",P2(1:2),"z",0,"signI",1);
wire02 = OxyArcWire("z",0,"signI",1,"center",[0 0],"r",r,"phi1",phi1,"phi2",phi2);
tic
A2 = wire02.getanode("node",dD12,"I",1);
toc
%%
% figure;
% f_quiver(dD12,A2);

%%
figure
wire02.plot("color","k"); hold on
plot3(dP12(1,:),dP12(2,:),dP12(3,:),"ro"); hold on
plot3(dD12(1,:),dD12(2,:),dD12(3,:));
%%
figure
plot(lD12+D1(1),A,'ro','DisplayName','Biot-Savart Num'); hold on;
plot(lD12+D1(1),vecnorm(A2),'k-','DisplayName','Formule'); hold on;
%%
% figure
% semilogx(lD12+D1(1),A,'ro','DisplayName','Biot-Savart Num'); hold on;
% semilogx(lD12+D1(1),vecnorm(A2),'k-','DisplayName','Formule'); hold on;

%%
figure
plot(lD12,vecnorm(A2)./A,'DisplayName','Formule'); hold on;



