%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VectorElemField < Xhandle
    % --- Contructor
    methods
        function obj = VectorElemField()
            obj = obj@Xhandle;
        end
    end
    % --- get
    methods
        % -----------------------------------------------------------------
        function val = cnode(obj,id_elem)
            % ---
            if nargin <= 1
                id_elem = obj.parent_model.parent_mesh.nb_elem;
            end
            % ---
            val = obj.parent_model.parent_mesh.celem(:,id_elem);
        end
        % -----------------------------------------------------------------
        function val = inode(obj,id_elem)
            % ---
            if nargin <= 1
                id_elem = obj.parent_model.parent_mesh.nb_elem;
            end
            % ---
            if length(id_elem) == obj.parent_model.parent_mesh.nb_elem
                val = obj.parent_model.parent_mesh.prokit.node;
            else
                for i = 1:length(obj.parent_model.parent_mesh.prokit.node)
                    val{i} = obj.parent_model.parent_mesh.prokit.node{i}(id_elem,:);
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function val = gnode(obj,id_elem)
            % ---
            if nargin <= 1
                id_elem = obj.parent_model.parent_mesh.nb_elem;
            end
            % ---
            if length(id_elem) == obj.parent_model.parent_mesh.nb_elem
                val = obj.parent_model.parent_mesh.intkit.node;
            else
                for i = 1:length(obj.parent_model.parent_mesh.intkit.node)
                    val{i} = obj.parent_model.parent_mesh.intkit.node{i}(id_elem,:);
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
    end
    % --- plot
    methods
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.meshdom_obj = []
                args.id_meshdom = []
                args.id_elem = []
                args.show_dom = 1
            end
            % ---
            if isempty(args.id_meshdom)
                args.show_dom = 0;
                % ---
                if isempty(args.meshdom_obj)
                    if isempty(args.id_elem)
                        text(0,0,'Nothing to plot !');
                    else
                        gid_elem = args.id_elem;
                    end
                else
                    dom = args.meshdom_obj;
                    if isa(dom,'VolumeDom3d')
                        gid_elem = dom.gid_elem;
                    else
                        text(0,0,'Nothing to plot, dom must be a VolumeDom3d !');
                    end
                end
            else
                dom = obj.parent_model.parent_mesh.dom.(args.id_meshdom);
                if isa(dom,'VolumeDom3d')
                    gid_elem = dom.gid_elem;
                else
                    text(0,0,'Nothing to plot, dom must be a VolumeDom3d !');
                end
            end
            % ---
            if args.show_dom
                dom.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            end
            % ---
            celem = obj.parent_model.parent_mesh.celem;
            if isreal(obj.cvalue(gid_elem(1)))
                f_quiver(celem,obj.cvalue(gid_elem));
            else
                for i = 1:3
                    % ---
                    subplot(130 + i);
                    if i == 1
                        title('Real part');
                        f_quiver(celem,real(obj.cvalue(gid_elem)));
                    elseif i == 2
                        title('Imag part');
                        f_quiver(celem,imag(obj.cvalue(gid_elem)));
                    elseif i == 3
                        title('Magnitude');
                        % ---
                        node_ = obj.parent_model.parent_mesh.node;
                        elem = obj.parent_model.parent_mesh.elem(:,gid_elem);
                        f_patch('node',node_,'elem',elem,'elem_field',f_magnitude(obj.cvalue(gid_elem)));
                    end
                    % ---
                end
            end
            
        end
        % -----------------------------------------------------------------
    end
end