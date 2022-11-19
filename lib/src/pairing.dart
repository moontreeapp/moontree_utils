/// gives a uniuqe int for every pair of integers, order matters. for example:
/// cantor(0, 0); // 0
/// cantor(1, 0); // 1
/// cantor(0, 1); // 2
/// cantor(2, 0); // 3
/// cantor(1, 1); // 4
/// cantor(0, 2); // 5
/// cantor(3, 0); // 6
/// cantor(2, 1); // 7
/// cantor(1, 2); // 8
/// cantor(0, 3); // 9
/// cantor(4, 0); // 10
/// cantor(3, 1); // 11
/// cantor(2, 2); // 12
/// cantor(1, 3); // 13
/// cantor(0, 4); // 14
/// cantor(5, 0); // 15
/// cantor(4, 1); // 16
/// cantor(3, 2); // 17
/// cantor(2, 3); // 18
int cantor(int n, int m) => (n + m) * (n + m + 1) ~/ 2 + m;
