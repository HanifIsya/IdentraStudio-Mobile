import 'package:flutter/material.dart';

// ─────────────────────────────────────────
// MODEL DATA PROJECT
// ─────────────────────────────────────────

class ProjectModel {
  final String clientName;
  final String clientInitials;
  final String date;
  final double progress; // 0.0 – 1.0
  final List<ProjectMilestoneModel> milestones;
  final List<ProjectFileModel> files;

  const ProjectModel({
    required this.clientName,
    required this.clientInitials,
    required this.date,
    required this.progress,
    required this.milestones,
    required this.files,
  });
}

class ProjectMilestoneModel {
  final String title;
  final String date;
  final MilestoneStatus status;

  const ProjectMilestoneModel({
    required this.title,
    required this.date,
    required this.status,
  });
}

enum MilestoneStatus { done, inProgress, pending }

class ProjectFileModel {
  final String name;
  final String uploadedBy;
  final String uploadDate;
  final String time;
  final IconData icon;
  final Color iconColor;

  const ProjectFileModel({
    required this.name,
    required this.uploadedBy,
    required this.uploadDate,
    required this.time,
    required this.icon,
    required this.iconColor,
  });
}

// ─────────────────────────────────────────
// DUMMY DATA (ganti dengan data dari backend)
// ─────────────────────────────────────────

const _dummyProject = ProjectModel(
  clientName: 'Lee Chanyeol',
  clientInitials: 'LH',
  date: '15 April 2026',
  progress: 0.7,
  milestones: [
    ProjectMilestoneModel(
      title: 'Requirements Gathering',
      date: 'Project Progress 4/13/2026',
      status: MilestoneStatus.done,
    ),
    ProjectMilestoneModel(
      title: 'Wireframing',
      date: 'Project Progress 4/15/2026',
      status: MilestoneStatus.done,
    ),
    ProjectMilestoneModel(
      title: 'Development',
      date: 'End Progress 5/5/2026',
      status: MilestoneStatus.pending,
    ),
  ],
  files: [
    ProjectFileModel(
      name: 'Requirements.pdf',
      uploadedBy: 'Uploaded April 30',
      uploadDate: 'Apr 30, 09:32',
      time: 'Apr 30, 09:32',
      icon: Icons.picture_as_pdf_outlined,
      iconColor: Color(0xFFE53935),
    ),
    ProjectFileModel(
      name: 'Wireframe.sketch',
      uploadedBy: 'Uploaded April 30',
      uploadDate: 'Apr 30, 09:22',
      time: 'Apr 30, 09:22',
      icon: Icons.brush_outlined,
      iconColor: Color(0xFFFF9800),
    ),
  ],
);

// ─────────────────────────────────────────
// PROJECTS SCREEN
// ─────────────────────────────────────────

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: ganti _dummyProject dengan data dari backend
    final project = _dummyProject;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            _buildHeader(project),
            const SizedBox(height: 16),

            // ── Project Progress Card ──
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Project Progress',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  const Text('Project Progress',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: project.progress,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE0E0E0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4A4E53)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(project.progress * 100).toInt()}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Milestones ──
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...project.milestones.map(
                      (m) => _buildMilestoneRow(m, project.milestones)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Project Files ──
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Project Files',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  ...project.files.map((f) => _buildFileRow(f)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ProjectModel project) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF7C6AF5),
          child: Text(project.clientInitials,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text(project.clientName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        const Text('Details',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A4E53))),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMilestoneRow(
      ProjectMilestoneModel milestone, List<ProjectMilestoneModel> all) {
    final isLast = all.last == milestone;

    Widget statusIcon;
    switch (milestone.status) {
      case MilestoneStatus.done:
        statusIcon = Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
              color: Color(0xFF4CAF50), shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        );
        break;
      case MilestoneStatus.inProgress:
        statusIcon = Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              shape: BoxShape.circle),
          child: const Icon(Icons.access_time,
              color: Colors.grey, size: 16),
        );
        break;
      case MilestoneStatus.pending:
        statusIcon = Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade100,
              shape: BoxShape.circle),
          child: const Icon(Icons.circle_outlined,
              color: Colors.grey, size: 16),
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Milestone bullet dengan warna berdasarkan status
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: milestone.status == MilestoneStatus.done
                  ? const Color(0xFF4A4E53)
                  : milestone.status == MilestoneStatus.inProgress
                      ? Colors.blue
                      : Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(milestone.date,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          statusIcon,
        ],
      ),
    );
  }

  Widget _buildFileRow(ProjectFileModel file) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: file.iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(file.icon, color: file.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${file.uploadedBy}  ${file.time}',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.add_circle_outline,
              color: Colors.grey, size: 22),
        ],
      ),
    );
  }
}
