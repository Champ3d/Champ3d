function mesh3d = f_intkit3d(mesh3d,varargin)
% F_INTKIT3D gives the integral kit.
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh3d : mesh data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% mesh3d : mesh data structure with kit added
%--------------------------------------------------------------------------
% EXAMPLE
% mesh3d = F_INTKIT3D(mesh3d);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'get'};

% --- default input value
get = '_all';

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~isfield(mesh3d,'node') || ~isfield(mesh3d,'elem')
    error([mfilename ' : #mesh3d struct must contain at least .node and .elem']);
end
%--------------------------------------------------------------------------
if isfield(mesh3d,'elem_type')
    elem_type = mesh3d.elem_type;
else
    elem_type = f_elemtype(mesh3d.elem,'defined_on','elem');
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
U   = con.U;
V   = con.V;
W   = con.W;
cU  = con.cU;
cV  = con.cV;
cW  = con.cW;
%--------------------------------------------------------------------------
% Center
[cdetJ, cJinv] = f_jacobien(mesh3d,cU,cV,cW);
cWn = f_wn(mesh3d,cU,cV,cW);
[cgradWn, cgradF] = f_gradwn(mesh3d,cU,cV,cW,'jinv',cJinv,'get','gradF');
cWe = f_we(mesh3d,cU,cV,cW,'wn',cWn,'gradf',cgradF,'jinv',cJinv);
cWf = f_wf(mesh3d,cU,cV,cW,'wn',cWn,'gradf',cgradF,'jinv',cJinv);
%--------------------------------------------------------------------------
% Gauss points
[detJ, Jinv] = f_jacobien(mesh3d,U,V,W);
Wn = f_wn(mesh3d,U,V,W);
[gradWn, gradF] = f_gradwn(mesh3d,U,V,W,'jinv',Jinv,'get','gradF');
We = f_we(mesh3d,U,V,W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
Wf = f_wf(mesh3d,U,V,W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
%--------------------------------------------------------------------------
% --- Outputs
mesh3d.cdetJ = cdetJ;
mesh3d.cJinv = cJinv;
mesh3d.cWn = cWn;
mesh3d.cgradWn = cgradWn;
mesh3d.cWe = cWe;
mesh3d.cWf = cWf;
% ---
mesh3d.detJ = detJ;
mesh3d.Jinv = Jinv;
mesh3d.Wn = Wn;
mesh3d.gradWn = gradWn;
mesh3d.We = We;
mesh3d.Wf = Wf;

