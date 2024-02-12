function mesh = f_intkit(mesh,varargin)
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
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'get','flat_node'};

% --- default input value
flat_node = [];
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
if ~isfield(mesh,'node') || ~isfield(mesh,'elem')
    error([mfilename ' : #mesh3d/2d struct must contain at least .node and .elem']);
end
%--------------------------------------------------------------------------
if isfield(mesh,'elem_type')
    elem_type = mesh.elem_type;
else
    error([mfilename ' : #mesh struct must contain .elem_type']);
end
%--------------------------------------------------------------------------
tic
f_fprintf(0,'Make #intkit');
%--------------------------------------------------------------------------
U   = [];
V   = [];
W   = [];
cU  = [];
cV  = [];
cW  = [];
%--------------------------------------------------------------------------
con  = f_connexion(elem_type);
coor = {'U','V','W','cU','cV','cW'};
for i = 1:length(coor)
    if isfield(con,coor{i})
        eval([coor{i} '= con.' coor{i} ';'])
        % U   = con.U;
        % V   = con.V;
        % W   = con.W;
        % cU  = con.cU;
        % cV  = con.cV;
        % cW  = con.cW;
    end
end
%--------------------------------------------------------------------------
% Center
[cdetJ, cJinv] = f_jacobien(mesh,'u',cU,'v',cV,'w',cW,'flat_node',flat_node);
cWn = f_wn(mesh,'u',cU,'v',cV,'w',cW);
[cgradWn, cgradF] = f_gradwn(mesh,'u',cU,'v',cV,'w',cW,'jinv',cJinv,'get','gradF','flat_node',flat_node);
cWe = f_we(mesh,'u',cU,'v',cV,'w',cW,'wn',cWn,'gradf',cgradF,'jinv',cJinv,'flat_node',flat_node);
cWf = f_wf(mesh,'u',cU,'v',cV,'w',cW,'wn',cWn,'gradf',cgradF,'jinv',cJinv,'flat_node',flat_node);
cWv = f_wv(mesh,'cdetJ',cdetJ);
%--------------------------------------------------------------------------
% Gauss points
[detJ, Jinv] = f_jacobien(mesh,'u',U,'v',V,'w',W,'flat_node',flat_node);
Wn = f_wn(mesh,'u',U,'v',V,'w',W,'flat_node',flat_node);
[gradWn, gradF] = f_gradwn(mesh,'u',U,'v',V,'w',W,'jinv',Jinv,'get','gradF','flat_node',flat_node);
We = f_we(mesh,'u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv,'flat_node',flat_node);
Wf = f_wf(mesh,'u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv,'flat_node',flat_node);
%--------------------------------------------------------------------------
% --- Outputs
mesh.intkit.cdetJ = cdetJ;
mesh.intkit.cJinv = cJinv;
mesh.intkit.cWn = cWn;
mesh.intkit.cgradWn = cgradWn;
mesh.intkit.cWe = cWe;
mesh.intkit.cWf = cWf;
mesh.intkit.cWv = cWv;
% ---
mesh.intkit.detJ = detJ;
mesh.intkit.Jinv = Jinv;
mesh.intkit.Wn = Wn;
mesh.intkit.gradWn = gradWn;
mesh.intkit.We = We;
mesh.intkit.Wf = Wf;
%--------------------------------------------------------------------------
%--- Log message
f_fprintf(0,'--- in',...
          1,toc, ...
          0,'s \n');
