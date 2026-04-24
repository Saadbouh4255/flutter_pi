import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Guide de Nouakchott',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4.0,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'lib/resources/NKTT.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 6,
                    shadowColor: Colors.teal.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(Icons.location_city, size: 48, color: Colors.teal),
                          const SizedBox(height: 12),
                          Text(
                            'Bienvenue à Nouakchott !',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Nouakchott est la vibrante capitale de la Mauritanie, située sur la côte atlantique du désert du Sahara. C'est un mélange unique de cultures, offrant des marchés animés, de superbes hôtels et des expériences inoubliables.",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Pourquoi utiliser cette application ?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.explore, color: Colors.white)),
                    title: Text('Découvrir les attractions', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Trouvez les meilleurs endroits à visiter, pour manger et vous détendre.'),
                  ),
                  const ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.category, color: Colors.white)),
                    title: Text('Guide par catégories', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Naviguez facilement à travers les marchés, les plages, les hôtels et plus encore.'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
