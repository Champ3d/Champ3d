function c3dobj = f_build_bc(c3dobj,varargin)
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
arglist = {'id_emdesign3d','id_bc'};

% --- default input value
id_emdesign3d = [];
id_bc = '_all';

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_emdesign3d)
    error([mfilename ': #id_emdesign3d must be given']); 
end
%--------------------------------------------------------------------------
if iscell(id_emdesign3d)
    id_emdesign3d = id_emdesign3d{1};
end
%--------------------------------------------------------------------------
id_bc = f_to_scellargin(id_bc);
%--------------------------------------------------------------------------
if any(strcmpi(id_bc,{'_all'}))
    if isfield(c3dobj.emdesign3d.(id_emdesign3d),'bc')
        id_bc = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).bc);
    else
        return
    end
end
%--------------------------------------------------------------------------
for iec = 1:length(id_bc)
    id_phydom = id_bc{iec};
    to_be_rebuilt = c3dobj.emdesign3d.(id_emdesign3d).bc.(id_phydom).to_be_rebuilt;
    if to_be_rebuilt
        %------------------------------------------------------------------
        em_model = c3dobj.emdesign3d.(id_emdesign3d).em_model;
        %------------------------------------------------------------------
        f_fprintf(0,'Build #bc',1,id_phydom, ...
                  0,'in #emdesign3d',1,id_emdesign3d, ...
                  0,'for',1,em_model,0,'\n');
        %------------------------------------------------------------------
        tic;
        %------------------------------------------------------------------
        id_mesh3d = c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d;
        %------------------------------------------------------------------
        phydomobj = c3dobj.emdesign3d.(id_emdesign3d).bc.(id_phydom);
        %------------------------------------------------------------------
        bc_type = phydomobj.bc_type;
        %------------------------------------------------------------------
        id_dom3d = phydomobj.id_dom3d;
        id_dom3d = f_to_scellargin(id_dom3d);
        % ---
        id_elem = [];
        id_face = [];
        id_edge = [];
        for i = 1:length(id_dom3d)
            defined_on = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d{i}).defined_on;
            if f_strcmpi(defined_on,'elem')
                id_elem = [id_elem ...
                    c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d{i}).id_elem];
            elseif f_strcmpi(defined_on,'face')
                id_face = [id_face ...
                    c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d{i}).id_face];
            elseif f_strcmpi(defined_on,'edge')
                id_edge = [id_edge ...
                    c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d{i}).id_edge];
            end
        end
        %------------------------------------------------------------------
        % --- Output
        c3dobj.emdesign3d.(id_emdesign3d).bc.(id_phydom).id_elem = id_elem;
        c3dobj.emdesign3d.(id_emdesign3d).bc.(id_phydom).id_face = id_face;
        c3dobj.emdesign3d.(id_emdesign3d).bc.(id_phydom).id_edge = id_edge;
        %------------------------------------------------------------------
        switch em_model
            case {'fem_aphijw','fem_aphits'}
                %----------------------------------------------------------
                if f_strcmpi(bc_type,{'fixed'})

                end
                if f_strcmpi(bc_type,{'bsfield'})
                    %----------------------------------------------------------
                    coef_name  = 'bc_value';
                    coef_array = f_callcoefficient(c3dobj,'phydomobj',phydomobj,...
                                                          'coefficient',coef_name);
                    
                end
            case {'fem_tomejw','fem_tomets'}
                % TODO
        end
        % --- Log message
        f_fprintf(0,'--- in',...
                  1,toc, ...
                  0,'s \n');
    end
end