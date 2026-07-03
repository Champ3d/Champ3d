clear all
close all
clc

% ---------------- Paramètres géométriques ----------------
mur = 2000;
I0  = 1;
imagelevel = 20;

epaisseur    = 6e-3;   % épaisseur de chaque noyau
z1primaire   = -4e-3;       % interface 2
z1secondaire = 4e-3;    % interface 3  -> airgap = 4 mm



zinterface = [z1primaire - epaisseur;
              z1primaire;
              z1secondaire;
              z1secondaire + epaisseur];

% ---------------- Source réelle ----------------

c0 = [0, 0];

alpha = (mur - 1)/(mur + 1);
beta  = 1 + alpha;

disp(' ')
disp('===== PARAMETRES =====')
fprintf('alpha = %.12g\n', alpha)
fprintf('beta  = %.12g\n', beta)
fprintf('c0    = [%g , %g]\n', c0(1), c0(2))

disp(' ')
disp('===== INTERFACES =====')
fprintf('interface 1 : z = %g\n', zinterface(1))
fprintf('interface 2 : z = %g\n', zinterface(2))
fprintf('interface 3 : z = %g\n', zinterface(3))
fprintf('interface 4 : z = %g\n', zinterface(4))

%% ===================== TEST SG1 =====================
disp(' ')
disp('==========================================')
disp('TEST SOUS-GROUPE 1')
disp('==========================================')

imagesys_sg1 = generateimage_sg1(c0, I0, z1primaire, z1secondaire, epaisseur, mur, imagelevel);

afficher_region(imagesys_sg1.imageregion1, 1)
afficher_region(imagesys_sg1.imageregion2, 2)
afficher_region(imagesys_sg1.imageregion3, 3)
afficher_region(imagesys_sg1.imageregion4, 4)
afficher_region(imagesys_sg1.imageregion5, 5)

%% ===================== TEST SG2 =====================
disp(' ')
disp('==========================================')
disp('TEST SOUS-GROUPE 2')
disp('==========================================')

imagesys_sg2 = generateimage_sg2(c0, I0, z1primaire, z1secondaire, epaisseur, mur, imagelevel);

afficher_region(imagesys_sg2.imageregion1, 1)
afficher_region(imagesys_sg2.imageregion2, 2)
afficher_region(imagesys_sg2.imageregion3, 3)
afficher_region(imagesys_sg2.imageregion4, 4)
afficher_region(imagesys_sg2.imageregion5, 5)

return

%% ===================== TEST FUSION =====================
disp(' ')
disp('==========================================')
disp('TEST FUSION SG1 + SG2')
disp('==========================================')

imagesys = imagesys_sg1.fusionner(imagesys_sg2);

afficher_region(imagesys.imageregion1, 1)
afficher_region(imagesys.imageregion2, 2)
afficher_region(imagesys.imageregion3, 3)
afficher_region(imagesys.imageregion4, 4)
afficher_region(imagesys.imageregion5, 5)

%% ===================== FONCTION LOCALE =====================
function afficher_region(liste_region, num_region)

disp(' ')
fprintf('===== REGION %d =====\n', num_region)

if isempty(liste_region)
    disp('vide')
    return
end

for i = 1:length(liste_region)
    img = liste_region{i};
    fprintf(['img %d : pos=[%g , %g]  I=%g  region=%d  next_interface=%d' ...
             '  deja_traite=%d\n'], ...
             i, img.pos(1), img.pos(2), img.I, ...
             img.region, img.next_interface, img.deja_traite);
end

end