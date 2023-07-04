function f_quiver(node,vector,varargin)
% F_QUIVER plots arrows of vector field. 
%--------------------------------------------------------------------------
% F_QUIVER(node,vector);
%   ---> node = 2xN or 3xN matrix
%        vector = 2xN or 3xN matrix
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

%----- verifications

if size(node,2) ~= size(vector,2)
    disp([mfilename ' : check node and vector format and size !'])
    return
end

for i = 1:length(varargin)/2
    eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
end

%----- equally sized vector
if ~exist('vtype','var')
    vtype = 'proportional'; % equal
end
%----- aspect factor
if ~exist('afactor','var')
    afactor = 5;
end
%----- scale factor
if ~exist('sfactor','var')
    sfactor = 1;
end
%-----
[dim, nbNode] = size(node);
if dim < 3
    node(3,:) = 0;
    vector(3,:) = 0;
end
%----- component
if exist('component','var')
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

if strcmpi(vtype,'equal')
    %----- try to scale
    dmax = max(node(1,:)) - min(node(1,:));
    for i = 2:dim
        dmax = max(dmax, max(node(i,:)) - min(node(i,:)));
    end
    %----- size of arrows
    if ~exist('vsize','var')
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
    patchinfo.EdgeColor = 'non';
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
    patchinfo.EdgeColor = 'non';
    patchinfo.LineWidth = 0.1;
    patch(patchinfo); hold on; axis equal; alpha(1);
    h = colorbar;
    h.Label.String = 'Enter Unit';
    f_colormap; view(3); axis equal; axis tight;
    box on;
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
end











