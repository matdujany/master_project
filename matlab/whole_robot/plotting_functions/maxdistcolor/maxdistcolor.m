function [rgb,ucs,err,RGB,UCS,opts] = maxdistcolor(N,fun,opts,varargin)
% Generate an RGB colormap of maximally distinct colors, using a uniform colorspace.
%
% (c) 2017-2019 Stephen Cobeldick.
%
%%% Syntax:
% rgb = maxdistcolor(N,fun)
% rgb = maxdistcolor(N,fun,opts)
% rgb = maxdistcolor(N,fun,<name-value pairs>)
% [rgb,ucs,err] = maxdistcolor(N,fun,...)
%
% Repeatedly applies a greedy algorithm to search the entire RGB color cube
% to find the truly maximally distinct set of N colors. To ensure that the
% greedy algorithm works correctly I recommend using 8 bits per channel.
%
% Because the quality of the output depends mostly on the colorspace used
% I strongly recommend using a proper uniform colorspace, for example from
% my CIECAM02 implementation: <https://github.com/DrosteEffect/CIECAM02>
%
%%% Options include:
% * Limit the lightness range of the output colors.
% * Limit the chroma range of the output colors.
% * Colors to be excluded (e.g. background colors).
% * Colors to be included (e.g. corporate colors).
% * Specify a different RGB bit depth (e.g. 8 bits per channel, TrueColor).
% * Sort the output colormap (e.g. by hue, lightness, farthest colors, etc.).
%
% See also MAXDISTCOLOR_VIEW SRGB_2_JAB SRGB_2_LAB COLORNAMES COLORMAP RGBPLOT AXES SET LINES PLOT
%
%% Options %%
%
% The options may be supplied either
% 1) in a scalar structure, or
% 2) as a comma-separated list of name-value pairs.
%
% Field names and string values are case-insensitive. The following field
% names and values are permitted as options (*=default value):
%
% Field  | Permitted  |
% Name:  | Values:    | Description:
% =======|============|====================================================
% Lmin   | 0<=L<=1    | Lightness range limits to exclude light/dark colors.
% Lmax   |            | Scaled so 0->black and 1->white, Lmin=*0, Lmax=*1.
% -------|------------|----------------------------------------------------
% Cmin   | 0<=C<=Inf  | Chroma limit to exclude grays and saturated colors,
% Cmax   |            | in units of the UCS colorspace, Cmin=*0, Cmax=*Inf.
% -------|------------|----------------------------------------------------
% inc    | RGB matrix | Mx3 RGB matrix of colors to include, *[] (none).
% -------|------------|----------------------------------------------------
% exc    | RGB matrix | Mx3 RGB matrix of colors to exclude, *[1,1,1] (white).
% -------|------------|----------------------------------------------------
% disp   | 'off'    * | Does not print to the command window.
%        | 'summary'  | Print the status after the completion of main steps.
%        | 'verbose'  | Print the status after every algorithm iteration.
% -------|------------|----------------------------------------------------
% sort   | 'none'   * | The output matrices are not sorted.
%        | 'farthest' | The next color is farthest from the current color.
%        | 'hue'      | Sorted by hue, the angle calculated from ucs(:,2:3).
%        | 'zip'      | Sorted by hue, then zip alternating colors together.
%        | 'lightness'| Sorted by the lightness value L or J, from ucs(:,1).
%        | 'maxmin'   | Maximize the minimum adjacent color difference. See Note1.
%        | 'minmax'   | Minimize the maximum adjacent color difference. See Note1.
%        | 'longest'  | The longest path joining all color nodes.       See Note1.
%        | 'shortest' | The shortest path joining all color nodes.      See Note1.
% -------|------------|----------------------------------------------------
% path   | 'open'   * | <sort> options 'maxmin', 'minmax', 'longest', & 'shortest':
%        | 'closed'   | select if the path through all colors forms a loop or not.
% -------|------------|----------------------------------------------------
% start  | 0<=A<=360  | Start angle for <sort> options 'hue' & 'zip', *0.
% -------|------------|----------------------------------------------------
% bitR   | 1<=R<=53   | RGB colorspace bits for   Red channel, *6. See Note2.
% bitG   | 1<=G<=53   | RGB colorspace bits for Green channel, *7. See Note2.
% bitB   | 1<=B<=53   | RGB colorspace bits for  Blue channel, *6. See Note2.
% -------|------------|----------------------------------------------------
%
% Note1: These algorithms use an exhaustive search which generates all row
%        permutations of the colormap. An error occurs for N greater than 9.
% Note2: Using 8 bits per channel requires 64 bit MATLAB with atleast 8 GB RAM.
%        A smaller number of bits gives a smaller RGB cube (faster), but the
%        greedy algorithm can fail to work for smaller RGB cubes: user beware!
%
%% Examples %%
%
% >> N = 5;
% >> fun = @(m)srgb_2_Jab(m,'LCD'); % recommended colorspace.
% >> rgb = maxdistcolor(N,fun)
% rgb =
%     1.0000    0.3228    0.0000
%     0.8730    0.0000    1.0000
%     0.0000    0.0000    0.7937
%     0.0000    0.5512    0.0000
%     0.2222    0.0000    0.0000
% >> axes('ColorOrder',rgb, 'NextPlot','replacechildren')
% >> X = linspace(0,pi*3,1000);
% >> Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% >> plot(X,Y, 'linewidth',4)
%
% >> maxdistcolor(N,fun, 'exc',[0,0,0]) % Exclude black (e.g. background).
% ans =
%     0.8095    1.0000    0.0000
%     1.0000    0.0000    0.9524
%     0.1111    0.8661    1.0000
%     0.6349    0.3543    0.0000
%     0.2698    0.1024    1.0000
%
% >> maxdistcolor(N,fun, 'inc',[1,0,1]) % Include magenta.
% ans =
%     1.0000    0.0000    1.0000
%     0.0000    0.5433    0.0000
%     0.0000    0.3543    1.0000
%     0.5873    0.0000    0.0000
%     0.0000    0.0000    0.0159
%
% >> [rgb,Lab] = maxdistcolor(6,@srgb_2_Lab, 'Lmin',0.5, 'Lmax',0.7) % Lightness limits.
% rgb =
%     0.7619    0.0000    1.0000
%     1.0000    0.0000    0.0000
%     0.0000    0.7795    0.0000
%     0.0000    0.5591    1.0000
%     0.8254    0.6457    0.0794
%     0.8254    0.2835    0.5397
% Lab =
%    50.3665   89.7885  -77.4167
%    53.2329   80.1093   67.2201
%    69.9972  -71.4464   68.9565
%    58.7262    9.8285  -64.4614
%    69.8987    5.1700   70.3789
%    52.1378   59.8754   -6.6658
%
%% Input and Output Arguments %%
%
%%% Inputs:
%  N    = Numeric Scalar, the required number of output colors.
%  fun  = Function Handle, a function to convert from RGB to a uniform colorspace.
%         Must accept an Nx3 RGB matrix, and return an Nx3 matrix (of the UCS).
%  opts = Structure Scalar, with optional fields and values as per 'Options' above.
%  OR
%  <name-value pairs> = a comma-separated list of field names and associated values.
%
%%% Outputs:
%  rgb = Numeric Matrix, size Nx3, the colors in RGB, where 0<=rgb<=1.
%  ucs = Numeric Matrix, size Nx3, the colors in the uniform colorspace.
%  err = Logical Scalar, true if the greedy algorithm did not reach a stable solution.
%
% [rgb,ucs,err] = maxdistcolor(N,fun,*opts)
% [rgb,ucs,err] = maxdistcolor(N,fun,*<name-value pairs>)

%% Input Wrangling %%
%
assert(isnumeric(N)&&isscalar(N),'First input <N> must be a numeric scalar.')
assert(isfinite(N)&&N>=0,'First input <N> must be a finite positive value. Input: %g',N)
assert(isreal(N),'First input <N> cannot be a complex value. Input: %g%+gi',N,imag(N))
%
assert(isa(fun,'function_handle'),'Second input <fun> must be a function handle.')
map = fun([0,0,0;1,1,1]);
assert(isfloat(map)&&ismatrix(map),'Second input <fun> must return a floating-point matrix.')
assert(all(size(map)==[2,3]),'Second input <fun> output matrix has an incorrect size.')
assert(all(isfinite(map(:))),'Second input <fun> output matrix values must be finite.')
assert(isreal(map),'Second input <fun> output matrix values cannot be complex.')
%
% Default option values:
stpo = struct('start',0, 'Cmin',0, 'Cmax',Inf, 'Lmin',0, 'Lmax',1,...
	'exc',[1,1,1], 'inc',[], 'sort','none', 'path','open', 'disp','off',...
	'bitR',6, 'bitG',7, 'bitB',6); % similar to some LCD screens.
%
% Check any user-supplied option fields and values:
if nargin==3
	assert(isstruct(opts)&&isscalar(opts),...
		'When calling with three inputs, the third input <opts> must be a scalar structure.')
	opts = mdcOptions(stpo,opts);
elseif nargin>3 % options as <name-value> pairs
	opts = struct(opts,varargin{:});
	assert(isscalar(opts),'Invalid <name-value> pairs: cell array values are not permitted.')
	opts = mdcOptions(stpo,opts);
else
	opts = stpo;
end
stpo = opts;
%
assert(stpo.Lmax>stpo.Lmin,'The value Lmax must be greater than the value Lmin.')
assert(stpo.Cmax>stpo.Cmin,'The value Cmax must be greater than the value Cmin.')
%
%% Generate RGB and UCS Arrays %%
%
bitV = [stpo.bitR,stpo.bitG,stpo.bitB];
stpo.ohm = pow2(bitV)-1; % e.g. 8 bits -> 255.
stpo.int = pow2(max(3,ceil(log2(max(bitV))))); % required bits.
stpo.typ = sprintf('uint%d',stpo.int); % e.g. 6 bits -> uint8.
stpo.cyc = strcmp('closed',stpo.path); % closed/open -> true/false.
stpo.mfn = mfilename();
[~,stpo.osv] = ismember(stpo.disp,{'summary','verbose'}); % off/summary/verbose -> 0/1/2.
%
[RGB,UCS] = mdcRgbCube(stpo,fun);
%
% Get user supplied RGB colormaps:
[exc,cxe] = mdcMapMat(stpo,fun,'exc');
[inc,cni] = mdcMapMat(stpo,fun,'inc');
%
assert(size(intersect(exc,inc,'rows'),1)==0,...
  'Options <exc> and <inc> must not contain the same RGB values')
%
nmt = N+size(exc,1); % number of color nodes to test (N + excluded colors).
nmf = N-size(inc,1); % number of color nodes to find (N - included colors).
%
mdcDisplay(stpo,1,'Finished processing any input arguments.')
%
%% Greedy Algorithm %%
%
if nmf==0
	err = false;
	rgb = inc;
	ucs = cni;
elseif nmf>0
	err = true;
	dwn = nmt;
	bst = 0;
	cnt = 0;
	vec = 0;
	mxi = (nmt+3)*(3+sum(bitV)); % magic numbers, based on tests.
	%
	fmt = ['The specified RGB cube contains fewer color nodes than the\n',...
		'requested number of colors. This can be avoided in several ways:\n',...
		'* request fewer colors <N> (now: %d),\n',...
		'* decrease the number of <exc> colors (now: %d),\n',...
		'* increase the difference between <Cmax> and <Cmin>,\n',...
		'* increase the difference between <Lmax> and <Lmin>,\n',...
		'* increase the number of bits for any color channel.'];
	assert(nmt<=size(RGB,1), fmt, N,size(exc,1))
	%
	idz = zeros(nmf,1);
	win = zeros(nmf,3);
	chk = zeros(nmf,nmf);
	%
	win = [win;cxe;cni];
	%
	mdcDisplay(stpo,2,'Starting the greedy algorithm...')
	%
	while err && cnt<=mxi
		row = 1+mod(cnt,nmf);
		cnt = 1+cnt;
		vec(:) = Inf;
		% Distance between all nodes (except for the one being moved):
		for k = [1:row-1,row+1:nmt]
			%vec = min(vec,sum(bsxfun(@minus,ucs,win(k,:)).^2,2));
			vec = min(vec,... requires less memory:
				(UCS(:,1)-win(k,1)).^2 + ...
				(UCS(:,2)-win(k,2)).^2 + ...
				(UCS(:,3)-win(k,3)).^2);
		end
		% Move that node to the farthest point from the other nodes:
		[~,idr]    = max(vec);   % farthest point.
		win(row,:) = UCS(idr,:); % move node.
		idz(row,1) = idr; % Save the index.
		chk(row,:) = idz; % Save the index.
		% Check if any nodes have changed index:
		tmp = any(diff(chk));
		err = any(tmp);
		%
		dwn = max(dwn-~err,dwn*err);
		%
		% Display:
		if stpo.osv>=2
			idb = nchoosek(1:nmt,2);
			dst = min(sqrt(sum((win(idb(:,1),:)-win(idb(:,2),:)).^2,2)));
			bst = max(bst,dst);
			fmt = '%s: %2d %2d %6d/%d   %s   %#.9g   %#.9g\n';
			fprintf(fmt,stpo.mfn,dwn,row,cnt,mxi,char('0'+tmp),dst,bst)
		end
	end
	%
	rgb = [inc;bsxfun(@rdivide,double(RGB(idz,:)),stpo.ohm)];
	ucs = [cni;UCS(idz,:)];
	%
	mdcDisplay(stpo,1,sprintf('Finished the greedy algorithm in %i iterations.',cnt))
	%
else
	error('Not enough colors requested: option <inc> must have <N> or fewer rows.')
end
%
if err
	warning('The greedy algorithm did not complete to a stable solution.')
end
%
%% Sort %%
%
mdcDisplay(stpo,2,'Starting to sort the colormap...')
%
switch lower(stpo.sort)
case 'none'
	ids = 1:N;
case 'maxmin'
	ids = mdcBestPerm(ucs,N, stpo, @(v)-min(v));
case 'minmax'
	ids = mdcBestPerm(ucs,N, stpo, @(v)+max(v));
case 'longest'
	ids = mdcBestPerm(ucs,N, stpo, @(v)-sum(v));
case 'shortest'
	ids = mdcBestPerm(ucs,N, stpo, @(v)+sum(v));
case 'farthest'
	ids = mdcFarthest(ucs,N);
case 'lightness'
	[~,ids] = sortrows(ucs);
case 'hue'
	[~,ids] = sort(mdcAtan2D(ucs(:,3),ucs(:,2),stpo.start));
case 'zip'
	[~,ids] = sort(mdcAtan2D(ucs(:,3),ucs(:,2),stpo.start));
	ids([1:2:N,2:2:N]) = ids;
otherwise
	error('This <sort> option is not supported: %s',typ)
end
%
rgb = rgb(ids,:);
ucs = ucs(ids,:);
%
mdcDisplay(stpo,1,'Finished sorting the colormap.')
%
mdcDisplay(stpo,1,'Finished all code. Hurrah!')
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%maxdistcolor
function stpo = mdcOptions(stpo,opts)
% Options check: only supported fieldnames with suitable option values.
%
cFld = fieldnames(opts);
idx = ~cellfun(@(f)any(strcmpi(f,fieldnames(stpo))),cFld);
if any(idx)
	error('Unsupported field name/s:%s',sprintf(' <%s>,',cFld{idx}))
end
%
% Colormap options:
stpo = mdcMapChk(stpo,opts,cFld,'exc');
stpo = mdcMapChk(stpo,opts,cFld,'inc');
%
% Integer options:
stpo = mdcValChk(stpo,opts,cFld,'bitR',false, 1,53); % flintmax
stpo = mdcValChk(stpo,opts,cFld,'bitG',false, 1,53); % flintmax
stpo = mdcValChk(stpo,opts,cFld,'bitB',false, 1,53); % flintmax
%
% Float options:
stpo = mdcValChk(stpo,opts,cFld,'Cmin',true, 0,Inf);
stpo = mdcValChk(stpo,opts,cFld,'Cmax',true, 0,Inf);
stpo = mdcValChk(stpo,opts,cFld,'Lmin',true, 0,1);
stpo = mdcValChk(stpo,opts,cFld,'Lmax',true, 0,1);
stpo = mdcValChk(stpo,opts,cFld,'start',true, 0,360);
%
% String options:
stpo = mdcStrChk(stpo,opts,cFld,'disp','off','summary','verbose');
stpo = mdcStrChk(stpo,opts,cFld,'path','open','closed');
stpo = mdcStrChk(stpo,opts,cFld,'sort','none','farthest',...
	'hue','zip','lightness','maxmin','minmax','longest','shortest');
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcOptions
function idx = mdcStrCmpi(cFld,sFld)
% Options check: throw an error if more than one fieldname match.
idx = strcmpi(cFld,sFld);
if nnz(idx)>1
	error('Duplicate field names:%s\b.',sprintf(' <%s>,',cFld{idx}));
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcStrCmpi
function stpo = mdcMapChk(stpo,opts,cFld,sFld)
% Options check: numeric colormap, size Nx3.
idx = mdcStrCmpi(cFld,sFld);
if any(idx)
	map = opts.(cFld{idx});
	assert(isnumeric(map)&&ismatrix(map),'Input <%s> must be a numeric matrix.',sFld)
	S = size(map);
	assert(S(2)==3||all(S==0),'The <%s> numeric matrix must be empty or have size Nx3.',sFld)
	assert(all(isfinite(map(:))),'The <%s> colormap values must be finite.',sFld)
	assert(isreal(map),'The <%s> colormap values cannot be complex.',sFld)
	stpo.(sFld) = map;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcMapChk
function stpo = mdcValChk(stpo,opts,cFld,sFld,isf,minV,maxV)
% Options check: scalar numeric value.
idx = mdcStrCmpi(cFld,sFld);
if any(idx)
	val = opts.(cFld{idx});
	assert(isnumeric(val),'The <%s> input must be numeric. Class: %s',sFld,class(val))
	assert(isscalar(val),'The <%s> input must be scalar. Numel %d',sFld,numel(val))
	assert(imag(val)==0,'The <%s> value cannot be complex. Input: %g%+gi',sFld,val,imag(val))
	assert(isf||(fix(val)==val),'The <%s> value must be integer. Input: %g',sFld,val)
	assert(val>=minV,'The <%s> value must be >=%g. Input: %g',sFld,minV,val)
	assert(val<=maxV,'The <%s> value must be <=%g. Input: %g',sFld,maxV,val)
	stpo.(sFld) = double(val);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcValChk
function stpo = mdcStrChk(stpo,opts,cFld,sFld,varargin)
% Options check: character row vector.
idx = mdcStrCmpi(cFld,sFld);
if any(idx)
	tmp = opts.(cFld{idx});
	if ~(ischar(tmp)&&isrow(tmp)&&any(strcmpi(tmp,varargin)))
		error('The <%s> value must be one of:%s\b.',sFld,sprintf(' ''%s'',',varargin{:}));
	end
	stpo.(sFld) = lower(tmp);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcStrChk
function mdcDisplay(stpo,val,str)
% Display text in the command window.
if stpo.osv>=val
	fprintf('%s: %s\n',stpo.mfn,str)
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcDisplay
function [RGB,UCS] = mdcRgbCube(stpo,fun)
% Generate cube of colors in RGB, and corresponding UCS. Select by lightness & chroma.
%
mdcDisplay(stpo,2,'Creating the RGB cube (all color nodes)...')
% Generate all RGB colors in the cube:
[R,G,B] = ndgrid(...
	cast(0:stpo.ohm(1),stpo.typ),...
	cast(0:stpo.ohm(2),stpo.typ),...
	cast(0:stpo.ohm(3),stpo.typ));
RGB = [R(:),G(:),B(:)];
clear R G B
% Convert to uniform colorspace (e.g. Lab or Jab):
mdcDisplay(stpo,2,'Converting from RGB to UCS (call external function)...')
UCS = fun(bsxfun(@rdivide,double(RGB),stpo.ohm));
% Identify lightness and chroma values within the requested ranges:
tmp = fun([0,0,0;1,1,1]);
lim = interp1([0;1],tmp(:,1),[stpo.Lmin;stpo.Lmax]);
chr = sqrt(sum(UCS(:,2:3).^2,2));
idk = lim(1)<=UCS(:,1) & UCS(:,1)<=lim(2) & stpo.Cmin<=chr & chr<=stpo.Cmax;
% Select only the colors with the required lightness and chroma ranges:
RGB = RGB(idk,:);
UCS = UCS(idk,:);
%
mdcDisplay(stpo,1,sprintf('Defined %i RGB and UCS color nodes.',size(RGB,1)))
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcRgbCube
function [rgb,ucs] = mdcMapMat(stpo,fun,fld)
% Check user-supplied include/exclude RGB colormap, convert to UCS.
%
rgb = stpo.(fld);
fmt = 'Input <%s> %s values must be %s';
%
if isempty(rgb)
	rgb = nan(0,3);
elseif isfloat(rgb)
	assert(all(0<=rgb(:)&rgb(:)<=1),fmt,fld,'floating point','0<=rgb<=1')
	rgb = double(rgb);
else
	tmp = sprintf('0<=Red<=%d, 0<=Green<=%d, 0<=Blue<=%d',stpo.ohm);
	assert(all(all(0<=rgb&bsxfun(@le,rgb,stpo.ohm))),fmt,fld,'integer',tmp)
	rgb = bsxfun(@rdivide,double(rgb),stpo.ohm);
end
ucs = fun(rgb);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcMapMat
function ang = mdcAtan2D(Y,X,start)
% ATAN2 with an output in degrees.
%
ang = mod(360*atan2(Y,X)/(2*pi)-start,360);
ang(Y==0 & X==0) = 0;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcAtan2D
function idp = mdcBestPerm(ucs,N,stpo,cost)
% Exhaustive search for the permutation that minimizes the cost function.
%
assert(N<10,'This <sort> option requires N<10, as it generates all permutations.')
%
big = prod(1:N);
cyc = stpo.cyc;
osv = stpo.osv>=2;
low = cost(sum(diff([ucs;ucs(cyc,:)],1,1).^2,2));
if osv
	fprintf('%s: %9d/%-9d  %g\n',stpo.mfn,1,big,low)
end
% Generate permutations using Heap's algorithm:
idx = 1:N;
idp = idx;
idc = ones(1,N);
idi = 1;
cnt = 1;
while idi<=N
	if idc(idi)<idi
		% Swap indices:
		vec = [idc(idi),1];
		tmp = vec(1+mod(idi,2));
		idx([tmp,idi]) = idx([idi,tmp]);
		% Calculate the cost:
		new = cost(sum(diff(ucs([idx,idx(cyc)],:),1,1).^2,2));
		if new<low
			low = new;
			idp = idx;
		end
		if osv
			cnt = cnt+1;
			fprintf('%s: %9d/%-9d  %g\n',stpo.mfn,cnt,big,low)
		end
		% Prepare next iteration:
		idc(idi) = 1+idc(idi);
		idi      = 1;
	else
		idc(idi) = 1;
		idi      = 1+idi;
	end
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcBestPerm
function idp = mdcFarthest(ucs,N)
% Permutation where the next color is the farthest of the remaining colors.
%
dst = sum(bsxfun(@minus,permute(ucs,[1,3,2]),permute(ucs,[3,1,2])).^2,3);
[~,idx] = max(sum(dst));
idp = [idx,2:N];
for k = 2:N
	vec = dst(:,idx);
	dst(idx,:) = -Inf;
	dst(:,idx) = -Inf;
	[~,idx] = max(vec);
	idp(k) = idx;
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mdcFarthest