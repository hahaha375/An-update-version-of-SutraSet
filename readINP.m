function [o2]=readINP(varargin)
% This file was created to read the SUTRA input data set
% Especially for Data set 22, because it records the mesh structure
% (In Chinese UTF-8)
% 这个脚本用于读取SUTRA的input file，主要目的是为了获取data set 22的数据
% 因为data set 22中记录了网格的structure
% Liu Yuxuan 2023

  %% a string storing the caller functions
  caller = dbstack('-completenames'); caller = caller.name;

  o2.varargin       = varargin;
  [fileIDame, varargin] = getNext(varargin,'char','');
  % an option to see whether use inp contents to guide the reading process
  %   a hard reading process will be conducted if left empty
  [output_no,  varargin]   = getProp(varargin,'outputnumber',0);
  [output_from,  varargin] = getProp(varargin,'outputfrom',1);
  [inpObj,  varargin]      = getProp(varargin,'inpObj',[]);
  o2.output_no             = output_no;
  fileID                       = fopen([fileIDame,'.inp']);

  if fileID==-1 
    fprintf(1,'%s : Trying to open %s .inp\n',caller,fileIDame);
    fileID=fopen([fileIDame,'.inp']);
    if fileID==-1
      fprintf('%s: file nod found!!\n',caller,fileIDame);
      o=-1;o2=-1;
      return
    end
  end

  nextline = fgetl(fileID);

% find Data set 2B
while ischar(nextline)
    if contains(nextline, '# Data set 2B','IgnoreCase',true)
        break
    end
    nextline = fgetl(fileID);
end
o2.meshtype = textscan(fileID, '%s %s', 1); % read the next line

% find Data set 3
while ischar(nextline)
    if contains(nextline, '# Data set 3','IgnoreCase',true)
        break
    end
    nextline = fgetl(fileID);
end
minformation = textscan(fileID, '%d %d %d %d %d %d %d', 1); % read the next line
nextline = fgetl(fileID);
o2.nn = minformation{1,1};
o2.ne = minformation{1,2};
o2.np = minformation{1,3};
o2.nc = minformation{1,4};
o2.nf = minformation{1,5};
o2.ns = minformation{1,6};
o2.no = minformation{1,7};
% % find the bottom of the text file
% fseek(fileID, 0, 'eof');
% pos = ftell(fileID)-3; % read the last byte of the file (the last line is empty)
% % fine the begining of the last line
% while pos > 0
%     fseek(fileID, pos, 'bof');  % move the pointer to the position
%     ch = fread(fileID, 1, 'uchar');  % read an character
%     if ch == 10  % read the '\n' character
%         pos = pos+1; % fine the begining of the last line
%         break;  
%     end
%     pos = pos - 1;  % move one character forward
% end
% fseek(fileID, pos, 'bof'); % move to the begining of the last line
% linesize = numel(fgetl(fileID)); % move and get oneline size
% % move to the begining of data set 22
% % Be cautious here, as in the Windows system, the newline character is '\r\n' 
% % and occupies two characters. However, when reading a line of data, the 
% % space occupied by the newline character is ignored, so we need to account
% % for it by adding +2. 
% % Additionally, the current pointer is positioned at the beginning of the 
% % last line in the file, so we need to subtract the count of one unit
% fseek(fileID, pos-(linesize+2)*(o2.ne-1), 'bof');
% 
% % scan data set 22
% if o2.meshtype{1} == "'2D"
% lseif o2.meshtype{1} == "'3D"
%     o2.ds22 = textscan(fileID, '%d %d %d %d %d %d %d %d %d', o2.ne);
% else
%     error('Data type error\n')
% end    o2.ds22 = textscan(fileID, '%d %d %d %d %d', o2.ne);
% e

% find data set 14B and jump
while ischar(nextline)
    if contains(nextline, '# Data set 14B','IgnoreCase',true)
        break
    end
    nextline = fgetl(fileID);
end
% for iter = 1:o2.nn
%     fgetl(fileID);
% end
textscan(fileID, '%d %d %f %f %f %f', o2.nn);
fprintf('Jumping Data Set 14B\n')

% find data set 15B and jump
while ischar(nextline)
    if contains(nextline, '# Data set 15B','IgnoreCase',true)
        break
    end
    nextline = fgetl(fileID);
end
% for iter = 1:o2.ne
%     fgetl(fileID);
% end
if o2.meshtype{1} == "'2D"
    textscan(fileID, '%d %d %f %f %f %f %f %f %f', o2.ne);
elseif o2.meshtype{1} == "'3D"
    textscan(fileID, '%d %d %f %f %f %f %f %f %f %f %f %f', o2.ne);
end  
fprintf('Jumping Data Set 15B\n')

% find data set 17 and jump
while ischar(nextline)
    if contains(nextline, '# Data set 17','IgnoreCase',true)
        break
    end
    nextline = fgetl(fileID);
end
% for iter = 1:o2.nc
%     fgetl(fileID);
% end
textscan(fileID, '%d %f %f', o2.nc);
fprintf('Jumping Data Set 17\n')

% find data set 19 and jump
while ischar(nextline)
    if contains(nextline, '# Data set 19','IgnoreCase',true)
        break
    end
    nextline = fgetl(fileID);
end
% for iter = 1:o2.np
%     fgetl(fileID);
% end
textscan(fileID, '%d %f %f', o2.np);
fprintf('Jumping Data Set 19B\n')

% find data set 22 and read
while ischar(nextline)
    if contains(nextline, '# Data set 22','IgnoreCase',true)
        break
    end
    nextline = fgetl(fileID);
end
nextline = fgetl(fileID);
% scan data set 22
if o2.meshtype{1} == "'2D"
    o2.ds22 = textscan(fileID, '%d %d %d %d %d', o2.ne);
elseif o2.meshtype{1} == "'3D"
    o2.ds22 = textscan(fileID, '%d %d %d %d %d %d %d %d %d', o2.ne);
else
    error('Data type error\n')
end    


% Check the data
if max(o2.ds22{1,1}) == o2.ne
    fprintf('Successfully read .inp file\n')
else
    error('Some error occured, plese check the data or contact the author\n')
end
fclose all;
end