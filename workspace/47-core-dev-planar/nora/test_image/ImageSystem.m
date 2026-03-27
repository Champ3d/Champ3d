classdef ImageSystem < Xhandle

properties
        imageregionair = {}
        imageregionnoyau = {}
        kmax = 2
        xmir = 0
        ymir = 0
        alpha=0
        beta=0
 end

    % --- Constructors
    methods
        function obj = ImageSystem(args)
            arguments
                args.imageregionair  = {}
                args.imageregionnoyau = {}
                args.kmax {mustBeNumeric}      = 2
                args.xmir {mustBeNumeric}      = 0
                args.ymir {mustBeNumeric}      = 0
                args.alpha {mustBeNumeric}    = 1e-4
                args.beta {mustBeNumeric} = 1
               
            end
            % ---
            obj@Xhandle;
            % ---
           
            % ---
              obj.imageregionair = args.imageregionair;
            obj.imageregionnoyau = args.imageregionnoyau;
          
            obj.kmax = args.kmax;
            obj.xmir = args.xmir;
            obj.ymir = args.ymir;
            obj.alpha = args.alpha;
            obj.beta = args.beta;
            % ---
        end

    end

%---setup
methods
 
     function setup(obj)
            obj.imageregionair = {};
            obj.imageregionnoyau = {};
           
        end


end







    methods
        function addregionair(obj, pos, I,ou)
            arguments
                obj
                pos
                I
                ou
             end
        
             obj.imageregionair{end+1} = struct("pos", pos, "I", I,"ou",ou);
        end

        function addregionnoyau(obj, pos, I,ou)
            arguments
                obj
                pos
                I
                ou
            end
        
            obj.imageregionnoyau{end+1} = struct("pos", pos, "I", I,"ou",ou);
        end

       
    end
%%
methods


    function clearregionair(obj)
        obj.imageregionair = {};
    end

    function clearregionnoyau(obj)
        obj.imageregionnoyau = {};
    end

    
end
%%
methods
    function removeregionair(obj, pos, I, tol)
        arguments
            obj
            pos
            I
            tol double = 1e-10
        end

        keep = true(1, numel(obj.imageregionair));
        for k = 1:numel(obj.imageregionair)
            samePos = norm(obj.imageregionair{k}.pos - pos) < tol;
            sameI   = abs(obj.imageregionair{k}.I - I) < tol;
            if samePos && sameI
                keep(k) = false;
            end
        end
        obj.imageregionair = obj.imageregionair(keep);
    end

    function removeregionnoyau(obj, pos, I, tol)
        arguments
            obj
            pos
            I
            tol double = 1e-10
        end

        keep = true(1, numel(obj.imageregionnoyau));
        for k = 1:numel(obj.imageregionnoyau)
            samePos = norm(obj.imageregionnoyau{k}.pos - pos) < tol;
            sameI   = abs(obj.imageregionnoyau{k}.I - I) < tol;
            if samePos && sameI
                keep(k) = false;
            end
        end
        obj.imageregionnoyau = obj.imageregionnoyau(keep);
    end

   


end


%%
methods
    function out = in_regionair(obj, pos, I, tol)
        arguments
            obj
            pos
            I
            tol double = 1e-10
        end

        out = 0;
        for k = 1:length(obj.imageregionair)
            samePos = norm(obj.imageregionair{k}.pos - pos) < tol;
            sameI   = abs(obj.imageregionair{k}.I - I) < tol;

            if samePos && sameI
                out = 1;
                return
            end
        end
    end

    function out = is_regionnoyau(obj, pos, I, tol)
        arguments
            obj
            pos
            I
            tol double = 1e-10
        end

        out = 0;
        for k = 1:length(obj.imageregionnoyau)
            samePos = norm(obj.imageregionnoyau{k}.pos - pos) < tol;
            sameI   = abs(obj.imageregionnoyau{k}.I - I) < tol;

            if samePos && sameI
                out = 1;
                return
            end
        end
    end
end

end