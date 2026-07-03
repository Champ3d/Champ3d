mur = 2000;

tP = 1000e-3;
wP = 1000e-3;
cP = [0, -tP/2];
% ---
agap = 4e-3;
% ---
I0 = 1;
x0 = 0;
y0 = agap;
c0 = [wP/2-5e-3, y0];



xmir = +wP/2;
ymir = 0;
k=40;
%%
imagesys = generateimage(c0, I0,xmir, ymir, mur, k);

img1 = imagesys.imageregion1;
img2 = imagesys.imageregion2;
img0 = imagesys.imageregion0;
img={};
liste_a_faire = extraire_nouveaux(img1,img1,img)