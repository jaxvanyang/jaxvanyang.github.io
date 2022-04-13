---
title: 题解 | 第十三届蓝桥杯大赛软件赛省赛
modified_date: 2022-04-13
---

> C/C++ 大学 B 组

> 感谢 [@Kenshin2438](https://github.com/Kenshin2438) 指正，本文中部分题目代码并非正确解答，评测结果如下：

![judge result](https://camo.githubusercontent.com/f261886391cc8a86832f3c148d09e9ae6f264efae43e2a7782f7591b289484c0/68747470733a2f2f73312e617831782e636f6d2f323032322f30342f31312f4c5a70576e4f2e706e67)

查看完整题目请点击：<{{ "/assets/docs/lanqiao-sheng-13.pdf" | absolute_url }}>

参考代码仓库：<https://gitee.com/Jaxvanyang/lanqiao>，有错误欢迎指正。

## A. 九进制转十进制

直接对答案：

```
1478
```

## B. 顺子日期

先明确顺子的概念：连续递增的三个数字。2022 肯定无法作为顺子的一部分，所以不予考虑。

只考虑月份和日期有以下几种情况：

```
012[0~9]  // 10
123[0~1]  // 2
[1~1]012  // 1
[0~1]123  // 2
```

注意第一种情况和第四种情况有一个日期是重复的：0123，所以答案是：

```
10 + 2 + 1 + 2 - 1 = 14
```

## C. 刷题统计

因为是从星期一开始统计，所以我们可以先计算刷了多少周，再计算剩下的有几天是工作日，几天是周末，分别计算题数相加即可。

{% details 参考代码 %}
```cpp
#include <iostream>

using ll = long long;

int main() {
  ll a, b, n;
  std::cin >> a >> b >> n;

  ll weekday = 5 * a;
  ll week = 5 * a + 2 * b;

  ll week_cnt = n / week;
  ll ans = week_cnt * 7;
  ll rem = n % week;
  if (rem > weekday) {
    rem -= weekday;
    ans += 5;
    ans += (rem + b - 1) / b;
  } else {
    ans += (rem + a - 1) / a;
  }

  std::cout << ans << std::endl;
}
```
{% enddetails %}

## D. 修剪灌木

注意到灌木是先长再修剪的，移动到其它灌木上时，当前灌木会长高 1，最会回到该灌木上时也会长高 1，最终的高度就是往返的天数。
从左到右和从右到左的往返时间可能是不同的，设当前灌木处于第 $i$ 排 $(1 \leq i \leq N)$，则最高高度为：

$$max(i - 1 + i - 1, n - i + n - i) = 2 \times max(i - 1, n - i)$$

需要注意的是当 $N = 1$ 时答案是 $1$，用上面的公式计算出来的结果是错误的，但是题目给的数据范围是 $1 < N$，所以没有考虑这点的同学也不用担心。

{% details 参考代码 %}
```cpp
#include <iostream>

int main() {
  int n;
  std::cin >> n;

  for (int i = 1; i <= n; ++i) {
    int l = 2 * (i - 1);
    int r = 2 * (n - i);
    std::cout << std::max(l, r) << std::endl;
  }
}
```
{% enddetails %}

## E. X 进制减法

> 此题解答有误，猜测可能是需要保证相减的结果也满足 X 进制。

一个合理的猜想是进制越低，最后的结果就越小，对于特定的一位，设 $A$ 这一位的数字是 $a$，$B$ 在这一位的数字是 $b$，再考虑到最低进制是 $2$，那么这一位的最低进制就是：

$$max(2, max(a, b) + 1)$$

所以我们可以先计算出每一位的进制，然后就能计算出每一位的权（$w$），权的计算可以类比十进制，第 $i$ 位的权 $w_i = 10^{i - 1}$，实际上就是第 $0$ 位的权为 $1$，之后逐位乘 $10$，类似地，$X$ 进制的第 $i$ 位的权就是所有比 $i$ 低的位进制的乘积。

但其实这道题出得有点不好，输入的 $N$ 完全没有必要，除非给出的数字就不合法，所以前面计算最低进制的公式没有考虑 $N$。如果直接模拟逐位减法，结果用 $X$ 进制表示十分复杂，所以最好先将 $A, B$ 都转为十进制再相减。

{% details 参考代码 %}
```cpp
#include <cstdio>
#include <iostream>

using ll = long long;

const int N = 1e5 + 10;
const int mod = 1e9 + 7;

int a[N], b[N], c[N];

int main() {
  int n, a_len, b_len;
  scanf("%d", &n);
  scanf("%d", &a_len);
  for (int i = a_len - 1; i >= 0; --i) {
    scanf("%d", a + i);
  }
  scanf("%d", &b_len);
  for (int i = b_len - 1; i >= 0; --i) {
    scanf("%d", b + i);
  }

  for (int i = 0; i < std::min(a_len, b_len); ++i) {
    c[i] = std::max(a[i], b[i]) + 1;
    c[i] = std::max(c[i], 2);
  }

  for (int i = std::min(a_len, b_len); i < std::max(a_len, b_len); ++i) {
    c[i] = a[i] + 1;
  }

  ll ans = 0;
  for (int i = 1; i < a_len; ++i) {
    c[i] = (ll) c[i - 1] * c[i] % mod;
  }

  ans = a[0];
  for (int i = 1; i < a_len; ++i) {
    ans = (ans + (ll) a[i] * c[i - 1] % mod) % mod;
  }

  ans = (ans + mod - b[0]) % mod;
  for (int i = 1; i < b_len; ++i) {
    ans = (ans + mod - (ll) b[i] * c[i - 1] % mod) % mod;
  }

  // std::cout << ans << std::endl;
  printf("%lld\n", ans);

  return 0;
}
```
{% enddetails %}

## F. 统计子矩阵

> 此题解答有误，经队友提醒，这道题需要采用类似最大子段和的解法优化到 $O(n^3)$ 的时间复杂度解决。

前缀和的经典题型，最朴素的做法是先计算出前缀和，再枚举子矩阵的起始行 $a$、起始列 $b$、终止行 $c$、终止列 $d$，一共四层循环，$O(N^4)$ 的复杂度，但是 $N$ 最大可以等于 $500$，所以肯定会超时。这时候可以考虑优化一下，注意到矩阵的元素都是正数，说明在固定 $a, b, c$ 时，子矩阵的和是随着 $d$ 的的增大而增大的，这时候我们就可以用二分快速找到最后一个满足条件的 $d$，优化后的复杂度是 $O(N^3 \times log_2N)$，理论上能过。

需要注意的是二分时可能没有满足条件的 $d$，这时候需要特判。

{% details 参考代码 %}
```cpp
#include <cstdio>
#include <iostream>

const int N = 550;

int matrix[N][N];
int sum[N][N];

int sum_of(int a, int b, int c, int d) {
  return sum[c][d] - sum[a - 1][d] - sum[c][b - 1] + sum[a - 1][b - 1];
}

int main() {
  int n, m, k;
  scanf("%d%d%d", &n, &m, &k);

  for (int i = 1; i <= n; ++i) {
    for (int j = 1; j <= m; ++j) {
      scanf("%d", matrix[i] + j);
      sum[i][j] = matrix[i][j] + sum[i - 1][j] + sum[i][j - 1] - sum[i - 1][j - 1];
      // std::cout << "i = " << i << " j = " << j << " sum = " << sum[i][j] << std::endl;
    }
  }

  int ans = 0;
  for (int a = 1; a <= n; ++a) {
    for (int b = 1; b <= m; ++b) {
      for (int c = a; c <= n; ++c) {
        int l = b, r = m;
        while (l < r) {
          int mid = (l + r + 1) >> 1;
          if (sum_of(a, b, c, mid) > k) {
            r = mid - 1;
          } else {
            l = mid;
          }
        }

        if (sum_of(a, b, c, l) <= k) {
          // std::cout << "sum_of " << a << ", " << b << ", " << c << ", " << l <<" = " << sum_of(a, b, c, l) << std::endl;
          ans += l - b + 1;
        }
      }
    }
  }

  // std::cout << ans << std::endl;
  printf("%d\n", ans);
  return 0;
}
```
{% enddetails %}

## G. 积木画

一开始看到这题的时候第一感觉是画布的状态很难表示，但是通过自己在草稿纸上画一画可以发现合法的排列方法是有规律的，因为不能有空缺，任意选一种合法排列，从右到左依次取出最右边的积木块，在这个过程中最右边只可能出现下面五种类型（点号表示不确定的积木块组合）：

```c
// 1
...
...

// 2
...#
...

// 3
...
...#

// 4
...##
...

// 5
...
...##
```

这样我们只需要给出类型和长度就能指示哪些区域是已经填充的，而不用考虑其内部的排列方式，很容易就能想到用 5 个数组来存储每种填充有多少种排列方式。

再让我们从左到右来考虑，每次只放置一块积木，我们可以列出每种类型可以转换成的类型，例如类型 1 就可以转换成：

```c
// 类型 1
...#
...#

// 类型 4
...##
...

// 类型 5
...
...##

// 类型 2
...##
...#

// 类型 3
...#
...##
```

一开始只有一种没有积木的情况，然后我们再模拟每次放一块积木的过程，将可以转换的状态加上当前状态的排列方式，这就变成了简单的动态规划。另外由于类型 2 和类型 3、类型 4 和 类型 5 都是镜像的关系，我们可以分别只记录其中一种类型，但要小心不要算错。

我的代码中没有记录类型 5，其实也可以将将类型 1、4、5 合并成一种，因为类型 4 和 5 只能转换成类型 1。

{% details 参考代码 %}
```cpp
#include <iostream>

using ll = long long;

const int mod = 1e9 + 7;
const int N = 1e7 + 10;

int dp[4][N];

inline void mod_add(int &x, int y) {
  x = (x + y) % mod;
}

int main() {
  int n;
  scanf("%d", &n);
  dp[0][0] = 1;

  for (int i = 0; i <= n; ++i) {
    mod_add(dp[0][i], dp[3][i]);
    // mod_add(dp[0][i], dp[4][i]);

    mod_add(dp[0][i + 1], dp[0][i]);
    mod_add(dp[3][i + 2], dp[0][i]);
    // mod_add(dp[4][i + 2], dp[0][i]);
    mod_add(dp[1][i + 2], dp[0][i]);
    mod_add(dp[2][i + 2], dp[0][i]);

    mod_add(dp[0][i + 1], dp[1][i]);
    mod_add(dp[2][i + 1], dp[1][i]);

    mod_add(dp[0][i + 1], dp[2][i]);
    mod_add(dp[1][i + 1], dp[2][i]);

    // for (int j = 0; j < 5; ++j) {
    //   std::cout << j << ", " << i << " = " << dp[j][i] << std::endl;
    // }
  }

  printf("%d\n", dp[0][n]);
}
```
{% enddetails %}

## H. 扫雷

> 此题解答有误，经队友提醒，正确的解法需要用并查集合并可引爆的雷。

最朴素的做法就是模拟每次引爆一个排雷火箭或炸雷，再考虑会被引爆的炸雷，用递归的方式来做不方便统计，而且容易重复计算，我们可以用一个队列存储待引爆的排雷火箭和炸雷，每次取出队首，再将会引爆的炸雷加入队列，这个代码框架很容易想到，但是这道题难的是快速找出能引爆的炸雷，每次都遍历所有未引爆的炸雷显然是不现实的。

查看数据范围我们可以发现 $1 \leq r \leq 10$，如果是暴力遍历的话，很多时候都是在检查超出引爆范围外的不可能引爆的炸雷，所以我们可以想办法将搜索的范围缩小到引爆范围附近，一个简单的方法是先对炸雷进行排序，每次只检查 $X$ 坐标之差和 $Y$ 坐标之差小于等于 $r$ 的炸雷（可以用二分，后面再讲具体实现），这样我们的搜索范围就缩小到了一个边长为 $2r$ 的正方形，每次搜索的复杂度大概是：

$$O(log_2n) \times O(这个范围内的炸雷数量)$$

另外题目中说炸雷可能重叠，如果炸雷集中到一个点上的话，每次搜索的复杂度还是很大，所以我们需要合并重叠得到炸雷，$r$ 最大是 $10$，每次搜索的复杂度大概是：

$$O(log_2n) \times O(200)$$

这样总的复杂度就是：

$$O(400 \times nlog_2n)$$

具体实现最重要的对炸雷排序和去重，我们可以先定义一个结构体 $Node$ 记录炸雷的 $x, y, r$，再定义 $Node$ 的比较函数方便排序。存储可以选用 STL 的 `map`，刚好满足我们排序和去重的需求。利用 `map` 自带的 `lower_bound` 函数，我们可以快速查找到第一个 $X$ 坐标在正方形范围内的炸雷，还可以通过 `upper_bound` 找到第一个 $X$ 坐标不在范围内的炸雷，$Y$ 坐标同理。

另外排雷火箭和炸雷其实没有什么区别，我们可以将它们都归类为炸雷，然后将答案初始化为排雷火箭数量的负数 $-m$，具体实现如下：

{% details 参考代码 %}
```cpp
#include <cstdio>
#include <iostream>
#include <queue>
// #include <set>
#include <map>
#include <vector>

using ll = long long;

const int N = 5e4 + 10;
const int R = 10;

struct Node {
  int x, y, r;

  Node(int x = 0, int y = 0, int r = 0) : x(x), y(y), r(r) {}
};

bool operator<(const Node &a, const Node &b) {
  return a.x < b.x || (a.x == b.x && a.y < b.y) ||
         (a.x == b.x && a.y == b.y && a.r < b.r);
}

// Node mines[N], rockets[N];

bool fire(const Node &a, const Node &b) {
  int x = std::abs(a.x - b.x);
  int y = std::abs(a.y - b.y);
  if (x > R || y > R) return false;
  return x * x + y * y <= a.r * a.r;
}

int main() {
  int n, m;
  scanf("%d%d", &n, &m);

  // std::set<Node> st;
  std::map<Node, int> mp;
  for (int i = 0; i < n; ++i) {
    int x, y, r;
    scanf("%d%d%d", &x, &y, &r);
    Node node(x, y, r);
    ++mp[node];
  }

  std::map<Node, int> temp;
  for (int i = 0; i < m; ++i) {
    int x, y, r;
    scanf("%d%d%d", &x, &y, &r);
    ++temp[Node(x, y, r)];
  }
  std::queue<std::pair<Node, int>> q;
  for (const auto &it : temp) {
    q.push(it);
  }

  int ans = -m;
  while (q.size()) {
    auto cur_p = q.front();
    auto cur = cur_p.first;
    q.pop();
    ans += cur_p.second;

    Node l = Node(cur.x - cur.r, cur.y), r = Node(cur.x + cur.r, cur.y);
    auto begin = mp.lower_bound(l);
    auto end = mp.upper_bound(r);

    int size = 0;

    std::vector<std::pair<Node, int>> tmp;

    for (auto p = begin; p != end;) {
      // std::cout << cur.x << ", " << cur.y << ", " << cur.r << std::endl
      //           << p->x << ", " << p->y << ", " << p->r << std::endl;
      ++size;
      if (fire(cur, p->first)) {
        // std::cout << "ok" << std::endl;
        q.push(*p);
        tmp.push_back(*p);
        ++p;
      } else if (p->first.y < cur.y - cur.r) {
        auto next = mp.lower_bound(Node(p->first.x, cur.y - cur.r));
        if (next == p) ++next;
        p = next;
      } else if (p->first.y > cur.y + cur.r) {
        auto next = mp.lower_bound(Node(p->first.x + 1, cur.y - cur.r));
        p = next;
      } else {
        ++p;
      }
    }

    // std::cout << "size = " << size << std::endl;

    for (auto &pair : tmp) {
      mp.erase(pair.first);
    }
  }

  printf("%d\n", ans);
}
```
{% enddetails %}

## I. 李白打酒加强版

很多这种计算可能方案数的题目都可以用动态规划解决，这道题也不例外，只不过这道题的状态有点多，不优化的话有已遇到店或花的次数、剩余酒量、遇到店的次数、遇到花的次数，一共四种状态，但是遇到店或花的次数就是遇到店的和遇到花的次数之和，所以很容易优化到三种状态。

另外很重要的一点是只有遇到花的时候剩余酒量才会减少，所以合理的剩余酒量只可能小于等于遇到花的次数 $M$，所以我们只需要一个这么大的数组就能保存所有状态的种数了：

```cpp
// N 为遇到店的次数，M 为遇到花的次数
int dp[N + M][M][N];
```

讲得不是很清楚，但是直接看代码就很清楚了。

{% details 参考代码 %}
```cpp
#include <cstdio>
#include <iostream>

using ll = long long;

const int mod = 1e9 + 7;
const int N = 105;
int dp[N << 1][N][N];

void mod_add(int &x, int y) {
  x = (x + y) % mod;
}

int main() {
  int n, m;
  scanf("%d%d", &n, &m);

  int x = n + m;
  dp[0][2][0] = 1;
  
  for (int i = 0; i < x; ++i) {
    for (int j = 0; j <= m; ++j) {
      for (int k = 0; k <= n; ++k) {
        if (!dp[i][j][k]) continue;
        // std::cout << i << ", " << j << ", " << k << ": " << dp[i][j][k] << std::endl;
        
        int rem_store = n - k;
        int rem_flower = x - i - rem_store;

        // int check_sum = rem_store + rem_flower + i;
        // if (check_sum != x) std::cout << "error" << std::endl;

        if (k < n && j * 2 <= rem_flower) {
          mod_add(dp[i + 1][j * 2][k + 1], dp[i][j][k]);
        }

        if (j && rem_flower) {
          mod_add(dp[i + 1][j - 1][k], dp[i][j][k]);
        }
      }
    }
  }

  // for (int i = 0; i <= n; ++i) {
  //   std::cout << dp[x][0][i] << std::endl;
  // }

  // std::cout << dp[x - 1][1][n] << std::endl;
  printf("%d\n", dp[x - 1][1][n]);
}
```
{% enddetails %}

## J. 砍竹子

一开始看到这道题我以为是一道区间操作的题目，但其实很简单，我们只需要从最简单的情况来考虑就很容易想到解法。

先考虑只有一根竹子的情况，那么只能不断重复砍这一根竹子，按照数据范围中的最大高度 $10^{18}$，竹子的高度变化如下：

```
1000000000000000000
707106781
18803
96
7
2
1
```

可以看到下降得非常快，最高的竹子都只需要砍 $6$ 次，这个特性给了我们后面具体实现的可能。

再考虑有两根竹子的情况，我们先计算出这两根竹子所有可能的高度（不包括 $1$），将答案 $ans$ 初始化为这两根竹子分别砍的次数之和，如果这两根竹子有相等的可能高度，那么必然就可以将这两次砍合并为一次，效果就是 $ans = ans - 1$，这就是解题的关键。再注意到每根竹子最多只需要砍 $6$ 次，我们只需要 $O(12)$ 的复杂度就能计算出相邻两竹子相等的可能高度个数。

最后总结一下，先算出每根竹子的可能高度，将答案 $ans$ 初始化为每根竹子砍的次数之和，然后遍历每对相邻的竹子，计算出它们相等的可能高度个数 $cnt$，然后将 $ans$ 减去 $cnt$，遍历结束后 $ans$ 就是最少次数。

{% details 参考代码 %}
```cpp
#include <cmath>
#include <cstdio>
#include <iostream>

using ll = long long;
const int N = 2e5 + 10;
const int C = 6;

ll hs[N][C];
int lens[N];

inline ll foo(ll h) { return sqrt(h / 2 + 1); }

int calc(int i, int j) {
  int cnt = 0;
  int pi = 0, pj = 0;

  while (pi < lens[i] && pj < lens[j]) {
    if (hs[i][pi] == hs[j][pj]) {
      ++cnt, ++pi, ++pj;
    } else if (hs[i][pi] > hs[j][pj]) {
      ++pi;
    } else {
      ++pj;
    }
  }

  return cnt;
}

int main() {
  int n;
  scanf("%d", &n);

  ll ans = 0;
  for (int i = 0; i < n; ++ i) {
    ll h;
    scanf("%lld", &h);
    while (h != 1) {
      hs[i][lens[i]++] = h;
      h = foo(h);
    }

    ans += lens[i];
  }

  for (int i = 1; i < n; ++i) {
    ans -= calc(i - 1, i);
  }

  printf("%lld\n", ans);
}
```
{% enddetails %}