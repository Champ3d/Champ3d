function c3dobj = f_build_mconductor(c3dobj,varargin)
% F_BUILD_MCONDUCTOR returns the em matrix system related to mconductor.
%--------------------------------------------------------------------------
% c3dobj = F_BUILD_mconductor(c3dobj,option);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_mconductor'};

% --- default input value
id_emdesign3d = [];
id_mconductor = '_all';

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
id_mconductor = f_to_scellargin(id_mconductor);
%--------------------------------------------------------------------------
if any(strcmpi(id_mconductor,{'_all'}))
    id_mconductor = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).mconductor);
end
%--------------------------------------------------------------------------
for iec = 1:length(id_mconductor)
    %----------------------------------------------------------------------
    em_model = c3dobj.emdesign3d.(id_emdesign3d).em_model;
    %----------------------------------------------------------------------
    fprintf(['Building mcon ' id_mconductor{iec} ...
             ' in emdesign3d #' id_emdesign3d ...
             ' for ' em_model]);
    switch em_model
        case {'aphijw'}
            tic;
            %--------------------------------------------------------------
            phydomobj = c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_mconductor{iec});
            %--------------------------------------------------------------
            coef_name  = 'mu_r';
            %--------------------------------------------------------------
            murwfwf = f_cwfwf(c3dobj,'phydomobj',phydomobj,...
                                     'coefficient',coef_name);
            %--------------------------------------------------------------
            % --- Output
            c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_mconductor{iec}).aphijw.murwfwf = murwfwf;
            % --- Log message
            fprintf(' --- in %.2f s \n',toc);
        case {'aphits'}
            tic;
            %--------------------------------------------------------------
            phydomobj = c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_mconductor{iec});
            %--------------------------------------------------------------
            coef_name  = 'mu_r';
            %--------------------------------------------------------------
            murwfwf = f_cwfwf(c3dobj,'phydomobj',phydomobj,...
                                     'coefficient',coef_name);
            %--------------------------------------------------------------
            % --- Output
            c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_mconductor{iec}).aphits.murwfwf = murwfwf;
            % --- Log message
            fprintf(' --- in %.2f s \n',toc);
        case {'tomejw'}
            % TODO
        case {'tomets'}
            % TODO
    end
end

