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
            obj.id = char(java.util.UUID.randomUUID.toString);
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
    % setup/build/assembly scheme
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