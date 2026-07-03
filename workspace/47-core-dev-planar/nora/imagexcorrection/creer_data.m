function data_opt=creer_data(I0,wP,tP,agap,d,l,mur,px_primaire,py_primaire,px_secondaire,py_secondaire,imagelevel)
c0=[wP/2-l,d];

data_opt.c0   = c0;
data_opt.mur  = mur;
data_opt.I0   = I0;
data_opt.tP   = tP;
data_opt.wP   = wP;
data_opt.agap = agap;
data_opt.px_primaire = px_primaire;
data_opt.py_primaire = py_primaire;
data_opt.px_secondaire=px_secondaire;
data_opt.py_secondaire=py_secondaire;
data_opt.z1primaire=0;
data_opt.z1secondaire=agap;
data_opt.imagelevel=imagelevel;
data_opt.mirback=-wP/2;
data_opt.mirfront=wP/2;
if isfile('data_opt.mat')
    delete('data_opt.mat');
end

save('data_opt.mat','data_opt')


end