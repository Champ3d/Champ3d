% ---------------- Paramètres géométriques ----------------
mur = 2000;
I0  = 1;
imagelevel = 1;

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
