%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Xhandle < matlab.mixin.Copyable
    %----------------------------------------------------------------------
    properties (Hidden)
        tmp
    end
    %----------------------------------------------------------------------
    methods
        %------------------------------------------------------------------
        function le(obj,objx)
            % ---
            if isstruct(objx)
                fname = fieldnames(objx);
            elseif isobject(objx)
                fname = properties(objx);
            end
            % ---
            validprop = properties(obj);
            % ---
            for i = 1:length(fname)
                if any(f_strcmpi(fname,validprop))
                    obj.(fname{i}) = objx.(fname{i});
                end
            end
        end
        %------------------------------------------------------------------
        function res = is_available(obj,args,field_name)
            arguments
                obj
                args struct = []
                field_name = []
            end
            % ---
            if nargin < 1
                res = 0;
                return
            end
            % ---
            if isempty(args)
                res = 0;
                return
            end
            % ---
            if isempty(field_name)
                field_name = fieldnames(args);
            end
            % ---
            field_name = f_to_scellargin(field_name);
            % ---
            res = 1;
            args4obj = [];
            for i = 1:length(field_name)
                if isfield(args,field_name{i})
                    if isempty(args.(field_name{i}))
                        res = 0;
                        args = rmfield(args,field_name{i});
                    else
                        args4obj.(field_name{i}) = args.(field_name{i});
                    end
                else
                    res = 0;
                end
            end
            % ---
            obj.tmp.args = f_to_namedarg(args4obj);
        end
        %------------------------------------------------------------------
        function args = getargs(obj,args)
            % --- do first
            args = obj.cal_parent_multiphysical_model(args);
            args = obj.cal_parent_model(args);
            % --- then
            args = obj.cal_mesh3d_collection(args);
            args = obj.cal_id_mesh3d(args);
            args = obj.cal_mesh2d_collection(args);
            args = obj.cal_id_mesh2d(args);
            % ---
            args = obj.cal_mesh1d_collection(args);
            args = obj.cal_id_line(args);
            % ---
            args = obj.cal_parent_mesh(args);
            % ---
            args = obj.cal_dom3d_collection(args);
            args = obj.cal_dom2d_collection(args);
            % ---
        end
        %------------------------------------------------------------------
    end

    % ---
    methods (Hidden)
        % ---
        function args = cal_mesh3d_collection(obj,args)
            if isfield(args,'mesh3d_collection')
                if isempty(args.mesh3d_collection)
                    if isprop(obj,'mesh3d_collection')
                        args.mesh3d_collection = obj.mesh3d_collection;
                    end
                end
            end
        end
        % ---
        function args = cal_mesh2d_collection(obj,args)
            if isfield(args,'mesh2d_collection')
                if isempty(args.mesh2d_collection)
                    if isprop(obj,'mesh2d_collection')
                        args.mesh2d_collection = obj.mesh2d_collection;
                    end
                end
            end
        end
        % ---
        function args = cal_mesh1d_collection(obj,args)
            if isfield(args,'mesh1d_collection')
                if isempty(args.mesh1d_collection)
                    if isprop(obj,'mesh1d_collection')
                        args.mesh1d_collection = obj.mesh1d_collection;
                    end
                end
            end
        end
        % ---
        function args = cal_dom3d_collection(obj,args)
            if isfield(args,'dom3d_collection')
                if isempty(args.dom3d_collection)
                    if isprop(obj,'dom3d_collection')
                        args.dom3d_collection = obj.dom3d_collection;
                    end
                end
            end
        end
        % ---
        function args = cal_dom2d_collection(obj,args)
            if isfield(args,'dom2d_collection')
                if isempty(args.dom2d_collection)
                    if isprop(obj,'dom2d_collection')
                        args.dom2d_collection = obj.dom2d_collection;
                    end
                end
            end
        end
        % ---
        function args = cal_id_mesh3d(obj,args)
            if isfield(args,'id_mesh3d')
                if isempty(args.id_mesh3d)
                    if isprop(obj,'mesh3d_collection')
                        if isprop(obj.mesh3d_collection,'data')
                            if ~isempty(obj.mesh3d_collection.data)
                                fn = fieldnames(obj.mesh3d_collection.data);
                                fn = fn{1};
                                args.id_mesh3d = fn;
                            end
                        end
                    end
                end
            end
        end
        % ---
        function args = cal_id_mesh2d(obj,args)
            if isfield(args,'id_mesh2d')
                if isempty(args.id_mesh2d)
                    if isprop(obj,'mesh2d_collection')
                        if isprop(obj.mesh2d_collection,'data')
                            if ~isempty(obj.mesh2d_collection.data)
                                fn = fieldnames(obj.mesh2d_collection.data);
                                fn = fn{1};
                                args.id_mesh2d = fn;
                            end
                        end
                    end
                end
            end
        end
        % ---
        function args = cal_parent_mesh(obj,args)
            if isfield(args,'parent_mesh')
                if isempty(args.parent_mesh)
                    args = obj.cal_mesh3d_collection(args);
                    args = obj.cal_id_mesh3d(args);
                    args = obj.cal_mesh2d_collection(args);
                    args = obj.cal_id_mesh2d(args);
                    % ---
                    if isfield(args,'mesh3d_collection')
                        if isprop(args.mesh3d_collection,'data')
                            if ~isempty(args.mesh3d_collection.data)
                                if isfield(args,'id_mesh3d')
                                    if ~isempty(args.id_mesh3d)
                                        args.parent_mesh = ...
                                            args.mesh3d_collection.data.(args.id_mesh3d);
                                    end
                                end
                            end
                        end
                    end
                    % ---
                    if isfield(args,'mesh2d_collection')
                        if isprop(args.mesh2d_collection,'data')
                            if ~isempty(args.mesh2d_collection.data)
                                if isfield(args,'id_mesh2d')
                                    if ~isempty(args.id_mesh2d)
                                        args.parent_mesh = ...
                                            args.mesh2d_collection.data.(args.id_mesh2d);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        % ---
        function args = cal_id_line(obj,args)
            id__ = {'id_xline','id_yline','id_zline'};
            for i = 1:length(id__)
                id_ = id__{i};
                if isfield(args,id_)
                    if isempty(args.(id_))
                        if isprop(args,'mesh1d_collection')
                            if isprop(args.mesh1d_collection,'data')
                                if ~isempty(args.mesh1d_collection.data)
                                    fn = fieldnames(args.mesh1d_collection.data);
                                    fn = fn{1};
                                    args.(id_) = fn;
                                end
                            end
                        end
                    end
                end
            end
        end
        % ---
        function args = cal_parent_multiphysical_model(obj,args)
            if isfield(args,'parent_multiphysical_model')
                if ~isempty(args.parent_multiphysical_model)
                    mpmodel = args.parent_multiphysical_model;
                    if isprop(mpmodel,'mesh1d_collection')
                        if isfield(args,'mesh1d_collection')
                            args.mesh1d_collection = mpmodel.mesh1d_collection;
                        end
                    end
                    if isprop(mpmodel,'mesh2d_collection')
                        if isfield(args,'mesh2d_collection')
                            args.mesh2d_collection = mpmodel.mesh2d_collection;
                        end
                    end
                    if isprop(mpmodel,'mesh3d_collection')
                        if isfield(args,'mesh3d_collection')
                            args.mesh3d_collection = mpmodel.mesh3d_collection;
                        end
                    end
                    if isprop(mpmodel,'dom2d_collection')
                        if isfield(args,'dom2d_collection')
                            args.dom2d_collection = mpmodel.dom2d_collection;
                        end
                    end
                    if isprop(mpmodel,'dom3d_collection')
                        if isfield(args,'dom3d_collection')
                            args.dom3d_collection = mpmodel.dom3d_collection;
                        end
                    end
                end
            end
        end
        % ---
        function args = cal_parent_model(obj,args)
            if isfield(args,'parent_model')
                if ~isempty(args.parent_model)
                    mpmodel = args.parent_model;
                    if isprop(mpmodel,'mesh1d_collection')
                        if isfield(args,'mesh1d_collection')
                            args.mesh1d_collection = mpmodel.mesh1d_collection;
                        end
                    end
                    if isprop(mpmodel,'mesh2d_collection')
                        if isfield(args,'mesh2d_collection')
                            args.mesh2d_collection = mpmodel.mesh2d_collection;
                        end
                    end
                    if isprop(mpmodel,'mesh3d_collection')
                        if isfield(args,'mesh3d_collection')
                            args.mesh3d_collection = mpmodel.mesh3d_collection;
                        end
                    end
                    if isprop(mpmodel,'dom2d_collection')
                        if isfield(args,'dom2d_collection')
                            args.dom2d_collection = mpmodel.dom2d_collection;
                        end
                    end
                    if isprop(mpmodel,'dom3d_collection')
                        if isfield(args,'dom3d_collection')
                            args.dom3d_collection = mpmodel.dom3d_collection;
                        end
                    end
                end
            end
        end
        % ---
        % ---
        % ---
    end

end