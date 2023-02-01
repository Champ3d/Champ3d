function f_viewthings(varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
type = [];
node = [];
edge = [];
face = [];
elem = [];

for i = 1:nargin/2
    eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
end


if ~exist('type','var')
    disp('#type must be defined : #type = node, edge, face, elem !')
    return
end

if ~exist('linewidth','var')
    linewidth = 2;
end

switch type
    case 'node'
        if ~exist('color','var')
            color = 'k';
        end
        if isempty(node)
            disp('#node must be given !')
            return
        end
        if size(node,1) == 2
            plot(node(1,:),node(2,:),['s' color],'MarkerFaceColor',color);
            axis tight; axis equal; box on;
            xlabel('x (m)'); ylabel('y (m)');
        elseif size(node,1) == 3
            plot3(node(1,:),node(2,:),node(3,:),['s' color],'MarkerFaceColor',color);
            axis tight; axis equal; box on; view(3);
            xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); 
        end
    case 'edge'
        if ~exist('color','var')
            color = 'k';
        end
        if isempty(node)
            disp('#node must be given !')
            return
        end
        if isempty(edge)
            disp('#edge must be given !')
            return
        end
        nbEdge = size(edge,2);
        dim = size(node,1);
        if dim == 2
            for i = 1:nbEdge
                plot([node(1,edge(1,i)) node(1,edge(2,i))],...
                     [node(2,edge(1,i)) node(2,edge(2,i))],...
                     ['-' color],'lineWidth',linewidth);
                hold on
            end
            alpha(0.5);
            axis tight; axis equal; box on;
            xlabel('x (m)'); ylabel('y (m)');
        elseif dim == 3
            for i = 1:nbEdge
                plot3([node(1,edge(1,i)) node(1,edge(2,i))],...
                      [node(2,edge(1,i)) node(2,edge(2,i))],...
                      [node(3,edge(1,i)) node(3,edge(2,i))],...
                      ['-' color],'lineWidth',linewidth);
                hold on
            end
            alpha(0.5);
            axis tight; axis equal; box on; view(3);
            xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); 
            hold off
        end
    case 'face'
        if ~exist('color','var')
            color = rand(1,3);
        end
        if isempty(node)
            disp('#node must be given !')
            return
        end
        if isempty(face)
            disp('#face must be given !')
            return
        end
        %------------------------------------------------------------------
        [filface,id_face] = f_filterface(face);
        for i = 1:length(filface)
            f = filface{i};
            patchinfo.Vertices = node.';
            patchinfo.Faces = f.';
            if ~exist('field','var') & ~exist('node_field','var')
                patchinfo.FaceColor = color;
                if strcmpi(color,'non')
                    patchinfo.EdgeColor = 'k';
                else
                    patchinfo.EdgeColor = [80 80 80]./255; %'non';
                end
                alpha(0.5);
            elseif ~exist('node_field','var')
                patchinfo.FaceColor = 'flat';
                patchinfo.FaceVertexCData = f_tocolv(field(id_face{i}));
                patchinfo.EdgeColor = [80 80 80]./255; %'non';
            else
                patchinfo.FaceColor = 'interp';
                patchinfo.FaceVertexCData = f_tocolv(node_field);
                patchinfo.EdgeColor = [80 80 80]./255; %'non';
            end
            patch(patchinfo); hold on;
            h = colorbar;
            h.Label.String = 'Enter Unit';
            f_colormap;
        end
        %-----
        axis tight; axis equal; box on; view(3);
        %-----
        dim = size(node,1);
        switch dim
            case 2
                xlabel('x (m)'); ylabel('y (m)');
            case 3
                xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); 
        end
        %------------------------------------------------------------------
    case 'elem'
        if ~exist('color','var')
            color = rand(1,3);
        end
        switch elem_type
            case 'prism'
                if ~isempty(elem) & ~isempty(node)
                    mesh = f_mdsprism(node,elem,'face');
                    con  = f_connexion(mesh.elem_type);
                end
            case 'tet'
            case 'hex'
                if ~isempty(elem) & ~isempty(node)
                    mesh = f_mdshexa(node,elem,'face');
                    con  = f_connexion(mesh.elem_type);
                end
        end
        
        IDFace = [];
        IDElem = [];
        for i = 1:con.nbFa_inEl
            IDFace = [IDFace mesh.face_in_elem(i,:)];
            IDElem = [IDElem 1:mesh.nbElem];
        end
        [IDFace,iIDElem] = unique(IDFace);
        IDElem = IDElem(iIDElem);
        if ~exist('field','var')
            f_viewthings('type','face','node',mesh.node,...
                         'face',mesh.face,'color',color);
        else
            f_viewthings('type','face','node',mesh.node,...
                         'face',mesh.face(:,IDFace),'field',f_tocolv(field(IDElem)));
        end
    otherwise
end

    
end