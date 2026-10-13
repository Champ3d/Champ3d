function [Bprimaire,Bsecondaire] = induction_analytique

load data_opt.mat
c0 = data_opt.c0;
mur = data_opt.mur;
I0 = data_opt.I0;
tP = data_opt.tP;
wP = data_opt.wP;
agap = data_opt.agap;
px_primaire = data_opt.px_primaire;
py_primaire = data_opt.py_primaire;
px_secondaire = data_opt.px_secondaire;
py_secondaire = data_opt.py_secondaire;
z1primaire = data_opt.z1primaire;
z1secondaire = data_opt.z1secondaire;
imagelevel = data_opt.imagelevel;

node1 = [px_primaire; py_primaire];
Bprimaire = calculBregion(c0,I0,z1primaire,z1secondaire,tP,mur,imagelevel,node1);

node2 = [px_secondaire; py_secondaire];
Bsecondaire = calculBregion(c0,I0,z1primaire,z1secondaire,tP,mur,imagelevel,node2);




end