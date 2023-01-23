function [notBo,onBo] = f_bound(p2d,t2d,e2d,idDom)
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
%tic;
%fprintf('Computing bound ...')
%--------------------------------------------------------------------------
nb_p = size(p2d,2);
nb_t = size(t2d,2);
%--------------------------------------------------------------------------
ie = find(e2d(3,:) == idDom | e2d(4,:) == idDom);
onBo = unique([e2d(1,ie) e2d(2,ie)]);
onBo = unique(onBo);
%--------------------------------------------------------------------------
notBo = setdiff(1:nb_p,onBo);
%--------------------------------------------------------------------------
%fprintf('done ----- in %.2f s \n',toc);
%--------------------------------------------------------------------------