void main() {
  var a = 5;

  print(a.isEven);
  String b = test2(a) as String;

  print(b.length);
}

T? test<T extends Object?> (T input){
  return input;
}

int test2(int input){
  return input;
}