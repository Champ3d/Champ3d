close all
clear all
clc


c0   = [0.09 0.002];
I0   = 1;

xmir = 0.1;
ymir = 0;

mur  = 1000;
k    = 4;

% --- positions miroirs théoriques
px  = fmirx(c0,xmir);
py  = fmiry(c0,ymir);
pxy = fmiry(px,ymir);

alpha = (mur - 1)/(mur + 1);
beta  = 1 + alpha;

disp(' ')
disp('Coefficients')
fprintf('alpha = %.12g\n', alpha)
fprintf('beta  = %.12g\n', beta)

disp(' ')
disp('Positions théoriques')
fprintf('c0  = [%g , %g]\n',c0(1),c0(2))
fprintf('px  = [%g , %g]\n',px(1),px(2))
fprintf('py  = [%g , %g]\n',py(1),py(2))
fprintf('pxy = [%g , %g]\n',pxy(1),pxy(2))


imagesys = generateimage(c0,I0,xmir,ymir,mur,k);


disp(' ')
disp('===== REGION 1 =====')
for i=1:length(imagesys.imageregion1)
    img = imagesys.imageregion1{i};
    fprintf('img %d : pos=[%g , %g]  I=%g\n',i,img.pos(1),img.pos(2),img.I);
end


disp(' ')
disp('===== REGION 0 =====')
for i=1:length(imagesys.imageregion0)
    img = imagesys.imageregion0{i};
    fprintf('img %d : pos=[%g , %g]  I=%g\n',i,img.pos(1),img.pos(2),img.I);
end


disp(' ')
disp('===== REGION 2 =====')
for i=1:length(imagesys.imageregion2)
    img = imagesys.imageregion2{i};
    fprintf('img %d : pos=[%g , %g]  I=%g\n',i,img.pos(1),img.pos(2),img.I);
end