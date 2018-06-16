% 保护算法
function [flag,info] = test_fault(fault_t, Ip, In, Vp, Vn)

%构造时间窗
t_begin = fault_t - 300;
t_end = fault_t + 699;

% 计算故障分量
fault_Ip = Ip(t_begin:t_end) - Ip(t_begin-1000:t_end-1000);
fault_In = In(t_begin:t_end) - In(t_begin-1000:t_end-1000);
fault_Vp = Vp(t_begin:t_end) - Vp(t_begin-1000:t_end-1000);
fault_Vn = Vn(t_begin:t_end) - Vn(t_begin-1000:t_end-1000);

% 加入噪声
fault_Ip = awgn(fault_Ip,20,'measured');
fault_In = awgn(fault_In,20,'measured');
fault_Vp = awgn(fault_Vp,20,'measured');
fault_Vn = awgn(fault_Vn,20,'measured');

% 模量变换
I1 = fault_Ip - fault_In;
I0 = fault_Ip + fault_In;
V1 = fault_Vp - fault_Vn;
V0 = fault_Vp + fault_Vn;

% 求反行波
Vb1 = (V1 - I1 * 260) / 2;
Vb0 = (V0 - I0 * 380) / 2;

% 小波变换
scale = 5;
[SWD1, SWA1] = wvt(Vb1, scale);
[SWD0, SWA0] = wvt(Vb0, scale);

% 模极大值比较，消噪
for i = 1:scale
    mid = zeros(1,1000);
    for j = 2 : 999
        if abs(SWD1(i+1,j)) > abs(SWD1(i+1,j-1)) && abs(SWD1(i+1,j)) > abs(SWD1(i+1,j+1))
            mid(j) = 1;
        end
    end
    if i == 1
        Mid1 = mid;
    else
        for k = -4:4
            Mid1 = Mid1 | circshift(Mid1',k)';
        end
        Mid1 = mid & Mid1;
    end
end

for i = 1:1000
    if Mid1(i) && testnoise(SWD1, i, scale)
        Mid1(i) = 0;
    end
end

Mid0 = ones(1,1000);
for i = 1:scale
    mid = zeros(1,1000);
    for j = 2 : 999
        if abs(SWD0(i+1,j)) > abs(SWD0(i+1,j-1)) && abs(SWD0(i+1,j)) > abs(SWD0(i+1,j+1))
            mid(j) = 1;
        end
    end
    if i == 1
        Mid0 = mid;
    else
        for k = -4:4
            Mid0 = Mid0 | circshift(Mid0',k)';
        end
        Mid0 = mid & Mid0;
    end
end

for i = 1:1000
    if Mid0(i) && testnoise(SWD0, i, scale)
        Mid0(i) = 0;
    end
end

% 雷击识别
thunder_detect1 = abs(sum(Vb1(300:650))) / abs(sum(Vb1(651:1000)));
thunder_detect2 = abs(sum(Vb0(300:650))) / abs(sum(Vb0(651:1000)));

% 故障检测
threshold1 = 500;
threshold0 = 100;

for i = 1:1000
    if Mid1(i) == 1 && abs(SWD1(scale+1,i)) < threshold1
        Mid1(i) = 0;
    end
end

for i = 1:1000
    if Mid0(i) == 1 && abs(SWD0(scale+1,i)) < threshold0
        Mid0(i) = 0;
    end
end

if sum(Mid1) == 0
    flag = 0;
else
    for i = 1:1000
        if Mid1(i) == 1
            break;
        end
    end
    if sum(Mid0) == 0
        flag = 3;
    else
        for j = i:1000
            if Mid0(j) == 1
                break;
            end
        end
        if SWD0(scale+1,j) > threshold0
            flag = 2;
        elseif SWD0(scale+1,j) < threshold0 * (-1)
            flag = 1;
        else
            flag = 3;
        end
    end
end

if flag == 1
    if thunder_detect1 > 2 && thunder_detect2 > 2
        flag = 4;
    elseif thunder_detect1 < 2 && thunder_detect2 > 2
        flag = 3;
    end
end

switch flag
    case 0
        info = '无故障';
    case 1
        info = '正极故障';
    case 2
        info = '负极故障';
    case 3
        info = '双极故障';
    case 4
        info = '雷击干扰';
end


figure
for i = 1:6
    subplot(6,1,i);
    plot(SWD1(i,:))
end

 for i=2:6
subplot(6,1,i)
title(['第',num2str(i-1),'尺度下小波变换'])
 end

subplot(6,1,1)
title('原信号')