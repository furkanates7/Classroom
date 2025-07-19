import 'package:flutter/material.dart';
import 'create_class_screen.dart';
import 'role_selection_screen.dart';
import '../services/class_manager.dart';
import '../models/class.dart';

class HomeScreen extends StatefulWidget {
  final String? selectedRole;
  
  HomeScreen({this.selectedRole});
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.selectedRole;
  }

  final List<Widget> _screens = [];

  @override
  Widget build(BuildContext context) {
    // Rol seçilmemişse rol seçim ekranına git
    if (_selectedRole == null) {
      return RoleSelectionScreen();
    }

    _screens.clear();
    _screens.addAll([
      ClassesTab(selectedRole: _selectedRole!),
      AssignmentsTab(selectedRole: _selectedRole!),
      ProfileTab(selectedRole: _selectedRole!),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text('Classroom'),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () {
              setState(() {
                _selectedRole = null;
              });
            },
            tooltip: 'Rol Değiştir',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Sınıflar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Ödevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class ClassesTab extends StatefulWidget {
  final String selectedRole;
  
  ClassesTab({required this.selectedRole});
  
  @override
  _ClassesTabState createState() => _ClassesTabState();
}

class _ClassesTabState extends State<ClassesTab> {
  List<ClassModel> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<ClassModel> classes;
      if (widget.selectedRole == "teacher") {
        classes = await ClassManager.getTeacherClasses('teacher_1');
      } else {
        classes = await ClassManager.getStudentClasses();
      }
      
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classroom\'a Hoş Geldiniz!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Rol: ${widget.selectedRole == "teacher" ? "Öğretmen" : "Öğrenci"}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          
          if (widget.selectedRole == "teacher") ...[
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateClassScreen(),
                  ),
                );
                // Sınıf oluşturulduktan sonra listeyi yenile
                _loadClasses();
              },
              icon: Icon(Icons.add),
              label: Text('Yeni Sınıf Oluştur'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 16),
          ],
          
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _classes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.class_,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Henüz sınıf yok',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.selectedRole == "teacher" 
                                  ? 'İlk sınıfınızı oluşturun'
                                  : 'Bir sınıfa katılın',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _classes.length,
                        itemBuilder: (context, index) {
                          final classItem = _classes[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Icon(
                                  Icons.class_,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                classItem.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(classItem.subject),
                                  if (classItem.description.isNotEmpty)
                                    Text(
                                      classItem.description,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                ],
                              ),
                              trailing: widget.selectedRole == "teacher"
                                  ? IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await ClassManager.deleteClass(classItem.id);
                                        _loadClasses();
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class AssignmentsTab extends StatelessWidget {
  final String selectedRole;
  
  AssignmentsTab({required this.selectedRole});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Henüz ödev yok',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sınıflarınızdaki ödevler burada görünecek',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final String selectedRole;
  
  ProfileTab({required this.selectedRole});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(
                          selectedRole == "teacher" ? Icons.person : Icons.school,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedRole == "teacher" ? "Öğretmen" : "Öğrenci",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              selectedRole == "teacher" 
                                  ? "Sınıf oluşturabilir ve yönetebilirsiniz"
                                  : "Sınıflara katılabilir ve ödevleri görüntüleyebilirsiniz",
                              style: TextStyle(
                                color: Colors.grey[600],
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
          
          SizedBox(height: 24),
          
          ListTile(
            leading: Icon(Icons.swap_horiz),
            title: Text('Rol Değiştir'),
            subtitle: Text('Farklı bir rol ile devam et'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RoleSelectionScreen(),
                ),
              );
            },
          ),
          
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Hakkında'),
            subtitle: Text('Classroom Eğitim Platformu'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Classroom'),
                  content: Text('Eğitim platformu v1.0\n\nÖğretmenler ve öğrenciler için tasarlanmış modern bir sınıf yönetim sistemi.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Tamam'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 