import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  bool editing = false;
  bool loading = true;
  bool saving = false;
  String? error;
  String? success;
  Map<String, dynamic>? userData;
  Map<String, dynamic> formData = {};

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  Future<void> _fetchProfile() async {
    setState(() {
      loading = true;
      error = null;
      success = null;
    });
    try {
      final data = await _userService.getProfile();
      setState(() {
        userData = data;
        loading = false;
        editing = false;
        formData = {
          "name": data["name"] ?? "",
          "email": data["email"] ?? "",
          "cnp": data["patient_detail"]?["cnp"] ?? "",
          "birthdate": data["patient_detail"]?["birthdate"] ?? "",
          "gender": data["patient_detail"]?["gender"] ?? "",
          "phone": data["patient_detail"]?["phone"] ?? "",
          "address": data["patient_detail"]?["address"] ?? "",
        };
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      saving = true;
      error = null;
      success = null;
    });
    try {
      await _userService.updateProfile(formData);
      setState(() {
        success = "Datele au fost actualizate!";
        editing = false;
      });
      _fetchProfile();
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        saving = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  String getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    final parts = name.trim().split(" ");
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  String getAvatarUrl(String name) {
    final initials = getInitials(name);
    return "https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(initials)}&backgroundColor=30cfd0,330867&radius=50";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : userData == null
          ? Center(child: Text(error ?? "Eroare necunoscută."))
          : SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(18, 26, 18, 70),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // Avatar + buton de editare pe același rând
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xff30cfd0).withOpacity(0.15),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: NetworkImage(getAvatarUrl(formData["name"] ?? "")),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (!loading && !editing)
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 3,
                        child: InkWell(
                          customBorder: CircleBorder(),
                          onTap: () => setState(() => editing = true),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.edit,
                              color: Color(0xff30cfd0),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 22),
                Text(
                  formData["name"] ?? "",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Color(0xff330867),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(formData["email"] ?? "",
                    style: TextStyle(color: Colors.grey[700], fontSize: 17)),
                SizedBox(height: 20),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            label: "Nume și prenume",
                            icon: Icons.person,
                            enabled: editing,
                            initialValue: formData["name"],
                            onChanged: (v) => formData["name"] = v,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: "Email",
                            icon: Icons.email,
                            enabled: editing,
                            initialValue: formData["email"],
                            onChanged: (v) => formData["email"] = v,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: "CNP",
                            icon: Icons.credit_card,
                            enabled: editing,
                            initialValue: formData["cnp"],
                            onChanged: (v) => formData["cnp"] = v,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: "Data nașterii",
                            icon: Icons.cake,
                            enabled: editing,
                            initialValue: formData["birthdate"],
                            onChanged: (v) => formData["birthdate"] = v,
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: formData["gender"].toString().isEmpty
                                ? null
                                : formData["gender"].toString(),
                            icon: Icon(Icons.arrow_drop_down, color: Color(0xff30cfd0)),
                            items: [
                              DropdownMenuItem(
                                child: Text('Feminin'),
                                value: 'Feminin',
                              ),
                              DropdownMenuItem(
                                child: Text('Masculin'),
                                value: 'Masculin',
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: "Gen",
                              prefixIcon: Icon(Icons.wc, color: Color(0xff30cfd0)),
                              enabled: editing,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onChanged: editing
                                ? (v) => setState(() => formData["gender"] = v!)
                                : null,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: "Telefon",
                            icon: Icons.phone,
                            enabled: editing,
                            initialValue: formData["phone"],
                            onChanged: (v) => formData["phone"] = v,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: "Adresă",
                            icon: Icons.location_on,
                            enabled: editing,
                            initialValue: formData["address"],
                            onChanged: (v) => formData["address"] = v,
                          ),
                          SizedBox(height: 20),
                          if (error != null)
                            Text(error!, style: TextStyle(color: Colors.red)),
                          if (success != null)
                            Text(success!, style: TextStyle(color: Colors.green[800])),
                          if (editing)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: Icon(Icons.cancel, color: Colors.redAccent),
                                    label: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                                      child: Text("Renunță",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.redAccent, width: 1.6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: Colors.redAccent.withOpacity(0.07),
                                    ),
                                    onPressed: saving
                                        ? null
                                        : () => setState(() {
                                      editing = false;
                                      success = null;
                                      error = null;
                                      formData = {
                                        "name": userData!["name"] ?? "",
                                        "email": userData!["email"] ?? "",
                                        "cnp": userData!["patient_detail"]?["cnp"] ?? "",
                                        "birthdate": userData!["patient_detail"]?["birthdate"] ?? "",
                                        "gender": userData!["patient_detail"]?["gender"] ?? "",
                                        "phone": userData!["patient_detail"]?["phone"] ?? "",
                                        "address": userData!["patient_detail"]?["address"] ?? "",
                                      };
                                    }),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: saving
                                        ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                        : Icon(Icons.save),
                                    label: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                                      child: Text("Salvează",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xff30cfd0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: saving ? null : _updateProfile,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required bool enabled,
    required String? initialValue,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xff30cfd0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[50],
      ),
      onChanged: onChanged,
    );
  }
}
