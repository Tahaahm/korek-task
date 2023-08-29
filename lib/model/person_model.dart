class PersonModel {
  final String name;
  final String categories;
  final int status;
  final double price;

  PersonModel(
      {required this.name,
      required this.categories,
      required this.status,
      required this.price});
}

List<PersonModel> items = [
  PersonModel(
      name: "Ali", categories: "TOP G", status: 5, price: 10000000000000),
  PersonModel(name: "Shalaw", categories: "TOP", status: 3, price: 122121),
  PersonModel(
      name: "Taha", categories: "TOP G", status: 5, price: 10000000000000),
  PersonModel(name: "Jawamer", categories: "G", status: 2, price: 1),
];
