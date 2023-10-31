function c3dobj = f_build_mconductor(c3dobj,varargin)
% F_BUILD_MCONDUCTOR returns the em matrix system related to mconductor.
%--------------------------------------------------------------------------
% c3dobj = F_BUILD_MCONDUCTOR(c3dobj,option);
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
    if isfield(c3dobj.emdesign3d.(id_emdesign3d),'mconductor')
        id_mconductor = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).mconductor);
    else
        return
    end
end
%--------------------------------------------------------------------------
for iec = 1:length(id_mconductor)
    id_phydom = id_mconductor{iec};
    to_be_rebuilt = c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_phydom).to_be_rebuilt;
    if to_be_rebuilt
        %----------------------------------------------------------------------
        em_model = c3dobj.emdesign3d.(id_emdesign3d).em_model;
        %----------------------------------------------------------------------
        f_fprintf(0,'Build #mcon',1,id_phydom, ...
                  0,'in #emdesign3d',1,id_emdesign3d, ...
                  0,'for',1,em_model,0,'\n');
        switch em_model
            case {'fem_aphijw','fem_aphits'}
                tic;
                %--------------------------------------------------------------
                phydomobj = c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_phydom);
                %--------------------------------------------------------------
                coef_name  = 'mu_r';
                coef_array = f_callcoefficient(c3dobj,'phydomobj',phydomobj,...
                                                      'coefficient',coef_name);
                %--------------------------------------------------------------
                mu0 = 4 * pi * 1e-7;
                nu0nur = f_invtensor(mu0 .* coef_array);
                %--------------------------------------------------------------
                nu0nurwfwf = f_cwfwf(c3dobj,'phydomobj',phydomobj,...
                                        'coefficient',nu0nur);
                %--------------------------------------------------------------
                % --- Output
                c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_phydom).nu0nurwfwf = nu0nurwfwf;
                %----------------------------------------------------------
                coeftype = f_coeftype(phydomobj.(coef_name));
                switch coeftype
                    case {'function_ltensor_array','function_iso_array'}
                        c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_phydom).to_be_rebuilt = 1;
                    otherwise
                        c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_phydom).to_be_rebuilt = 0;
                end
                %----------------------------------------------------------
            case {'fem_tomejw','fem_tomets'}
                % TODO
        end
        % --- Log message
        f_fprintf(0,'--- in',...
                  1,toc, ...
                  0,'s \n');
    end
end

