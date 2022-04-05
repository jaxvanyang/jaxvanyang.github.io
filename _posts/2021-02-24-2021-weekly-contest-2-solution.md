---
title: CSUST 2021 周赛 2 题解
modified_date: 2022-04-05
categories:
- 题解
---

> 周赛补题链接：<http://acm.csust.edu.cn/contest/129/problems>  

本文可以用 GitHub 登录评论，如果有写得不好的地方欢迎提出建议，也欢迎讨论。  

本文所列 5 份代码皆通过测试，请不要复制提交测试。  

文末有少量参考链接，可以学习一下：）

也可以到 [CSDN](https://blog.csdn.net/Jax_Yang/article/details/114021999) 阅读

## 目录

- [A. 睿智小明买鞭炮](#a-睿智小明买鞭炮)

- [B. 龙卷风摧毁停车场](#b-龙卷风摧毁停车场)

- [C. 5G 传输](#c-5g-传输)

- [D. 神奇的数字串](#d-神奇的数字串)

- [E. 矩阵](#e-矩阵)

- [参考链接](#参考链接)

## [A. 睿智小明买鞭炮](http://acm.csust.edu.cn/contest/129/problem/A)

### 涉及的知识

1. 二分查找

2. 动态规划

3. 勉强可以算作贪心

### 思路
为了方便叙述，我们先约定：一共有 `n` 个规则，对于第 `i` 个规则 `rules[i]`，`rules[i][0]` 表示该规则最少购买的鞭炮数，`rules[i][1]` 表示该规则每盒鞭炮的价格。  

假设查询的鞭炮数是 `num`，满足最少花费所购买的鞭炮数不一定就是 `num`，因为可能买得越多老板打折越狠，所以就得分情况讨论。  

我们先找到可以满足购买数最少的 `rules[i]`， 因为数组有序，所以可以用二分查找，用 `ans` 记录下 `num * rules[i][1]`；打折更狠的规则只可能在 `i` 之后，所以我们只要找到 `i` 后面的最小规则花费，这一步查询可以用 `dp[i]` 记录区间 `[i, n]` 的规则花费最小值，数组 `dp` 可以很容易地用递推式 `dp[i] = min(dp[i + 1], rules[i][0] * rules[i][1])` 得到。最后的答案就是 `min(ans, dp[i + 1])`。  

{% details 代码 %}
```cpp
#include <iostream>
#include <vector>
using namespace std;

using ll = long long;

int find(vector<vector<ll>> &rules, ll num) {
  int l = 0, r = rules.size();
  while (l < r) {
    int mid = l + (r - l) / 2;
    if (rules[mid][0] > num) {
      r = mid;
    } else {
      l = mid + 1;
    }
  }
  return l - 1;
}

int main() {
  ll n, q;
  scanf("%lld%lld", &n, &q);

  // 使用一个二维数组记录规则，因为题目给出的规则已经有序，所以不需要排序
  vector<vector<ll>> rules;
  for (ll i = 0; i < n; ++i) {
    ll s, p;
    scanf("%lld%lld", &s, &p);
    rules.push_back({s, p});
  }

  // dp[i] 表示 rules[i] 到 rules[n] 中最小的规则花费
  vector<ll> dp(n + 1);
  dp[n] = INT64_MAX;  // 将边界值设置为 long long 的最大值，可以减少边界判断
  for (int i = n - 1; i >= 0; --i) {
    dp[i] = min(dp[i + 1], rules[i][0] * rules[i][1]);  // 因为最小值具有传递性，所以可以用动态规划来做
  }

  // 处理每次查询
  while (q--) {
    ll num;
    scanf("%lld", &num);
    int id = find(rules, num);  // 二分查找到不少于鞭炮数量 num 的规则的下标 id，查找函数定义在 main 函数上面
    ll ans = rules[id][1] * num;
    ans = min(ans, dp[id + 1]);
    printf("%lld\n", ans);
  }
}
```
{% enddetails %}

## [B. 龙卷风摧毁停车场](http://acm.csust.edu.cn/contest/129/problem/B)

### 涉及的知识

1. 模拟

2. 感觉懂一点算法分析可以少走很多弯路

### 思路
约定：出发城市为 `s`，目标城市是 `t`。  

这道题其实只要模拟就行，先模拟直达得到一个答案，再模拟换乘得到第二个答案，再输出较小的那个，唯一需要注意的地方就是可能会有无法到达的情况。  

我的做法是先定义一个类 `Air` 表示航线，记录下沿途的城市 `cities` 和费用 `fee`，以及其中 `s` 和 `t` 的下标 `sId` 和 `tId`，记录下标可以简化后面的操作，不用每次都去遍历查询。第一种直达的情况再记录航线的时候就可以得到答案，只要 `sId ！= -1 && tId ！= -1 && sId < tId` 就说明可以直达；第二种情况就需要遍历所有的航线，选出其中的两条，再判断是否可以从 `s` 登上航线 `air1`，再换乘 `air2` 到达 `t`，可以转化为判断 `air1.cities[sId + 1, ...] 和 air2.cities[..., tId - 1]` 中是否有相同的城市，判断是否有重复元素可以用 `set` 实现。  

为什么说懂一点算法分析可以少走弯路呢？因为我一开始想用图算法来写，但不是 `TLE` 就是 `MLE`，还写出了 `TLE` 加上 `MLE` 的代码，感兴趣的可以到我的 [gitee 仓库](https://gitee.com/Jaxvanyang/lang-study/commit/f0c6b04cf2af5375238f183327f7e49080d9341e) 看看错误代码。直到后来我注意到城市和航线数量不多于 500 的条件，我才意识到这么小的数据量就算模拟写出三层循环都不会超时，而图算法动不动就是指数级别的复杂度，所以还是老老实实模拟吧。  

{% details 代码 %}
```cpp
#include <iostream>
#include <set>
#include <vector>

using namespace std;

int ans = INT32_MAX;  // 偷懒用 int 最大值表示到达不了的情况，幸好没有花费到达最大值的测试数据

class Air {
 public:
  vector<int> cities;
  int sId = -1, tId = -1; // 用于记录经过城市中目标城市的下标
  int fee;
  Air(int s, int t) { // 通过输入初始化航线
    int cityCnt;
    scanf("%d%d", &fee, &cityCnt);
    int city;
    for (int j = 0; j < cityCnt; ++j) {
      scanf("%d", &city);
      if (city == s) {
        sId = j;
      } else if (city == t) {
        tId = j;
      }
      cities.push_back(city);
    }

    // 如果该航线会从 s 到 t 就更新 ans
    if (sId != -1 && tId != -1 && sId < tId) {
      ans = min(ans, fee);
    }
  }
};

int main() {
  int s, t, n;
  scanf("%d%d%d", &s, &t, &n);
  vector<Air> airs;
  for (int i = 0; i < n; ++i) {
    airs.push_back(Air(s, t));
  }

  for (int i = 0; i < n; ++i) {
    for (int j = 0; j < n; ++j) {
      if (i == j) {
        continue;
      }
      if (airs[i].sId == -1 || airs[j].tId == -1) {
        continue;
      }
      set<int> st;  // 用于记录第一条航线的沿途城市
      for (int k = airs[i].sId + 1; k < airs[i].cities.size(); ++k) {
        st.insert(airs[i].cities[k]);
      }

      for (int k = 0; k < airs[j].tId; ++k) {
        if (st.count(airs[j].cities[k])) {  // 如果第二条航线的沿途城市和第一条有重合那么就可以换乘
          ans = min(ans, airs[i].fee + airs[j].fee);
          break;
        }
      }
    }
  }

  if (ans != INT32_MAX) // 偷懒成功
    printf("%d\n", ans);
  else
    printf("-1\n");
}
```
{% enddetails %}

## [C. 5G 传输](http://acm.csust.edu.cn/contest/129/problem/C)

### 涉及的知识

1. 最小生成树（Prim 算法或 Kruskal 算法）  

2. 并查集  

3. 超级源点  

### 思路

因为最小生成树是很经典的算法，所以我就不多介绍了。这道题主要的难点就在于不仅要考虑边权（连接两个城市的花费），还要考虑点权（也就是建 5G 信号塔的花费），但只要想到加入超级源点就可以转化成简单的求最小生成树了，具体见代码。  

我用的是 Kruskal 算法，因为不会 Prim 算法……  

{% details 代码 %}
```cpp
#include <algorithm>
#include <iostream>
#include <vector>

using namespace std;

class UnionFind {
 public:
  int cnt;
  vector<int> ids;
  UnionFind(int n) {
    cnt = n;
    for (int i = 0; i < n; ++i) {
      ids.push_back(i);
    }
  }

  void un(int p, int q) {
    int pId = find(p), qId = find(q);
    if (pId != qId) {
      ids[pId] = qId;
      --cnt;
    }
  }

  int find(int p) {
    if (p != ids[p]) {
      ids[p] = find(ids[p]);
    }
    return ids[p];
  }

  bool isConnected(int p, int q) { return find(p) == find(q); }
};

int main() {
  int n;
  scanf("%d", &n);

  vector<vector<int>> edges;
  for (int i = 0; i < n; ++i) {
    int cost;
    scanf("%d", &cost);
    edges.push_back({cost, i, n});  // 将建信号塔的花费转化成各点到虚拟出来的超级源点的连接花费
  }
  for (int i = 0; i < n; ++i) {
    for (int j = 0; j < n; ++j) {
      int cost;
      scanf("%d", &cost);
      if (i < j) edges.push_back({cost, i, j});
    }
  }

  sort(edges.begin(), edges.end());
  // 不能使用集合维护边，因为 Kruskal 算法是针对森林设计的
  // 已经加入的点并不一定会彼此连通，它们可能处于不同的树中
  UnionFind uf(n + 1);  //所以要用并查集
  int ans = 0;
  int i = 0;
  while (uf.cnt > 1) {
    if (!uf.isConnected(edges[i][1], edges[i][2])) {
      ans += edges[i][0];
      uf.un(edges[i][1], edges[i][2]);
    }
    ++i;
  }
  printf("%d\n", ans);
}
```
{% enddetails %}

## [D. 神奇的数字串](http://acm.csust.edu.cn/contest/129/problem/D)

### 涉及的知识

1. 前缀和

2. 单调队列

### 思路

约定：`nums[i]` 表示第 `i` 个数字，`nums` 初始大小为 `n`。  

对于 `nums[i]` 移位 `k` 次后就位于 `[(i + k) % n]`，为了简化移位操作可以将数组复制一份添加到原数组后面，这样 `[k, ..., k + n - 1]` 就是移位 `k` 次后得到的数字串了。  

如果直接暴力枚举，复杂度为 `O(n^2)`，注意到 `1 <= n <= 1e6`，很可能会超时，所以需要优化。  

优化的方式是采用单调队列和前缀和，使用 `index[i]` 记录前 `i` 个元素的前缀和，对于区间 `[l, r]`，用 `queMin.front()` 记录 `index[l, r]` 中的最小值，具体实现请参考代码，这样时间复杂度就降到了 `O(n)`。  

{% details 代码 %}
```cpp
#include <deque>
#include <iostream>
#include <vector>
using namespace std;

int main() {
  int n;
  scanf("%d", &n);
  vector<int> nums;
  for (int i = 0; i < n; ++i) {
    int num;
    scanf("%d", &num);
    nums.push_back(num);
  }
  for (int i = 0; i < n; ++i) {
    nums.push_back(nums[i]);
  }
  vector<int> index{0};
  for (int i = 0; i < 2 * n; ++i) {
    index.push_back(index.back() + nums[i]);
  }

  // 存放 [l, r] 中对最小值有贡献的元素
  // queMin.front 始终是 [l, r] 中的最小值，在每次移动时维护这个性质即可
  deque<int> queMin;
  for (int i = 1; i <= n; ++i) {
    // 单调队列需要和队尾比较，因为可能出现新元素不小于队首但小于队尾的情况，这时依然需要更新队列
    while (queMin.size() && queMin.back() > index[i]) queMin.pop_back();
    queMin.push_back(index[i]);
  }
  int l = 1, r = n;
  int ans = 0;
  while (l <= n) {

    // 注意单调队列中存放的是整个扩展数组的前缀和
    if (queMin.front() - index[l - 1] >= 0) ++ans;

    if (index[l] == queMin.front()) queMin.pop_front();
    ++l;
    ++r;
    while (queMin.size() && index[r] < queMin.back()) queMin.pop_back();
    queMin.push_back(index[r]);
  }
  printf("%d\n", ans);
}
```
{% enddetails %}

## [E. 矩阵](http://acm.csust.edu.cn/contest/129/problem/E)

### 涉及的知识

1. 简单的数学推导

2. 前缀和

3. 线段树

### 思路

线段树学得不好，谁能帮我写一下……  

{% details 代码 %}
```cpp
#include <iostream>
#include <vector>
using namespace std;
using ll = long long;

ll gcd(ll a, ll b) {
  if (b == 0) return a;
  return gcd(b, a % b);
}

vector<ll> as, bs;
vector<ll> idx{0};
vector<ll> tree;

void build(int l, int r, int p) {
  if (l == r) {
    tree[p] = bs[l];
    return;
  }
  int m = (l + r) / 2;
  build(l, m, p * 2);
  build(m + 1, r, p * 2 + 1);
  tree[p] = gcd(tree[p * 2], tree[p * 2 + 1]);
}

ll getGcd(int l, int r, int begin, int end, int p) {
  if (l <= begin && end <= r) {
    return tree[p];
  }
  int m = (begin + end) / 2;
  if (l <= m && m < r) {
    return gcd(getGcd(l, r, begin, m, p * 2),
               getGcd(l, r, m + 1, end, p * 2 + 1));
  }
  if (l > m) {
    return getGcd(l, r, m + 1, end, p * 2 + 1);
  }
  return getGcd(l, r, begin, m, p * 2);
}

int main() {
  int n;
  scanf("%d", &n);
  for (int i = 0; i < n; ++i) {
    ll num;
    scanf("%lld", &num);
    as.push_back(num);
    idx.push_back(idx.back() + num);
  }

  for (int i = 0; i < n; ++i) {
    ll num;
    scanf("%lld", &num);
    bs.push_back(num);
  }

  tree = vector<ll>(4 * n);
  build(0, n - 1, 1);

  int q;
  scanf("%d", &q);
  while (q--) {
    int x1, y1, x2, y2;
    scanf("%d%d%d%d", &x1, &y1, &x2, &y2);
    ll a = idx[x2] - idx[x1 - 1];
    ll b = getGcd(y1 - 1, y2 - 1, 0, n - 1, 1);
    printf("%lld\n", a * b);
  }
}
```
{% enddetails %}

## 参考链接

- [线段树](https://oi-wiki.org/ds/seg/)  

- [最小生成树](https://weread.qq.com/web/reader/7cc32910718ff66b7cc8d9dk341323f021e34173cb3824c)  

- [单调队列的练习题](https://leetcode-cn.com/problems/longest-continuous-subarray-with-absolute-diff-less-than-or-equal-to-limit/)  
