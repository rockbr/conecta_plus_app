// Ajustes feitos:
// - Adicionado preview com confirmação após tirar a foto
// - Movido lógica de salvar a imagem apenas após confirmação
// - Seleção do tipo movida para tela de confirmação

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:conecta_plus_app/database/fotos_helper.dart';
import 'package:conecta_plus_app/model/foto.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:conecta_plus_app/widget/principal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  bool enableAudio = false;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  bool cameraFrontal = false;
  final fotoHelper = FotosHelper();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Sessao.cameras.isNotEmpty) {
      controller = CameraController(Sessao.cameras[0], ResolutionPreset.medium);
      onNewCameraSelected(controller!.description);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Câmera')),
      body: Column(
        children: <Widget>[
          Expanded(child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: controller != null && controller!.value.isRecordingVideo ? Colors.redAccent : Colors.grey,
                width: 3.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Center(child: _cameraPreviewWidget()),
            ),
          )),
          _captureControlRowWidget(),
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized) {
      return const Text('Câmera não disponível', style: TextStyle(color: Colors.white));
    }
    return Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: CameraPreview(controller!, child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onTapDown: (details) => onViewFinderTap(details, constraints),
          );
        },
      )),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) => _baseScale = _currentScale;

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (controller == null || _pointers != 2) return;
    _currentScale = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);
    await controller!.setZoomLevel(_currentScale);
  }

  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const SizedBox(width: 24),
        const Spacer(),
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.camera_alt),
          color: Colors.amber,
          onPressed: controller != null && controller!.value.isInitialized
              ? () => _takeAndPreviewPicture()
              : null,
        ),
        const Spacer(),
        IconButton(
          iconSize: 24,
          icon: cameraFrontal ? const Icon(Icons.camera_rear) : const Icon(Icons.camera_front),
          color: Colors.amberAccent,
          onPressed: () {
            final nextCamera = cameraFrontal ? Sessao.cameras[0] : Sessao.cameras[1];
            controller = CameraController(nextCamera, ResolutionPreset.medium);
            cameraFrontal = !cameraFrontal;
            onNewCameraSelected(controller!.description);
          },
        ),
      ],
    );
  }

  Future<void> _takeAndPreviewPicture() async {
    final file = await takePicture();
    if (file == null) return;

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FotoPreviewPage(
          imagePath: file.path,
          onConfirm: (String tipoSelecionado) async {
            final foto = Foto.notId(
              dataHora: DateTime.now().toString(),
              idUsuario: Sessao.idUsuario,
              arquivo: file.path,
              nomeCliente: Sessao.nomeCliente,
              enviado: 0,
              finalizado: 0,
              fotoDeletada: 0,
              tipo: tipoSelecionado,
            );

            await fotoHelper.insertListFoto([foto]);

            if (mounted) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Principal()));
            }
          },
        ),
      ),
    );
  }

  Future<XFile?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return null;
    if (controller!.value.isTakingPicture) return null;
    try {
      return await controller!.takePicture();
    } catch (e) {
      TratarErro.gravarLog('camera.dart: $e', 'ERRO');
      return null;
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller?.setExposurePoint(offset);
    controller?.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    controller?.dispose();
    final newController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controller = newController;
    newController.addListener(() => setState(() {}));
    try {
      await newController.initialize();
      _maxAvailableZoom = await newController.getMaxZoomLevel();
      _minAvailableZoom = await newController.getMinZoomLevel();
    } catch (e) {
      TratarErro.gravarLog('Erro ao inicializar camera: $e', 'ERRO');
    }
    setState(() {});
  }
}

class _FotoPreviewPage extends StatefulWidget {
  final String imagePath;
  final Function(String tipoSelecionado) onConfirm;

  const _FotoPreviewPage({required this.imagePath, required this.onConfirm});

  @override
  State<_FotoPreviewPage> createState() => _FotoPreviewPageState();
}

class _FotoPreviewPageState extends State<_FotoPreviewPage> {
  String? _tipoSelecionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmação')),
      body: Column(
        children: [
          Expanded(child: Image.file(File(widget.imagePath))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo da Foto',
                    border: OutlineInputBorder(),
                  ),
                  value: _tipoSelecionado,
                  items: ['DDS', 'D.O', 'ENTRADA', 'EPI', 'EQUIPE', 'SAÍDA', 'OUTROS']
                      .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _tipoSelecionado = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tirar outra'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _tipoSelecionado == null
                          ? null
                          : () => widget.onConfirm(_tipoSelecionado!),
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}