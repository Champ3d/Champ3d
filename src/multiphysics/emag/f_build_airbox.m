function c3dobj = f_build_airbox(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_airbox'};

% --- default input value
id_emdesign3d = [];
id_airbox = '_all';

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
id_airbox = f_to_scellargin(id_airbox);
%--------------------------------------------------------------------------
if any(strcmpi(id_airbox,{'_all'}))
    id_airbox = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).airbox);
end
%--------------------------------------------------------------------------
for iec = 1:length(id_airbox)
    %----------------------------------------------------------------------
    em_model = c3dobj.emdesign3d.(id_emdesign3d).em_model;
    %----------------------------------------------------------------------
    fprintf(['Building airbox ' id_airbox{iec} ...
             ' in emdesign3d #' id_emdesign3d ...
             ' for ' em_model]);
    switch em_model
        case {'aphijw','aphits'}
            tic;
            %--------------------------------------------------------------
            phydomobj = c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox{iec});
            %--------------------------------------------------------------
            coef_name  = 'sigma';
            %--------------------------------------------------------------
            %sigwewe = f_cwewe(c3dobj,'phydomobj',phydomobj,...
            %                         'coefficient',coef_name);
            %--------------------------------------------------------------
            % --- Output
            %c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox{iec}).aphijw.sigwewe = sigwewe;
            % --- Log message
            fprintf(' --- in %.2f s \n',toc);
        case {'tomejw','tomets'}
            % TODO
    end
end