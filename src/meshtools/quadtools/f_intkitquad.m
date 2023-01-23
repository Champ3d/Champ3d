function iKit = f_intkitquad(p2d,t2d)

%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------
nb_t = size(t2d,2);
volume = 0;

x1=p2d(1,t2d(1,:)); x2=p2d(1,t2d(2,:)); x3=p2d(1,t2d(3,:)); x4=p2d(1,t2d(4,:)); xN=[x1;x2;x3;x4].';
y1=p2d(2,t2d(1,:)); y2=p2d(2,t2d(2,:)); y3=p2d(2,t2d(3,:)); y4=p2d(2,t2d(4,:)); yN=[y1;y2;y3;y4].';

U = 1/sqrt(3)*[-1 -1  1  1];
V = 1/sqrt(3)*[-1  1 -1  1]; % W = [1 1 1 1];

for iG = 1:length(U)
%% Jacobien

% GNu=[-ones(1,nb_t);+ones(1,nb_t);zeros(1,nb_t)].';
% GNv=[-ones(1,nb_t);zeros(1,nb_t);+ones(1,nb_t)].';

u = U(iG).*ones(1,nb_t);
v = V(iG).*ones(1,nb_t);

GNu=[(-1+v)./4; (+1-v)./4; (1+v)./4; (-1-v)./4].';
GNv=[(-1+u)./4; (-1-u)./4; (1+u)./4; (+1-u)./4].';


Jac(1,:,1)=sum((GNu(:,:).*xN(:,:)).');
Jac(1,:,2)=sum((GNu(:,:).*yN(:,:)).');
Jac(2,:,1)=sum((GNv(:,:).*xN(:,:)).');
Jac(2,:,2)=sum((GNv(:,:).*yN(:,:)).');

a11(1,:)=Jac(1,:,1); a12(1,:)=Jac(1,:,2);
a21(1,:)=Jac(2,:,1); a22(1,:)=Jac(2,:,2);

detJ{iG} = a11.*a22 - a21.*a12;

Jaci{iG}(1,:,1) = +1./detJ{iG}.*Jac(2,:,2);
Jaci{iG}(1,:,2) = -1./detJ{iG}.*Jac(1,:,2);
Jaci{iG}(2,:,1) = -1./detJ{iG}.*Jac(2,:,1);
Jaci{iG}(2,:,2) = +1./detJ{iG}.*Jac(1,:,1);

%% gradN
gradWn{iG} = zeros(2,nb_t,4);
for i = 1:4
    gradWn{iG}(1,:,i)=Jaci{iG}(1,:,1).*GNu(:,i)'+Jaci{iG}(1,:,2).*GNv(:,i)';
    gradWn{iG}(2,:,i)=Jaci{iG}(2,:,1).*GNu(:,i)'+Jaci{iG}(2,:,2).*GNv(:,i)';
end


%% Wn
N1 = 1/4*(1-u).*(1-v);
N2 = 1/4*(1+u).*(1-v);
N3 = 1/4*(1+u).*(1+v);
N4 = 1/4*(1-u).*(1+v);
Wn{iG}  = [N1; N2; N3; N4];

%%
volume = volume + detJ{iG};

end

%% the kit
iKit.Jaci = Jaci;
iKit.detJ = detJ;
iKit.gradWn = gradWn;
iKit.Wn = Wn;
iKit.wei = 1;
iKit.volume = volume;

%% cen
U = 0;
V = 0;

u = U.*ones(1,nb_t);
v = V.*ones(1,nb_t);

GNu=[(-1+v)./4; (+1-v)./4; (1+v)./4; (-1-v)./4].';
GNv=[(-1+u)./4; (-1-u)./4; (1+u)./4; (+1-u)./4].';

Jac(1,:,1)=sum((GNu(:,:).*xN(:,:)).');
Jac(1,:,2)=sum((GNu(:,:).*yN(:,:)).');
Jac(2,:,1)=sum((GNv(:,:).*xN(:,:)).');
Jac(2,:,2)=sum((GNv(:,:).*yN(:,:)).');

a11(1,:)=Jac(1,:,1); a12(1,:)=Jac(1,:,2);
a21(1,:)=Jac(2,:,1); a22(1,:)=Jac(2,:,2);

detJc = a11.*a22 - a21.*a12;

Jacic(1,:,1) = +1./detJc.*Jac(2,:,2);
Jacic(1,:,2) = -1./detJc.*Jac(1,:,2);
Jacic(2,:,1) = -1./detJc.*Jac(2,:,1);
Jacic(2,:,2) = +1./detJc.*Jac(1,:,1);

gradWnc = zeros(2,nb_t,4);
for i = 1:4
    gradWnc(1,:,i)=Jacic(1,:,1).*GNu(:,i)'+Jacic(1,:,2).*GNv(:,i)';
    gradWnc(2,:,i)=Jacic(2,:,1).*GNu(:,i)'+Jacic(2,:,2).*GNv(:,i)';
end

N1 = 1/4*(1-u).*(1-v);
N2 = 1/4*(1+u).*(1-v);
N3 = 1/4*(1+u).*(1+v);
N4 = 1/4*(1-u).*(1+v);
Wnc = [N1; N2; N3; N4];

%% the kit
iKit.Jacic = Jacic;
iKit.detJc = detJc;
iKit.gradWnc = gradWnc;
iKit.Wnc = Wnc;
iKit.weic = 1;

