import 'package:flutter/material.dart';

class ServiceCategory {
  final String name;
  final IconData icon;

  const ServiceCategory({required this.name, required this.icon});
}

const List<ServiceCategory> appServiceCategories = [
  ServiceCategory(name: 'Zidărie și Structuri', icon: Icons.construction),
  ServiceCategory(name: 'Fundații și Betoane', icon: Icons.layers),
  ServiceCategory(name: 'Acoperișuri și Tinichigerie', icon: Icons.roofing_outlined),
  ServiceCategory(name: 'Dulgherie', icon: Icons.carpenter),
  ServiceCategory(name: 'Termoizolații și Hidroizolații', icon: Icons.thermostat_outlined),
  ServiceCategory(name: 'Demolări și Decopertări', icon: Icons.build_outlined),
  ServiceCategory(name: 'Instalații Electrice', icon: Icons.electrical_services_outlined),
  ServiceCategory(name: 'Instalații Sanitare', icon: Icons.water_drop_outlined),
  ServiceCategory(name: 'Instalații Termice', icon: Icons.local_fire_department),
  ServiceCategory(name: 'Montaj Obiecte Sanitare', icon: Icons.plumbing),
  ServiceCategory(name: 'Climatizare și Ventilație', icon: Icons.ac_unit_outlined),
  ServiceCategory(name: 'Reparații Electrocasnice', icon: Icons.devices_other),
  ServiceCategory(name: 'Zugrăveli și Vopsitorii', icon: Icons.format_paint_outlined),
  ServiceCategory(name: 'Montaj Gresie și Faianță', icon: Icons.grid_on_outlined),
  ServiceCategory(name: 'Montaj Parchet', icon: Icons.layers_outlined),
  ServiceCategory(name: 'Pereți și Tavane False', icon: Icons.view_quilt),
  ServiceCategory(name: 'Montaj Uși și Ferestre', icon: Icons.window),
  ServiceCategory(name: 'Asamblare Mobilier', icon: Icons.chair_outlined),
  ServiceCategory(name: 'Design Interior', icon: Icons.home_outlined),
  ServiceCategory(name: 'Curățenie Generală', icon: Icons.cleaning_services_outlined),
  ServiceCategory(name: 'Curățenie după Constructor', icon: Icons.cleaning_services),
  ServiceCategory(name: 'Curățare Geamuri', icon: Icons.window),
  ServiceCategory(name: 'Curățare Tapițerii', icon: Icons.weekend_outlined),
  ServiceCategory(name: 'Bone și Îngrijire Copii', icon: Icons.child_care_outlined),
  ServiceCategory(name: 'Îngrijire Vârstnici', icon: Icons.elderly_outlined),
  ServiceCategory(name: 'Întreținere Grădină', icon: Icons.grass_outlined),
  ServiceCategory(name: 'Toaletare Copaci', icon: Icons.park_outlined),
  ServiceCategory(name: 'Design Peisagistic', icon: Icons.landscape_outlined),
  ServiceCategory(name: 'Sisteme de Irigații', icon: Icons.water_outlined),
  ServiceCategory(name: 'Garduri și Porți', icon: Icons.fence),
  ServiceCategory(name: 'Pavaje și Alei', icon: Icons.texture),
  ServiceCategory(name: 'Curățare Jgheaburi', icon: Icons.water_damage_outlined),
  ServiceCategory(name: 'Muncă Agricolă Sezonieră', icon: Icons.agriculture_outlined),
  ServiceCategory(name: 'Utilaje Agricole', icon: Icons.precision_manufacturing_outlined),
  ServiceCategory(name: 'Transport și Mutări', icon: Icons.local_shipping_outlined),
  ServiceCategory(name: 'Deratizare/Dezinsecție/Dezinfecție', icon: Icons.pest_control),
];

