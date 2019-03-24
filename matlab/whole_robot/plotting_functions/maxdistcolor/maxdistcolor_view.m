function [rgb,ucs,err,RGB,UCS,opts] = maxdistcolor_view(N,fun,varargin)
% Create a figure for interactive generation and display of MAXDISTCOLOR colors.
%
% (c) 2019 Stephen Cobeldick
%
% This function has exactly the same inputs and outputs as MAXDISTCOLOR.
% See MAXDISTCOLOR for descriptions of the required and optional arguments.
% 
% See also MAXDISTCOLOR SRGB_2_JAB SRGB_2_LAB COLORNAMES COLORMAP RGBPLOT AXES SET LINES PLOT

%% New Figure %%
%
figH = figure('Units','pixels', 'ToolBar','figure', 'NumberTitle','off',...
	'HandleVisibility','off', 'Name',mfilename(), 'Visible','on');
figP = get(figH, 'Position');
figY = get(figH, 'Pointer');
set(figH, 'Pointer','watch')
%
iniH = uicontrol(figH, 'Units','pixels', 'Style','text', 'HitTest','off',...
	'Visible','on',	'String','Initializing the figure... please wait.');
iniX = get(iniH,'Extent');
set(iniH,'Position',[figP(3:4)/2-iniX(3:4)/2,iniX(3:4)])
%
drawnow()
%
% First call to check input arguments and define all output arguments:
[rgbM,ucs,err,RGB,UCS,opts] = maxdistcolor(N,fun,varargin{:});
%
if isempty(opts.exc)
	opts.exc = nan(0,3);
end
if isempty(opts.inc)
	opts.inc = nan(0,3);
end
%
delete(iniH)
%
%% Parameters %%
%
% Maximum chroma:
tmp = fun(dec2bin(0:7)-'0');
mxc = max(max(abs(tmp(:,2:3))));
tmp = 10.^floor(log10(mxc)-0.1);
mxc = tmp.*ceil(1.1*mxc./tmp);
% Graphics parameters:
gap = 7;
fgd = [0.7,0.3,0.2];
% Number slider properties:
nRng = [1,64];
nStp = [1,5];
nFun = @(n) max(nRng(1),min(nRng(2),n));
% Table properties:
tTxt = {'exc'; 'inc'};
% Menu properties:
mTxt = {'plot'; 'sort'; 'path'; 'disp'};
mSrt = {{'none','farthest','hue','zip','lightness'},{'maxmin','minmax','longest','shortest'}};
mStr = {''; [mSrt{:}]; {'open','closed'}; {'off','summary','verbose'}};
% Slider properties:
sTxt = {'Cmax'; 'Cmin';   'Lmax';   'Lmin'; 'bitR'; 'bitG'; 'bitB'; 'start'};
sInt = [ false;  false;    false;    false;   true;   true;   true;   false];
sRng = [ 0,mxc;  0,mxc;      0,1;      0,1;   1,32;   1,32;   1,32;   0,360];
sStp = [  1,10;   1,10;0.005,0.1;0.005,0.1;    1,2;    1,2;    1,2;    1,10];
sFun = @(n,k) max(sRng(k,1),min(sRng(k,2),n));
sStr = @(x) sprintf('%.4g',round(1000*x)/1000);
%
%% Interactive Graphics Objects %%
%
% Get text width:
cnc = {'Red','Green','Blue'};
tmp = uicontrol(figH, 'Style','text', 'Units','pixels', 'String',cnc);
txw = get(tmp,'Extent');
txh = txw(4)/numel(cnc);
txw = num2cell(ones(1,3)*(7+txw(3)));
delete(tmp)
% Add drop-down menus:
mTxN = numel(mTxt);
mAxH = axes('Parent',figH, 'Units','pixels', 'Visible','off', 'View',[0,90],...
	'HitTest','off', 'Xlim',[0,1], 'Ylim',[0,2*mTxN]);
mTxH = text(zeros(1,mTxN),2*mTxN-1:-2:1, mTxt, 'parent',mAxH, 'Color',fgd,...
	'VerticalAlignment','bottom','HorizontalAlignment','left');
set(mTxH(1),'Color',fgd([3,2,1]));
for k = mTxN:-1:1
	if k>1
		idm = find(strcmpi(opts.(mTxt{k}),mStr{k}));
	else
		idm = 1;
	end
	mUiH(k) = uicontrol(figH, 'Style','popupmenu', 'Units','pixels',...
		'String',mStr{k}, 'Callback',{@fOptMenu,k}, 'Value',idm);
end
% Add horizontal sliders:
sTxN = numel(sTxt);
for k = sTxN:-1:1
	val = opts.(sTxt{k});
	sTxH(k) = uicontrol(figH, 'Units','pixels', 'Style','text',...
		'String',sTxt{k}, 'HorizontalAlignment','left', 'ForegroundColor',fgd);
	sVaH(k) = uicontrol(figH, 'Units','pixels', 'Style','edit',...
		'String',sStr(val), 'HorizontalAlignment','left', 'Callback',{@fOptEdit,k});
	sUiH(k) = uicontrol(figH, 'Units','pixels', 'Style','slider', 'Value',1,...
		'Min',sRng(k,1), 'Max',sRng(k,2), 'Value',sFun(val,k),...
		'SliderStep',sStp(k,:)./diff(sRng(k,:)), 'Callback',@fUpDtMap);
	addlistener(sUiH(k), 'Value', 'PostSet',@(o,e)fOptSlide(o,e,k));
end
% Add tables:
tTxN = numel(tTxt);
for k = tTxN:-1:1
	tmp = opts.(tTxt{k});
	tmp(end+1:N,:) = NaN;
	tUiH(k) = uitable(figH, 'Units','pixels', 'Data',tmp, 'ColumnWidth',txw,...
		'ColumnName',cnc, 'ColumnEditable',true, 'CellEditCallback',{@fCellEdit,k});
	tTxH(k) = uicontrol(figH, 'Style','text', 'Units','pixels','ForegroundColor',fgd,...
		'String',tTxt{k}, 'HorizontalAlignment','left');
	tCbH(k) = uicontrol(figH, 'Style','checkbox', 'Units','pixels','String','X',...
		'Callback',{@fCheckBox,k});
end
% Add colorbar:
bAxH = axes('Parent',figH, 'Units','pixels', 'Visible','off',...
	'HitTest','off', 'Xlim',[0.5,1.4], 'Ylim',[0,N]+0.5, 'View',[0,90],...
	'YDir','reverse', 'XTick',[], 'YTick',1:N, 'Box','off');
bImH = image('CData',permute(rgbM,[1,3,2]), 'Parent',bAxH);
% Add number slider:
nVaH = uicontrol(figH, 'Units','pixels', 'Style','edit', 'String',sprintf('%d',N),...
	'HorizontalAlignment','center', 'Callback',@fNumEdit);
nUiH = uicontrol(figH, 'Units','pixels', 'Style','slider', 'Value',nFun(N),...
	'Min',nRng(1), 'Max',nRng(2), 'SliderStep',nStp./diff(nRng), 'Callback',@fUpDtMap);
addlistener(nUiH, 'Value', 'PostSet',@fNumSlide);
%
%% Main Plot Objects %%
%
ndx = 'Colormap Index';
axp = {'Units','normalized', 'NextPlot','replacechildren'};
pnp = {figH, 'Units','pixels', 'BorderType','none', 'Title',''};
%
pAxH(7) = axes('Parent',uipanel(pnp{:}), axp{:}, 'UserData',3);
pAxS(7) = struct('title','Truncated RGB Color Cube', 'fun',@fTruncRGB,...
	'isn','', 'X','b', 'Y','a', 'Z','L');
%
pAxH(6) = axes('Parent',uipanel(pnp{:}), axp{:}, 'UserData',3);
pAxS(6) = struct('title','Colors with Sort Path', 'fun',@fSortPath,...
	'isn','', 'X','b', 'Y','a', 'Z','L');

pAxH(5) = axes('Parent',uipanel(pnp{:}), axp{:}, 'UserData',3);
pAxS(5) = struct('title','Colors with RGB Cube', 'fun',@fCubeRGB,...
	'isn','', 'X','b', 'Y','a', 'Z','L');
%
pAxH(4) = axes('Parent',uipanel(pnp{:}), axp{:});
pAxS(4) = struct('title','Adjacent Color Matrix', 'fun',@fAdjaNode,...
	'isn','XY', 'X',ndx, 'Y',ndx, 'Z','');
%
pAxH(3) = axes('Parent',uipanel(pnp{:}), axp{:}, 'XTick',[], 'YDir','reverse');
pAxS(3) = struct('title','Bands with Color Names', 'fun',@fBandName,...
	'isn','Y', 'X','', 'Y',ndx, 'Z','');
%
pAxH(2) = axes('Parent',uipanel(pnp{:}), axp{:}, 'UserData',3);
pAxS(2) = struct('title','Euclidean Distance (3D)', 'fun',@fEuclDist,...
	'isn','XY', 'X',ndx, 'Y',ndx, 'Z','Distance');
%
pAxH(1) = axes('Parent',uipanel(pnp{:}), axp{:}, 'UserData',2);
pAxS(1) = struct('title','Euclidean Distance (2D)', 'fun',@fEuclDist,...
	'isn','X',  'X',ndx, 'Y','Distance', 'Z','');
%
pPnH = get(pAxH,'Parent');
pPnH = [pPnH{:}];
%
for k = 1:numel(pAxH)
	xlabel(pAxH(k), pAxS(k).X)
	ylabel(pAxH(k), pAxS(k).Y)
	zlabel(pAxH(k), pAxS(k).Z)
	title( pAxH(k), pAxS(k).title)
	if isequal(get(pAxH(k),'UserData'),3)
		view(pAxH(k),3)
	end
end
%
%% Initialize GUI %%
%
arrayfun(@(s,a) s.fun(a), pAxS, pAxH)
set(pPnH(2:end), 'Visible','off', 'HitTest','off')
set(pPnH(1), 'Visible','on', 'HitTest','on')
set(mUiH(1), 'String',{pAxS.title})
set(figH, 'Pointer',figY, 'ResizeFcn',@fSizeObj)
fNumTick()
fSizeObj()
%
%% Main Plot Functions %%
%
	function fTruncRGB(axh) % Show the truncated RGB cube.
		delete(get(axh, 'Children'))
		[az,el] = view(axh);
		% Get boundary color nodes:
		R = size(UCS,1);
		B = 1e4; % max elements for ALPHASHAPE: more elements -> slower runtime.
		S = ceil(R/B);
		V = [];
		for idk = 1:S
			X = idk:S:R;
			try
				T = fGetBound(X);
			catch %#ok<CTCH>
				text(0.5,0.5,0.5,{'ALPHASHAPE not found','(requires R2014b or later)'},...
					'Parent',axh, 'HorizontalAlignment','center', 'FontWeight','bold')
				return
			end
			V = union(V,X(T(:)));
		end
		T = fGetBound(V);
		% Show truncated RGB cube:
		rgbX = pow2([opts.bitR,opts.bitG,opts.bitB])-1;
		patch('Faces',T, 'Vertices',UCS(V,[3,2,1]), 'Parent',axh,...
			'EdgeColor','none', 'FaceColor','interp',...
			'FaceVertexCData',bsxfun(@rdivide,double(RGB(V,:)),rgbX));
		% Show color nodes:
		hold(axh,'on')
		scatter3(ucs(:,3),ucs(:,2),ucs(:,1), 13, 'k', 'filled', 'Parent',axh)
		% Orient axes:
		axis(axh,'equal')
		view(axh,az,el)
		mat = fun([0,0,0;1,1,1]);
		set(axh, 'XGrid','on', 'YGrid','on', 'ZGrid','on',...
			'XLim',[-mxc,mxc], 'YLim',[-mxc,mxc], 'ZLim',[mat(1),mat(2)])
	end
	function T = fGetBound(X) % Get boundary of the node cloud.
		shp = alphaShape(UCS(X,[3,2,1]),Inf); % requires R2014b or later.
		shp.Alpha = shp.criticalAlpha('all-points');
		T = shp.boundaryFacets();
	end
%
	function fSortPath(axh) % Colors shown in UCS space, with path.
		delete(get(axh, 'Children'))
		[az,el] = view(axh);
		% Show color nodes:
		n2s = cellstr(strjust(num2str((1:N).'),'left'));
		scatter3(ucs(:,3),ucs(:,2),ucs(:,1), 256, rgbM, 'filled', 'Parent',axh)
		text(ucs(:,3),ucs(:,2),ucs(:,1),n2s, 'Parent',axh, 'HorizontalAlignment','center')
		hold(axh,'on')
		% Show path:
		ipc = strcmpi(opts.path,'closed');
		mat = ucs([1:N,1:+ipc],:);
		plot3(mat(:,3),mat(:,2),mat(:,1),'-k', 'Parent',axh)
		% Show distances:
		vec = sqrt(sum(diff(mat,1,1).^2,2));
		[mxv,mxi] = max(vec);
		[mnv,mni] = min(vec);
		mxp = mean(mat(mxi:mxi+1,:),1);
		mnp = mean(mat(mni:mni+1,:),1);
		text(mxp(3),mxp(2),mxp(1), sprintf('max:%.5g',mxv), 'Parent',axh)
		text(mnp(3),mnp(2),mnp(1), sprintf('min:%.5g',mnv), 'Parent',axh)
		% Orient axes:
		axis(axh,'equal')
		view(axh,az,el)
	end
%s
	function fCubeRGB(axh) % Colors shown in UCS space, with RGB cube.
		delete(get(axh, 'Children'))
		[az,el] = view(axh);
		% Show color nodes:
		scatter3(ucs(:,3),ucs(:,2),ucs(:,1), 256, rgbM, 'filled', 'Parent',axh)
		text(ucs(:,3),ucs(:,2),ucs(:,1),cellstr(num2str((1:N).')), 'Parent',axh, 'HorizontalAlignment','center')
		% Show outline of RGB cube:
		M = 23;
		[X,Y,Z] = ndgrid(linspace(0,1,M),0:1,0:1);
		mat = fun([X(:),Y(:),Z(:);Y(:),Z(:),X(:);Z(:),X(:),Y(:)]);
		X = reshape(mat(:,3),M,[]);
		Y = reshape(mat(:,2),M,[]);
		Z = reshape(mat(:,1),M,[]);
		line(X,Y,Z, 'Color','k', 'Parent',axh)
		% Orient axes:
		axis(axh,'equal')
		view(axh,az,el)
	end
%
	function fAdjaNode(axh) % Show matrix with all colors adjacent.
		delete(get(axh, 'Children'))
		[R,C] = ndgrid(0:N);
		V = (1:N*(N+1)).';
		V(N+1:N+1:end) = [];
		image('Parent',axh, 'CData',repmat(permute(rgbM,[1,3,2]),[1,N,1]));
		patch('Parent',axh, 'Faces',[V,V+N+1,V+N+2], 'Vertices',0.5+[R(:),C(:)],...
			'FaceColor','flat', 'FaceVertexCData',rgbM(mod(V,N+1),:), 'EdgeColor','none');
	end
%
	function fBandName(axh) % Show bands with colornames (if COLORNAMES is available).
		delete(get(axh, 'Children'))
		image(permute(rgbM,[1,3,2]), 'Parent',axh)
		try
			C = colornames('CSS',rgbM);
		catch %#ok<CTCH>
			C = repmat({'COLORNAMES not found: download FEX #48155'},1,N);
		end
		text(ones(1,N), 1:N, C, 'Parent',axh,...
			'HorizontalAlignment','center', 'BackgroundColor','white')
	end
%
	function fEuclDist(axh) % Show Euclidean distances (2D or 3D).
		delete(get(axh, 'Children'))
		aud = get(axh, 'UserData');
		sgc = {'Parent',axh, 'LineWidth',2.8, 'Marker','o'};
		vtd = Inf;
		for idk = 1:N
			dst = sqrt(sum(bsxfun(@minus,ucs,ucs(idk,:)).^2,2));
			vtd = min(vtd,min(dst([1:idk-1,idk+1:N])));
			switch aud
				case 2
					scatter(1:N, dst, 123, rgbM,...
						sgc{:}, 'MarkerFaceColor',rgbM(idk,:));
				case 3
					scatter3(idk*ones(1,N), 1:N, dst, 123, rgbM,...
						sgc{:}, 'MarkerFaceColor',rgbM(idk,:));
			end
			hold(axh,'on')
		end
		%
		if aud==2 && numel(vtd)
			text(N+0.5,vtd,sprintf(' %#.5g',vtd), 'Parent',axh)
		end
	end
%
%% Callback Functions %%
%
	function fUpDtMap(~,~) % Update colormap using options structure.
		% Generate colormap:
		set(figH, 'Pointer','watch')
		drawnow()
		[rgbM,ucs,err,RGB,UCS] = maxdistcolor(N,fun,opts);
		set(figH, 'Pointer',figY)
		% Update colorbar:
		set(bImH, 'CData',permute(rgbM,[1,3,2]))
		% Update main plots:
		arrayfun(@(s,h) s.fun(h), pAxS, pAxH)
	end
%
	function fNumEdit(obj,~) % Number edit box callback.
		str = get(obj, 'String');
		if all(isstrprop(str,'digit')) && sscanf(str,'%d')
			N = sscanf(str,'%d');
			set(nUiH, 'Value',nFun(N))
			fNumTick()
			fUpDtMap()
		else
			set(obj,'String',sprintf('%d',N))
		end
	end
	function fNumSlide(~,evt) % Number slider listener callback.
		try
			N = round(get(evt,'NewValue'));
		catch %#ok<CTCH>
			N = round(evt.AffectedObject.Value);
		end
		set(nVaH, 'String',sprintf('%d',N))
		fNumTick()
	end
	function fNumTick() % Number adjust limits and tickmarks.
		fPermSort()
		% Colorbar limits:
		set(bAxH, 'Ylim',[0,N]+0.5, 'YTick',1:N)
		% Table sizes:
		for idk = 1:tTxN
			new = get(tUiH(idk), 'Data');
			new(end+1:N,:) = NaN;
			new(N+1:end,:) = [];
			set(tUiH(idk), 'Data',new)
		end
		% Main plot axes limits:
		for idk = 1:numel(pAxH)
			for C = pAxS(idk).isn
				set(pAxH(idk), [C,'Lim'],[0,N]+0.5, [C,'Tick'],1:N);
			end
		end
	end
%
	function fOptEdit(obj,~,idk) % Options edit box callback.
		str = get(obj, 'String');
		new = str2double(str);
		if ~isreal(new) || (sInt(idk) && fix(new)~=new) || new<sRng(idk,1) || new>sRng(idk,2)
			new = NaN;
		end
		if isnan(new)
			set(obj, 'String',sStr(opts.(sTxt{idk})))
		else
			opts.(sTxt{idk}) = new;
			set(sUiH(idk), 'Value',new)
			fUpDtMap()
		end
	end
	function fOptSlide(~,evt,idk) % Options slider listener callback.
		try
			new = get(evt,'NewValue');
		catch %#ok<CTCH>
			new = evt.AffectedObject.Value;
		end
		if sInt(idk)
			new = round(new);
			set(sUiH(idk), 'Value',new)
		end
		opts.(sTxt{idk}) = new;
		set(sVaH(idk), 'String',sStr(new))
	end
%
	function fOptMenu(obj,~,idk) % Options menu callback.
		idv = get(obj,'Value');
		if idk>1
			opts.(mTxt{idk}) = mStr{idk}{idv};
			fUpDtMap()
		else
			set(pPnH,     'Visible','off', 'HitTest','off')
			set(pPnH(idv),'Visible','on',  'HitTest','on')
		end
	end
%
	function fCellEdit(obj,~,idk) % Options table cell callback.
		new = get(obj,'Data');
		isn = sum(isnan(new),2);
		idz = isn==0;
		if all(idz|(isn==3))
			new = new(idz,:);
			if get(tCbH(idk),'Value') % uint
				idb = strncmpi(sTxt,'bit',3);
				bit = get(sUiH(idb),'Value');
				pwr = pow2(max(3,ceil(log2(max([bit{:}])))));
				new = cast(new,sprintf('uint%d',pwr));
			end
			opts.(tTxt{idk}) = new;
			fUpDtMap()
		end
	end
	function fCheckBox(obj,~,idk) % Options table checkbox callback.
		old = get(tUiH(idk),'Data');
		idb = strncmpi(sTxt,'bit',3);
		ohm = get(sUiH(idb),'Value');
		ohm = pow2([ohm{:}])-1;
		if get(obj,'Value')
			% float->uint
			new = round(bsxfun(@times,old,ohm));
		else
			% uint->float
			new = bsxfun(@rdivide,old,ohm);
		end
		set(tUiH(idk),'Data',new);
	end
%
	function fPermSort() % No permutation sorting if N>9.
		ids = strcmpi('sort',mTxt);
		idn = get(mUiH(ids), 'Value');
		if N>9
			if idn > numel(mSrt{1})
				idn = 1;
			end
			opts.sort = mSrt{1}{idn};
			set(mUiH(ids), 'String',mSrt{1}, 'Value',idn)
		else
			set(mUiH(ids), 'String',mStr{ids})
		end
	end
%
	function fSizeObj(~,~) % Resize the figure contents.
		drawnow()
		try
			figP = get(figH, 'Position');
		catch %#ok<CTCH>
			return
		end
		% Ensure minimum figure size:
		adj = max(figP(3:4),[425,254]);
		pFg = [figP(1:2)+min(0,figP(3:4)-adj),adj];
		% Get object sizes:
		mUiX = cell2mat(get(mUiH, 'Extent'));
		sTxX = cell2mat(get(sTxH, 'Extent'));
		tCbX = cell2mat(get(tCbH, 'Extent'));
		tUiX = cell2mat(get(tUiH, 'Extent'));
		tTxX = cell2mat(get(tTxH, 'Extent'));
		% Group widths and heights:
		tWd = max(tUiX(:,3))+21; % table width
		bWd = 36; % colorbar axes width
		aWd = pFg(3)-tWd-bWd-gap*4; % main axes width
		mHt = max(mUiX(:,4)); % menu height
		% Menu UI positions:
		mUiP = mUiX;
		mUiP(:,1) = aWd+bWd+3*gap;
		mUiP(:,2) = gap+2*mHt*(mTxN-1:-1:0)+3;
		mUiP(:,3) = tWd;
		mUiP(:,4) = mHt;
		set(mUiH,{'Position'},num2cell(mUiP,2))
		% Menu text positions:
		mAxP = mUiP(end,:);
		mAxP(:,4) = 2*mTxN*mHt;
		set(mAxH,'Position',mAxP)
		% Horizontal slider text positions:
		sHt = (2*mTxN*mHt)/sTxN;
		sTxP = sTxX;
		sTxP(:,1) = gap;
		sTxP(:,2) = gap+sHt*(sTxN-1:-1:0);
		sTxP(:,3) = max(sTxX(:,3));
		sTxP(:,4) = sHt;
		set(sTxH,{'Position'},num2cell(sTxP,2))
		% Horizontal slider value positions:
		sVaP = sTxP;
		sVaP(:,1) = sum(sTxP(:,[1,3]),2);
		set(sVaH,{'Position'},num2cell(sVaP,2))
		% Horizontal slider UI positions:
		sUiP = sVaP;
		sUiP(:,1) = sum(sVaP(:,[1,3]),2);
		sUiP(:,3) = aWd-sTxP(:,3)-sVaP(:,3);
		set(sUiH,{'Position'},num2cell(sUiP,2))
		% Table UI positions:
		bHt = pFg(4)-2*mTxN*mHt-3*gap;
		tUiP = tUiX;
		tUiP(:,1) = aWd+bWd+3*gap;
		tUiP(:,2) = 2*mTxN*mHt+2*gap+[bHt/2;0];
		tUiP(:,3) = tWd;
		tUiP(:,4) = bHt/2;
		set(tUiH,{'Position'},num2cell(tUiP,2))
		% Table text positions:
		tTxP = tTxX;
		tTxP(:,1) = tUiP(:,1)+3;
		tTxP(:,2) = tUiP(:,2)+bHt/2-tTxX(:,4);
		tTxP(:,4) = tTxX(:,4)-3;
		set(tTxH,{'Position'},num2cell(tTxP,2))
		% Table checkbox UI positions:
		tCbP = tCbX(:,[1,2,4,4]);
		tCbP(:,1) = tUiP(:,1)+tUiP(:,3)-21;
		tCbP(:,2) = tUiP(:,2)+tUiP(:,4)-21;
		set(tCbH,{'Position'},num2cell(tCbP,2))
		% Colorbar axes position:
		bAxP = tUiP(end,:);
		bAxP(1) = aWd+gap*2;
		bAxP(3) = bWd;
		bAxP(4) = bHt;
		set(bAxH,'Position',bAxP)
		% Number slider UI position:
		nUiP = bAxP;
		nUiP(2) = gap;
		nUiP(4) = 2*mTxN*mHt-txh;
		set(nUiH,'Position',nUiP)
		% Number slider value position:
		nVaP = nUiP;
		nVaP(2) = gap+nUiP(4);
		nVaP(4) = txh;
		set(nVaH,'Position',nVaP)
		% Main plots uipanel position:
		pPnP = bAxP;
		pPnP(1) = gap;
		pPnP(3) = aWd;
		set(pPnH,'Position',pPnP)
	end
%
if nargout
	waitfor(figH)
	rgb = rgbM;
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%maxdistcolor_view