// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
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
  _CameraState createState() {
    return _CameraState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  // This enum is from a different package, so a new value could be added at
  // any time. The example should keep working if that happens.
  // ignore: dead_code
  return Icons.camera;
}

void logError(String code, String? message) {
  if (message != null) {
    TratarErro.gravarLog(
        'camera.dart: Error: $code\nError Message: $message', 'ERRO');
  } else {
    TratarErro.gravarLog('camera.dart: $code', 'ERRO');
  }
}

class _CameraState extends State<Camera>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  bool enableAudio = false;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  bool cameraFrontal = false;

  final fotoHelper = FotosHelper();

  bool motraBotaoSalvar = false;
  List<Foto> midiasSalvas = [];
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  T? _ambiguate<T>(T? value) => value;

  @override
  void initState() {
    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);

    if (Sessao.cameras.isNotEmpty) {
      controller = CameraController(Sessao.cameras[0], ResolutionPreset.medium);
      onNewCameraSelected(controller!.description);
    }
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Câmera'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color:
                  controller != null && controller!.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
          /*_modeControlRowWidget(),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _cameraTogglesRowWidget(),
                _thumbnailWidget(),
              ],
            ),
          ),*/
          Visibility(
            visible: motraBotaoSalvar,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 15.0, left: 10.0, right: 10.0, bottom: 40.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: const Text(
                        'Salvar',
                        textScaleFactor: 1.2,
                      ),
                      onPressed: () {
                        setState(() {
                          Util.printDebug("Save button clicked");
                          Util.circularProgressIndicator(
                              context, "Salvando imagens...");
                          _salvar();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Câmera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onTapDown: (TapDownDetails details) =>
                      onViewFinderTap(details, constraints),
                );
              }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribui os widgets
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        const SizedBox(width: 24), // Espaço de 48 pixels à esquerda
        const Spacer(), // Adiciona um espaço flexível antes do ícone Icons.camera_alt
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: cameraController != null &&
              cameraController.value.isInitialized &&
              !cameraController.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
        ),
        const Spacer(), // Adiciona um espaço flexível depois do ícone Icons.camera_alt
        IconButton(
          iconSize: 24,
          icon: cameraFrontal
              ? const Icon(Icons.camera_rear)
              : const Icon(Icons.camera_front),
          color: Colors.blueGrey,
          onPressed: () {
            if (Sessao.cameras.isNotEmpty) {

              if (!cameraFrontal && Sessao.cameras.length > 1) {
                controller = CameraController(
                    Sessao.cameras[1], ResolutionPreset.medium);
                setState(() {
                  cameraFrontal = true;
                });
              } else {
                controller = CameraController(
                    Sessao.cameras[0], ResolutionPreset.medium);
                setState(() {
                  cameraFrontal = false;
                });
              }

              onNewCameraSelected(controller!.description);
            }
          },
        ),
      ],
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
        // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
        // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          imageFile = file;
        });
        if (file != null) {
          setState(() {
            motraBotaoSalvar = true;
          });

          Foto foto = Foto.notId(
              dataHora: DateTime.now().toString(),
              idUsuario: Sessao.idUsuario,
              arquivo: file.path,
              enviado: 0,
              finalizado: 0,
              fotoDeletada: 0);

          midiasSalvas.add(foto);

          showInSnackBar('Clique no botão salvar para continuar...');
        }
      }
    });
  }

  void onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      TratarErro.gravarLog('camera.dart $e', 'ERRO');
      _showCameraException(e);
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      TratarErro.gravarLog('camera.dart $e', 'ERRO');
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      TratarErro.gravarLog('camera.dart $e', 'ERRO');
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      TratarErro.gravarLog('camera.dart $e', 'ERRO');
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void _salvar() async {
    try {
      if (midiasSalvas.isNotEmpty) {
        await fotoHelper.insertListFoto(midiasSalvas);
      }

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Principal()));

    } on Exception catch (e) {
      TratarErro.gravarLog('camera.dart $e', 'ERRO');
    }
  }
}