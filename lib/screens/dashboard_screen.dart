import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final User? user = authProvider.user;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                },
              ),
            ],
          ),
          body: user == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Card
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      user.name.isNotEmpty 
                                          ? user.name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome, ${user.name}!',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          user.email,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            user.primaryRole.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue[800],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quick Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: _buildQuickActions(user),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Recent Activity
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.info, color: Colors.blue),
                          title: const Text('Welcome to Reusemart!'),
                          subtitle: const Text('Start exploring the app features'),
                          trailing: Text(
                            'Now',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  List<Widget> _buildQuickActions(User user) {
    List<Map<String, dynamic>> actions = [];

    // Common actions for all users
    actions.addAll([
      {
        'icon': Icons.person,
        'title': 'Profile',
        'color': Colors.blue,
        'onTap': () {},
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'color': Colors.grey,
        'onTap': () {},
      },
    ]);

    // Role-specific actions
    if (user.hasRole('buyer')) {
      actions.addAll([
        {
          'icon': Icons.shopping_cart,
          'title': 'My Orders',
          'color': Colors.green,
          'onTap': () {},
        },
        {
          'icon': Icons.favorite,
          'title': 'Wishlist',
          'color': Colors.red,
          'onTap': () {},
        },
      ]);
    }

    if (user.hasRole('consignor')) {
      actions.addAll([
        {
          'icon': Icons.inventory,
          'title': 'My Items',
          'color': Colors.orange,
          'onTap': () {},
        },
        {
          'icon': Icons.analytics,
          'title': 'Sales Report',
          'color': Colors.purple,
          'onTap': () {},
        },
      ]);
    }

    if (user.hasRole('admin')) {
      actions.addAll([
        {
          'icon': Icons.dashboard,
          'title': 'Admin Panel',
          'color': Colors.indigo,
          'onTap': () {},
        },
        {
          'icon': Icons.people,
          'title': 'Manage Users',
          'color': Colors.teal,
          'onTap': () {},
        },
      ]);
    }

    return actions.map((action) {
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: action['onTap'],
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon'],
                  size: 32,
                  color: action['color'],
                ),
                const SizedBox(height: 8),
                Text(
                  action['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
