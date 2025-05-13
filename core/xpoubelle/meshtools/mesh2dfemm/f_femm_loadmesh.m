function dom2d = f_femm_loadmesh(dom2d,varargin)
% f_load_femm_mesh ...
%--------------------------------------------------------------------------
% dom2D = f_load_femm_mesh(dom2D,'mesh_type','simple')
% dom2D = f_load_femm_mesh(dom2D,'mesh_type','full')
%--------------------------------------------------------------------------
% FEMM
% Author : David Meeker
% Copyright (C) 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

dom2d.mesher = 'triangle-femm';
dom2d.mesh_type = 'full';

% --- valid argument list (to be updated each time modifying function)
arglist = {'meshfile'};

% --- default input value
meshfile = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
% ----- 1/ read all -----
fileID = fopen(meshfile);
fileDA = textscan(fileID,'%s %s %s %s %s %s %s %s %s');
fclose(fileID);

% ----- 2/ mesh et solution data -----
iData   = find(strcmp(fileDA{1,1}(:,1),'[Solution]'));
iNoeud  = iData+1;          nbNoeud = str2double(fileDA{1,1}(iNoeud,1));
iElem   = iNoeud+nbNoeud+1; nbElem  = str2double(fileDA{1,1}(iElem ,1));

% 2/a/ points
node(1,1:nbNoeud) = str2double(fileDA{1,1}(iNoeud+1 : iNoeud+nbNoeud,1));
node(2,1:nbNoeud) = str2double(fileDA{1,2}(iNoeud+1 : iNoeud+nbNoeud,1));
% 2/b/ potential A
data(1,1:nbNoeud) = str2double(fileDA{1,3}(iNoeud+1 : iNoeud+nbNoeud,1));
% 2/c/ element
elem(1,1:nbElem) = str2double(fileDA{1,1}(iElem +1 : iElem +nbElem ,1)) + 1 ;
elem(2,1:nbElem) = str2double(fileDA{1,2}(iElem +1 : iElem +nbElem ,1)) + 1 ;
elem(3,1:nbElem) = str2double(fileDA{1,3}(iElem +1 : iElem +nbElem ,1)) + 1 ;
elem(4,1:nbElem) = str2double(fileDA{1,4}(iElem +1 : iElem +nbElem ,1)) + 1 ;
% c(1:nbElem ,1) = (p(t(:,1),1) + p(t(:,2),1) + p(t(:,3),1))./3;
% c(1:nbElem ,2) = (p(t(:,1),2) + p(t(:,2),2) + p(t(:,3),2))./3;
%--------------------------------------------------------------------------

%----- check and correct mesh
[node,elem]=f_reorg2d(node,elem);
%--------------------------------------------------------------------------
dom2d.mesh.meshfile  = meshfile;
dom2d.mesh.data      = data;
dom2d.mesh.node      = node;
dom2d.mesh.nbNode    = size(dom2d.mesh.node,2);
dom2d.mesh.elem      = elem;
dom2d.mesh.id_dom    = elem(end,:);
dom2d.mesh.nbElem    = size(dom2d.mesh.elem,2);
dom2d.mesh.eb        = [];
dom2d.mesh.elem_type = 'tri';
dom2d.dName = unique(elem(4,:));
dom2d.nbDom = length(dom2d.dName);

if strcmpi(dom2d.mesh_type,'full')
    fmesh = f_mdstri(dom2d.mesh.node,dom2d.mesh.elem,'full');
    dom2d.mesh = f_addtostruct(fmesh,dom2d.mesh);
end

end