function [nOnBound,eOnBound] = f_bound_of(t2dAll,idElem)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------
idElem = unique(idElem);
%--------------------------------------------------------------------------
t2d = t2dAll(1:5,idElem);
t2d(5,:) = 1;
nb_t = length(idElem);
%--------------------------------------------------------------------------
e         = zeros(4,2,nb_t);
EdNo_inEl = [1 2; 1 4; 2 3; 3 4];
siEd_inEl = [1; -1; 1; 1];
si_ed     = zeros(4,nb_t);
for i = 1:4
    e(i,:,:) = [t2d(EdNo_inEl(i,1),:); t2d(EdNo_inEl(i,2),:)];
    [e(i,:,:), ie] = sort(squeeze(e(i,:,:)));
    si_ed(i,:) = siEd_inEl(i) .* diff(ie);
end
%--------------------------------------------------------------------------
e2d = [];
for i = 1:4
    e2d = [e2d squeeze(e(i,:,:))];
end
e2d     = f_unique(e2d,'urow');
nbEdge  = length(e2d(1,:));
%--------------------------------------------------------------------------
ed_in_el = zeros(4,nb_t);
for i = 1:4
    ed_in_el(i,:) = f_findvec(squeeze(e(i,:,:)),e2d);
end
%--------------------------------------------------------------------------
eL_of_ed = zeros(1,nbEdge);
for i = 1:4
    eL_of_ed(ed_in_el(i,si_ed(i,:) > 0)) = find(si_ed(i,:) > 0);
end
dL_of_ed = zeros(1,nbEdge);
dL_of_ed(eL_of_ed > 0) = t2d(5,eL_of_ed(eL_of_ed > 0));
%--------------------------------------------------------------------------
eR_of_ed = zeros(1,nbEdge);
for i = 1:4
    eR_of_ed(ed_in_el(i,si_ed(i,:) < 0)) = find(si_ed(i,:) < 0);
end
dR_of_ed = zeros(1,nbEdge);
dR_of_ed(eR_of_ed > 0) = t2d(5,eR_of_ed(eR_of_ed > 0));
%--------------------------------------------------------------------------
e2d(3,:) = dL_of_ed;
e2d(4,:) = dR_of_ed;
%--------------------------------------------------------------------------
ie = find(e2d(3,:) == 0 | e2d(4,:) == 0);
eOnBound = e2d(1:2,ie);
nOnBound = unique([e2d(1,ie) e2d(2,ie)]);
nOnBound = unique(nOnBound);
%--------------------------------------------------------------------------
%fprintf('done ----- in %.2f s \n',toc);





