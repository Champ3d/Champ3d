clear all
close all

R_in=0.100; % rayon interieur
R_out=0.375; % rayon exterieur
teta=100/360*2*pi; % angle de l'arc
Radius=5e-3; % rayon fil


%spire source

ndec_r=100; % nombre decoupages radial
ndec_teta=200; % nombre decoupage axial

teta_out=linspace(pi/2+teta/2,pi/2-teta/2,ndec_teta);
teta_in=linspace(pi/2-teta/2,pi/2+teta/2,ndec_teta);
R_left=linspace(R_in,R_out,ndec_r);
R_right=linspace(R_out,R_in,ndec_r);


Xs=[R_left*cos(pi/2+teta/2) R_out*cos(teta_out) R_right*cos(pi/2-teta/2) R_in*cos(teta_in) ];
Ys=[R_left*sin(pi/2+teta/2) R_out*sin(teta_out) R_right*sin(pi/2-teta/2) R_in*sin(teta_in) ];
Zs=Xs*0;

% suppression doublons

indice=[ndec_r+1 ndec_r+ndec_teta 2*ndec_r+ndec_teta];

Xs(indice)=[];
Ys(indice)=[];
Zs=Xs*0;

%spire destination

var1=Radius/tan(teta/2);
var2=Radius/sin(teta/2);
delta=atan(Radius/(R_in+Radius));

R_left=linspace(R_in+Radius-var1,R_out-Radius-var1,ndec_r);
R_right=linspace(R_out-Radius-var1,R_in+Radius-var1,ndec_r);
teta_out=linspace(pi/2+teta/2-delta,pi/2-teta/2+delta,ndec_teta);
teta_in=linspace(pi/2-teta/2+delta,pi/2+teta/2-delta,ndec_teta);

Xd=[R_left*cos(pi/2+teta/2) (R_out-Radius)*cos(teta_out) R_right*cos(pi/2-teta/2) (R_in+Radius)*cos(teta_in) ];
Yd=[var2+R_left*sin(pi/2+teta/2) (R_out-Radius)*sin(teta_out) var2+R_right*sin(pi/2-teta/2) (R_in+Radius)*sin(teta_in) ];

Xr = Xd.*cos(2*pi/3)+Yd.*sin(2*pi/3);
Yr = -Xd.*sin(2*pi/3)+Yd.*cos(2*pi/3); 

%Xd = Xr;
%Yd = Yr;

% suppression doublons


Xd(indice)=[];
Yd(indice)=[];
Zd=Xs*0;


figure; 

hold on
plot3(Xs,Ys,Zs,'g');
plot3(Xd,Yd,Zd,'b');
view(2)
axis equal

% calcul inductance

xsi=Xs(1:end-1);
xsf=Xs(2:end);
ysi=Ys(1:end-1);
ysf=Ys(2:end);
zsi=Zs(1:end-1);
zsf=Zs(2:end);

len=sum(sqrt((xsi-xsf).^2+(ysi-ysf).^2+(zsi-zsf).^2)); % longueur inducteur

xdi=Xd(1:end-1);
xdf=Xd(2:end);
ydi=Yd(1:end-1);
ydf=Yd(2:end);
zdi=Zd(1:end-1);
zdf=Zd(2:end);

L=0;
A = zeros(3,length(xdi));
for ii=1:size(xsi,2)
    for jj=1:size(xdi,2)
        [Lx,Ax] = fun_calcul_mutuel_segment(xsi(ii),ysi(ii),zsi(ii),...
            xsf(ii),ysf(ii),zsf(ii),xdi(jj),ydi(jj),zdi(jj),...
            xdf(jj),ydf(jj),zdf(jj));
        L=L+Lx;
        A(:,jj)=A(:,jj)+Ax;
    end
end

mu0=4*pi*1e-7;
Ltotal=L+len*mu0/(8*pi);

%%
dl=[(xdf+xdi)./2; (ydf+ydi)./2; (zdf+zdi)./2];
figure
f_quiver(dl,A)


