classdef SutraLab
   methods(Static)
       
       %*********************** Function readETdat ************************
       function [tide]=readETinp(fname)
           fn=fopen(fname);
           for i=1:48
             line=fgetl(fn);
           end % i
           temp=fscanf(fn,'%g %g %g %g %g %*g %*g',[1 5]);
           line=fgetl(fn); % Reand the line again to proceed to the next line
           tide.tasp=temp(1,1);
           tide.tane=temp(1,2);
           tide.tpsp=temp(1,3);
           tide.tpne=temp(1,4);
           tide.msl=temp(1,5);
           fclose(fn);
       end % Function readETinp
       %****************************** END ********************************
       
       
       %*********************** Function readETdat ************************
       function nrow=linecount(fname)
           fn=fopen(fname);
           nrow=0;
           tline=fgetl(fn);
           while ischar(tline)
               tline=fgetl(fn);
               nrow=nrow+1;
           end % while
           fclose(fn);
       end % Function linecount
       %****************************** END ********************************
       
       
       %*********************** Function readinp **************************
       function [inp,f1,f2,f3,f4,f5]=readinp(fname)
          fn=fopen(fname);
       
            for i=1:5
                line=fgetl(fn);
            end
            f1=fscanf(fn,'%*s %*s %*s %g %g',[1 2]); % Dataset 2B
            inp.nnv=f1(1);  % Number of nodes along x-direction
            inp.nnh=f1(2);  % Number of nodes along y-direction
            inp.nev=f1(1)-1;   % Number of elements along x-direction
            inp.neh=f1(2)-1;   % Number of elements along y-direction
            inp.nn=f1(1)*f1(2); % Number of nodes
            inp.ne=(f1(1)-1)*(f1(2)-1); % Number of elements
            line=fgetl(fn); % Reand the line of Dataset 2B again to proceed to the next line
            
            for i=1:10
                line=fgetl(fn);
            end
            f2=fscanf(fn,'%*s %*s %*s %*s %g %g %g %g %g %g %g %g %g',[1 9]); % Dataset 6B
            itmax=f2(2);  % Total numner of time steps
            line=fgetl(fn); % Reand the line of Dataset 6B again to proceed to the next line
           
            for i=1:9
                line=fgetl(fn);
            end
            f3=fscanf(fn,'%f %*s %*s %*s %*s %*s',[1 1]);  % Dataset 8B
            line=fgetl(fn); % Reand the line of Dataset 8B again to proceed to the next line
            if mod(itmax,f3(1))==0  % Calculate the number of output in .NOD file
                if(f3(1)<0)
                    if abs(f3(1))==1
                    inp.nno=(itmax-mod(itmax,abs(f3(1))))/abs(f3(1)); % Number of output in .NOD file
                    else
                    inp.nno=(itmax-mod(itmax,abs(f3(1))))/abs(f3(1))+1; % Number of output in .NOD file
                    end
                else
                    if f3(1)==1
                    inp.nno=(itmax-mod(itmax,f3(1)))/f3(1)+1; % Number of output in .NOD file
                    else
                    inp.nno=(itmax-mod(itmax,f3(1)))/f3(1)+2; %
                    end
                end % if
            else
                if(f3(1)<0)
                    inp.nno=(itmax-mod(itmax,abs(f3(1))))/abs(f3(1))+2; % Number of output in .NOD file
                else
                    inp.nno=(itmax-mod(itmax,f3(1)))/f3(1)+3; % Number of output in .NOD file
                end % if
            end % if
            f4=fscanf(fn,'%f %*s %*s %*s %*s',[1 1]);  % Dataset 8C
            line=fgetl(fn); % Reand the line of Dataset 8C again to proceed to the next line
            if mod(itmax,f4(1))==0  % Calculate the number of output in .NOD file
                inp.neo=(itmax-mod(itmax,f4(1)))/f4(1)+1; % Number of output in .ELE file
            else
                inp.neo=(itmax-mod(itmax,f4(1)))/f4(1)+2; % Number of output in .ELE file
            end % if
            
            %line2=fgetl(fn);
            line4=SutraLab.readnext(fn,'#') ;
            f5=cell2mat(textscan(line4,'%f %f %f %f %*s',[1 4]));  % Dataset 8C
            if mod(itmax,f5(1))==0  % Calculate the number of output in .BCOF file
              if f5(1)==1 % a conditioner to resolve nonconsistency when nbcfpr==1 
	       inp.nbcof=(itmax-mod(itmax,f5(1)))/f5(1)+0; % Number of output in .BCOF file
              else
	       inp.nbcof=(itmax-mod(itmax,f5(1)))/f5(1)+1; % Number of output in .BCOF file
	      end
            else
                inp.nbcof=(itmax-mod(itmax,f5(1)))/f5(1)+2; % Number of output in .BCOF file
            end % if
            
            if mod(itmax,f5(3))==0  % Calculate the number of output in .BCOP file
	      if f5(3)==1
                inp.nbcop=(itmax-mod(itmax,f5(3)))/f5(3)+0; % Number of output in .BCOP file
	      else
                inp.nbcop=(itmax-mod(itmax,f5(3)))/f5(3)+1; % Number of output in .BCOP file
              end
            else
                inp.nbcop=(itmax-mod(itmax,f5(3)))/f5(3)+2; % Number of output in .BCOP file
            end % if
                        
            fclose(fn);
       end % Function readinp
       %****************************** END ********************************
       
       
       %*********************** Function readnod **************************
       function [a ta a1]=readnod(fname,inp,tide,outnod)
            fn=fopen(fname);
            
            for i=1:12 % Reading the first 12 rows' heading
               line=fgetl(fn);
            end
               temp=fscanf(fn,'%*s %g %g %*s %*g %*s %*g %*s %*g',[2 inp.nno]); % Time steps (1st row) and Time (sec) (2nd row)
               if inp.nno==inp.neo
                 ta(1:2,:)=temp(1:2,2:inp.nno);
                 ta(2,:)=ta(2,:)/24/3600; % Change time from seconds to day
               else
                 ta(1:2,:)=temp(1:2,3:inp.nno);
                 ta(2,:)=ta(2,:)/24/3600; % Change time from seconds to day
               end % if
               line=fgetl(fn); % Read the line again to proceed to the next line
            
            for j=1:outnod
              for i=1:5  % Read the first five rows of each out
                line=fgetl(fn);
              end % i
           
            if inp.nno==inp.neo
              if j==1  % Jump over the first round of output
                for m=1:inp.nn
                   line=fgetl(fn);
                end
              else
                  a(j-1).label={'x','y','p','c','s'};
                  a1(:,:,j-1)=fscanf(fn,'%g %g %g %g %g',[5 inp.nn]);
                  line=fgetl(fn);   % If the last column is not captured, it requires to use the previous line
                  for k=1:5
                    a(j-1).terms{k}=a1(k,:,j-1);
                  end % for
              a(j-1).TsNumber=ta(1,j-1);  % Time steps
		      a(j-1).RealTDays=ta(2,j-1); % Time (day)
              a(j-1).TDlevel=tide.msl+tide.tasp*sin(2*pi*ta(2,j-1)*86400/tide.tpsp)+ ...
                                       tide.tane*sin(2*pi*ta(2,j-1)*86400/tide.tpne);  % Calculate tidal level
              end % if
            else
              if j<=2  % Jump over the first round of output
                for m=1:inp.nn
                   line=fgetl(fn);
                end
              else
                  a(j-2).label={'x','y','p','c','s'};
                  a1(:,:,j-2)=fscanf(fn,'%g %g %g %g %g',[5 inp.nn]);
                  line=fgetl(fn);   % If the last column is not captured, it requires to use the previous line
                  for k=1:5
                    a(j-2).terms{k}=a1(k,:,j-2);
                  end % for
              a(j-2).TsNumber=ta(1,j-2);  % Time steps
		      a(j-2).RealTDays=ta(2,j-2); % Time (day)
              a(j-2).TDlevel=tide.msl+tide.tasp*sin(2*pi*ta(2,j-2)*86400/tide.tpsp)+ ...
                                       tide.tane*sin(2*pi*ta(2,j-2)*86400/tide.tpne);  % Calculate tidal level
              end % if
            end %if
            end % j
            fclose(fn);
	   end % Funtion readnod
       %****************************** END ********************************
       
       
       %*********************** Function readele **************************
       function [b b1]=readele(fname,inp,outele)
           fn=fopen(fname);
           for i=1:12 % Reading the first 12 rows' heading
              line=fgetl(fn);
           end
              temp=fscanf(fn,'%*s %g %g %*s %*g %*s %*g %*s %*g',[2 inp.neo]); % Time steps (1st row) and Time (sec) (2nd row)
              line=fgetl(fn); % Read the line again to proceed to the next line
          
           for j=1:outele
              for i=1:5  % Read the first five rows of each out 
                line=fgetl(fn);
              end % i
         
              if j==1  % Jump over the first round of output
                for m=1:inp.ne
                   line=fgetl(fn);
                end
              else
                  b(j-1).label={'xe','ye','vx','vy'};
                  b1(:,:,j-1)=fscanf(fn,'%g %g %g %g',[4 inp.ne]);
                  line=fgetl(fn);   % If the last column is not captured, it requires to use the previous line
                  for k=1:4
                    b(j-1).terms{k}=b1(k,:,j-1);
                  end % for
              end % if
            end % j
            fclose(fn);     
       end % Function readele
       %****************************** END ********************************
       
       
	   %*********************** Function readseep *************************
       function [seep]=readseep(fname,outele,f4)
          fn=fopen(fname);
          line=fgetl(fn); % Jump over the first time step's output
          for j=1:outele-1
            for i=1:f4(1)-1
              line=fgetl(fn);
            end
              seep(:,:,j)=fscanf(fn,'%g %*g %g %g',[3 1]);
              line=fgetl(fn);
          end % for
          fclose(fn);
       end % Function readseep
       %****************************** END ********************************
	   
	   
       %*********************** Function readbcof *************************
       function [bcof,bcof1]=readbcof(fname,inp)
           fn=fopen(fname);
           for i=1:12 % Reading the first 12 rows' heading
              line=fgetl(fn);
           end
              temp=fscanf(fn,'%*s %g %g',[2 inp.nbcof]);
              line=fgetl(fn);
              
           for j=1:100 % Should be inp.nbcof
               for i=1:7
                  line=fgetl(fn);
               end
               
               if j==1  % Jump over the first round of output
                 for m=1:inp.nnh
                   line=fgetl(fn);
                 end
               else
                 bcof(j-1).label={'FluidSource','Conc','Rconc'};
                 bcof1(:,:,j-1)=fscanf(fn,'%*g %*s %*s %g %g %g',[3 inp.nnh]);
                 line=fgetl(fn);
                 for k=1:3
                   bcof(j-1).terms{k}=bcof1(k,:,j-1);
                 end
               end % if
           end % for
           fclose(fn);
       end % Function readbcof
       %****************************** END ********************************
       
       
       %*********************** Function readbcop *************************
       function [bcop,bcop1]=readbcop(fname,inp)
           fn=fopen(fname);
           for i=1:12 % Reading the first 12 rows' heading
              line=fgetl(fn);
           end
              temp=fscanf(fn,'%*s %g %g',[2 inp.nbcop]);
              line=fgetl(fn);
              
           for j=1:100 % Should be inp.nbcop
               for i=1:7
                  line=fgetl(fn);
               end
               
               if j==1  % Jump over the first round of output
                 for m=1:inp.nnh
                   line=fgetl(fn);
                 end
               else
                 bcop(j-1).label={'RSFluid','SoluteC','RSSolute'};
                 bcop1(:,:,j-1)=fscanf(fn,'%*g %*s %*s %g %g %g %*g %*g',[3 inp.nnh]);
                 line=fgetl(fn);
                 for k=1:3
                   bcop(j-1).terms{k}=bcop1(k,:,j-1);
                 end
               end % if
           end % for
           fclose(fn);
       end % Function readbcop
       %****************************** END ********************************
       

       
       
       
        function line=readnext(fn,keywords)
        % line=readnext(fn,keywords)
	% read next line that is not started from '#'
	% fn  -- file handle
	% keywords -- should be hatch
             line=fgetl(fn);
             while  line(1)=='#'
               line=fgetl(fn);
             end
	end % function
   end % methods 
end % classdef
