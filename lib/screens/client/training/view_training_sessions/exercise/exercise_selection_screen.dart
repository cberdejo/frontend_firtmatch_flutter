import 'dart:async';

import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/services/sesion_entrenamientos_service.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/widget/dialog.dart';
import 'package:fit_match/widget/exercise_list_item_seletable.dart';
import 'package:fit_match/widget/search_widget.dart';
import 'package:flutter/material.dart';

class ExecriseSelectionScreen extends StatefulWidget {
  final User user;

  const ExecriseSelectionScreen({super.key, required this.user});
  @override
  _ExecriseSelectionScreen createState() => _ExecriseSelectionScreen();
}

class _ExecriseSelectionScreen extends State<ExecriseSelectionScreen> {
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();

  List<Ejercicios> exercises = [];
  Map<int, int> selectedExercisesOrder = {};
  List<GrupoMuscular> muscleGroups = [];
  List<Equipment> equipment = [];

  String filtroBusqueda = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreExercisesOnScroll);
    _loadExercises();
    _initMuscleGroups();
    _initEquipment();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_loadMoreExercisesOnScroll);
    _debounce?.cancel();
  }

  void _loadMoreExercisesOnScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _loadExercises();
      }
    }
  }

  void _loadExercises() async {
    // Si no hay más posts o ya está cargando, retorna.
    if (!_hasMore || _isLoading) return;

    // Inicia la carga de posts.
    _setLoadingState(true);

    try {
      // Obtener ejercicios.
      List<Ejercicios> exercises = await EjerciciosMethods().getAllEjercicios(
        userId: widget.user.user_id,
        page: _currentPage,
        pageSize: _pageSize,
        name: filtroBusqueda.isNotEmpty
            ? filtroBusqueda
            : null, // Añadido filtro por nombre
      );
      if (exercises.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      }
      // Actualizar la lista de posts y el estado si el componente sigue montado.
      else if (mounted) {
        _updateExerciseList(exercises);
      }
    } catch (e) {
      print(e);
    } finally {
      // Finalmente, asegura que se actualice el estado de carga.
      if (mounted) {
        _setLoadingState(false);
      }
    }
  }

  void _updateExerciseList(List<Ejercicios> newExecises) {
    setState(() {
      _currentPage++;
      exercises.addAll(newExecises);
    });
  }

  void _initMuscleGroups() async {}

  void _initEquipment() async {}

  void _showDialog(String description) async {
    CustomDialog.show(
      context,
      Text(description),
      () {
        print('Diálogo cerrado');
      },
    );
  }

  void _selectExercise(Ejercicios ejercicio) {
    setState(() {
      if (selectedExercisesOrder.containsKey(ejercicio.exerciseId)) {
        selectedExercisesOrder.remove(ejercicio.exerciseId);
      } else {
        selectedExercisesOrder[ejercicio.exerciseId] =
            selectedExercisesOrder.length + 1;
      }
    });
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  void _setLoadingState(bool loading) {
    setState(() => _isLoading = loading);
  }

  void _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        filtroBusqueda = text;
      });

      // Iniciar una nueva búsqueda con el nuevo filtro
      exercises
          .clear(); // Limpia la lista actual antes de cargar nuevos resultados
      _currentPage = 1; // Restablece a la primera página
      _loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SearchWidget(
              text: filtroBusqueda,
              hintText: 'Buscar ejercicios',
              onChanged: (text) => _onSearchChanged(text),
            )),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Card(
              child: Text(
                'Crear ejercicio',
                style: const TextStyle(fontSize: 12, color: primaryColor),
                textScaler: width < webScreenSize
                    ? const TextScaler.linear(1)
                    : const TextScaler.linear(1.5),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  exercises.length + 1, // +1 para el posible indicador de carga
              itemBuilder: (context, index) {
                if (index < exercises.length) {
                  final isSelected = selectedExercisesOrder
                      .containsKey(exercises[index].exerciseId);
                  return BuildExerciseItem(
                    ejercicio: exercises[index],
                    isSelected: isSelected,
                    order: selectedExercisesOrder[exercises[index].exerciseId],
                    onSelectedEjercicio: (exercise) =>
                        _selectExercise(exercise),
                    onPressedInfo: () {
                      _showDialog(exercises[index].description != null
                          ? exercises[index].description!
                          : 'Sin descripción');
                    },
                  );
                } else {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container();
                }
              },
            ),
          ),
          selectedExercisesOrder.isNotEmpty
              ? _buildPersistentFooterButtons(MediaQuery.of(context).size.width)
              : Container(),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container();
  }

  Widget _buildPersistentFooterButtons(num width) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Text(
              'Añadir individualmente',
              style: const TextStyle(fontSize: 12, color: primaryColor),
              textScaler: width < webScreenSize
                  ? const TextScaler.linear(1)
                  : const TextScaler.linear(1.2),
            ),
          ),
          selectedExercisesOrder.length > 1
              ? ElevatedButton(
                  onPressed: () {
                    // Agrega como super set
                  },
                  child: Text(
                    'Añadir como super set',
                    style: const TextStyle(fontSize: 12, color: primaryColor),
                    textScaler: width < webScreenSize
                        ? const TextScaler.linear(1)
                        : const TextScaler.linear(1.2),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container();
  }
}

 

/*
 return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre de ejercicio',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Actualiza la lista de ejercicios según la búsqueda
              },
            ),
          ),
          DropdownButton<String>(
            value: muscleGroupFilter,
            onChanged: (String? newValue) {
              setState(() {
                muscleGroupFilter = newValue!;
                // Actualiza la lista de ejercicios según el filtro de grupo muscular
              });
            },
            items: <String>[
              'Todos los grupos musculares',
              'Pecho',
              'Espalda',
              // Añade más grupos musculares aquí
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          DropdownButton<String>(
            value: equipmentFilter,
            onChanged: (String? newValue) {
              setState(() {
                equipmentFilter = newValue!;
                // Actualiza la lista de ejercicios según el filtro de equipamiento
              });
            },
            items: <String>[
              'Todo el equipamiento',
              'Pesas',
              'Máquina',
              // Añade más opciones de equipamiento aquí
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  title: Text(exercise.name),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.check_circle,
                      color: blueColor,
                    ),
                    onPressed: () {
                      setState(() {
                        //isSelected
                      });
                    },
                  ),
                  onTap: () {
                    // Muestra información sobre el ejercicio o realiza alguna acción
                  },
                );
              },
            ),
          ),
        ],
      ),
      */