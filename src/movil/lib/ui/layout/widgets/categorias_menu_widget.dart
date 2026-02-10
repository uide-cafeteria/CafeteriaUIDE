import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class CategoriasMenuWidget extends StatefulWidget {
  const CategoriasMenuWidget({super.key});

  @override
  State<CategoriasMenuWidget> createState() => _CategoriasMenuWidgetState();
}

class _CategoriasMenuWidgetState extends State<CategoriasMenuWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardColor,
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.centerLeft, // ← fuerza alineación a la izquierda
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: const BoxDecoration(),
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        dividerHeight: 0,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.zero, // ← elimina TODO padding lateral del TabBar
        tabAlignment:
            TabAlignment.start, // ← clave: alinea las tabs a la izquierda
        tabs: [
          _buildTab("Almuerzos", 0),
          _buildTab("Desayunos", 1),
          _buildTab("Postres", 2),
          _buildTab("Otros", 3),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _tabController.index == index;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : AppTheme.primaryColor.withOpacity(0.8),
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
