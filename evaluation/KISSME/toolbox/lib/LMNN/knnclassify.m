function [Eval,Details]=LSevaluate(L,xTr,lTr,xTe,lTe,KK);
% function [Eval,Details]=LSevaluate(L,xTr,yTr,xTe,yTe,Kg);
%
% INPUT:
%  L	:   transformation matrix (learned by LMNN)
%  xTr	:   training vectors (each column is an instance)
%  yTr	:   training labels  (row vector!!)
%  xTe  :   test vectors
%  yTe  :   test labels
%  Kg	:   number of nearest neighbors
%
% Good luck!
%
% copyright by Kilian Q. Weinberger, 2006
%  
% version 1.1  (04/13/07) 
% Little bugfix, couldn't handle single test vectors beforehand. 
% Thanks to Karim T. Abou-Moustafa for pointing it out to me. 
%

MM=min([lTr lTe]);
if(nargin<6)
 KK=1:2:3;
end;

if(length(KK)==1) outputK=ceil(KK/2);KK=1:2:KK;else outputK=1:length(KK);end;

Kn=max(KK);
D=length(L);

xTr=L*xTr(1:D,:);
xTe=L*xTe(1:D,:);
B=700;
[NTr]=size(xTr,2);
[NTe]=size(xTe,2);

Eval=zeros(2,length(KK));
lTr2=zeros(length(KK),NTr);
lTe2=zeros(length(KK),NTe);

iTr=zeros(Kn,NTr);
iTe=zeros(Kn,NTe);


sx1=sum(xTr.^2,1);
sx2=sum(xTe.^2,1);

for i=1:B:max(NTr,NTe)
  if(i<=NTr)
   BTr=min(B-1,NTr-i);  
   %Dtr=distance(xTr,xTr(:,i:i+BTr));
   Dtr=addh(addv(-2*xTr'*xTr(:,i:i+BTr),sx1),sx1(i:i+BTr));
%  [dist,nn]=sort(Dtr);
    [dist,nn]=mink(Dtr,Kn+1);
   nn=nn(2:Kn+1,:);
   lTr2(:,i:i+BTr)=LSKnn2(lTr(nn),KK,MM);
   iTr(:,i:i+BTr)=nn;
   Eval(1,:)=sum((lTr2(:,1:i+BTr)~=repmat(lTr(1:i+BTr),length(KK),1))',1)./(i+BTr);
  end;
  if(i<=NTe)
   BTe=min(B-1,NTe-i);  
   Dtr=addh(addv(-2*xTr'*xTe(:,i:i+BTe),sx1),sx2(i:i+BTe));
   [dist,nn]=mink(Dtr,Kn);
   lTe2(:,i:i+BTe)=LSKnn2(reshape(lTr(nn),max(KK),BTe+1),KK,MM);
   iTe(:,i:i+BTe)=nn;   
   Eval(2,:)=sum((lTe2(:,1:i+BTe)~=repmat(lTe(1:i+BTe),length(KK),1))',1)./(i+BTe);
  end;   
  fprintf('%2.2f%%.:\n',(i+BTr)/max(NTr,NTe)*100);
  disp(Eval.*100);
end;


Details.lTe2=lTe2;
Details.lTr2=lTr2;
Details.iTe=iTe;
Details.iTr=iTr;
Eval=Eval(:,outputK);


function yy=LSKnn2(Ni,KK,MM);
% function yy=LSKnn2(Ni,KK,MM);
%

if(nargin<2)
 KK=1:2:3;
end;

N=size(Ni,2);
Ni=Ni-MM+1;
classes=unique(unique(Ni))';

%yy=zeros(1,size(Ni,2));
%for i=1:size(Ni,2)
%  n=zeros(max(un),1);
%  for j=1:size(Ni,1)  
%     n(Ni(j,i))=n(Ni(j,i))+1;  
%  end;
%  [temp,yy(i)]=max(n);
%end;



T=zeros(length(classes),N,length(KK));


for i=1:length(classes)
c=classes(i);  
 for k=KK
%  NNi=Ni(1:k,:)==c;
%  NNi=NNi+(Ni(1,:)==c).*0.01;% give first neighbor tiny advantage
try
  T(i,:,k)=sum(Ni(1:k,:)==c,1);
catch
keyboard;
end;
 end;
end;

yy=zeros(max(KK),N);
for k=KK
 [temp,yy(k,1:N)]=max(T(:,:,k)+T(:,:,1).*0.01);
 yy(k,1:N)=classes(yy(k,:));
end;
yy=yy(KK,:);

yy=yy+MM-1;

