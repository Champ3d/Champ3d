function c3dobj = f_build_coil(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_coil'};

% --- default input value
id_emdesign3d = [];
id_coil = '_all';

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
id_coil = f_to_scellargin(id_coil);
%--------------------------------------------------------------------------
if any(strcmpi(id_coil,{'_all'}))
    if isfield(c3dobj.emdesign3d.(id_emdesign3d),'coil')
        id_coil = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).coil);
    else
        return
    end
end
%--------------------------------------------------------------------------
for iec = 1:length(id_coil)
    %----------------------------------------------------------------------
    em_model = c3dobj.emdesign3d.(id_emdesign3d).em_model;
    %----------------------------------------------------------------------
    fprintf(['Build coil ' id_coil{iec} ...
             ' in emdesign3d #' id_emdesign3d ...
             ' for ' em_model]);
    switch em_model
        case {'aphijw','aphits'}
            tic;
            %--------------------------------------------------------------
            phydomobj = c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil{iec});
            %--------------------------------------------------------------
            coef_name  = 'sigma';
            coef_array = f_callcoefficient(c3dobj,'phydomobj',phydomobj,...
                                                  'coefficient',coef_name);
            %--------------------------------------------------------------
            sigwewe = f_cwewe(c3dobj,'phydomobj',phydomobj,...
                                     'coefficient',coef_array);
            %--------------------------------------------------------------
            % --- Output
            c3dobj.emdesign3d.(id_emdesign3d).coil.(id_coil{iec}).(em_model).sigwewe = sigwewe;
            % --- Log message
            fprintf(' --- in %.2f s \n',toc);
        case {'tomejw','tomets'}
            % TODO
    end
end