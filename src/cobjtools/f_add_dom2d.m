function c3dobj = f_add_dom2d(c3dobj,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh2d','id_dom2d','id_x','id_y','elem_code'};

% --- default input value
id_mesh2d = [];
id_dom2d = [];
id_x = [];
id_y = [];
elem_code = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_mesh2d)
    id_mesh2d = fieldnames(c3dobj.mesh2d);
    id_mesh2d = id_mesh2d{1};
end

if isempty(id_dom2d)
    error([mfilename ' : #id_dom2d must be given !']);
end

%--------------------------------------------------------------------------
switch c3dobj.mesh2d.(id_mesh2d).mesher
    case 'mesh2dgeo1d'
        if isempty(elem_code)
            %--------------------------------------------------------------
            if isempty(id_x) || isempty(id_y)
                error([mfilename ' : #id_x and #id_y must be given !']);
            end
            %--------------------------------------------------------------
            id_x = f_to_dcellargin(id_x);
            id_y = f_to_dcellargin(id_y);
            [id_x, id_y] = f_pairing_dcellargin(id_x, id_y);
            %--------------------------------------------------------------
            id_all_elem = 1:c3dobj.mesh2d.(id_mesh2d).nb_elem;
            all_elem_code = c3dobj.mesh2d.(id_mesh2d).elem_code;
            all_id_x = fieldnames(c3dobj.mesh1d.(c3dobj.mesh2d.(id_mesh2d).id_mesh1d).x);
            all_id_y = fieldnames(c3dobj.mesh1d.(c3dobj.mesh2d.(id_mesh2d).id_mesh1d).y);
            id_elem = [];
            elem_code = [];
            for i = 1:length(id_x)
                for j = 1:length(id_x{i})
                    %------------------------------------------------------
                    id_xij = id_x{i}{j};
                    id_xij = replace(id_xij,'...','');
                    % checking validity
                    idxvalid = regexp(all_id_x,[id_xij '\w*']);
                    % ---
                    for m = 1:length(idxvalid)
                        if sum(idxvalid{m}) >= 1
                            codeidx = f_str2code(all_id_x{m});
                            for k = 1:length(id_y{i})
                                %------------------------------------------
                                id_yik = id_y{i}{k};
                                id_yik = replace(id_yik,'...','');
                                % checking validity
                                idyvalid = regexp(all_id_y,[id_yik '\w*']);
                                % ---
                                for l = 1:length(idyvalid)
                                    if sum(idyvalid{l}) >= 1
                                        codeidy = f_str2code(all_id_y{l});
                                        id_elem = [id_elem ...
                                                   id_all_elem(all_elem_code == codeidx * codeidy)];
                                        elem_code = [elem_code codeidx * codeidy];
                                    end
                                end
                            end
                        end
                    end
                end
            end
            id_elem = unique(id_elem);
            elem_code = unique(elem_code);
            %--------------------------------------------------------------
            c3dobj.mesh2d.(id_mesh2d).dom2d.(id_dom2d).id_elem = id_elem;
            c3dobj.mesh2d.(id_mesh2d).dom2d.(id_dom2d).elem_code = elem_code;
        else
            id_elem = [];
            for i = 1:length(elem_code)
                id_elem = [id_elem ...
                    find(c3dobj.mesh2d.(id_mesh2d).elem_code == elem_code(i))];
            end
            id_elem = unique(id_elem);
            %--------------------------------------------------------------
            c3dobj.mesh2d.(id_mesh2d).dom2d.(id_dom2d).id_elem = id_elem;
            c3dobj.mesh2d.(id_mesh2d).dom2d.(id_dom2d).elem_code = elem_code;
        end
    case 'quadmesh'
    case 'triangle_femm'
        id_elem = [];
        for i = 1:length(elem_code)
            id_elem = [id_elem ...
                find(c3dobj.mesh2d.(id_mesh2d).elem_code == elem_code(i))];
        end
        id_elem = unique(id_elem);
        %------------------------------------------------------------------
        c3dobj.mesh2d.(id_mesh2d).dom2d.(id_dom2d).id_elem = id_elem;
        c3dobj.mesh2d.(id_mesh2d).dom2d.(id_dom2d).elem_code = elem_code;
end
%------------------------------------------------------------------
f_fprintf(0,'Add #dom2d',...
          1, id_dom2d,...
          0,'-',...
          1,length(id_elem),...
          0,' elem \n');
%------------------------------------------------------------------


%--------------------------------------------------------------------------
%------------------------------------------------------------------
% id_x = f_to_dcellargin(id_x);
% id_y = f_to_dcellargin(id_y);
% [id_x, id_y] = f_pairing_dcellargin(id_x, id_y);
% %------------------------------------------------------------------
% id_elem_x = [];
% id_elem_y = [];
% for i = 1:length(id_x)
%     for j = 1:length(id_x{i})
%         id_elem_x = [id_elem_x ...
%                geo.geo2d.mesh2d.(id_mesh2d).(id_x{i}{j}).id_elem];
%     end
%     for j = 1:length(id_y{i})
%         id_elem_y = [id_elem_y ...
%                geo.geo2d.mesh2d.(id_mesh2d).(id_y{i}{j}).id_elem];
%     end
% end
% id_elem_x = unique(id_elem_x);
% id_elem_y = unique(id_elem_y);
% %------------------------------------------------------------------
% geo.geo2d.dom2d.(id_dom2d).id_elem = intersect(id_elem_x,id_elem_y);
% %------------------------------------------------------------------

