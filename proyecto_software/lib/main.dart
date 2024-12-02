import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FrutTech "Dale sabor a tu vida"',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class Product {
  final String name;
  final double price;
  final IconData icon;
  int quantity;

  Product({
    required this.name,
    required this.price,
    required this.icon,
    this.quantity = 1,
  });
}
class Purchase {
  final double totalAmount;
  final List<Product> products;

  Purchase({required this.totalAmount, required this.products});
}

class ShoppingCartController extends GetxController {
  final RxList<Product> cartItems = <Product>[].obs;
  final RxList<Purchase> purchaseHistory = <Purchase>[].obs;

  double get total =>
      cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  void addToCart(Product product) {
    cartItems.add(product);
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      cartItems[index].quantity = newQuantity;
    }
  }

  void makePurchase() {
    final List<Product> purchasedProducts = List.from(cartItems);
    final double totalAmount = total;
    final Purchase purchase = Purchase(totalAmount: totalAmount, products: purchasedProducts);
    purchaseHistory.add(purchase);
    cartItems.clear();
  }
}

class HomePage extends StatelessWidget {
  final ShoppingCartController cartController =
      Get.put(ShoppingCartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FrutTech'),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Productos Vegetarianos',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            SizedBox(height: 20),
            Text(
              '¡Descubre una amplia variedad de productos vegetarianos!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Get.to(ProductPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[900],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Ver Productos',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(LoginPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[900],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      print('Usuario ${user!.uid} ha iniciado sesión');
    } catch (e) {

      print('Error durante el inicio de sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ingrese su correo electrónico y contraseña',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            SizedBox(height: 20),
ElevatedButton(
  onPressed: () {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    signInWithEmailAndPassword(email, password);

    Get.to(PurchaseHistoryPage());
  },
              child: Text('Iniciar Sesión'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.to(RegisterPage());
              },
              child: Text(
                'Crear una cuenta',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductSearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  var searchText = ''.obs;

  void updateSearchText(String text) {
    searchText.value = text;
  }

  void clearSearchText() {
    searchController.clear();
    searchText.value = '';
  }
}

class ProductPage extends StatelessWidget {
  final ShoppingCartController cartController = Get.find();
  final ProductSearchController searchController = Get.put(ProductSearchController());

  final List<Product> products = [
    Product(name: 'Tofu', price: 3.49, icon: Icons.ramen_dining),
    Product(name: 'Batido fruta', price: 3.99, icon: Icons.local_cafe),
    Product(name: 'Queso vegano', price: 5.49, icon: Icons.local_pizza),
    Product(name: 'Sopa de miso', price: 3.99, icon: Icons.soup_kitchen),
    Product(name: 'Pizza vegana', price: 9.99, icon: Icons.local_pizza),
    Product(name: 'Nuggets soya', price: 6.99, icon: Icons.food_bank),
    Product(name: 'Pan integral', price: 2.49, icon: Icons.bakery_dining),
    Product(name: 'Yogur de coco', price: 4.29, icon: Icons.icecream),
    Product(name: 'Heladovegan', price: 6.49, icon: Icons.icecream),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddProductDialog(context);
            },
          ),
          Obx(() {
            return badges.Badge(
              badgeContent: Text(
                cartController.cartItems.length.toString(),
                style: TextStyle(color: Colors.white),
              ),
              showBadge: cartController.cartItems.isNotEmpty,
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Get.to(ShoppingCartPage());
                },
              ),
            );
          }),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Get.to(LoginPage());
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController.searchController,
              decoration: InputDecoration(
                labelText: 'Buscar',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clearSearchText();
                  },
                ),
              ),
              onChanged: (value) {
                searchController.updateSearchText(value);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              String searchText = searchController.searchText.value.toLowerCase();
              List<Product> filteredProducts = products.where((product) {
                return product.name.toLowerCase().contains(searchText);
              }).toList();

              return ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Row(
                        children: [
                          Icon(filteredProducts[index].icon), 
                          SizedBox(width: 8),
                          Text(filteredProducts[index].name),
                        ],
                      ),
                      subtitle: Text('\$${filteredProducts[index].price.toStringAsFixed(2)}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          cartController.addToCart(filteredProducts[index]);
                        },
                        child: Text('Añadir al carrito'),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController cantidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Añadir Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre del producto'),
                            inputFormatters: [
                LengthLimitingTextInputFormatter(11), 
              ], 
              ),

              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Precio del producto'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), 
                 LengthLimitingTextInputFormatter(9), 
              ],
              ),

              TextField(
                controller: cantidadController,
                decoration: InputDecoration(labelText: 'Cantidad del Producto'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4), // Limita la cantidad máxima
                ],
              )

            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                String name = nameController.text;
                double? price = double.tryParse(priceController.text);
                int? quantity = int.tryParse(cantidadController.text.trim());
                if (name.isNotEmpty && price != null && quantity != null && quantity > 0) {
                  products.add(Product(name: name, price: price, quantity: quantity, icon: Icons.local_offer));
                  Navigator.of(context).pop();
                } else {

                }
              },
              child: Text('Añadir'),
            ),
          ],
        );
      },
    );
  }
}



class ShoppingCartPage extends StatelessWidget {
  final ShoppingCartController cartController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito de Compras'),
      ),
      drawer: AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(cartController.cartItems[index].name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '\$${cartController.cartItems[index].price.toStringAsFixed(2)}'),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Text('Cantidad: '),
                                TextButton(
                                  onPressed: () {

                                    _editQuantity(context, index);
                                  },
                                  child: Obx(() => Text(
                                        '${cartController.cartItems[index].quantity}',
                                        style: TextStyle(
                                          color: Colors.green[900],
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            cartController.removeFromCart(index);
                            Get.snackbar(
                                'Eliminado', 'Producto eliminado del carrito');
                          },
                        ),
                      ),
                    );
                  },
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() => Text(
                  'Total: \$${cartController.total.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          ),
          ElevatedButton(
            onPressed: () {
              Get.to(PaymentPage());
            },
            child: Text('Realizar Pago'),
          ),
        ],
      ),
    );
  }

  void _editQuantity(BuildContext context, int index) {
    TextEditingController quantityController = TextEditingController(
        text: cartController.cartItems[index].quantity.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar cantidad'),
          content: TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Cantidad'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                int newQuantity = int.tryParse(quantityController.text) ?? 1;
                cartController.updateQuantity(index, newQuantity);
                Get.back();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final ShoppingCartController cartController = Get.find();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderNameController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  String? selectedMonth;
  String? selectedYear;

  final List<String> months = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12'
  ];

  final List<String> years = List<String>.generate(20, (index) => (2024 + index).toString());

  void _completePayment() {
  
    cartController.makePurchase();
    Get.snackbar('Pago Completado', 'Gracias por su compra.');
    Get.to(PurchaseHistoryPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(labelText: 'Número de Tarjeta'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16), 
              ],
            ),
            TextField(
              controller: cardHolderNameController,
              decoration: InputDecoration(labelText: 'Nombre en la Tarjeta'),
              inputFormatters: [
                LengthLimitingTextInputFormatter(16), 
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Mes de Expiración'),
                    value: selectedMonth,
                    items: months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Año de Expiración'),
                    value: selectedYear,
                    items: years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            TextField(
              controller: cvvController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'CVV'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3), 
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _completePayment,
              child: Text('Completar Pago'),
            ),
          ],
        ),
      ),
    );
  }
} 



class PurchaseHistoryPage extends StatelessWidget {
  final ShoppingCartController cartController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Compras'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              cartController.cartItems.clear();
              cartController.purchaseHistory.clear();
              Get.offAll(HomePage());
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Obx(() => cartController.purchaseHistory.isEmpty
          ? Center(
              child: Text('No hay historial de compras'),
            )
          : ListView.builder(
              itemCount: cartController.purchaseHistory.length,
              itemBuilder: (context, index) {
                final purchase = cartController.purchaseHistory[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compra ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Total: \$${purchase.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Productos:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: purchase.products.map((product) {
                            return Text(
                              '${product.name} - \$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
    );
  }
}


class RegisterPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Cuenta'),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Teléfono'),
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            TextFormField(
              controller: birthDateController,
              decoration: InputDecoration(labelText: 'Fecha de Nacimiento'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.snackbar('Registro Exitoso',
                    'Tu cuenta ha sido registrada exitosamente.',
                    snackPosition: SnackPosition.BOTTOM);

                nameController.clear();
                lastNameController.clear();
                phoneController.clear();
                emailController.clear();
                passwordController.clear();
                birthDateController.clear();

                Get.off(LoginPage());
              },
              child: Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'FrutTech',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Get.to(HomePage());
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Productos'),
            onTap: () {
              Get.to(ProductPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Carrito de Compras'),
            onTap: () {
              Get.to(ShoppingCartPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Historial de Compras'),
            onTap: () {
              Get.to(PurchaseHistoryPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.login),
            title: Text('Iniciar Sesión'),
            onTap: () {
              Get.to(LoginPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Registrar Cuenta'),
            onTap: () {
              Get.to(RegisterPage());
            },
          ),
        ],
      ),
    );
  }
}