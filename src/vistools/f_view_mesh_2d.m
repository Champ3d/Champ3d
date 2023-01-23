function f_view_mesh_2d(dom2d,varargin)
% F_VIEW_MESH2D plots the input 2D domaine.
%--------------------------------------------------------------------------
% f_view_mesh2D(dom2D);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

datin = [];

if nargin > 1
    datin.edgeLabels = 'on';
    datin.subdomainLabels  = 'on';
    datin.view_mesh  = 'off';
    datin.info = 'on';
    for i = 1:nargin/2
        eval(['datin.' varargin{2*i-1} '= varargin{2*i};']);
    end
    if ~isfield(datin,'plotter')
        datin.plotter = 'champ3d';
    end
    
    switch lower(datin.plotter)
        case 'champ3d'
            if ~isfield(dom2d.mesh,'bound')
                f_plotmesh2d('elem_type','tri','node',dom2d.mesh.node,...
                              'bound',[],'elem',dom2d.mesh.elem);
                info = [ inputname(1) ', ' ...
                        'nbNode=' num2str(size(dom2d.mesh.node,2)) ', ' ...
                        'nbElem=' num2str(size(dom2d.mesh.elem,2))];
                title(info);
            else
                f_plotmesh2d('elem_type','tri','node',dom2d.mesh.node,...
                          'bound',dom2d.mesh.bound,'elem',dom2d.mesh.elem);
                info = [ inputname(1) ', ' ...
                        'nbNode=' num2str(size(dom2d.mesh.node,2)) ', ' ...
                        'nbElem=' num2str(size(dom2d.mesh.elem,2))];
                title(info);
            end
        case 'pdetool'
            if isfield(dom2d.mesh,'dgeo')
                pdegplot(dom2d.mesh.dgeo,'EdgeLabels',datin.edgeLabels,'SubdomainLabels',datin.subdomainLabels);
                hold on;  axis equal;
            end
            if strcmpi(datin.view_mesh,'on')
                if isfield(dom2d.mesh,'bound')
                    pdemesh(dom2d.mesh.node,dom2d.mesh.bound,dom2d.mesh.elem); axis equal;
                else
                    pdemesh(dom2d.mesh.node,[],dom2d.mesh.elem); axis equal;
                end
            end
            if strcmpi(datin.info,'on')
                info = [ inputname(1) ', ' ...
                        'nbNode=' num2str(size(dom2d.mesh.node,2)) ', ' ...
                        'nbElem=' num2str(size(dom2d.mesh.elem,2))];
                title(info);
            end
            xlabel('x (m)'); ylabel('y (m)');
    end
else
    f_plotmesh2d('elem_type','tri','node',dom2d.mesh.node,...
                 'bound',dom2d.mesh.bound,'elem',dom2d.mesh.elem);
    info = [ inputname(1) ', ' ...
            'nbNode=' num2str(size(dom2d.mesh.node,2)) ', ' ...
            'nbElem=' num2str(size(dom2d.mesh.elem,2))];
    title(info);
end

end