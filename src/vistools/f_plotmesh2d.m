function f_plotmesh2d(varargin)
% F_PLOTMESH2D plots the input 2D mesh.
%--------------------------------------------------------------------------
% F_PLOTMESH2D('elem_type','tri','node',dom2D.mesh.node,...
%               'bound',dom2D.mesh.bound,'elem',dom2D.mesh.elem);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
if mod(nargin,2) ~= 0 
    error([mfilename ': Check function arguments : #elem_type, #node, #bound, #elem !']);
end

for i = 1:nargin/2
    eval([(lower(varargin{2*i-1})) '= varargin{2*i} ;']);
end

patchinfo.Vertices = node(1:2,:).';
czElem = 1e-3; % make annotation higher

if (elem_type == 33 | strcmpi(elem_type, 'tri'))
    iDom = unique(elem(4,:));
    for i = 1:length(iDom)
        %---
        iElem = find(elem(4,:)==iDom(i));
        patchinfo.Faces = elem(1:3,iElem).';
        %---
        % r = rand(1,1); b = rand(1,1); g = rand(1,1);
        patchinfo.FaceColor = rand(1,3);
        %---
        alpha(0.5);
        %---
        patch(patchinfo); hold on;
        %---
        if iElem
            cxElem = 1/3 * (node(1,elem(1,iElem(1))) + node(1,elem(2,iElem(1))) + node(1,elem(3,iElem(1))));
            cyElem = 1/3 * (node(2,elem(1,iElem(1))) + node(2,elem(2,iElem(1))) + node(2,elem(3,iElem(1))));
            plot(cxElem,cyElem,'rs');
            text(cxElem,cyElem,czElem,['IDdom: ' num2str(iDom(i))],'FontSize',16,'FontWeight','Bold'); hold on;
        end
        axis equal; box on; grid off
        xlabel('x (m)'); ylabel('y (m)'); axis equal;
    end
    if ~isempty(bound)
        xB = node(1,bound(1,:)); yB = node(2,bound(1,:));
        xl = node(1,bound(2,:)) - node(1,bound(1,:));
        yl = node(2,bound(2,:)) - node(2,bound(1,:));
        hold on
        quiver(xB,yB,xl,yl,'Color','k','LineWidth',2,'ShowArrowHead','off','AutoScale','off');
        axis equal; box on; grid off
        xlabel('x (m)'); ylabel('y (m)'); axis equal;
    end
elseif (elem_type == 44 | strcmpi(elem_type, 'quad'))
    iDom = unique(elem(5,:));
    for i = 1:length(iDom)
        %---
        iElem = find(elem(5,:)==iDom(i));
        patchinfo.Faces = elem(1:4,iElem).';
        %---
        %r = rand(1,1); b = rand(1,1); g = rand(1,1);
        patchinfo.FaceColor = rand(1,3);
        %---
        alpha(0.5);
        %---
        patch(patchinfo); hold on;
        %---
        if iElem
            cxElem = 1/4 * (node(1,elem(1,iElem(1))) + node(1,elem(2,iElem(1))) + node(1,elem(3,iElem(1))) + node(1,elem(4,iElem(1))));
            cyElem = 1/4 * (node(2,elem(1,iElem(1))) + node(2,elem(2,iElem(1))) + node(2,elem(3,iElem(1))) + node(2,elem(4,iElem(1))));
            plot(cxElem,cyElem,'rs');
            text(cxElem,cyElem,czElem,['IDdom: ' num2str(iDom(i))],'FontSize',16,'FontWeight','Bold'); hold on;
        end
        axis equal; box on; grid off
        xlabel('x (m)'); ylabel('y (m)'); axis equal;
    end
    if ~isempty(bound)
        xB = node(1,bound(1,:)); yB = node(2,bound(1,:));
        xl = node(1,bound(2,:)) - node(1,bound(1,:));
        yl = node(2,bound(2,:)) - node(2,bound(1,:));
        hold on
        quiver(xB,yB,xl,yl,'Color','k','LineWidth',2,'ShowArrowHead','off','AutoScale','off');
        axis equal; box on; grid off
        xlabel('x (m)'); ylabel('y (m)'); axis equal;
    end
end

end