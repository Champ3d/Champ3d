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

%--------------------------------------------------------------
tic
f_fprintf(0,'Make #intkit \n');
fprintf('   ');
%--------------------------------------------------------------
elem_type_ = obj.elem_type;
%--------------------------------------------------------------
U   = [];
V   = [];
W   = [];
cU  = [];
cV  = [];
cW  = [];
%--------------------------------------------------------------
con  = f_connexion(elem_type_);
coor = {'U','V','W','cU','cV','cW'};
for i = 1:length(coor)
    if isfield(con,coor{i})
        eval([coor{i} '= con.' coor{i} ';'])
    end
end
%--------------------------------------------------------------
fnmeshds = fieldnames(obj.meshds);
for i = 1:length(fnmeshds)
    if isempty(obj.meshds.(fnmeshds{i}))
        obj.build_meshds;
        break
    end
end
%--------------------------------------------------------------
% Center
[cdetJ, cJinv] = obj.jacobien('u',cU,'v',cV,'w',cW);
cWn = obj.wn('u',cU,'v',cV,'w',cW);
[cgradWn, cgradF] = obj.gradwn('u',cU,'v',cV,'w',cW,'jinv',cJinv,'get','gradF');
cWe = obj.we('u',cU,'v',cV,'w',cW,'wn',cWn,'gradf',cgradF,'jinv',cJinv);
cWf = obj.wf('u',cU,'v',cV,'w',cW,'wn',cWn,'gradf',cgradF,'jinv',cJinv);
cWv = obj.wv('cdetJ',cdetJ);
%--------------------------------------------------------------
% Gauss points
[detJ, Jinv] = obj.jacobien('u',U,'v',V,'w',W);
Wn = obj.wn('u',U,'v',V,'w',W);
[gradWn, gradF] = obj.gradwn('u',U,'v',V,'w',W,'jinv',Jinv,'get','gradF');
We = obj.we('u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
Wf = obj.wf('u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
%--------------------------------------------------------------
% --- Outputs
obj.intkit.cdetJ = cdetJ;
obj.intkit.cJinv = cJinv;
obj.intkit.cWn = cWn;
obj.intkit.cgradWn = cgradWn;
obj.intkit.cWe = cWe;
obj.intkit.cWf = cWf;
obj.intkit.cWv = cWv;
% ---
obj.intkit.detJ = detJ;
obj.intkit.Jinv = Jinv;
obj.intkit.Wn = Wn;
obj.intkit.gradWn = gradWn;
obj.intkit.We = We;
obj.intkit.Wf = Wf;
%--------------------------------------------------------------
%--- Log message
f_fprintf(0,'--- in',...
          1,toc, ...
          0,'s \n');
end