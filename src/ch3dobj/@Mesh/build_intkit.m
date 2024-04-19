%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function obj = build_intkit(obj)
%--------------------------------------------------------------------------
if obj.build_intkit_done
    return
end
%--------------------------------------------------------------------------
tic
f_fprintf(0,'Make #intkit \n');
fprintf('   ');
%--------------------------------------------------------------------------
U   = [];
V   = [];
W   = [];
cU  = [];
cV  = [];
cW  = [];
%--------------------------------------------------------------------------
refelem = obj.refelem;
coor = {'U','V','W','cU','cV','cW'};
for i = 1:length(coor)
    if isfield(refelem,coor{i})
        eval([coor{i} '= refelem.' coor{i} ';'])
    end
end
%--------------------------------------------------------------------------
fnmeshds = fieldnames(obj.meshds);
for i = 1:length(fnmeshds)
    if isempty(obj.meshds.(fnmeshds{i}))
        obj.build_meshds;
        break
    end
end
%--------------------------------------------------------------------------
for3d = 0;
dim   = 2;
if size(obj.node,1) == 3
    for3d = 1;
    dim   = 3;
end
%--------------------------------------------------------------------------
% Center
[cdetJ, cJinv] = obj.jacobien('u',cU,'v',cV,'w',cW);
cWn = obj.wn('u',cU,'v',cV,'w',cW);
[cgradWn, cgradF] = obj.gradwn('u',cU,'v',cV,'w',cW,'jinv',cJinv,'get','gradF');
cWe = obj.we('u',cU,'v',cV,'w',cW,'wn',cWn,'gradf',cgradF,'jinv',cJinv);
cWf = obj.wf('u',cU,'v',cV,'w',cW,'wn',cWn,'gradf',cgradF,'jinv',cJinv);
cWv = obj.wv('cdetJ',cdetJ);
%--------------------------------------------------------------------------
obj.build_meshds('get','celem');
%--------------------------------------------------------------------------
% Gauss points
[detJ, Jinv] = obj.jacobien('u',U,'v',V,'w',W);
Wn = obj.wn('u',U,'v',V,'w',W);
[gradWn, gradF] = obj.gradwn('u',U,'v',V,'w',W,'jinv',Jinv,'get','gradF');
We = obj.we('u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
Wf = obj.wf('u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
%--------------------------------------------------------------------------
nbNo_inEl = refelem.nbNo_inEl;
realx = (reshape(obj.node(1,obj.elem),nbNo_inEl,[])).';
realy = (reshape(obj.node(2,obj.elem),nbNo_inEl,[])).';
if for3d
    realz = (reshape(obj.node(3,obj.elem),nbNo_inEl,[])).';
end
nb_inode  = length(U);
node_g = cell(1,nb_inode);
for i = 1:nb_inode
    node_g{i} = zeros(obj.nb_elem,dim);
    node_g{i}(:,1) = sum(Wn{i} .* realx,2);
    node_g{i}(:,2) = sum(Wn{i} .* realy,2);
    if for3d
        node_g{i}(:,3) = sum(Wn{i} .* realz,2);
    end
end
%--------------------------------------------------------------------------
% --- Outputs
obj.intkit.cdetJ = cdetJ;
obj.intkit.cJinv = cJinv;
obj.intkit.cWn = cWn;
obj.intkit.cgradWn = cgradWn;
obj.intkit.cWe = cWe;
obj.intkit.cWf = cWf;
obj.intkit.cWv = cWv;
obj.intkit.cnode{1} = obj.celem.';
% ---
obj.intkit.detJ = detJ;
obj.intkit.Jinv = Jinv;
obj.intkit.Wn = Wn;
obj.intkit.gradWn = gradWn;
obj.intkit.We = We;
obj.intkit.Wf = Wf;
obj.intkit.node = node_g;
%--------------------------------------------------------------------------
obj.build_intkit_done = 1;
%--------------------------------------------------------------------------
%--- Log message
f_fprintf(0,'--- in',...
          1,toc, ...
          0,'s \n');
end