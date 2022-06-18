function num = num2string(num)
num = sprintf('%g_',num);
num(end) = [];
end