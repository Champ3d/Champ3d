function [Bprimaire,Bsecondaire]=induction_analytique_image_correction(gamma1,gamma2,gamma3,gamma4,coeff)

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
mirback=data_opt.mirback;
mirfont=data_opt.mirfront;


Bsecondaire=0;
Bprimaire=0;

node1 = [px_primaire; py_primaire];






x = fmirx(c0,mirfont);
xcorrection_front = x(1);

x = fmirx(c0,mirback);
xcorrection_back = x(1);


y=fmiry(c0,z1primaire);
h2=y(2);

y=fmiry(c0,z1secondaire);
h1=y(2);



if(coeff(1) ~= 0)

    Bcorrection = {};
    
    Bcorrection{1} = fB([xcorrection_back,  h1], node1, gamma1*I0);
    Bcorrection{2} = fB([xcorrection_back,  h2], node1, gamma2*I0);
    Bcorrection{3} = fB([xcorrection_front, h1], node1, gamma3*I0);
    Bcorrection{4} = fB([xcorrection_front, h2], node1, gamma4*I0);
    
    
    Btotal = 0;
    for i = 1:4
        Btotal = Btotal + Bcorrection{i};
    end
    
    Bprimaire = Btotal;

end



node2 = [px_secondaire; py_secondaire];

if(coeff(2) ~= 0)
    Bcorrection2 = {};
    
    Bcorrection2{1} = fB([xcorrection_back,  h1], node2, gamma1*I0);
    Bcorrection2{2} = fB([xcorrection_back,  h2], node2, gamma2*I0);
    Bcorrection2{3} = fB([xcorrection_front, h1], node2, gamma3*I0);
    Bcorrection2{4} = fB([xcorrection_front, h2], node2, gamma4*I0);
    
    Btotal2 = 0;
    for i = 1:4
        Btotal2 = Btotal2 + Bcorrection2{i};
    end
    
    Bsecondaire= Bsecondaire+ Btotal2;
end

end