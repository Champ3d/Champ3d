function f_quiver(node,vector,args)
% F_QUIVER plots arrows of vector field. 
%--------------------------------------------------------------------------
% F_QUIVER(node,vector);
%   ---> node = 2xN or 3xN matrix
%        vector = 2xN or 3xN matrix
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

arguments
    node
    vector
    args.vtype {mustBeMember(args.vtype,{'proportional','equal'})} = 'proportional'
    args.afactor = 5
    args.sfactor = 1
    args.id_node = []
    args.component = []
    args.vsize = []
end
% --- 
vtype = args.vtype;
afactor = args.afactor;
sfactor = args.sfactor;
id_node = args.id_node;
component = args.component;
vsize = args.vsize;
%--------------------------------------------------------------------------
if ~isempty(id_node)
    node = node(:,id_node);
end
%--------------------------------------------------------------------------
if issparse(vector)
    vector = full(vector);
end
%--------------------------------------------------------------------------
[dim, nbNode] = size(node);
%--------------------------------------------------------------------------
if size(vector,1) ~= dim
    vector = vector.';
end
%---
if size(vector,2) == 1
    vector = repmat(vector,1,nbNode);
end
%---
if size(vector,2) ~= nbNode
    error([mfilename ' : check node and vector size !'])
end
%--------------------------------------------------------------------------
if dim < 3
    node(3,:) = 0;
    vector(3,:) = 0;
end
%----- component
if ~isempty(component)
    switch component
        case {1,'x'}
            vector(2,:) = 0;
            vector(3,:) = 0;
        case {2,'y'}
            vector(1,:) = 0;
            vector(3,:) = 0;
        case {3,'z'}
            vector(1,:) = 0;
            vector(2,:) = 0;
    end
end
%--------------------------------------------------------------------------
if strcmpi(vtype,'equal')
    %----- try to scale
    dmax = max(node(1,:)) - min(node(1,:));
    for i = 2:dim
        dmax = max(dmax, max(node(i,:)) - min(node(i,:)));
    end
    %----- size of arrows
    if isempty(vsize)
        vsize = sfactor * dmax / nbNode^(1/(dim));
    end
    %----- direction and lenght
    dvec = f_normalize(vector);
    lvec = f_norm(vector);
    %----- end node
    endnode = zeros(dim,nbNode);
    for i = 1:dim
        endnode(i,:) = node(i,:); % + vsize/2 .* dvec(i,:);
    end
    %----- the pyramid
    randomvec = rand(3,1);
    randomvec = randomvec./norm(randomvec);
    oz = repmat(randomvec,1,nbNode);
    dbase1 = f_normalize(cross(dvec,oz));
    dbase2 = f_normalize(cross(dvec,dbase1));
    p1 = zeros(dim,nbNode); p2 = zeros(dim,nbNode); p3 = zeros(dim,nbNode);
    p4 = zeros(dim,nbNode); p5 = zeros(dim,nbNode);

    for i = 1:dim
        p1(i,:) = endnode(i,:) + vsize/2 .* dvec(i,:);
        p2(i,:) = endnode(i,:) + vsize/2/afactor .* +dbase1(i,:);
        p3(i,:) = endnode(i,:) + vsize/2/afactor .* -dbase1(i,:);
        p4(i,:) = endnode(i,:) + vsize/2/afactor .* +dbase2(i,:);
        p5(i,:) = endnode(i,:) + vsize/2/afactor .* -dbase2(i,:);
    end

    pynode = [p1 p2 p3 p4 p5];
    pylvec = [lvec lvec lvec lvec];
    itri = [1 2 4; 1 2 5; 1 3 4; 1 3 5];

    pytri = zeros(3, 4*nbNode);
    for i = 1:4
        elem = [];
        for j = 1:3
            elem = [elem; ...
                    (itri(i,j)-1)*nbNode + 1 : itri(i,j)*nbNode];
        end
        pytri(:,(i-1)*nbNode + 1 : i*nbNode) = elem;
    end

    clear patchinfo
    patchinfo.Vertices = pynode.';
    patchinfo.Faces = pytri.';
    patchinfo.FaceColor = 'flat';
    patchinfo.FaceVertexCData = pylvec.';
    % patchinfo.FaceLighting = 'gouraud';
    patchinfo.EdgeColor = 'k';%[0.9 0.9 0.9];
    patchinfo.LineWidth = 0.1;
    patch(patchinfo); hold on; axis equal; alpha(1);
    h = colorbar;
    h.Label.String = 'Enter Unit';
    f_colormap; view(3); axis equal; axis tight;
    box on;
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
else

    %----- try to scale
    dmax = max(node(1,:)) - min(node(1,:));
    for i = 2:dim
        dmax = max(dmax, max(node(i,:)) - min(node(i,:)));
    end
    %----- direction and lenght
    dvec = f_normalize(vector);
    lvec = f_norm(vector);
    %----- size of arrows
    vsize = lvec ./ max(lvec) .* (sfactor * dmax / nbNode^(1/(dim)));
    %----- end node
    endnode = zeros(dim,nbNode);
    for i = 1:dim
        endnode(i,:) = node(i,:); % + vsize./2 .* dvec(i,:);
    end
    %----- the pyramid
    randomvec = rand(3,1);
    randomvec = randomvec./norm(randomvec);
    oz = repmat(randomvec,1,nbNode);
    dbase1 = f_normalize(cross(dvec,oz));
    dbase2 = f_normalize(cross(dvec,dbase1));
    p1 = zeros(dim,nbNode); p2 = zeros(dim,nbNode); p3 = zeros(dim,nbNode);
    p4 = zeros(dim,nbNode); p5 = zeros(dim,nbNode);

    for i = 1:dim
        p1(i,:) = endnode(i,:) + vsize./2 .* dvec(i,:);
        p2(i,:) = endnode(i,:) + vsize./2/afactor .* +dbase1(i,:);
        p3(i,:) = endnode(i,:) + vsize./2/afactor .* -dbase1(i,:);
        p4(i,:) = endnode(i,:) + vsize./2/afactor .* +dbase2(i,:);
        p5(i,:) = endnode(i,:) + vsize./2/afactor .* -dbase2(i,:);
    end

    pynode = [p1 p2 p3 p4 p5];
    pylvec = [lvec lvec lvec lvec];
    itri = [1 2 4; 1 2 5; 1 3 4; 1 3 5];

    pytri = zeros(3, 4*nbNode);
    for i = 1:4
        elem = [];
        for j = 1:3
            elem = [elem; ...
                    (itri(i,j)-1)*nbNode + 1 : itri(i,j)*nbNode];
        end
        pytri(:,(i-1)*nbNode + 1 : i*nbNode) = elem;
    end

    clear patchinfo
    patchinfo.Vertices = pynode.';
    patchinfo.Faces = pytri.';
    patchinfo.FaceColor = 'flat';
    patchinfo.FaceVertexCData = pylvec.';
    % patchinfo.FaceLighting = 'gouraud';
    patchinfo.EdgeColor = 'k'; %[0.9 0.9 0.9];
    patchinfo.LineWidth = 0.1;
    patch(patchinfo); hold on; axis equal;
    h = colorbar;
    h.Label.String = 'Enter Unit';
    f_colormap; view(3); axis equal; axis tight;
    box on;
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
end
%--------------------------------------------------------------------------
f_chlogo;
%--------------------------------------------------------------------------
% c3name = '$\overrightarrow{champ}{3d}$';
% c3_already = 0;
% %--------------------------------------------------------------------------
% % ztchamp3d = findobj(gcf, 'Type', 'Text');
% % ztchamp3d = ztchamp3d.String;
% % if iscell(ztchamp3d)
% %     for i = 1:length(ztchamp3d)
% %         if strcmpi(ztchamp3d{i},c3name)
% %             c3_already = 1;
% %         end
% %     end
% % elseif ischar(ztchamp3d)
% %     if strcmpi(ztchamp3d,c3name)
% %         c3_already = 1;
% %     end
% % end
% %--------------------------------------------------------------------------
% if ~c3_already
%     texpos = get(gca, 'OuterPosition');
%     hold on;
%     text(texpos(1),texpos(2)+1.05, ...
%          c3name, ...
%          'FontSize',10, ...
%          'FontWeight','bold',...
%          'Color','blue', ...
%          'Interpreter','latex',...
%          'Units','normalized', ...
%          'VerticalAlignment', 'baseline', ...
%          'HorizontalAlignment', 'right');
% end
% %--------------------------------------------------------------------------