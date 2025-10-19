На этом [[https://youtu.be/MQypaRgVePw?list=PL2PmRem6srUk-Jflnt3-RuzuICb7TN0FR&t=1401|таймкоде]] формула вероятности выводится следующим образом:
![[Source/Pasted image 20240621233619.png]]
$$p(m_{x,y})=\frac{k}{n};$$
$O_{x,y}$ хранит кол-во успешных детекций (обнаружение препятствия) $k$ минус кол-во безуспешных детекций (не обнаружение препятствия) $(n-k)$, где $n$ – кол-во всех замеров $(n=C_{x,y})$. Т.е. $$O_{x,y}=k-(n-k)=2k-n=2k-C_{x,y},$$
$$\Rightarrow \quad k=\frac{O_{x,y}+C_{x,y}}{2} \quad \Rightarrow \quad p(m_{x,y})=\frac{O_{x,y}+C_{x,y}}{2C_{x,y}}.$$
#Робототехника