clear
clc

%% Input
% input A b c should be SLP
% A = [3 2 0; 1 4 0; 2 3 1];
% b = [10; 11; 13];
% c = [-4 -5 -1];
A=[-3,-1;-1,-4];
b=[-15;-10];
c=[1,1];


%% 单纯形表初始化
%构造初始单纯形表
[m, n] = size(A);
% 列名
name = cell(1,n+m+1);
name{1}='base';
for i = 1:m+n
    eval(['name{',num2str(i+1),'}=''x_',num2str(i),''';'])
end
% 行名
rname=cell(m+1,1);
rname{1}='object';
for i = 1:m
    eval(['rname{',num2str(i+1),'}=''x_',num2str(n+i),''';'])
end
T = array2table([0,c,zeros(1,m) ;b,A, eye(m)],'VariableNames',name,'RowNames',rname);

disp('初始单纯形表为：')
disp(T);

base=n+1:m+n;

%% 对偶单纯形法
if ~isempty(find(b<0, 1))
    disp('存在relative cost负，使用对偶单纯形法')
    for i =1:100
        count=0;
     for j = 2:m+1
         if table2array(T(j,1))>=0
             count = count +1;
         end
     end
     if count == m
         disp('所有relative cost均非负，结束迭代')
         break
     end
     
     disp('选择任一小于0 xk0')
     for j = 2:m+1
         if table2array(T(j,1))<0
             baseout = j;
             break
         end
     end
     disp(['选择出基',T.Properties.RowNames{baseout}])

     hasNum=false;
     for j = 2:m+n+1
         if ~hasNum
             choose = j;
             num = table2array(T(1,j))/table2array(T(baseout,j));
             if ~isnan(num)
                 hasNum=true;
             end
             continue
         end
         if table2array(T(baseout,j))>=0
             continue
         end
         if table2array(T(1,j))/table2array(T(baseout,j))>num
             choose = j;
             num = table2array(T(1,j))/table2array(T(baseout,j));
         end
     end
     basein=choose;
     disp(['选择入基',T.Properties.VariableNames{basein}])
     
     inName=T.Properties.VariableNames{basein};
     outName=T.Properties.RowNames{baseout};
     
     rname=T.Properties.RowNames;
     rname{baseout}=inName;
     T.Properties.RowNames=rname;
     
     disp(['选择的枢轴点为(',num2str(baseout-1),',',num2str(basein-1),')'])
     base(baseout-1)=basein-1;
     
     disp('更新的单纯形表为：')
     
     T(baseout,:)=array2table(table2array(T(baseout,:))/table2array(T(baseout,basein)));
     for j = 1:m+1
         if j == baseout
             continue
         end
         if table2array(T(j,basein))==0
             continue
         end
         T(j,:) = array2table((table2array(T(j,:)) - table2array(T(baseout,:)) * (table2array(T(j,basein)) / table2array(T(baseout,basein)))));
     end
     disp(T)
     
     disp('本次迭代得到的解为：')
     for j = 1:m+n
         if find(base==j,1)
             fprintf(['x_',num2str(j),'=',num2str(table2array(T(find(base==j,1)+1,1))),'   '])
         else
             fprintf(['x_',num2str(j),'=0   '])
         end
     end
     fprintf('\n')
         
     disp('本次迭代已完成')
     disp('--------------------------')
     fprintf('\n\n')
     
    end
    
    %% 单纯形法
else
    disp('所有relative cost为负数，使用单纯形法')
for i=1:100
     count=0;
     for j = 2:m+n+1
         if table2array(T(1,j))>=0
             count = count +1;
         end
     end
     if count == m+n
         disp('所有relative cost均非负，结束迭代')
         break
     end
     
     disp(['进入迭代',num2str(i)])
     
     disp('当前的基为:')
     disp(base);
     
    
     
     disp('选择任一负relative cost:')
     for j = 2:m+n+1
         if table2array(T(1,j))<0
             basein = j;
             disp(['基',T.Properties.VariableNames{j},'的值为',num2str(table2array(T(1,j)))])
             disp(['选择入基',T.Properties.VariableNames{j}]);
             break
         end
     end
     
     disp('选择出基变量:')
     hasNum=false;
     for j = 2:m+1
         disp(['基变量',T.Properties.RowNames{j},'的θ值为:',num2str( table2array(T(j,1))/table2array(T(j,basein)))])
         if ~hasNum
             choose = 2;
             num = table2array(T(j,1))/table2array(T(j,basein));
             if ~isnan(num)
                 hasNum=true;
             end
             continue
         end
         
         if table2array(T(j,1))/table2array(T(j,basein))<num
             choose = j;
             num = table2array(T(j,basein))/table2array(T(j,1));
         end
     end
     disp(['选择θ最小的基',T.Properties.RowNames{choose},'作为出基变量'])
     baseout=choose;
     
     inName=T.Properties.VariableNames{basein};
     outName=T.Properties.RowNames{baseout};
     
     rname=T.Properties.RowNames;
     rname{baseout}=inName;
     T.Properties.RowNames=rname;
     
     disp(['选择的枢轴点为(',num2str(baseout-1),',',num2str(basein-1),')'])
     base(baseout-1)=basein-1;

     disp('更新的单纯形表为：')
%      NEW=zeros(m+1,m+n+1);
%      OLD=table2array(T);
%      for j = 1:m+1
%          for k = 1:m+n+1
%              if j~=baseout
%                  NEW(j,k)=(OLD(j,k)*OLD(baseout,basein)-OLD(j,basein)*OLD(baseout,k))/OLD(baseout,basein);
%              else
%                  NEW(baseout,k)=OLD(baseout,k)/OLD(baseout,basein);
%              end
%          end
%      end
%      T(:,:)=array2table(NEW);
     
     
     T(baseout,:)=array2table(table2array(T(baseout,:))/table2array(T(baseout,basein)));
     for j = 1:m+1
         if j == baseout
             continue
         end
         if table2array(T(j,basein))==0
             continue
         end
         T(j,:) = array2table((table2array(T(j,:)) - table2array(T(baseout,:)) * (table2array(T(j,basein)) / table2array(T(baseout,basein)))));
     end
     disp(T)
     
     disp('本次迭代得到的解为：')
     for j = 1:m+n
         if find(base==j,1)
             fprintf(['x_',num2str(j),'=',num2str(table2array(T(find(base==j,1)+1,1))),'   '])
         else
             fprintf(['x_',num2str(j),'=0   '])
         end
     end
     fprintf('\n')
         
     disp('本次迭代已完成')
     disp('--------------------------')
     fprintf('\n\n')
         
         
     
    
end
end
