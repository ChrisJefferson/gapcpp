gap> LoadPackage("gapcpp", false);;
gap> x := CompileMethod("int f(int i) { return i; }", "f", 1);;
gap> x(2);
2
gap> x(-100);
-100
gap> q := CompileMethod("int f() { return 1;} ", "f", 0);;
gap> q();
1
gap> y := CompileMethod("std::vector<int> f(std::vector<int> i) { return i; }", "f", 1);;
gap> y([1,2,3]);
[ 1, 2, 3 ]
gap> y([]);
[  ]
gap> z := CompileMethod("std::pair<int, bool> f(std::pair<int, bool> i) { return i; }", "f", 1);;
gap> z([1,true]);
[ 1, true ]
gap> sorter := CompileMethod("""
> std::vector<int> s(std::vector<int> v)
> { 
>   std::sort(v.begin(), v.end());
>   return v;
> }""", "s", 1);;
gap> sorter([4,1,2,3,5]);
[ 1, 2, 3, 4, 5 ]
