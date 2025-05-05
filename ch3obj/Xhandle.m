%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Xhandle < matlab.mixin.Copyable
    %----------------------------------------------------------------------
    properties
        id
    end
    %----------------------------------------------------------------------
    methods
        function obj = Xhandle()
            % obj.id = char(java.util.UUID.randomUUID.toString);
        end
    end
    %----------------------------------------------------------------------
    % Object methods
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
                if any(f_strcmpi(fname{i},validprop))
                    obj.(fname{i}) = objx.(fname{i});
                end
            end
        end
        %------------------------------------------------------------------
        function objx = uplus(obj)
            objx = copy(obj);
        end
        %------------------------------------------------------------------
        function objx = ctranspose(obj)
            objx = copy(obj);
        end
        %------------------------------------------------------------------
    end
    %----------------------------------------------------------------------
    % reset/setup scheme
    methods
        function is_defining_obj_of(obj,dependent_obj)
            % ---
            if isobject(dependent_obj)
                if isprop(dependent_obj,'defining_obj')
                    len = length(dependent_obj.defining_obj);
                    dependent_obj.defining_obj{len+1} = obj;
                    % ---
                    dependent_obj.defining_obj = f_unique(dependent_obj.defining_obj);
                end
            end
            % ---
            if isprop(obj,'dependent_obj')
                len = length(obj.dependent_obj);
                if isobject(dependent_obj)
                    obj.dependent_obj{len+1} = dependent_obj;
                    % ---
                    obj.dependent_obj = f_unique(obj.dependent_obj);
                end
            end
        end
        % ---
        function depend_on_obj(obj,defining_obj)
            % ---
            if isobject(defining_obj)
                if isprop(defining_obj,'dependent_obj')
                    len = length(defining_obj.dependent_obj);
                    defining_obj.dependent_obj{len+1} = obj;
                    % ---
                    defining_obj.dependent_obj = f_unique(defining_obj.dependent_obj);
                end
            end
            % ---
            if isprop(obj,'defining_obj')
                len = length(obj.defining_obj);
                if isobject(defining_obj)
                    obj.defining_obj{len+1} = defining_obj;
                    % ---
                    obj.defining_obj = f_unique(obj.defining_obj);
                end
            end
        end
        % ---
        function reset_dependent_obj(obj)
            if isprop(obj,'dependent_obj')
                len = length(obj.dependent_obj);
                for i = 1:len
                    depobj = obj.dependent_obj{i};
                    if isobject(depobj)
                        if ismethod(depobj,'reset')
                            depobj.reset;
                        end
                    end
                end
            end
        end
        % ---
        function build_defining_obj(obj)
            if isprop(obj,'defining_obj')
                len = length(obj.defining_obj);
                for i = 1:len
                    defobj = obj.defining_obj{i};
                    if isobject(defobj)
                        if ismethod(defobj,'build')
                            defobj.build;
                        end
                    end
                end
            end
        end
        % ---
        function assembly_defining_obj(obj)
            if isprop(obj,'defining_obj')
                len = length(obj.defining_obj);
                for i = 1:len
                    defobj = obj.defining_obj{i};
                    if isobject(defobj)
                        if ismethod(defobj,'assembly')
                            defobj.assembly;
                        end
                    end
                end
            end
        end
        % ---
    end
    %----------------------------------------------------------------------
    methods
        function transfer_dep_def(obj,objx,objy)
            % ---
            k = 0;
            for i = 1:length(obj.dependent_obj)
                k = k + 1;
                objy.dependent_obj{k} = obj.dependent_obj{i};
            end
            for i = 1:length(objx.dependent_obj)
                k = k + 1;
                objy.dependent_obj{k} = objx.dependent_obj{i};
            end
            % ---
            objy.dependent_obj = f_unique(objy.dependent_obj);
            for i = 1:length(objy.dependent_obj)
                objy.is_defining_obj_of(objy.dependent_obj{i});
            end
            % ---
            k = 0;
            for i = 1:length(obj.defining_obj)
                k = k + 1;
                objy.defining_obj{k} = obj.defining_obj{i};
            end
            for i = 1:length(objx.defining_obj)
                k = k + 1;
                objy.defining_obj{k} = objx.defining_obj{i};
            end
            % ---
            objy.defining_obj = f_unique(objy.defining_obj);
            for i = 1:length(objy.defining_obj)
                objy.defining_obj{i}.is_defining_obj_of(objy);
            end
            % ---
        end
    end
    %----------------------------------------------------------------------
    % build/assembly scheme
    methods
        function callsubfieldbuild(obj,args)
            arguments
                obj
                args.field_name = []
            end
            %--------------------------------------------------------------
            field_name_ = f_to_scellargin(args.field_name);
            %--------------------------------------------------------------
            for i = 1:length(field_name_)
                field_name = field_name_{i};
                % ---
                if isprop(obj,field_name)
                    if isempty(obj.(field_name))
                        continue
                    end
                else
                    continue
                end
                % ---
                if isstruct(obj.(field_name))
                    idsub_ = fieldnames(obj.(field_name));
                    for j = 1:length(idsub_)
                        idsub = idsub_{j};
                        % ---
                        f_fprintf(0,['Build #' field_name],1,idsub,0,'\n');
                        % ---
                        subfield = obj.(field_name).(idsub);
                        % ---
                        if ismethod(subfield,'build')
                            subfield.build;
                        end
                    end
                elseif isobject(obj.(field_name))
                    subfield = obj.(field_name);
                    if ismethod(subfield,'build')
                        subfield.build;
                    end
                end
            end
            %--------------------------------------------------------------
        end
        function callsubfieldassembly(obj,args)
            arguments
                obj
                args.field_name = []
            end
            %--------------------------------------------------------------
            field_name_ = f_to_scellargin(args.field_name);
            %--------------------------------------------------------------
            for i = 1:length(field_name_)
                field_name = field_name_{i};
                % ---
                if isprop(obj,field_name)
                    if isempty(obj.(field_name))
                        continue
                    end
                else
                    continue
                end
                % ---
                if isstruct(obj.(field_name))
                    idsub_ = fieldnames(obj.(field_name));
                    for j = 1:length(idsub_)
                        idsub = idsub_{j};
                        % ---
                        f_fprintf(0,['Assembly #' field_name],1,idsub,0,'\n');
                        % ---
                        subfield = obj.(field_name).(idsub);
                        % ---
                        if ismethod(subfield,'assembly')
                            subfield.assembly;
                        end
                    end
                elseif isobject(obj.(field_name))
                    subfield = obj.(field_name);
                    if ismethod(subfield,'assembly')
                        subfield.assembly;
                    end
                end
            end
            %--------------------------------------------------------------
        end
    end
end