%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FreeScalarElemField < Xhandle
    properties
        reference_potential = 0
    end
    properties
        value
        node = []
        % ---
        dom = []
    end
    properties (Dependent)
        defined_on
    end
    % --- Contructor
    methods
        function obj = FreeScalarElemField(args)
            arguments
                args.value
                args.dom
                args.node
                args.reference_potential = 0
            end
            % ---
            obj = obj@Xhandle;
            % ---
            obj <= args;
            % ---
            FreeScalarElemField.setup(obj);
        end
    end
    % --- setup
    methods (Static)
        function setup(obj)
            if ~isempty(obj.dom)
                if f_strcmpi(obj.defined_on,'elem')
                    obj.node = obj.dom.parent_mesh.celem(:,obj.dom.gid_elem);
                elseif f_strcmpi(obj.defined_on,'face')
                    obj.node = obj.dom.parent_mesh.cface(:,obj.dom.gid_face);
                end
            end
        end
    end
    % --- get
    methods
        function val = get.defined_on(obj)
            if isempty(obj.dom)
                val = 'node';
            else
                if isa(obj.dom,'VolumeDom')
                    val = 'elem';
                elseif isa(obj.dom,'SurfaceDom')
                    val = 'face';
                end
            end
        end
    end
    % --- set/check
    methods
        
    end
    % --- plot
    methods
        function plot(obj)
            % ---
            FreeScalarElemField.setup(obj);
            % ---
            defon = obj.defined_on;
            switch defon
                case 'node'
                    scatter3(obj.node(1,:),obj.node(2,:),obj.node(3,:),[],obj.value);
                    f_colormap;
                case 'elem'
                    
                case 'face'
            end
            % ---
        end
    end
end