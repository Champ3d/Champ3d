%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VolumeDom3d < VolumeDom
    properties
        id_dom2d
        id_zline
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_mesh','id_dom2d','id_zline','elem_code', ...
                        'gindex','condition'};
        end
    end
    % --- Constructors
    methods
        function obj = VolumeDom3d(args)
            arguments
                % ---
                args.id
                args.parent_mesh
                args.id_dom2d
                args.id_zline
                args.elem_code
                args.gindex
                args.condition
            end
            % ---
            obj = obj@VolumeDom;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            VolumeDom3d.setup(obj);
            % ---
        end
    end
    % --- setup/reset
    methods (Static)
        function setup(obj)
            % must try id_zline first -> elem_code
            if ~isempty(obj.id_zline)
                obj.build_from_idmesh1d2d;
            elseif ~isempty(obj.elem_code)
                obj.build_from_elem_code;
            elseif ~isempty(obj.gindex)
                obj.build_from_gindex;
            end
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            VolumeDom3d.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods (Access = private)
        % -----------------------------------------------------------------
        function build_from_idmesh1d2d(obj)
            id_dom2d_ = f_to_dcellargin(obj.id_dom2d);
            id_zline_ = f_to_dcellargin(obj.id_zline);
            [id_dom2d_, id_zline_] = f_pairing_dcellargin(id_dom2d_, id_zline_);
            % ---
            all_id_dom2d  = fieldnames(obj.parent_mesh.parent_mesh2d.dom);
            all_id_mesh1d = fieldnames(obj.parent_mesh.parent_mesh1d.dom);
            all_elem_code = obj.parent_mesh.elem_code;
            id_all_elem   = 1:obj.parent_mesh.nb_elem;
            % ---
            gindex_ = [];
            elem_code_ = [];
            % ---
            for i = 1:length(id_dom2d_)
                for j = 1:length(id_dom2d_{i})
                    iddom2d = id_dom2d_{i}{j};
                    valid_iddom2d = f_validid(iddom2d,all_id_dom2d);
                    % ---
                    if isempty(valid_iddom2d)
                        error(['dom2d ' iddom2d ' not found !']);
                    end
                    % ---
                    for m = 1:length(valid_iddom2d)
                        % ---
                        dom2d = obj.parent_mesh.parent_mesh2d.dom.(valid_iddom2d{m});
                        dom2d.is_defining_obj_of(obj);
                        % ---
                        codedom2d = dom2d.elem_code;
                        % ---
                        for o = 1:length(codedom2d)
                            for k = 1:length(id_zline_{i})
                                idz = id_zline_{i}{k};
                                valid_idz = f_validid(idz,all_id_mesh1d);
                                % ---
                                if isempty(valid_idz)
                                    error(['zline ' idz ' not found !']);
                                end
                                % ---
                                for l = 1:length(valid_idz)
                                    % ---
                                    zline = obj.parent_mesh.parent_mesh1d.dom.(valid_idz{l});
                                    % zline.is_defining_obj_of(obj);
                                    % ---
                                    codeidz = zline.elem_code;
                                    % ---
                                    given_elem_code = codedom2d(o) .* codeidz;
                                    gindex_ = [gindex_ ...
                                                id_all_elem(all_elem_code == given_elem_code)];
                                    % ---
                                    elem_code_ = [elem_code_ given_elem_code];
                                end
                            end
                        end
                    end
                end
            end
            % ---
            gindex_ = unique(gindex_);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                % ---------------------------------------------------------
                node = obj.parent_mesh.node;
                elem = obj.parent_mesh.elem(:,gindex_);
                elem_type = obj.parent_mesh.elem_type;
                % ---
                idElem = ...
                    f_findelem(node,elem,'condition', obj.condition);
                gindex_ = gindex_(idElem);
            end
            % -------------------------------------------------------------
            obj.gindex  = unique(gindex_);
            obj.elem_code = unique(obj.parent_mesh.elem_code(gindex_));
            % -------------------------------------------------------------
        end
    end
end