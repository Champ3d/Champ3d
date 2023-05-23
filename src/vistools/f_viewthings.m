function f_viewthings(varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'type','node','elem','edge','face','color','edge_color','linewidth', ...
           'field','node_field'};
       

% --- default input value
type = []; % 'node','elem','edge','face'
node = [];
edge = [];
face = [];
elem = [];
edge_color = 'none';
color = 'b';
linewidth = 2;
field = [];
node_field = [];
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:nargin/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if ~any(strcmpi(type,{'node','elem','edge','face'}))
    error([mfilename ' : #type must be defined : #type = node, edge, face, elem !']);
end

%--------------------------------------------------------------------------
switch type
    %----------------------------------------------------------------------
    case 'node'
        % ---
        if isempty(node)
            error([mfilename ' : #node must be given !']);
        end
        % ---
        if size(node,1) == 2
            plot(node(1,:),node(2,:),['o' color],'MarkerFaceColor',color);
            axis tight; axis equal; box on;
            xlabel('x (m)'); ylabel('y (m)');
        elseif size(node,1) == 3
            plot3(node(1,:),node(2,:),node(3,:),['o' color],'MarkerFaceColor',color);
            axis tight; axis equal; box on; view(3);
            xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); 
        end
    %----------------------------------------------------------------------
    case 'edge'
        % ---
        if isempty(node) || isempty(edge)
            error([mfilename ' : #node and #edge must be given !']);
        end
        % ---
        nbEdge = size(edge,2);
        dim = size(node,1);
        if dim == 2
            %xnode = zeros(2,nbEdge);
            %ynode = zeros(2,nbEdge);
            xnode = [node(1,edge(1,:)); node(1,edge(2,:))];
            ynode = [node(2,edge(1,:)); node(2,edge(2,:))];
            %for i = 1:nbEdge
            %    plot([node(1,edge(1,i)) node(1,edge(2,i))],...
            %         [node(2,edge(1,i)) node(2,edge(2,i))],...
            %         ['-' color],'lineWidth',linewidth);
            %    hold on
            %end
            plot(xnode,ynode,['-' color],'lineWidth',linewidth);
            alpha(0.5);
            axis tight; axis equal; box on;
            xlabel('x (m)'); ylabel('y (m)');
        elseif dim == 3
            %for i = 1:nbEdge
            %    plot3([node(1,edge(1,i)) node(1,edge(2,i))],...
            %          [node(2,edge(1,i)) node(2,edge(2,i))],...
            %          [node(3,edge(1,i)) node(3,edge(2,i))],...
            %          ['-' color],'lineWidth',linewidth);
            %    hold on
            %end
            xnode = [node(1,edge(1,:)); node(1,edge(2,:))];
            ynode = [node(2,edge(1,:)); node(2,edge(2,:))];
            znode = [node(3,edge(1,:)); node(3,edge(2,:))];
            plot3(xnode,ynode,znode,['-' color],'lineWidth',linewidth);
            alpha(0.5);
            axis tight; axis equal; box on; view(3);
            xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); 
            hold off
        end
    case 'face'
        % ---
        if isempty(node) || isempty(face)
            error([mfilename ' : #node and #face must be given !']);
        end
        %------------------------------------------------------------------
        allnode = [];
        [filface,id_face] = f_filterface(face);
        for i = 1:length(filface)
            f = filface{i};
            for ii = 1:size(f,1)
                allnode = [allnode f(ii,:)];
            end
            patchinfo.Vertices = node.';
            patchinfo.Faces = f.';
            cax = [];
            if ~exist('field','var') && ~exist('node_field','var')
                patchinfo.FaceColor = color;
                if strcmpi(color,'non')
                    patchinfo.EdgeColor = 'k';
                else
                    if isempty(edge_color)
                        patchinfo.EdgeColor = 'non';%[80 80 80]./255; %'non';
                    else
                        patchinfo.EdgeColor = edge_color;
                    end
                end
                alpha(0.5);
            elseif ~exist('node_field','var')
                patchinfo.FaceColor = 'flat';
                patchinfo.FaceVertexCData = f_tocolv(field(id_face{i}));
                if isempty(edge_color)
                    patchinfo.EdgeColor = 'non';%[80 80 80]./255; %'non';
                else
                    patchinfo.EdgeColor = edge_color;
                end
                cax = [min(patchinfo.FaceVertexCData) max(patchinfo.FaceVertexCData)];
            else
                patchinfo.FaceColor = 'interp';
                patchinfo.FaceVertexCData = f_tocolv(node_field);
                if isempty(edge_color)
                    patchinfo.EdgeColor = 'non';%[80 80 80]./255; %'non';
                else
                    patchinfo.EdgeColor = edge_color;
                end
                cax = [min(node_field(allnode)) max(node_field(allnode))];
            end
            patch(patchinfo); hold on;
            h = colorbar;
            allnode = unique(allnode);
            if ~isempty(cax); caxis(cax); end
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
                         'face',mesh.face,'color',color,'edge_color',edge_color);
        else
            f_viewthings('type','face','node',mesh.node,'edge_color',edge_color, ...
                         'face',mesh.face(:,IDFace),'field',f_tocolv(field(IDElem)));
        end
    otherwise
end

    
end