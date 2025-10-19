Напоминаю, что нам надо реализовать 4-мерный фильтр Калмана со следующими уравнениями:
$$\color{#ff035f} \hat{x}_k \color{white}= F_k \color{#2771e8} \hat{x}_{k-1} + \color{white} B_k \color{#2ecbff} \color{#ff861c}\vec{u}_k$$
$$\color{#ff035f} P_k \color{white} = F_k \color{#2771e8} P_{k-1} \color{white}F_k^T + \color{#02a879}Q_k$$
$$\color{#9a02a8} K' \color{white} = \color{#ff035f}P_k \color{white} H_k^T \left( H_k \color{#ff035f}P_k \color{white} H_k^T  + \color{#02a879}R_k\color{white}\right)^{-1}$$
$$\color{#2771e8} \hat{x}'_k \color{white} = \color{#ff035f} \hat{x}_k \color{white} + \color{#9a02a8} K' \color{white} \left( \color{#9aa802} \vec{z}_k \color{white} - H_k \color{#ff035f} \hat{x}_k \color{white} \right)$$
$$\color{#2771e8} P'_k \color{white} = \color{#ff035f} P_k \color{white} - \color{#9a02a8} K' \color{white} H_k \color{#ff035f} P_k$$

Вектор состояния $\hat{x} _k = \left( \begin{matrix} \lambda_k \\ \phi_k \\ v_{\lambda k} \\ v_{\phi k} \\ \end{matrix} \right)$.
# Predict
## Разложение вектора скорости $\vec{v_k}$

$\lambda_k$ и $\phi_k$ измеряются в градусах, а $v_{\lambda k}$ и $v_{\phi k}$ – в $м/c$.
Посмотрим, как меняется $v_\lambda$: ($\lambda_k$ – долгота (вдоль параллели), $\phi_k$ – широта (вдоль меридиана))

![](./Source/Speed_RPM_Bearing.png)

Угол $\theta$ всегда ориентирует относительно севера (т.е. относительно меридиана, на котором в данный момент измеряется ориентация). Таким образом, $v_\lambda$ всегда отвечает за движение вдоль параллели (меняется долгота), а $v_\phi$ – за движение по меридиану (который со временем меняется) (меняется широта).

Предполагается, что скорость равномерно растет в $\frac{RPM_k}{RPM_{k-1}}$ раз по модулю и вектор скорости при этом равномерно поворачивается на угол $\theta = Beaing_k - Bearing_{k-1}$. Тогда $$\vec{v} _k = \left( \begin{matrix} v_{\lambda k} \\ v_{\phi k} \\ \end{matrix} \right) = \frac{RPM_k}{RPM_{k-1}}\left( \begin{matrix} \cos \theta & -\sin \theta \\ \sin \theta & \cos \theta \\ \end{matrix} \right) \left( \begin{matrix} v_{\lambda k-1} \\ v_{\phi k-1} \\ \end{matrix} \right).$$
Т.е. $$v_{\lambda k} = \frac{RPM_k}{RPM_{k-1}} \left( v_{\lambda k-1}\cos{\theta} - v_{\phi k-1}\sin{\theta} \right);$$
$$v_{\phi k} = \frac{RPM_k}{RPM_{k-1}} \left( v_{\lambda k-1}\sin{\theta} + v_{\phi k-1}\cos{\theta} \right).$$

## Учет влияния скорости на положение в модели системы

### Общие рассуждения

Движение по меридиану ($v_\phi$) происходит по окружности с постоянным радиусом $R_з$, которая поворачивается вокруг оси $SN$ (Юг-СЕВЕР) из-за движения вдоль параллелей.
![[GEO_Latitude.png]]

Таким образом, чтобы определить изменение широты, нужно проинтегрировать $d\phi$:
$$\Delta \phi = \int\limits_0^{\Delta \phi}d\phi$$$$R_з d\phi = v_\phi(t)dt \Rightarrow \Delta \phi = \frac{180}{R_з \pi}\int\limits_0^{\Delta t} v_\phi (t) dt$$
Таким образом 
$$\phi _k = \phi _{k-1} + \frac{180}{R_з\pi}\int\limits_0^{\Delta t} v_{\phi k} (t) dt.$$
Движение по параллелям осуществляется несколько сложнее: Это по сути движение по окружности, которая непрерывно во времени меняет свой радиус. 
![[GEO_Longitude.png]]
$$R(t)=R_з \cdot \cos \phi(t)$$
$$\phi_k(t) = \phi _{k-1} + \frac{180}{R_з\pi}\int\limits_0^{t} v_{\phi k} (\xi) d\xi$$
$$R_k(t)=R_з \cdot \cos \left( \phi _{k-1} + \frac{180}{R_з\pi}\int\limits_0^{t} v_{\phi k} (\xi) d\xi \right)$$
Тогда $\lambda _k$ находится путем интегрирования:

$$\lambda _k = \lambda _{k-1} + \frac{180}{\pi}\int\limits_0^{\Delta t} \frac{v_{\lambda k}(t)}{R_k(t)}dt = \lambda _{k-1} + \frac{180}{R_з\pi}\int\limits_0^{\Delta t} \frac{v_{\lambda k}(t)}{\cos \left( \phi _{k-1} + \frac{180}{R_з \pi}\int\limits_0^{t} v_{\phi k} (\xi) d\xi \right)}dt.$$

### Нахождение интегралов

Необходимо получить $v_{\lambda k}(t)$ и $v_{\phi k}(t)$ при $t \in [0;\Delta t]$:
$$v_{\phi k}(t) = \frac{RPM_k \cdot t}{RPM_{k-1} \cdot \Delta t} \left( v_{\lambda k-1}\sin{\frac{\theta \cdot t}{\Delta t}} + v_{\phi k-1}\cos{\frac{\theta \cdot t}{\Delta t}} \right);$$$$v_{\lambda k}(t) = \frac{RPM_k \cdot t}{RPM_{k-1} \cdot \Delta t} \left( v_{\lambda k-1}\cos{\frac{\theta \cdot t}{\Delta t}} - v_{\phi k-1}\sin{\frac{\theta \cdot t}{\Delta t}} \right).$$
Теперь найдем интегралы $\frac{180}{R_з\pi}\int\limits_0^{\Delta t} v_{\phi k} (t) dt$ и $\frac{180}{\pi}\int\limits_0^{\Delta t} \frac{v_{\lambda k}(t)}{R_k(t)}dt$:

#### Широта $\phi$

Вычислим $\frac{180}{R_з\pi}\int\limits_0^{t} v_{\phi k} (x) dx$.
$$\int\limits_0^{t} v_{\phi k}(x)dx = \frac{RPM_k}{RPM_{k-1} \cdot \Delta t}\int\limits_0^{t}x \left( v_{\lambda k-1}\sin{\frac{\theta \cdot t}{\Delta t}} + v_{\phi k-1}\cos{\frac{\theta \cdot t}{\Delta t}} \right)dx = \frac{RPM_k \cdot (\Delta t)^2}{RPM_{k-1} \cdot \Delta t \cdot \theta^2} \left[ v_{\lambda k-1}\int\limits_0^{t}\frac{\theta \cdot x}{\Delta t}\sin{\frac{\theta \cdot x}{\Delta t}}d \left(\frac{\theta \cdot x}{\Delta t}\right) + v_{\phi k-1}\int\limits_0^{t} \frac{\theta \cdot x}{\Delta t}\cos{\frac{\theta \cdot x}{\Delta t}}d\left(\frac{\theta \cdot x}{\Delta t}\right) \right]=$$
$$=\frac{RPM_k \cdot \Delta t}{RPM_{k-1}\cdot \theta^2} \left[ v_{\lambda k-1}\int\limits_0^{t}\frac{\theta \cdot x}{\Delta t}\sin{\frac{\theta \cdot x}{\Delta t}}d \left(\frac{\theta \cdot x}{\Delta t}\right) + v_{\phi k-1}\int\limits_0^{t} \frac{\theta \cdot x}{\Delta t}\cos{\frac{\theta \cdot x}{\Delta t}}d\left(\frac{\theta \cdot x}{\Delta t}\right) \right].$$
Произведем замену $n = \frac{x \cdot \theta}{\Delta t}$, тогда пределы интегрирования изменятся следующим образом: $\left[ \begin{matrix} 0 \rightarrow 0 \\ t \rightarrow \frac{t \cdot \theta}{\Delta t} \\ \end{matrix} \right]$ и мы получим
$$\int\limits_0^{t} v_{\phi k}(x)dx = \frac{RPM_k \cdot \Delta t}{RPM_{k-1}\cdot \theta^2} \left[ v_{\lambda k-1}\int\limits_0^{\frac{t \cdot \theta}{\Delta t}}n\sin{n}\text{ }dn + v_{\phi k-1}\int\limits_0^{\frac{t \cdot \theta}{\Delta t}}n\cos{n} \text{ }dn \right].$$
Интегралы $\int\limits_0^{\frac{t \cdot \theta}{\Delta t}}n\sin{n}\text{ }dn$ и $\int\limits_0^{\frac{t \cdot \theta}{\Delta t}}n\cos{n}\text{ }dn$ легко берутся по частям, и они равны
$$\int\limits_0^{\frac{t \cdot \theta}{\Delta t}}n\sin{n}\text{ }dn = \sin \left(\frac{t \cdot \theta}{\Delta t} \right) - \frac{t \cdot \theta}{\Delta t} \cos \left(\frac{t \cdot \theta}{\Delta t} \right);$$$$\int\limits_0^{\frac{t \cdot \theta}{\Delta t}}n\cos{n}\text{ }dn = \frac{t \cdot \theta}{\Delta t} \sin \left(\frac{t \cdot \theta}{\Delta t} \right) + \cos \left(\frac{t \cdot \theta}{\Delta t} \right) -1.$$
Подставляем:
$$\int\limits_0^{t} v_{\phi k}(x)dx = \frac{RPM_k \cdot \Delta t}{RPM_{k-1}\cdot \theta^2} \left[ v_{\lambda k-1} \left(\sin \left(\frac{t \cdot \theta}{\Delta t} \right) - \frac{t \cdot \theta}{\Delta t} \cos \left(\frac{t \cdot \theta}{\Delta t} \right) \right) + v_{\phi k-1} \left(\frac{t \cdot \theta}{\Delta t} \sin \left(\frac{t \cdot \theta}{\Delta t} \right) + \cos \left(\frac{t \cdot \theta}{\Delta t} \right) -1\right)  \right].$$
Тогда 
$$\frac{180}{R_з\pi}\int\limits_0^{t} v_{\phi k} (x) dx = \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2} \left[ v_{\lambda k-1} \left(\sin \left(\frac{t \cdot \theta}{\Delta t} \right) - \frac{t \cdot \theta}{\Delta t} \cos \left(\frac{t \cdot \theta}{\Delta t} \right) \right) + v_{\phi k-1} \left(\frac{t \cdot \theta}{\Delta t} \sin \left(\frac{t \cdot \theta}{\Delta t} \right) + \cos \left(\frac{t \cdot \theta}{\Delta t} \right) -1\right)  \right]$$
и
$$\phi _k = \phi _{k-1} + \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2} \left[ v_{\lambda k-1} \left(\sin \theta - \theta \cos \theta \right) + v_{\phi k-1} \left(\theta \sin \theta + \cos \theta -1\right)  \right].$$

#### Долгота $\lambda$

Вычислим $\frac{180}{\pi}\int\limits_0^{\Delta t} \frac{v_{\lambda k}(t)}{R_k(t)}dt$.
$$\int\limits_0^{\Delta t} \frac{v_{\lambda k}(t)}{R_k(t)}dt =\frac{RPM_k}{R_з \cdot RPM_{k-1} \cdot \Delta t}\int\limits_0^{\Delta t} \frac{ t\left( v_{\lambda k-1}\cos{\frac{\theta \cdot t}{\Delta t}} - v_{\phi k-1}\sin{\frac{\theta \cdot t}{\Delta t}} \right)}{\cos \left( \phi _{k-1} + \frac{180}{\pi R_з}\int\limits_0^{t} v_{\phi k} (\xi) d\xi \right)}dt = $$
$$=\frac{RPM_k}{R_з \cdot RPM_{k-1} \cdot \Delta t}\int\limits_0^{\Delta t} \frac{ t\left( v_{\lambda k-1}\cos{\frac{\theta \cdot t}{\Delta t}} - v_{\phi k-1}\sin{\frac{\theta \cdot t}{\Delta t}} \right)}
{\cos \left( \phi _{k-1} + \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2} \left[ v_{\lambda k-1} \left(\sin \left(\frac{t \cdot \theta}{\Delta t} \right) - \frac{t \cdot \theta}{\Delta t} \cos \left(\frac{t \cdot \theta}{\Delta t} \right) \right) + v_{\phi k-1} \left(\frac{t \cdot \theta}{\Delta t} \sin \left(\frac{t \cdot \theta}{\Delta t} \right) + \cos \left(\frac{t \cdot \theta}{\Delta t} \right) -1\right)  \right]\right)}dt
$$
Отсюда получаем
$$\lambda _k = \lambda _{k-1} + \frac{180}{\pi}\frac{RPM_k}{R_з \cdot RPM_{k-1} \cdot \Delta t}\int\limits_0^{\Delta t} \frac{ t\left( v_{\lambda k-1}\cos{\frac{\theta \cdot t}{\Delta t}} - v_{\phi k-1}\sin{\frac{\theta \cdot t}{\Delta t}} \right)}{\cos \left( \phi _{k-1} + \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2} \left[ v_{\lambda k-1} \left(\sin \left(\frac{t \cdot \theta}{\Delta t} \right) - \frac{t \cdot \theta}{\Delta t} \cos \left(\frac{t \cdot \theta}{\Delta t} \right) \right) + v_{\phi k-1} \left(\frac{t \cdot \theta}{\Delta t} \sin \left(\frac{t \cdot \theta}{\Delta t} \right) + \cos \left(\frac{t \cdot \theta}{\Delta t} \right) -1\right)  \right]\right)}dt.$$
Несложно заметить, что получить представление в виде линейной комбинации $v_{\lambda k-1}$, $v_{\phi k-1}$ и $\phi_{k-1}$ НЕВОЗМОЖНО (по крайней мере ОЧЕНЬ сложно), так что приходится прибегать к линеаризации (Разложение этого интеграла в многомерный ряд Тейлора). Для начала сделаем пару замен:$$\left[\begin{matrix} k_1 = \frac{\theta}{\Delta t} \\k_2 = \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2} \\ \end{matrix} \right]$$
Тогда получим
$$\mathcal{J} = \int\limits_0^{\Delta t} \frac{ t\left( v_{\lambda k-1}\cos{\frac{\theta \cdot t}{\Delta t}} - v_{\phi k-1}\sin{\frac{\theta \cdot t}{\Delta t}} \right)}{\cos \left( \phi _{k-1} + \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2} \left[ v_{\lambda k-1} \left(\sin \left(\frac{t \cdot \theta}{\Delta t} \right) - \frac{t \cdot \theta}{\Delta t} \cos \left(\frac{t \cdot \theta}{\Delta t} \right) \right) + v_{\phi k-1} \left(\frac{t \cdot \theta}{\Delta t} \sin \left(\frac{t \cdot \theta}{\Delta t} \right) + \cos \left(\frac{t \cdot \theta}{\Delta t} \right) -1\right)  \right]\right)}dt =$$
$$= \int\limits_0^{\Delta t} \frac{ t\left( v_{\lambda k-1}\cos{k_1t} - v_{\phi k-1}\sin{k_1t} \right)}{\cos \left( \phi _{k-1} + k_2 \left[ v_{\lambda k-1} \left(\sin {k_1t} - {k_1t} \cos {k_1t} \right) + v_{\phi k-1} \left({k_1t} \sin {k_1t} + \cos {k_1t} -1\right)  \right]\right)}dt =$$
$$= \int\limits_0^{\Delta t} \frac{ t\left( v_{\lambda k-1}\cos{k_1t} - v_{\phi k-1}\sin{k_1t} \right)}{\cos \left[ \phi _{k-1} + v_{\lambda k-1} k_2\left(\sin {k_1t} - {k_1t} \cos {k_1t} \right) + v_{\phi k-1} k_2\left({k_1t} \sin {k_1t} + \cos {k_1t} -1\right) \right]}dt.$$
Введем $$f(\phi_{k-1},v_{\lambda k-1}, v_{\phi k-1}) = \frac{ t\left( v_{\lambda k-1}\cos{k_1t} - v_{\phi k-1}\sin{k_1t} \right)}{\cos \left[ \phi _{k-1} + v_{\lambda k-1} k_2\left(\sin {k_1t} - {k_1t} \cos {k_1t} \right) + v_{\phi k-1} k_2\left({k_1t} \sin {k_1t} + \cos {k_1t} -1\right) \right]}.$$
Мы стараемся сделать несколько вещей:
1. Добиться максимальной точности линеаризации, т.е. взять начальную точку, наиболее близкую к тем, что мы имеем в данных;
2. После линеаризации не иметь свободных (относительно $\phi_{k-1},v_{\lambda k-1}, v_{\phi k-1}$) членов, т.к. они никак не будут учтены в матрице ковариации и их придется пихать в управляющий сигнал, что не корректно.
В приоритете 2-й пункт:
Разлагая $f$ до 1го порядка вокруг $\left(\phi_{k-1}^*,v_{\lambda k-1}^*,v_{\phi k-1}^*\right)$, получим 
$$f(\phi_{k-1},v_{\lambda k-1}, v_{\phi k-1}) \approx f\left(\phi_{k-1}^*,v_{\lambda k-1}^*,v_{\phi k-1}^*\right) + \frac{\partial f\left(\phi_{k-1}^*,v_{\lambda k-1}^*,v_{\phi k-1}^*\right)}{\partial \phi_{k-1}}(\phi_{k-1}-\phi_{k-1}^*) +  \frac{\partial f\left(\phi_{k-1}^*,v_{\lambda k-1}^*,v_{\phi k-1}^*\right)}{\partial v_{\lambda k-1}}(v_{\lambda k-1}-v_{\lambda k-1}^*) + \frac{\partial f\left(\phi_{k-1}^*,v_{\lambda k-1}^*,v_{\phi k-1}^*\right)}{\partial v_{\phi k-1}}(v_{\phi k-1}-v_{\phi k-1}^*).$$
Проще всего занулить все свободные слагаемые, положив $\left[ \begin{matrix} \phi_{k-1}^* = 0 \\ v_{\lambda k-1}^* = 0 \\ v_{\phi k-1}^* = 0 \\ \end{matrix}\right]$, т.к. тогда не будет свободно болтающихся частных производных и $f(0,0,0) = 0$, как можно видеть выше.
Осталось найти частные производные (промежуточные этапы опущены, при необходимости дергать @SaprZheks):
$$\begin{matrix}
\left. \frac{\partial f}{\partial \phi_{k-1}} \right|_{(0,0,0)} =  0\\
\left. \frac{\partial f}{\partial v_{\lambda k-1}}\right|_{(0,0,0)} = t \cos (k_1t)\\
\left. \frac{\partial f}{\partial v_{\phi k-1}} \right|_{(0,0,0)} = -t \sin (k_1t)\\
\end{matrix}$$
Разложим $f$ в многомерный ряд Тейлора в окрестности $\left(0,0,0 \right)$:
$$f(\phi_{k-1},v_{\lambda k-1}, v_{\phi k-1}) \approx t \cos (k_1t)v_{\lambda k-1} - t \sin (k_1t)v_{\phi k-1}.$$
Тогда можно без труда посчитать интеграл $\mathcal{J}$:
$$\mathcal{J} = \int\limits_0^{\Delta t} f(\phi_{k-1},v_{\lambda k-1}, v_{\phi k-1})dt \approx \int\limits_0^{\Delta t} \left[ t \cos (k_1 t) v_{\lambda k-1} - t \sin (k_1t)v_{\phi k-1} \right]dt = \frac{v_{\lambda k-1}}{k_1^2}\int\limits_0^{\Delta t}k_1t \cos (k_1 t) d(k_1t) - \frac{v_{\phi k-1}}{k_1^2}\int\limits_0^{\Delta t} k_1 t \sin (k_1 t) d(k_1 t).$$
Производя замену $n = k_1 t$, получим $\left[ \begin{matrix} 0 \rightarrow 0 \\ \Delta t \rightarrow k_1 \Delta t \\ \end{matrix} \right]$ и
$$\mathcal{J} \approx \frac{v_{\lambda k-1}}{k_1^2}\int\limits_0^{k_1 \Delta t}n \cos n \text{ }d(n) - \frac{v_{\phi k-1}}{k_1^2}\int\limits_0^{k_1 \Delta t} n \sin n \text{ }d(n).$$
Эти интегралы уже вычислялись ранее. Подставляя те результаты, получим
$$\mathcal{J} \approx \frac{v_{\lambda k-1}}{k_1^2} \left( k_1 \Delta t \sin (k_1 \Delta t) + \cos (k_1 \Delta t) -1 \right) - \frac{v_{\phi k-1}}{k_1^2} \left( \sin(k_1 \Delta t) - k_1 \Delta t \cos (k_1 \Delta t) \right).$$
$$\lambda _k \approx \lambda _{k-1} + \frac{180}{\pi}\frac{RPM_k}{R_з \cdot RPM_{k-1} \cdot \Delta t} \left[\frac{v_{\lambda k-1}}{k_1^2} \left( k_1 \Delta t \sin (k_1 \Delta t) + \cos (k_1 \Delta t) -1 \right) - \frac{v_{\phi k-1}}{k_1^2} \left( \sin(k_1 \Delta t) - k_1 \Delta t \cos (k_1 \Delta t) \right) \right],$$
где $k_1 = \frac{\theta}{\Delta t}$. Подставляем:
$$\lambda _k \approx \lambda _{k-1} + \frac{180}{\pi}\frac{RPM_k}{R_з \cdot RPM_{k-1} \cdot \Delta t} \left[\frac{v_{\lambda k-1}}{\left( \frac{\theta}{\Delta t}\right)^2} \left( \frac{\theta}{\Delta t} \Delta t \sin (\frac{\theta}{\Delta t} \Delta t) + \cos (\frac{\theta}{\Delta t} \Delta t) -1 \right) - \frac{v_{\phi k-1}}{\left(\frac{\theta}{\Delta t}\right)^2} \left( \sin(\frac{\theta}{\Delta t} \Delta t) - \frac{\theta}{\Delta t} \Delta t \cos (\frac{\theta}{\Delta t} \Delta t) \right) \right] = $$
$$=\lambda _{k-1} + \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1} \cdot \theta^2}\left[v_{\lambda k-1}\left( \theta \sin \theta + \cos \theta -1 \right) - v_{\phi k-1} \left( \sin\theta - \theta \cos \theta \right) \right].$$
Этот результат ровно такой же, как если бы мы положили, что параллели ведут себя как меридианы, т.е. вычисляли бы долготу так же, как и широту.

## Итоговая матрица эволюция системы

$$\lambda _k =\lambda _{k-1} + v_{\lambda k-1}\frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1} \cdot \theta^2}\left( \theta \sin \theta + \cos \theta -1 \right) - v_{\phi k-1} \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1} \cdot \theta^2}\left( \sin\theta - \theta \cos \theta \right) .$$
$$\phi _k = \phi _{k-1} +  v_{\lambda k-1}\frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2} \left(\sin \theta - \theta \cos \theta \right) + v_{\phi k-1}\frac{180}{\pi} \frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2}\left(\theta \sin \theta + \cos \theta -1\right) .$$
$$v_{\lambda k} = v_{\lambda k-1}\frac{RPM_k}{RPM_{k-1}}\cos{\theta} - v_{\phi k-1}\frac{RPM_k}{RPM_{k-1}}\sin{\theta};$$
$$v_{\phi k} = v_{\lambda k-1}\frac{RPM_k}{RPM_{k-1}}\sin{\theta} + v_{\phi k-1}\frac{RPM_k}{RPM_{k-1}}\cos{\theta}.$$
Т.е. в матричной форме это выглядит так:
$$\hat{x} _k = \left( \begin{matrix} \lambda _k \\ \phi _k \\ v_{\lambda k} \\ v_{\phi k} \\ \end{matrix} \right) = \left( \begin{matrix}1 & 0 & \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2}(\theta \sin \theta + \cos \theta -1) & - \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2}(\sin \theta - \theta \cos \theta) \\0 & 1 & \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2}(\sin \theta - \theta \cos \theta) & \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2}(\theta \sin \theta + \cos \theta -1) \\ 0 & 0 & \frac{RPM_k}{RPM_{k-1}}\cos{\theta} & -\frac{RPM_k}{RPM_{k-1}}\sin{\theta} \\ 0 & 0 & \frac{RPM_k}{RPM_{k-1}}\sin{\theta} & \frac{RPM_k}{RPM_{k-1}}\cos{\theta} \\\end{matrix} \right) \left( \begin{matrix} \lambda _{k-1} \\\phi _{k-1} \\ v_{\lambda k-1} \\ v_{\phi k-1} \\ \end{matrix} \right),$$
т.е.
$$F_k = \left( \begin{matrix}1 & 0 & \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2}(\theta \sin \theta + \cos \theta -1) & - \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2}(\sin \theta - \theta \cos \theta) \\0 & 1 & \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2}(\sin \theta - \theta \cos \theta) & \frac{180}{\pi}\frac{RPM_k \cdot \Delta t}{R_з \cdot RPM_{k-1}\cdot \theta^2}(\theta \sin \theta + \cos \theta -1) \\ 0 & 0 & \frac{RPM_k}{RPM_{k-1}}\cos{\theta} & -\frac{RPM_k}{RPM_{k-1}}\sin{\theta} \\ 0 & 0 & \frac{RPM_k}{RPM_{k-1}}\sin{\theta} & \frac{RPM_k}{RPM_{k-1}}\cos{\theta} \\\end{matrix} \right).$$
Что касается $B_k$ – у нас нет 100% данных управления $\Rightarrow$ $B_k = 0$

Матрица $P_0$ принимается диагональной (на диагонали дисперсии величин, измеренные датчиками), ибо в самый начальный момент времени скорость никак не влияет на уверенность в нашем положении (ибо наше начальное положение – чисто измерения, а не оценка), зато после нескольких итераций матрица $F_k$ скорректирует это и положение станет явно зависеть от скорости.

Аналогично дополнительную неопределенность системы описываем диагональной ковариационной матрицей $\color{#02a879}Q_k$, потому что это по сути допуски на параметры вектора состояния модели, и точно предсказать, как именно, например, рандомное изменение скорости может рандомно изменить положение, сказать сложно, проще заложить такие возможности в допуск положения. Таким образом, нужно просто оценить 4 среднеквадратических отклонения:
$$\color{#02a879}Q_k \color{white}= \left( \begin{matrix}
\sigma^2_\lambda  & 0 & 0 & 0 \\
0 & \sigma^2_\phi  & 0 & 0 \\
0 & 0 & \sigma^2_{v_\lambda} & 0 \\
0 & 0 & 0 & \sigma^2_{v_\phi } \\
\end{matrix}
\right).$$
Причем уместно предположить, что $\sigma_\lambda  = \sigma_\phi$ и $\sigma_{v_\lambda } = \sigma_{v_\phi }$.

# Update

За измерения возьмем столбец $\vec{z} _k = \left( \begin{matrix} \lambda \\ \phi \\ v_\lambda \\ v_\phi \\ \end{matrix} \right)$, $\lambda$ и $\phi$ в $\degree$ , $v_\lambda$ и $v_\phi$ в м/с с ковариацией $$R_k = \left( \begin{matrix} \sigma^2_{meas \lambda} & 0 & 0 & 0 \\
0 &  \sigma^2_{meas \phi} & 0 & 0 \\
0 & 0 & \sigma^2_{v_{meas \lambda}} & 0 \\
0 & 0 & 0 & \sigma^2_{v_{meas \phi}} \\
\end{matrix} \right).$$
Тогда ожидаемые измерения будут такими:
$$\vec{\mu} _{expected} = H_k \cdot \hat{x} _k,$$
где
$$H_k = \left( \begin{matrix} 1 & 0 & 0 & 0 \\ 0 &  1 & 0 & 0 \\ 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ \end{matrix} \right)$$
и матрица ковариации
$$\Sigma_{expected} = H_k P_k H_k^T$$
$v_\lambda$ и $v_\phi$ берутся из 2-х показаний модуля скорости и ориентации $Bearing$.
В итоге получаем 
$$\color{#9a02a8} K' \color{white} = \color{#ff035f}P_k \color{white} H_k^T \left( H_k \color{#ff035f}P_k \color{white} H_k^T  + \color{#02a879}R_k \color{white} \right)^{-1}$$
$$\color{#2771e8} \hat{x}'_k \color{white} = \color{#ff035f} \hat{x}_k \color{white} + \color{#9a02a8} K' \color{white} \left( \color{#9aa802} \vec{z}_k \color{white} - H_k \color{#ff035f} \hat{x}_k \color{white} \right)$$
$$\color{#2771e8} P'_k \color{white} = \color{#ff035f} P_k \color{white} - \color{#9a02a8} K' \color{white} H_k \color{#ff035f} P_k$$

#Робототехника
