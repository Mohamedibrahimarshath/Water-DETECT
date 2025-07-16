function BW = SVM(I, varargin)


varargin = matlab.images.internal.stringToChar(varargin);
[I,isNumericThreshold,options] = parseInputs(I,varargin{:});

if isNumericThreshold
    T = options.T;
else
    method = options.Method;
    
    if strcmp(method,'global')
        T = computeGlobalThreshold(I);
    else
        sensitivity = options.Sensitivity;
        fgPolarity  = options.ForegroundPolarity;
        
        T = adaptthresh(I,sensitivity,'ForegroundPolarity',fgPolarity);
    end
    
end

% Binarize image using computed threshold
BW = binarize(I,T);

end

function BW = binarize(I,T)

classrange = getrangefromclass(I);

switch class(I)
    case {'uint8','uint16','uint32'}
        BW = I > T*classrange(2);
        
    case {'int8','int16','int32'}
        BW = I > classrange(1) + (classrange(2)-classrange(1))*T;
        
    case {'single','double'}
        BW = I > T;
end

end

function T = computeGlobalThreshold(I)

if isfloat(I)
    I = im2uint8(I);
    T = otsuthresh( imhist(I) );
else
    T = otsuthresh( imhist(I) );
end
end


function [I,isNumericThreshold,options] = parseInputs(I, varargin)

narginchk(1,6);
% validate image
validateImage(I);

isNumericThreshold = ~isempty(varargin) && ~ischar(varargin{1});

if isNumericThreshold
    
    options.T = validateT(varargin{1},size(I));
    
    if numel(varargin)>1
        error(message('MATLAB:TooManyInputs'))
    end
    
else
    if isempty(varargin)
        options.Method = 'global';
        return;
    end
    
    options.Method = validatestring(varargin{1},{'global','adaptive'},mfilename,'Method',2);
    
    if strcmp(options.Method,'global')
        
        if numel(varargin)>1
            error(message('MATLAB:TooManyInputs'))
        end
    else
        options.Sensitivity = 0.5;
        options.ForegroundPolarity = 'bright';
        
        numPVArgs = numel(varargin)-1;
        if mod(numPVArgs,2)~=0
            error(message('images:validate:invalidNameValue'));
        end
        
        ParamNames = {'Sensitivity','ForegroundPolarity'};
        ValidateFcn = {@validateSensitivity,@validateForegroundPolarity};
        
        for p = 2 : 2 : numel(varargin)-1
            
            Name = varargin{p};
            Value = varargin{p+1};
            
            idx = strncmpi(Name, ParamNames, numel(Name));
            
            if ~any(idx)
                error(message('images:validate:unknownParamName', Name));
            elseif numel(find(idx))>1
                error(message('images:validate:ambiguousParamName', Name));
            end
            
            validate = ValidateFcn{idx};
            options.(ParamNames{idx}) = validate(Value);
            
        end
    end
    
    
end
end

function validateImage(I)

supportedClasses = {'uint8','uint16','uint32','int8','int16','int32','single','double'};
supportedAttribs = {'real','nonsparse','3d'};
validateattributes(I,supportedClasses,supportedAttribs,mfilename,'I');

end

function T = validateT(T,sizeI)

validateattributes(T,{'numeric'},{'real','nonsparse','3d'},mfilename,'Threshold',2);

if ~( isscalar(T) || isequal(size(T),sizeI) )
    error(message('images:imbinarize:badSizedThreshold'))
end

end

function s = validateSensitivity(s)
validateattributes(s,{'numeric'},{'real','nonsparse','scalar','nonnegative','<=',1},mfilename,'Sensitivity');
end

function fgp = validateForegroundPolarity(fgp)
fgp = validatestring(fgp,{'bright','dark'},mfilename,'ForegroundPolarity');
end
