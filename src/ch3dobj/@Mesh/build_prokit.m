%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function obj = build_prokit(obj)
%--------------------------------------------------------------------------
if obj.build_prokit_done
    return
end
%--------------------------------------------------------------------------
tic
f_fprintf(0,'Make #prokit \n');
fprintf('   ');
%--------------------------------------------------------------------------
U = obj.refelem.iU;
V = obj.refelem.iV;
W = obj.refelem.iW;
%--------------------------------------------------------------------------
fnmeshds = fieldnames(obj.meshds);
for i = 1:length(fnmeshds)
    if isempty(obj.meshds.(fnmeshds{i}))
        obj.build_meshds;
        break
    end
end
%--------------------------------------------------------------------------
[detJ, Jinv] = obj.jacobien('u',U,'v',V,'w',W);
Wn = obj.wn('u',U,'v',V,'w',W);
[gradWn, gradF] = obj.gradwn('u',U,'v',V,'w',W,'jinv',Jinv,'get','gradF');
We = obj.we('u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
Wf = obj.wf('u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
%--------------------------------------------------------------------------
for3d = 0;
dim   = 2;
if size(obj.node,1) == 3
    for3d = 1;
    dim   = 3;
end
%--------------------------------------------------------------------------
nbNo_inEl = obj.refelem.nbNo_inEl;
realx = (reshape(obj.node(1,obj.elem),nbNo_inEl,[])).';
realy = (reshape(obj.node(2,obj.elem),nbNo_inEl,[])).';
if for3d
    realz = (reshape(obj.node(3,obj.elem),nbNo_inEl,[])).';
end
nb_inode  = length(U);
node = cell(1,nb_inode);
for i = 1:nb_inode
    node{i} = zeros(obj.nb_elem,dim);
    node{i}(:,1) = sum(Wn{i} .* realx,2);
    node{i}(:,2) = sum(Wn{i} .* realy,2);
    if for3d
        node{i}(:,3) = sum(Wn{i} .* realz,2);
    end
end
%--------------------------------------------------------------------------
% --- Outputs
obj.prokit.detJ = detJ;
obj.prokit.Jinv = Jinv;
obj.prokit.Wn = Wn;
obj.prokit.gradWn = gradWn;
obj.prokit.We = We;
obj.prokit.Wf = Wf;
obj.prokit.node = node;
%--------------------------------------------------------------------------
obj.build_prokit_done = 1;
%--------------------------------------------------------------------------
%--- Log message
f_fprintf(0,'--- in',...
          1,toc, ...
          0,'s \n');
end