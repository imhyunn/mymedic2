void main() {
  // map() -> 리스트와 같은 여러뭉탱이를 대상으로 사용할 수 있는 함수!

  int a = 5;
  List<int> arr = [1, 2, 3, 4, 5];
  List<String> newArr = arr.map((element){
    return "$element번째";
  }).toList();

  print(newArr);


  print("$a");
  Map<String, dynamic> map = {
    "key1" : "value1",
    "key2" : "value2",
    "key3" : "value3",
    "key4" : "value1",
    "key5" : "value2",
  };

  print(map['key1']); // 결과는 무엇이 나올까요?


  // [1, 2, 3, 4, 5]
  // ["1번째", "2번째", "3번째", "4번째", "5번째"]
}

