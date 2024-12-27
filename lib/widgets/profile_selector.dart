import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/models/profile.dart';
import 'package:safe/providers/profile_provider.dart';

class ProfileSelector extends StatelessWidget {
  const ProfileSelector({super.key});

  void _showCreateProfileDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = const Color(0xFF1A2B3C);
    final primaryColor = context
                .read<ProfileProvider>()
                .currentProfile
                ?.primaryColor !=
            null
        ? Color(context.read<ProfileProvider>().currentProfile!.primaryColor)
        : const Color(0xFF4558C8);

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(
              'إنشاء ملف شخصي جديد',
              style: TextStyle(
                color: primaryColor,
                fontFamily: Constants.defaultFontFamily,
              ),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الملف الشخصي',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لون الملف الشخصي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 55,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          const Color(0xFF1A2B3C), // Dark blue-grey
                          const Color(0xFF2E4F4B), // Deep muted green
                          const Color(0xFF5D3A3A), // Muted deep red
                          const Color(0xFF4A3A5D), // Deep muted purple
                          const Color(0xFF6D4C3A), // Muted burnt orange
                          const Color(0xFF2E4F4F), // Deep muted teal
                          const Color(0xFF5D3A4F), // Deep muted pink
                          const Color(0xFF3A3A5D), // Deep muted indigo
                          const Color(0xFF607D8B), // Soft blue-grey
                        ].map((color) {
                          return Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedColor = color);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  boxShadow: selectedColor == color
                                      ? [
                                          BoxShadow(
                                            color: color.withOpacity(0.4),
                                            blurRadius: 1,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : null,
                                  border: selectedColor == color
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null,
                                ),
                                child: selectedColor == color
                                    ? const Icon(Icons.check,
                                        color: Colors.white)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: primaryColor,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    context.read<ProfileProvider>().createProfile(
                          nameController.text,
                          selectedColor,
                        );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: const Text('إنشاء'),
              ),
            ],
            actionsAlignment: MainAxisAlignment.start,
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, ProfileProvider provider) {
    final currentProfile = provider.currentProfile;
    if (currentProfile == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'الملفات الشخصية',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(currentProfile.primaryColor),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: provider.profiles.map((profile) {
                      bool isCurrentProfile = profile.id == currentProfile.id;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(profile.primaryColor),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(profile.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCurrentProfile)
                              Icon(Icons.check,
                                  color: Color(profile.primaryColor))
                            else if (!profile.isDefault)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  Navigator.pop(context);
                                  provider.deleteProfile(profile.id);
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditProfileDialog(
                                    context, provider, profile);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          if (!isCurrentProfile) {
                            provider.switchProfile(profile.id);
                            Navigator.pop(context);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateProfileDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة ملف شخصي جديد'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    ProfileProvider provider,
    Profile profile,
  ) {
    final nameController = TextEditingController(text: profile.name);
    final primaryColor = Color(profile.primaryColor);

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'تعديل الملف الشخصي',
            style: TextStyle(
              color: primaryColor,
              fontFamily: Constants.defaultFontFamily,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الملف الشخصي',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  provider.updateProfile(
                    profile.copyWith(name: nameController.text),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: const Text('حفظ'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.start,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final currentProfile = provider.currentProfile;
        if (currentProfile == null) return const SizedBox();

        final primaryColor = Color(currentProfile.primaryColor);

        return GestureDetector(
          onTap: () => _showProfileMenu(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_drop_down,
                  color: primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  currentProfile.name,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: primaryColor,
                  radius: 12,
                  child:
                      const Icon(Icons.person, size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
