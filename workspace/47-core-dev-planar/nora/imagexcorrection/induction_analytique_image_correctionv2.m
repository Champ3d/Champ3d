function [Bprimaire,Bsecondaire]=induction_analytique_image_correctionv2(x1,x2,x3,x4,coeff)

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


alpha=(mur-1)/(mur+1);





y=fmiry(c0,z1primaire);
h2=y(2);

y=fmiry(c0,z1secondaire);
h1=y(2);



if(coeff(1) ~= 0)

    Bcorrection = {};
    
    Bcorrection{1} = fB([x1,  h1], node1, -alpha^2*I0);
    Bcorrection{2} = fB([x2,  h2], node1, -alpha^2*I0);
    Bcorrection{3} = fB([x3, h1], node1, -alpha^2*I0);
    Bcorrection{4} = fB([x4, h2], node1, -alpha^2*I0);
    
    
    Btotal = 0;
    for i = 1:4
        Btotal = Btotal + Bcorrection{i};
    end
    
    Bprimaire = Btotal;

end



node2 = [px_secondaire; py_secondaire];

if(coeff(2) ~= 0)
    Bcorrection2 = {};
    
    Bcorrection2{1} = fB([x1,  h1], node2, -alpha^2*I0);
    Bcorrection2{2} = fB([x2,  h2], node2, -alpha^2*I0);
    Bcorrection2{3} = fB([x3, h1], node2, -alpha^2*I0);
    Bcorrection2{4} = fB([x4, h2], node2, -alpha^2*I0);
    
    Btotal2 = 0;
    for i = 1:4
        Btotal2 = Btotal2 + Bcorrection2{i};
    end
    
    Bsecondaire= Bsecondaire+ Btotal2;
end

end