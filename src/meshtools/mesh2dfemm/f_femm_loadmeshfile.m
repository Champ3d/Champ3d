function c3dobj = f_femm_loadmeshfile(c3dobj,varargin)
% f_femm_loadmeshfile ...
%--------------------------------------------------------------------------
% c3dobj = f_femm_loadmeshfile(c3dobj,'mesh_file','path')
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'build_from','id_mesh2d','mesh_file'};

% --- default input value
id_mesh2d = [];
mesh_file = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
tic;
fprintf(['Loading mesh2d #' id_mesh2d ' from ' mesh_file ]);

%--------------------------------------------------------------------------
% ----- 1/ read all -----
fileID = fopen(mesh_file);
fileDA = textscan(fileID,'%s %s %s %s %s %s %s %s %s');
fclose(fileID);

% ----- 2/ mesh et solution data -----
iData   = find(strcmp(fileDA{1,1}(:,1),'[Solution]'));
iNoeud  = iData+1;          nb_node = str2double(fileDA{1,1}(iNoeud,1));
iElem   = iNoeud+nb_node+1; nb_elem  = str2double(fileDA{1,1}(iElem ,1));

% 2/a/ points
node = zeros(2,nb_node);
node(1,:) = str2double(fileDA{1,1}(iNoeud+1 : iNoeud+nb_node,1));
node(2,:) = str2double(fileDA{1,2}(iNoeud+1 : iNoeud+nb_node,1));
% 2/b/ potential A
data = str2double(fileDA{1,3}(iNoeud+1 : iNoeud+nb_node,1));
% 2/c/ element
elem = zeros(3,nb_elem);
elem(1,:) = str2double(fileDA{1,1}(iElem +1 : iElem +nb_elem ,1)) + 1 ;
elem(2,:) = str2double(fileDA{1,2}(iElem +1 : iElem +nb_elem ,1)) + 1 ;
elem(3,:) = str2double(fileDA{1,3}(iElem +1 : iElem +nb_elem ,1)) + 1 ;
elem_code = str2double(fileDA{1,4}(iElem +1 : iElem +nb_elem ,1)) + 1 ;
%--------------------------------------------------------------------------
%----- check and correct mesh
[node,elem] = f_reorg2d(node,elem);

%--------------------------------------------------------------------------
% --- Output
c3dobj.mesh2d.(id_mesh2d).mesher = 'triangle_femm';
c3dobj.mesh2d.(id_mesh2d).node = node;
c3dobj.mesh2d.(id_mesh2d).nb_node = nb_node;
c3dobj.mesh2d.(id_mesh2d).elem = elem;
c3dobj.mesh2d.(id_mesh2d).nb_elem = nb_elem;
c3dobj.mesh2d.(id_mesh2d).elem_code = elem_code;
c3dobj.mesh2d.(id_mesh2d).elem_type = 'tri';
c3dobj.mesh2d.(id_mesh2d).data = data;
% --- Log message
fprintf(' --- in %.2f s \n',toc);

end