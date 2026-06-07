// lib/features/academic/lecturer/widgets/workspace_profile_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/workspace_model.dart';
import '../../../../repositories/workspace_member_repository.dart';
import '../../../../repositories/user_repository.dart';

class WorkspaceProfileWidget extends StatelessWidget {
  final WorkspaceModel workspace;

  const WorkspaceProfileWidget({super.key, required this.workspace});

  // Fungsi untuk mengambil detail anggota dari Repository via Provider
  Future<List<Map<String, dynamic>>> _fetchMembers(BuildContext context) async {
    final memberRepo = context.read<WorkspaceMemberRepository>();
    final userRepo = context.read<UserRepository>();
    final members = await memberRepo.getMembers(workspace.id);
    
    List<Map<String, dynamic>> detailedMembers = [];
    for (var member in members) {
      final userProfile = await userRepo.getUser(member.studentId);
      detailedMembers.add({
        'role': member.isLeader ? 'Ketua' : 'Anggota',
        'name': userProfile.fullName,
        'email': userProfile.email
      });
    }
    return detailedMembers;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEstheticHeader(),
        const SizedBox(height: 28),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "Anggota Tim", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
          ),
        ),
        const SizedBox(height: 12),
        _buildEstheticMembersList(context), // Lempar context ke dalam fungsi
      ],
    );
  }

  // ==========================================
  // HEADER (Desain Modern Clean & Soft UI)
  // ==========================================
  Widget _buildEstheticHeader() {
    final bool hasTopic = workspace.topicName?.isNotEmpty ?? false;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.workspaces_outline, color: Colors.indigo.shade400, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  workspace.teamName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Topik Proyek:", 
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)
          ),
          const SizedBox(height: 8),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: hasTopic ? Colors.grey.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: hasTopic ? Colors.grey.shade200 : Colors.red.shade100),
            ),
            child: Text(
              hasTopic ? workspace.topicName! : "Topik belum ditentukan oleh mahasiswa",
              style: TextStyle(
                fontSize: 15,
                color: hasTopic ? Colors.black87 : Colors.red.shade400,
                fontWeight: hasTopic ? FontWeight.w600 : FontWeight.normal,
                fontStyle: hasTopic ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LIST ANGGOTA (Satu kotak menyatu bergaya iOS)
  // ==========================================
  Widget _buildEstheticMembersList(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchMembers(context), // <--- Gunakan fungsi _fetchMembers yang baru
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30), 
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.indigo)
            )
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.group_off_rounded, color: Colors.grey.shade400, size: 40),
                const SizedBox(height: 10),
                Text("Belum ada anggota kelompok", style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          );
        }
        
        final members = snapshot.data!;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02), 
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListView.separated(
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: members.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1, indent: 70, endIndent: 20),
            itemBuilder: (context, index) {
              final member = members[index];
              final isLeader = member['role'] == 'Ketua';
              
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: isLeader ? Colors.orange.shade50 : Colors.indigo.shade50,
                  child: Text(
                    member['name'].isNotEmpty ? member['name'].substring(0, 1).toUpperCase() : "?",
                    style: TextStyle(
                      color: isLeader ? Colors.orange.shade700 : Colors.indigo.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                title: Text(
                  member['name'], 
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    member['email'], 
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)
                  ),
                ),
                trailing: isLeader 
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade100)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: Colors.orange.shade400, size: 14),
                          const SizedBox(width: 4),
                          Text("Ketua", style: TextStyle(color: Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : null, 
              );
            },
          ),
        );
      },
    );
  }
}