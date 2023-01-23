function mesh = f_intkit3d(mesh)
% F_INTKIT3D adds the interpolation and integral kit to mesh.
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh : mesh data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% mesh : mesh data structure with kit added
%--------------------------------------------------------------------------
% EXAMPLE
% mesh = F_INTKIT3D(mesh);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

node = mesh.node;
elem = mesh.elem;
si_ori_edge_in_elem = mesh.si_ori_edge_in_elem;
si_ori_face_in_elem = mesh.si_ori_face_in_elem;

con = f_connexion(mesh.elem_type);
nbNo_inEl = con.nbNo_inEl;
nbG = con.nbG;
U = con.U;
V = con.V;
W = con.W;
Weigh = con.Weigh;
cU = con.cU;
cV = con.cV;
cW = con.cW;
cWeigh = con.cWeigh;
fN = con.N;
fgradNx = con.gradNx;
fgradNy = con.gradNy;
fgradNz = con.gradNz;
EdNo_inEl = con.EdNo_inEl;
NoFa_ofEd = con.NoFa_ofEd;
FaNo_inEl = con.FaNo_inEl;
NoFa_ofFa = con.NoFa_ofFa;
nbFa_inEl = con.nbFa_inEl;
nbEd_inEl = con.nbEd_inEl;


%---------------- Area of faces -------------------------------------------
mesh.a_face = f_measure(mesh.node,mesh.face,'face');
mesh.n_face = f_chavec(mesh.node,mesh.face,'face');



%---------------- Jacobien ------------------------------------------------
nbElem = size(elem,2);
%--------------------------------------------------------------------------
xnode = zeros(nbNo_inEl,nbElem);
ynode = zeros(nbNo_inEl,nbElem);
znode = zeros(nbNo_inEl,nbElem);
for j = 1:nbNo_inEl
    xnode(j,:) = node(1,elem(j,:));
    ynode(j,:) = node(2,elem(j,:));
    znode(j,:) = node(3,elem(j,:));
end
%--------------------------------------------------------------------------
for i = 1:nbG

u = U(i).*ones(1,nbElem);
v = V(i).*ones(1,nbElem);
w = W(i).*ones(1,nbElem);

%--------------------------------------------------------------------------
gradNx = fgradNx(u,v,w);
gradNy = fgradNy(u,v,w);
gradNz = fgradNz(u,v,w);

J(1,1,:) = sum(gradNx.*xnode);
J(1,2,:) = sum(gradNx.*ynode);
J(1,3,:) = sum(gradNx.*znode);

J(2,1,:) = sum(gradNy.*xnode);
J(2,2,:) = sum(gradNy.*ynode);
J(2,3,:) = sum(gradNy.*znode);

J(3,1,:) = sum(gradNz.*xnode);
J(3,2,:) = sum(gradNz.*ynode);
J(3,3,:) = sum(gradNz.*znode);

a11(1,:) = J(1,1,:);
a12(1,:) = J(1,2,:);
a13(1,:) = J(1,3,:);

a21(1,:) = J(2,1,:);
a22(1,:) = J(2,2,:);
a23(1,:) = J(2,3,:);

a31(1,:) = J(3,1,:);
a32(1,:) = J(3,2,:);
a33(1,:) = J(3,3,:);

A11 = a22.*a33 - a23.*a32;
A12 = a32.*a13 - a12.*a33;
A13 = a12.*a23 - a13.*a22;
A21 = a23.*a31 - a21.*a33;
A22 = a33.*a11 - a31.*a13;
A23 = a13.*a21 - a23.*a11;
A31 = a21.*a32 - a31.*a22;
A32 = a31.*a12 - a32.*a11;
A33 = a11.*a22 - a12.*a21;

detJ = a11.*a22.*a33 + a21.*a32.*a13 + a31.*a12.*a23 - ...
       a11.*a32.*a23 - a31.*a22.*a13 - a21.*a12.*a33;

Jinv(1,1,:) = 1./detJ.*A11;
Jinv(1,2,:) = 1./detJ.*A12;
Jinv(1,3,:) = 1./detJ.*A13;
Jinv(2,1,:) = 1./detJ.*A21;
Jinv(2,2,:) = 1./detJ.*A22;
Jinv(2,3,:) = 1./detJ.*A23;
Jinv(3,1,:) = 1./detJ.*A31;
Jinv(3,2,:) = 1./detJ.*A32;
Jinv(3,3,:) = 1./detJ.*A33;

%--------------------------------------------------------------------------

N = zeros(nbNo_inEl,nbElem);
for j = 1:length(con.N)
    N(j,:) = fN{j}(u,v,w);
end

%--------------------------------------------------------------------------
Wn = N;
% Wn = zeros(3,nbNo_inEl,nbElem);
% for j = 1:nbNo_inEl
%     Wn(1,j,:) = f_torowv(Jinv(1,1,:)).*gradNx(j,:) + f_torowv(Jinv(1,2,:)).*gradNy(j,:) + f_torowv(Jinv(1,3,:)).*gradNz(j,:);
% end
%--------------------------------------------------------------------------
gradWn = zeros(3,nbNo_inEl,nbElem);
for j = 1:nbNo_inEl
    gradWn(1,j,:) = f_torowv(Jinv(1,1,:)).*gradNx(j,:) + f_torowv(Jinv(1,2,:)).*gradNy(j,:) + f_torowv(Jinv(1,3,:)).*gradNz(j,:);
    gradWn(2,j,:) = f_torowv(Jinv(2,1,:)).*gradNx(j,:) + f_torowv(Jinv(2,2,:)).*gradNy(j,:) + f_torowv(Jinv(2,3,:)).*gradNz(j,:);
    gradWn(3,j,:) = f_torowv(Jinv(3,1,:)).*gradNx(j,:) + f_torowv(Jinv(3,2,:)).*gradNy(j,:) + f_torowv(Jinv(3,3,:)).*gradNz(j,:);
end

gradF = zeros(3,nbFa_inEl,nbElem); % 3 for x,y,z
for j = 1:nbFa_inEl
    nbN = length(find(FaNo_inEl(j,:)));
    for k = 1:nbN
        gradF(1,j,:) = gradF(1,j,:) + gradWn(1,FaNo_inEl(j,k),:);
        gradF(2,j,:) = gradF(2,j,:) + gradWn(2,FaNo_inEl(j,k),:);
        gradF(3,j,:) = gradF(3,j,:) + gradWn(3,FaNo_inEl(j,k),:);
    end
end

We = zeros(3,nbEd_inEl,nbElem);
for j = 1:nbEd_inEl
    We(1,j,:) = - (N(EdNo_inEl(j,1),:).*f_torowv(gradF(1,NoFa_ofEd(j,1),:)) - ...
                   N(EdNo_inEl(j,2),:).*f_torowv(gradF(1,NoFa_ofEd(j,2),:)))...
                   .*si_ori_edge_in_elem(j,:);
              
    We(2,j,:) = - (N(EdNo_inEl(j,1),:).*f_torowv(gradF(2,NoFa_ofEd(j,1),:)) - ...
                   N(EdNo_inEl(j,2),:).*f_torowv(gradF(2,NoFa_ofEd(j,2),:)))...
                   .*si_ori_edge_in_elem(j,:);

    We(3,j,:) = - (N(EdNo_inEl(j,1),:).*f_torowv(gradF(3,NoFa_ofEd(j,1),:)) - ...
                   N(EdNo_inEl(j,2),:).*f_torowv(gradF(3,NoFa_ofEd(j,2),:)))...
                   .*si_ori_edge_in_elem(j,:);
end


%--------------------------------------------------------------------------

nbNodemax = max(con.nbNo_inFa);

for j = 1:nbNodemax
    gradFxgradF{j} = zeros(3,nbFa_inEl,nbElem);
end

for j = 1:con.nbFa_inEl
    for k = 1:con.nbNo_inFa(j)
        knext = mod(k + 1,con.nbNo_inFa(j));
        if knext == 0
            knext = con.nbNo_inFa(j);
        end
        %-----
        gradFxgradF{k}(1,j,:) = gradF(2,NoFa_ofFa(j,k),:).*gradF(3,NoFa_ofFa(j,knext),:) - ...
                                gradF(3,NoFa_ofFa(j,k),:).*gradF(2,NoFa_ofFa(j,knext),:);
        gradFxgradF{k}(2,j,:) = gradF(3,NoFa_ofFa(j,k),:).*gradF(1,NoFa_ofFa(j,knext),:) - ...
                                gradF(1,NoFa_ofFa(j,k),:).*gradF(3,NoFa_ofFa(j,knext),:);
        gradFxgradF{k}(3,j,:) = gradF(1,NoFa_ofFa(j,k),:).*gradF(2,NoFa_ofFa(j,knext),:) - ...
                                gradF(2,NoFa_ofFa(j,k),:).*gradF(1,NoFa_ofFa(j,knext),:);
    end
end

Wf = zeros(3,nbFa_inEl,nbElem);

for j = 1:con.nbFa_inEl
    Wfx = zeros(1,nbElem);
    Wfy = zeros(1,nbElem);
    Wfz = zeros(1,nbElem);
    for k = 1:con.nbNo_inFa(j)
        Wfx = Wfx + ...
              N(FaNo_inEl(j,k),:).*f_torowv(gradFxgradF{k}(1,j,:));
        Wfy = Wfy + ...
              N(FaNo_inEl(j,k),:).*f_torowv(gradFxgradF{k}(2,j,:));
        Wfz = Wfz + ...
              N(FaNo_inEl(j,k),:).*f_torowv(gradFxgradF{k}(3,j,:));
    end
    Wf(1,j,:) = (5 - con.nbNo_inFa(j)) * Wfx .* si_ori_face_in_elem(j,:);
    Wf(2,j,:) = (5 - con.nbNo_inFa(j)) * Wfy .* si_ori_face_in_elem(j,:);
    Wf(3,j,:) = (5 - con.nbNo_inFa(j)) * Wfz .* si_ori_face_in_elem(j,:);
end

%--------------------------------------------------------------------------
    mesh.Wn{i}  = Wn;
    mesh.We{i}  = We;
    mesh.Wf{i}  = Wf;
    mesh.detJ{i} = detJ;
    mesh.Jinv{i} = Jinv;

end

%--------------------------------------------------------------------------


%                        Center


%--------------------------------------------------------------------------
u = cU.*ones(1,nbElem);
v = cV.*ones(1,nbElem);
w = cW.*ones(1,nbElem);

%--------------------------------------------------------------------------
gradNx = fgradNx(u,v,w);
gradNy = fgradNy(u,v,w);
gradNz = fgradNz(u,v,w);

J(1,1,:) = sum(gradNx.*xnode);
J(1,2,:) = sum(gradNx.*ynode);
J(1,3,:) = sum(gradNx.*znode);

J(2,1,:) = sum(gradNy.*xnode);
J(2,2,:) = sum(gradNy.*ynode);
J(2,3,:) = sum(gradNy.*znode);

J(3,1,:) = sum(gradNz.*xnode);
J(3,2,:) = sum(gradNz.*ynode);
J(3,3,:) = sum(gradNz.*znode);

a11(1,:) = J(1,1,:);
a12(1,:) = J(1,2,:);
a13(1,:) = J(1,3,:);

a21(1,:) = J(2,1,:);
a22(1,:) = J(2,2,:);
a23(1,:) = J(2,3,:);

a31(1,:) = J(3,1,:);
a32(1,:) = J(3,2,:);
a33(1,:) = J(3,3,:);

A11 = a22.*a33 - a23.*a32;
A12 = a32.*a13 - a12.*a33;
A13 = a12.*a23 - a13.*a22;
A21 = a23.*a31 - a21.*a33;
A22 = a33.*a11 - a31.*a13;
A23 = a13.*a21 - a23.*a11;
A31 = a21.*a32 - a31.*a22;
A32 = a31.*a12 - a32.*a11;
A33 = a11.*a22 - a12.*a21;

detJ = a11.*a22.*a33 + a21.*a32.*a13 + a31.*a12.*a23 - ...
       a11.*a32.*a23 - a31.*a22.*a13 - a21.*a12.*a33;

Jinv(1,1,:) = 1./detJ.*A11;
Jinv(1,2,:) = 1./detJ.*A12;
Jinv(1,3,:) = 1./detJ.*A13;
Jinv(2,1,:) = 1./detJ.*A21;
Jinv(2,2,:) = 1./detJ.*A22;
Jinv(2,3,:) = 1./detJ.*A23;
Jinv(3,1,:) = 1./detJ.*A31;
Jinv(3,2,:) = 1./detJ.*A32;
Jinv(3,3,:) = 1./detJ.*A33;

%--------------------------------------------------------------------------

N = zeros(nbNo_inEl,nbElem);
for j = 1:length(con.N)
    N(j,:) = fN{j}(u,v,w);
end

%--------------------------------------------------------------------------
Wn = N;
% Wn = zeros(3,nbNo_inEl,nbElem);
% for j = 1:nbNo_inEl
%     Wn(1,j,:) = f_torowv(Jinv(1,1,:)).*gradNx(j,:) + f_torowv(Jinv(1,2,:)).*gradNy(j,:) + f_torowv(Jinv(1,3,:)).*gradNz(j,:);
% end
%--------------------------------------------------------------------------
volume = 0;
for i = 1:nbNo_inEl
    volume = volume + cWeigh .* detJ .* Wn(i,:);
end
%--------------------------------------------------------------------------
gradWn = zeros(3,nbNo_inEl,nbElem);
for j = 1:nbNo_inEl
    gradWn(1,j,:) = f_torowv(Jinv(1,1,:)).*gradNx(j,:) + f_torowv(Jinv(1,2,:)).*gradNy(j,:) + f_torowv(Jinv(1,3,:)).*gradNz(j,:);
    gradWn(2,j,:) = f_torowv(Jinv(2,1,:)).*gradNx(j,:) + f_torowv(Jinv(2,2,:)).*gradNy(j,:) + f_torowv(Jinv(2,3,:)).*gradNz(j,:);
    gradWn(3,j,:) = f_torowv(Jinv(3,1,:)).*gradNx(j,:) + f_torowv(Jinv(3,2,:)).*gradNy(j,:) + f_torowv(Jinv(3,3,:)).*gradNz(j,:);
end

gradF = zeros(3,nbFa_inEl,nbElem); % 3 for x,y,z
for j = 1:nbFa_inEl
    nbN = length(find(FaNo_inEl(j,:)));
    for k = 1:nbN
        gradF(1,j,:) = gradF(1,j,:) + gradWn(1,FaNo_inEl(j,k),:);
        gradF(2,j,:) = gradF(2,j,:) + gradWn(2,FaNo_inEl(j,k),:);
        gradF(3,j,:) = gradF(3,j,:) + gradWn(3,FaNo_inEl(j,k),:);
    end
end

We = zeros(3,nbEd_inEl,nbElem);
for j = 1:nbEd_inEl
    We(1,j,:) = - (N(EdNo_inEl(j,1),:).*f_torowv(gradF(1,NoFa_ofEd(j,1),:)) - ...
                   N(EdNo_inEl(j,2),:).*f_torowv(gradF(1,NoFa_ofEd(j,2),:)))...
                   .*si_ori_edge_in_elem(j,:);
              
    We(2,j,:) = - (N(EdNo_inEl(j,1),:).*f_torowv(gradF(2,NoFa_ofEd(j,1),:)) - ...
                   N(EdNo_inEl(j,2),:).*f_torowv(gradF(2,NoFa_ofEd(j,2),:)))...
                   .*si_ori_edge_in_elem(j,:);

    We(3,j,:) = - (N(EdNo_inEl(j,1),:).*f_torowv(gradF(3,NoFa_ofEd(j,1),:)) - ...
                   N(EdNo_inEl(j,2),:).*f_torowv(gradF(3,NoFa_ofEd(j,2),:)))...
                   .*si_ori_edge_in_elem(j,:);
end


%--------------------------------------------------------------------------

nbNodemax = max(con.nbNo_inFa);

for j = 1:nbNodemax
    gradFxgradF{j} = zeros(3,nbFa_inEl,nbElem);
end

for j = 1:con.nbFa_inEl
    for k = 1:con.nbNo_inFa(j)
        knext = mod(k + 1,con.nbNo_inFa(j));
        if knext == 0
            knext = con.nbNo_inFa(j);
        end
        %-----
        gradFxgradF{k}(1,j,:) = gradF(2,NoFa_ofFa(j,k),:).*gradF(3,NoFa_ofFa(j,knext),:) - ...
                                gradF(3,NoFa_ofFa(j,k),:).*gradF(2,NoFa_ofFa(j,knext),:);
        gradFxgradF{k}(2,j,:) = gradF(3,NoFa_ofFa(j,k),:).*gradF(1,NoFa_ofFa(j,knext),:) - ...
                                gradF(1,NoFa_ofFa(j,k),:).*gradF(3,NoFa_ofFa(j,knext),:);
        gradFxgradF{k}(3,j,:) = gradF(1,NoFa_ofFa(j,k),:).*gradF(2,NoFa_ofFa(j,knext),:) - ...
                                gradF(2,NoFa_ofFa(j,k),:).*gradF(1,NoFa_ofFa(j,knext),:);
    end
end

Wf = zeros(3,nbFa_inEl,nbElem);

for j = 1:con.nbFa_inEl
    Wfx = zeros(1,nbElem);
    Wfy = zeros(1,nbElem);
    Wfz = zeros(1,nbElem);
    for k = 1:con.nbNo_inFa(j)
        Wfx = Wfx + ...
              N(FaNo_inEl(j,k),:).*f_torowv(gradFxgradF{k}(1,j,:));
        Wfy = Wfy + ...
              N(FaNo_inEl(j,k),:).*f_torowv(gradFxgradF{k}(2,j,:));
        Wfz = Wfz + ...
              N(FaNo_inEl(j,k),:).*f_torowv(gradFxgradF{k}(3,j,:));
    end
    Wf(1,j,:) = (5 - con.nbNo_inFa(j)) * Wfx .* si_ori_face_in_elem(j,:);
    Wf(2,j,:) = (5 - con.nbNo_inFa(j)) * Wfy .* si_ori_face_in_elem(j,:);
    Wf(3,j,:) = (5 - con.nbNo_inFa(j)) * Wfz .* si_ori_face_in_elem(j,:);
end

%--------------------------------------------------------------------------
mesh.cWn  = Wn;
mesh.cWe  = We;
mesh.cWf  = Wf;
mesh.cdetJ = detJ;
mesh.cJinv = Jinv;
mesh.v_elem = volume;
end