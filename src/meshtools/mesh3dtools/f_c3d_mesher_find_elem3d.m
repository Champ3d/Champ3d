function [id_elem, elem_code] = f_c3d_mesher_find_elem3d(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','id_dom2d','id_layer','elem_code'};

% --- default input value
id_mesh3d = [];
id_dom2d = [];
id_layer = [];
elem_code = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(elem_code)
    tic;
    %--------------------------------------------------------------
    if isempty(id_dom2d) || isempty(id_layer)
        error([mfilename ' : #id_dom2d and #id_layer must be given !']);
    end
    %--------------------------------------------------------------
    id_dom2d = f_to_dcellargin(id_dom2d);
    id_layer = f_to_dcellargin(id_layer);
    [id_dom2d, id_layer] = f_pairing_cellargin(id_dom2d, id_layer);
    %--------------------------------------------------------------
    id_all_elem = 1:c3dobj.mesh3d.(id_mesh3d).nb_elem;
    all_id_lay  = fieldnames(c3dobj.mesh1d.(c3dobj.mesh3d.(id_mesh3d).id_mesh1d).layer);
    elem_code   = c3dobj.mesh3d.(id_mesh3d).elem_code;
    id_elem = [];
    for i = 1:length(id_dom2d)
        for j = 1:length(id_dom2d{i})
            codeidd2d = c3dobj.mesh2d.(c3dobj.mesh3d.(id_mesh3d).id_mesh2d).dom2d.(id_dom2d{i}{j}).elem_code;
            %codeidd2d = f_str2code(id_dom2d{i}{j});
            for m = 1:length(codeidd2d)
                for k = 1:length(id_layer{i})
                    id_lik = id_layer{i}{k};
                    id_lik = replace(id_lik,'...','');
                    % checking validity
                    idlvalid = regexp(all_id_lay,[id_lik '\w*']);
                    % ---
                    for l = 1:length(idlvalid)
                        if sum(idlvalid{l}) >= 1
                            codeidlay = f_str2code(all_id_lay{l});
                            id_elem = [id_elem ...
                                       id_all_elem(elem_code == codeidd2d(m) * codeidlay)];
                        end
                    end
                end
            end
        end
    end
    id_elem = unique(id_elem);
    %--------------------------------------------------------------
    elem_code = unique(c3dobj.mesh3d.(id_mesh3d).elem_code(id_elem));
    %--------------------------------------------------------------
    % --- Log message
    fprintf(' - %d elem --- in %.2f s \n',length(id_elem),toc);
    %--------------------------------------------------------------
else
    tic;
    %--------------------------------------------------------------
    id_elem = [];
    for i = 1:length(elem_code)
        id_elem = [id_elem ...
            find(c3dobj.mesh3d.(id_mesh3d).elem_code == elem_code(i))];
    end
    id_elem = unique(id_elem);
    %--------------------------------------------------------------
    % --- Log message
    fprintf(' - %d elem --- in %.2f s \n',length(id_elem),toc);
    %--------------------------------------------------------------
end