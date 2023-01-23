function dom2d = f_make_mesh_2d(dom2d,varargin)

% dom2d = f_make_mesh_2d(dom2d,'mesher','pdetool2DMatlab','mesh_type','simple','dom2refine',[2 5]);
% dom2d = f_make_mesh_2d(dom2d,'mesher','pdetool2DMatlab','mesh_type','full','dom2refine',[2 5]);

%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

tic
fprintf('Making 2D mesh ... ');

%-----
if mod(nargin,2) == 0 
    error([mfilename ': Check function arguments! Initialize #dom2d if needed!']);
end
%-----
datin.hgrad = 1.3;
datin.box  = 'off';
datin.init = 'off';
datin.jiggle = 'mean';
datin.jiggleiter = 10;
datin.mesherversion = 'R2013a'; % preR2013a or R2013a
for i = 1:(nargin-1)/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
end

%-----
if isfield(datin,'mesher')
    dom2d.mesher = datin.mesher;
else
    error([mfilename ': #mesher not defined!']);
end
%-----
if isfield(datin,'mesh_type')
    dom2d.mesh_type = datin.mesh_type;
else
    dom2d.mesh_type = 'full';
end

%--------------------------------------------------------------------------
dom2d.mesher_option = datin;
%--------------------------------------------------------------------------
switch lower(dom2d.mesher)
    case 'pdetool2d'
        switch dom2d.mesh_type
            case 'simple'
                if isfield(datin,'hmax')
                    dom2d = f_pdetool2d(dom2d,'mesh_type','simple','Hgrad',datin.hgrad,'Hmax',datin.hmax,'Box',datin.box,...
                               'Init',datin.init,'Jiggle',datin.jiggle,...
                               'JiggleIter',datin.jiggleiter,'MesherVersion',datin.mesherversion);
                else
                    dom2d = f_pdetool2d(dom2d,'mesh_type','simple','Hgrad',datin.hgrad,'Box',datin.box,...
                               'Init',datin.init,'Jiggle',datin.jiggle,...
                               'JiggleIter',datin.jiggleiter,'MesherVersion',datin.mesherversion);
                end
            case 'full'
                if isfield(datin,'hmax')
                    dom2d = f_pdetool2d(dom2d,'mesh_type','full','Hgrad',datin.hgrad,'Hmax',datin.hmax,'Box',datin.box,...
                               'Init',datin.init,'Jiggle',datin.jiggle,...
                               'JiggleIter',datin.jiggleiter,'MesherVersion',datin.mesherversion);
                else
                    dom2d = f_pdetool2d(dom2d,'mesh_type','full','Hgrad',datin.hgrad,'Box',datin.box,...
                               'Init',datin.init,'Jiggle',datin.jiggle,...
                               'JiggleIter',datin.jiggleiter,'MesherVersion',datin.mesherversion);
                end
            otherwise
                if isfield(datin,'hmax')
                    dom2d = f_pdetool2d(dom2d,'mesh_type','simple','Hgrad',datin.hgrad,'Hmax',datin.hmax,'Box',datin.box,...
                               'Init',datin.init,'Jiggle',datin.jiggle,...
                               'JiggleIter',datin.jiggleIter,'MesherVersion',datin.mesherversion);
                else
                    dom2d = f_pdetool2d(dom2d,'mesh_type','simple','Hgrad',datin.hgrad,'Box',datin.box,...
                               'Init',datin.init,'Jiggle',datin.jiggle,...
                               'JiggleIter',datin.jiggleiter,'MesherVersion',datin.mesherversion);
                end
        end
    case 'dom2dtrimatlab'
    case 'triangle-femm'
    otherwise
end


fprintf('%.4f s \n',toc);


end