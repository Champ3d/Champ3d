function mesh = f_intkit2d(mesh,varargin)
% F_INTKIT2D adds the interpolation and integral kit to mesh.
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh : mesh data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'flatnode' : flatten nodes 
%--------------------------------------------------------------------------
% OUTPUT
% mesh : mesh data structure with kit added
%--------------------------------------------------------------------------
% EXAMPLE
% mesh = F_INTKIT2D(mesh);
% mesh = F_INTKIT2D(mesh,'flatnode',flatnode);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
% See also F_FLATFACE

% --- valid argument list (to be updated each time modifying function)
arglist = {'mesh','flatnode'};

% --- default input value
flatnode = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

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
cU = con.cU;
cV = con.cV;
fN = con.N;
fgradNx = con.gradNx;
fgradNy = con.gradNy;
EdNo_inEl = con.EdNo_inEl;
NoFa_ofEd = con.NoFa_ofEd;
FaNo_inEl = con.FaNo_inEl;
% NoFa_ofFa = con.NoFa_ofFa;
nbFa_inEl = con.nbFa_inEl;
nbEd_inEl = con.nbEd_inEl;

%---------------- Jacobien ------------------------------------------------

nbElem = size(elem,2);
%--------------------------------------------------------------------------
xnode = zeros(nbNo_inEl,nbElem);
ynode = zeros(nbNo_inEl,nbElem);

if ~isempty(flatnode)
    for j = 1:nbNo_inEl
        xnode(j,:) = flatnode(1,j,:);
        ynode(j,:) = flatnode(2,j,:);
    end
else
    for j = 1:nbNo_inEl
        xnode(j,:) = node(1,elem(j,:));
        ynode(j,:) = node(2,elem(j,:));
    end
end
%--------------------------------------------------------------------------

for i = 1:nbG

u = U(i).*ones(1,nbElem);
v = V(i).*ones(1,nbElem);

%--------------------------------------------------------------------------
gradNx = fgradNx(u,v);
gradNy = fgradNy(u,v);

J(1,1,:) = sum(gradNx.*xnode);
J(1,2,:) = sum(gradNx.*ynode);

J(2,1,:) = sum(gradNy.*xnode);
J(2,2,:) = sum(gradNy.*ynode);

a11(1,:) = J(1,1,:);
a12(1,:) = J(1,2,:);

a21(1,:) = J(2,1,:);
a22(1,:) = J(2,2,:);

detJ = a11.*a22 - a21.*a12;

Jinv(1,1,:) = +1./detJ.*a22;
Jinv(1,2,:) = -1./detJ.*a12;
Jinv(2,1,:) = -1./detJ.*a21;
Jinv(2,2,:) = +1./detJ.*a11;

%--------------------------------------------------------------------------

N = zeros(nbNo_inEl,nbElem);
for j = 1:length(con.N)
    N(j,:) = fN{j}(u,v);
end

%--------------------------------------------------------------------------
Wn = N;
% Wn = zeros(1,nbNo_inEl,nbElem);
% for j = 1:nbNo_inEl
%     Wn(1,j,:) = f_torowv(Jinv(1,1,:)).*gradNx(j,:) + f_torowv(Jinv(1,2,:)).*gradNy(j,:);
% end
%--------------------------------------------------------------------------
gradWn = zeros(2,nbNo_inEl,nbElem);
for j = 1:nbNo_inEl
    gradWn(1,j,:) = f_torowv(Jinv(1,1,:)).*gradNx(j,:) + f_torowv(Jinv(1,2,:)).*gradNy(j,:);
    gradWn(2,j,:) = f_torowv(Jinv(2,1,:)).*gradNx(j,:) + f_torowv(Jinv(2,2,:)).*gradNy(j,:);
end


gradF = zeros(2,nbFa_inEl,nbElem); % 2 for x,y
for j = 1:nbFa_inEl
    nbN = length(find(FaNo_inEl(j,:)));
    for k = 1:nbN
        gradF(1,j,:) = gradF(1,j,:) + gradWn(1,FaNo_inEl(j,k),:);
        gradF(2,j,:) = gradF(2,j,:) + gradWn(2,FaNo_inEl(j,k),:);
    end
end

We = zeros(2,nbEd_inEl,nbElem);
for j = 1:nbEd_inEl
    We(1,j,:) = - (N(EdNo_inEl(j,1),:).*f_torowv(gradF(1,NoFa_ofEd(j,1),:)) - ...
                   N(EdNo_inEl(j,2),:).*f_torowv(gradF(1,NoFa_ofEd(j,2),:)))...
                   .*si_ori_edge_in_elem(j,:);
              
    We(2,j,:) = - (N(EdNo_inEl(j,1),:).*f_torowv(gradF(2,NoFa_ofEd(j,1),:)) - ...
                   N(EdNo_inEl(j,2),:).*f_torowv(gradF(2,NoFa_ofEd(j,2),:)))...
                   .*si_ori_edge_in_elem(j,:);
end


%--------------------------------------------------------------------------

% nbNodemax = max(con.nbNo_inFa);
% 
% for j = 1:nbNodemax
%     gradFxgradF{j} = zeros(2,nbFa_inEl,nbElem);
% end
% 
% for j = 1:con.nbFa_inEl
%     for k = 1:con.nbNo_inFa(j)
%         knext = mod(k + 1,con.nbNo_inFa(j));
%         if knext == 0
%             knext = con.nbNo_inFa(j);
%         end
%         %-----
%         gradFxgradF{k}(1,j,:) = gradF(2,NoFa_ofFa(j,k),:).*gradF(3,NoFa_ofFa(j,knext),:) - ...
%                                 gradF(3,NoFa_ofFa(j,k),:).*gradF(2,NoFa_ofFa(j,knext),:);
%         gradFxgradF{k}(2,j,:) = gradF(3,NoFa_ofFa(j,k),:).*gradF(1,NoFa_ofFa(j,knext),:) - ...
%                                 gradF(1,NoFa_ofFa(j,k),:).*gradF(3,NoFa_ofFa(j,knext),:);
%     end
% end

Wf = zeros(2,nbFa_inEl,nbElem);

% for j = 1:con.nbFa_inEl
%     Wfx = zeros(1,nbElem);
%     Wfy = zeros(1,nbElem);
%     for k = 1:con.nbNo_inFa(j)
%         Wfx = Wfx + ...
%               N(FaNo_inEl(j,k),:).*f_torowv(gradFxgradF{k}(1,j,:));
%         Wfy = Wfy + ...
%               N(FaNo_inEl(j,k),:).*f_torowv(gradFxgradF{k}(2,j,:));
%     end
%     Wf(1,j,:) = (5 - con.nbNo_inFa(j)) * Wfx .* si_ori_face_in_elem(j,:);
%     Wf(2,j,:) = (5 - con.nbNo_inFa(j)) * Wfy .* si_ori_face_in_elem(j,:);
% end

%--------------------------------------------------------------------------
mesh.Wn{i}  = Wn;
mesh.gradWn{i} = gradWn;
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

%--------------------------------------------------------------------------
gradNx = fgradNx(u,v);
gradNy = fgradNy(u,v);

J(1,1,:) = sum(gradNx.*xnode);
J(1,2,:) = sum(gradNx.*ynode);

J(2,1,:) = sum(gradNy.*xnode);
J(2,2,:) = sum(gradNy.*ynode);


a11(1,:) = J(1,1,:);
a12(1,:) = J(1,2,:);

a21(1,:) = J(2,1,:);
a22(1,:) = J(2,2,:);


detJ = a11.*a22 - a21.*a12;

Jinv(1,1,:) = +1./detJ.*a22;
Jinv(1,2,:) = -1./detJ.*a12;
Jinv(2,1,:) = -1./detJ.*a21;
Jinv(2,2,:) = +1./detJ.*a11;


%--------------------------------------------------------------------------

N = zeros(nbNo_inEl,nbElem);
for j = 1:length(con.N)
    N(j,:) = fN{j}(u,v);
end

%--------------------------------------------------------------------------
Wn = zeros(1,nbNo_inEl,nbElem);
for j = 1:nbNo_inEl
    Wn(1,j,:) = f_torowv(Jinv(1,1,:)).*gradNx(j,:) + f_torowv(Jinv(1,2,:)).*gradNy(j,:);
end
%--------------------------------------------------------------------------
gradWn = zeros(2,nbNo_inEl,nbElem);
for j = 1:nbNo_inEl
    gradWn(1,j,:) = f_torowv(Jinv(1,1,:)).*gradNx(j,:) + f_torowv(Jinv(1,2,:)).*gradNy(j,:);
    gradWn(2,j,:) = f_torowv(Jinv(2,1,:)).*gradNx(j,:) + f_torowv(Jinv(2,2,:)).*gradNy(j,:);
end

gradF = zeros(2,nbFa_inEl,nbElem);
for j = 1:nbFa_inEl
    nbN = length(find(FaNo_inEl(j,:)));
    for k = 1:nbN
        gradF(1,j,:) = gradF(1,j,:) + gradWn(1,FaNo_inEl(j,k),:);
        gradF(2,j,:) = gradF(2,j,:) + gradWn(2,FaNo_inEl(j,k),:);
    end
end

We = zeros(2,nbEd_inEl,nbElem);
for j = 1:nbEd_inEl
    We(1,j,:) = - (N(EdNo_inEl(j,1),:).*f_torowv(gradF(1,NoFa_ofEd(j,1),:)) - ...
                   N(EdNo_inEl(j,2),:).*f_torowv(gradF(1,NoFa_ofEd(j,2),:)))...
                   .*si_ori_edge_in_elem(j,:);
              
    We(2,j,:) = - (N(EdNo_inEl(j,1),:).*f_torowv(gradF(2,NoFa_ofEd(j,1),:)) - ...
                   N(EdNo_inEl(j,2),:).*f_torowv(gradF(2,NoFa_ofEd(j,2),:)))...
                   .*si_ori_edge_in_elem(j,:);
end


%--------------------------------------------------------------------------

% nbNodemax = max(con.nbNo_inFa);

% for j = 1:nbNodemax
%     gradFxgradF{j} = zeros(2,nbFa_inEl,nbElem);
% end
% 
% for j = 1:con.nbFa_inEl
%     for k = 1:con.nbNo_inFa(j)
%         knext = mod(k + 1,con.nbNo_inFa(j));
%         if knext == 0
%             knext = con.nbNo_inFa(j);
%         end
%         %-----
%         gradFxgradF{k}(1,j,:) = gradF(2,NoFa_ofFa(j,k),:).*gradF(3,NoFa_ofFa(j,knext),:) - ...
%                                 gradF(3,NoFa_ofFa(j,k),:).*gradF(2,NoFa_ofFa(j,knext),:);
%         gradFxgradF{k}(2,j,:) = gradF(3,NoFa_ofFa(j,k),:).*gradF(1,NoFa_ofFa(j,knext),:) - ...
%                                 gradF(1,NoFa_ofFa(j,k),:).*gradF(3,NoFa_ofFa(j,knext),:);
%     end
% end

Wf = zeros(2,nbFa_inEl,nbElem);

% for j = 1:con.nbFa_inEl
%     Wfx = zeros(1,nbElem);
%     Wfy = zeros(1,nbElem);
%     for k = 1:con.nbNo_inFa(j)
%         Wfx = Wfx + ...
%               N(FaNo_inEl(j,k),:).*f_torowv(gradFxgradF{k}(1,j,:));
%         Wfy = Wfy + ...
%               N(FaNo_inEl(j,k),:).*f_torowv(gradFxgradF{k}(2,j,:));
%     end
%     Wf(1,j,:) = (5 - con.nbNo_inFa(j)) * Wfx .* si_ori_face_in_elem(j,:);
%     Wf(2,j,:) = (5 - con.nbNo_inFa(j)) * Wfy .* si_ori_face_in_elem(j,:);
% end

%--------------------------------------------------------------------------
mesh.cWn  = Wn;
mesh.cWe  = We;
mesh.cWf  = Wf;
mesh.cdetJ = detJ;
mesh.cJinv = Jinv;

end