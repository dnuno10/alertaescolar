import 'package:flutter/material.dart';
import '../models/models.dart';
import '../app/app_theme.dart';
import 'custom_card.dart';

class StudentCard extends StatelessWidget {
  final Alumno student;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StudentCard({
    super.key,
    required this.student,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          // Avatar del estudiante
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage:
                student.fotoUrl != null ? NetworkImage(student.fotoUrl!) : null,
            child: student.fotoUrl == null
                ? Icon(
                    Icons.person,
                    size: 32,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // Información del estudiante
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.nombre,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.grado,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.key,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      student.llave,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Estado y trailing
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Indicador de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: student.activo
                      ? AppTheme.successColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  student.activo ? 'Activo' : 'Inactivo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: student.activo ? AppTheme.successColor : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              if (trailing != null) ...[
                const SizedBox(height: 8),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
