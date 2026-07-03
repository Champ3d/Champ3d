

clear all
clc
mur = 2000;

tP = 15e-3;
wP = 750e-3;
dNoyauFerv=10e-3;
dNoyauFerh=10e-3;
agap = 200e-3;
I0 = 1;
imagelevel=10;
nbp=300;

px_primaire  = linspace(-wP/2,wP/2-20e-3,nbp);
py_primaire  = (dNoyauFerv).*ones(1,nbp);
px_secondaire  = linspace(-wP/2,+wP/2,nbp);
py_secondaire  = (agap-dNoyauFerv).*ones(1,nbp);


data_opt=creer_data(I0,wP,tP,agap,dNoyauFerv,dNoyauFerh,mur,px_primaire,py_primaire,px_secondaire ,py_secondaire ,imagelevel);

z1primaire = data_opt.z1primaire;
z1secondaire = data_opt.z1secondaire;
z2primaire=z1primaire-tP/2;
z2secondaire=z1secondaire+tP/2;


%%
[B_femm_primaire,B_femm_secondaire] = induction_FEMM;
[B_analytique_primaire,B_analytique_secondaire] = induction_analytique;

coeff=[1,1];
%%
%---------------------------------------  definition du probleme---------------------------------------------------------------
problem = struct;

problem.fitnessfcn = @(x) calcul_erreurv2(x,B_femm_primaire,B_femm_secondaire,B_analytique_primaire,B_analytique_secondaire,coeff);

problem.nvars = 4;

problem.lb = [ -10*wP, -10*wP, wP/2, wP/2];  


problem.ub = [-wP/2, -wP/2, 10*wP, 10*wP];  

problem.Aineq = [];
problem.bineq = [];
problem.Aeq = [];
problem.beq = [];
problem.solver='ga';
problem.options = optimoptions('ga', 'Display','iter','PopulationSize',200, 'MaxGenerations',1000,'FunctionTolerance',1e-10);

tic


[xopt,fval]=ga(problem);

temp_opt=toc;
% Affichage résultat
disp(' ')
disp('===== RESULTAT GA =====')
fprintf('fval = %.12g\n', fval)


x1 = xopt(1);
x2 = xopt(2);
x3 = xopt(3);
x4 = xopt(3);

fprintf('Temps opti : %.2f s\n', temp_opt);
fprintf('x1 = %g\n',x1)
fprintf('x2 = %g\n', x2)
fprintf('x3 = %g\n', x3)
fprintf('x4 = %g\n', x4)

%%


[Bprimaire,Bsecondaire]=induction_analytique_image_correctionv2(x1,x2,x3,x4,coeff);





%%


B_analytique_primaire.region3=B_analytique_primaire.region3+Bprimaire;
B_analytique_secondaire.region3=B_analytique_secondaire.region3+Bsecondaire;





%%

dossier='C:\Github\Champ3d\workspace\47-core-dev-planar\nora\imagexcorrection\opti_v2';
%close all

if(coeff(1) ~= 0)
fig1 = figure;hold on;
sgtitle(" Induction magnétique region 3 pres du courant")
subplot(121)
plot(px_primaire, (B_analytique_primaire.region3(1,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
plot(px_primaire, (B_femm_primaire (1,:)), "ro", "LineWidth", 2, 'DisplayName', 'FEM '); hold on
subplot(122)
plot(px_primaire, (B_analytique_primaire.region3(2,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
plot(px_primaire, (B_femm_primaire (2,:)), "ro", "LineWidth", 2, 'DisplayName', 'FEM '); hold on

nom_fig=sprintf('opti_primaire_coeff=%g_%g', coeff(1), coeff(2));
chemin_fig = fullfile(dossier, nom_fig);
savefig(fig1, [chemin_fig '.fig']);

end

if(coeff(2) ~= 0)
fig2=figure;hold on;
sgtitle(" Induction magnétique region 3 au secondaire")
subplot(121)
plot(px_secondaire, (B_analytique_secondaire.region3(1,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
plot(px_secondaire, (B_femm_secondaire (1,:)), "ro", "LineWidth", 2, 'DisplayName', 'FEM '); hold on
subplot(122)
plot(px_secondaire, (B_analytique_secondaire.region3(2,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
plot(px_secondaire, (B_femm_secondaire (2,:)), "ro", "LineWidth", 2, 'DisplayName', 'FEM '); hold on

nom_fig=sprintf('opti_secondaire_coeff=%g_%g', coeff(1), coeff(2));
chemin_fig = fullfile(dossier, nom_fig);

savefig(fig2, [chemin_fig '.fig']);


end
%%

nom_fichier = sprintf('opti_v2_coeff=%g_%g.txt', coeff(1), coeff(2));

fid = fopen(nom_fichier, 'w');


if fid == -1
    error('Impossible d''ouvrir le fichier');
end
fprintf(fid, '\n===== RESULTAT GA =====\n');
fprintf(fid, 'fval = %.12g\n', fval);

fprintf(fid, 'Temps opti : %.2f s\n', temp_opt);
fprintf(fid, 'x1 = %g\n', x1);
fprintf(fid, 'x2 = %g\n', x2);
fprintf(fid, 'x3 = %g\n', x3);
fprintf(fid, 'x4 = %g\n',x4);

fprintf(fid, 'Image sauvegardée : figure1.png\n');

fclose(fid);

disp(['Fichier enregistré : ', nom_fichier])















