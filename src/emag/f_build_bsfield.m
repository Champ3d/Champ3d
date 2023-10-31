function c3dobj = f_build_bsfield(c3dobj,varargin)
% F_BUILD_bsfield returns the em matrix system related to bsfield.
%--------------------------------------------------------------------------
% c3dobj = F_BUILD_bsfield(c3dobj,option);
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
arglist = {'id_emdesign3d','id_bsfield'};

% --- default input value
id_emdesign3d = [];
id_bsfield = '_all';

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
id_bsfield = f_to_scellargin(id_bsfield);
%--------------------------------------------------------------------------
if any(strcmpi(id_bsfield,{'_all'}))
    if isfield(c3dobj.emdesign3d.(id_emdesign3d),'bsfield')
        id_bsfield = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).bsfield);
    else
        return
    end
end
%--------------------------------------------------------------------------
for iec = 1:length(id_bsfield)
    %----------------------------------------------------------------------
    id_phydom = id_bsfield{iec};
    to_be_rebuilt = c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_phydom).to_be_rebuilt;
    if to_be_rebuilt
        %------------------------------------------------------------------
        em_model = c3dobj.emdesign3d.(id_emdesign3d).em_model;
        %------------------------------------------------------------------
        f_fprintf(0,'Build #bsfield',1,id_phydom, ...
                  0,'in #emdesign3d',1,id_emdesign3d, ...
                  0,'for',1,em_model,0,'\n');
        switch em_model
            case {'fem_aphijw','fem_aphits'}
                tic;
                %----------------------------------------------------------
                phydomobj = c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_phydom);
                %----------------------------------------------------------
                coef_name  = 'bs';
                bs_array = f_callcoefficient(c3dobj,'phydomobj',phydomobj,...
                                                    'coefficient',coef_name);
                wfbs = f_cwfvf(c3dobj,'phydomobj',phydomobj,'vector_field',bs_array);
                %----------------------------------------------------------
                % --- Output
                c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_phydom).bs_array = bs_array;
                c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_phydom).wfbs     = wfbs;
                % ---
                c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_phydom).to_be_rebuilt = 0;
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
