function c3dobj = f_build_bsfield(c3dobj,varargin)
% F_BUILD_bsfield returns the em matrix system related to bsfield.
%--------------------------------------------------------------------------
% c3dobj = F_BUILD_bsfield(c3dobj,option);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
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
    em_model = c3dobj.emdesign3d.(id_emdesign3d).em_model;
    %----------------------------------------------------------------------
    fprintf(['Build bsfield ' id_bsfield{iec} ...
             ' in emdesign3d #' id_emdesign3d ...
             ' for ' em_model]);
    switch em_model
        case {'aphijw'}
            tic;
            %--------------------------------------------------------------
            phydomobj = c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_bsfield{iec});
            %--------------------------------------------------------------
            coef_name  = 'mu_r';
            %--------------------------------------------------------------
            murwfwf = f_cwfwf(c3dobj,'phydomobj',phydomobj,...
                                     'coefficient',coef_name);
            %--------------------------------------------------------------
            % --- Output
            c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_bsfield{iec}).aphijw.murwfwf = murwfwf;
            % --- Log message
            fprintf(' --- in %.2f s \n',toc);
        case {'aphits'}
            tic;
            %--------------------------------------------------------------
            phydomobj = c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_bsfield{iec});
            %--------------------------------------------------------------
            coef_name  = 'mu_r';
            %--------------------------------------------------------------
            murwfwf = f_cwfwf(c3dobj,'phydomobj',phydomobj,...
                                     'coefficient',coef_name);
            %--------------------------------------------------------------
            % --- Output
            c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_bsfield{iec}).aphits.murwfwf = murwfwf;
            % --- Log message
            fprintf(' --- in %.2f s \n',toc);
        case {'tomejw'}
            % TODO
        case {'tomets'}
            % TODO
    end
end

%----------------------------------------------------------------------
Bs = design3d.sfield.bs;
%----------------------------------------------------------------------
MfJ = f_wfvf(design3d.mesh,'vector_field',Bs);
F   = design3d.mesh.R.' * MfJ;
Mff = f_cwfwf(design3d.mesh);
S   = design3d.mesh.R.' * Mff * design3d.mesh.R;
%--------------------------------------------------------------------------
iEA = setdiff(1:design3d.mesh.nbEdge,design3d.bcon(design3d.sfield.id_bcon).id_edge);
F   = F(iEA,1);
S   = S(iEA,iEA);
% figure
% f_viewthings('type','edge','node',mesh.node,'edge',mesh.edge(:,bcon(ibcon).id_edge));
%--------------------------------------------------------------------------
ABr = zeros(design3d.mesh.nbEdge,1);
ABr(iEA) = f_qmr(S,F);
%--------------------------------------------------------------------------
%rotA = dom3d.mesh.R * mRHS;
%B = f_postpro3d(dom3d.mesh,rotA,'W2');
%figure
%f_viewthings('type','elem','node',dom3d.mesh.node,'elem',dom3d.mesh.elem(:,dom3d.sfield(1).id_elem),...
%         'elem_type','prism','color','r'); hold on
%f_quiver(dom3d.mesh.cnode,real(B),'sfactor',2);
%--------------------------------------------------------------------------
mu0 = 4*pi*1e-7;
Mff = f_cwfwf(design3d.mesh,'coef',1/(mu0));
mRHS = design3d.mesh.R.' * Mff * design3d.mesh.R * ABr;
%--------------------------------------------------------------------------
design3d.aphi.sfieldRHS = mRHS;
design3d.aphi.Bs = Bs;

