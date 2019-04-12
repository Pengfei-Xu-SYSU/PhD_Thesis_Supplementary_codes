clear 
clc
%% 
%% �оٳ����������У�
t1 = 0.475;
g1 = 0.475;
t2 = 0.475;
g2 = 0.475;
t3 = 0.475;
g3 = 0.475;
t4 = 0.475;
g4 = 0.475;
t5 = 0.475;
g5 = 0.475;
t6 = 0.475;
g6 = 0.475;
t7 = 0.475;
g7 = 0.475;
t8 = 0.475;
g8 = 0.475;
t9 = 0.475;
g9 = 0.475;
t10 = 0.475;
g10 = 0.475;
t11 = 0.475;
g11 = 0.475;
t12 = 0.475;
g12 = 0.475;
t13 = 0.475;
h_sio = 1.6;


parameters = [  ...
    t1 g1 t2 g2 t3  g3  t4  g4  t5  g5  t6 g6 t7 g7 ...
    t8 g8 t9 g9 t10 g10 t11 g11 t12 g12 t13 ...
    h_sio];
parametersname = {    ...
    't1' 'g1' 't2' 'g2' 't3'  'g3'  't4'  'g4'  't5'  'g5' 't6' 'g6' 't7' 'g7'...
    't8' 'g8' 't9' 'g9' 't10' 'g10' 't11' 'g11' 't12' 'g12' 't13' ...
    'h_sio' }; % �����������գ�������ֶ�Ӧ���ϵ����
%strjoin



%% ��һ���������ʼ�Ļ���Ч�ʡ�
     period = 1;
     wl =1.550;
     
     model = mphopen('erwei_grating_coupler_.mph');
     model.param.set('lambda0', [num2str(wl) '[um]']);   %���벨��
     for i = 1 : size(parameters,2)  % ����ѭ�����������й�ʽ
        model.param.set(strjoin(parametersname(i)), [num2str(parameters(i)) '[um]']); 
     end
     model.study('std1').run;    
     
% ����Ĺ⹦�ʣ����ں�����Ч�ʼ��㣩
     in = mphglobal(model,'Powerin'); 
% �������� S11 ������ͨ������S31������ʾ��
     R = mphglobal(model,'abs(ewfd.S11)^2'); %���ŷ�������S11������׼ȷ����������Ĺ���
     T = mphglobal(model,'abs(ewfd.S31)^2'); %ͬ������S31���������������ڲ����й�Ĺ���
% ���Ϸ���Ĺ���
     up = mphglobal(model,'Powerup');
% ���     
     Efield = mphinterp(model,'ewfd.Ez','dataset','cln1');      
     
     angle = 8;
     overlapp = [];
     for ang = 1:size(angle,2)
      align = - period *((1:100)/5);    
      %align = align(Position);
     for i = 1: size(align,2)
         z = linspace(-10,30,size(Efield,2));
         for j = 1: size(z,2);
             Efib(j) = exp(-(((align(i)+z(j))/5.2).^2))*exp(1i*1.46*2*pi/wl*sind(angle(ang))*z(j));  % ���
         end 
        overlap(i) =   (abs(sum (conj(Efield).*Efib)))^2 ./ (sum(abs(Efield).^2)) / sum(abs(Efib).^2) ;        
     end
       overlapp = [overlapp ; overlap];
end   
     
     
      efficiency = [max(overlap)*up];   
      fprintf('��ʼЧ�� %d\n',efficiency)%��ʾ��ǰЧ��
     
     Position = find(overlap==max(overlap));
     
    
%% �����������Ŵ��㷨���㡣
flag = true;
while (flag)
     flag = false; % ����flag������
     for i = 1 : size(parameters,2)-1;
         temp = parameters;  % ������ʱ�������ڼ���
         for temp2 = [ temp(i)-0.005 , temp(i)+0.005 ]; 
             temp(i) = temp2;
             
             
             %��i������΢��10nm                      
             model = mphopen('erwei_grating_coupler_.mph');
             model.param.set('lambda0', [num2str(wl) '[um]']);   %���벨��
               for j = 1 : size(parameters,2)  % ����ѭ�����������й�ʽ
                   model.param.set(strjoin(parametersname(j)), [num2str(temp(j)) '[um]']);  
               end 
             model.study('std1').run;
             up = mphglobal(model,'Powerup');
             Efield = mphinterp(model,'ewfd.Ez','dataset','cln1');         
             align = - period *((1:100)/5);    
             overlap = [];
             for k = 1: size(align,2)
                 z = linspace(-10,30,size(Efield,2));
                 Efib= [];
                 for p = 1: size(z,2);
                     Efib(p) = exp(-(((align(k)+z(p))/5.2).^2))*exp(1i*1.46*2*pi/wl*sind(8)*z(p));  % ���
                 end 
                 overlap(k) =   (abs(sum (conj(Efield).*Efib)))^2 ./ (sum(abs(Efield).^2)) / sum(abs(Efib).^2) ;        
             end
             efftemp = max(overlap)*up; %��ʱ����Ч��
             
             if efftemp > efficiency  
                 %���Ч��������
                efficiency = efftemp; %����Ч��
                parameters = temp; %��������
                fprintf(' %d\n',efficiency)%��ʾ��ǰЧ��
                flag = true; %��flag          
             end 
         end
     end
end