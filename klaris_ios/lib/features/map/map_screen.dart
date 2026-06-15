import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../core/widgets/heat_indicator.dart';
import '../../data/models/prospect.dart';
import '../../data/repositories/prospects_repository.dart';

/// Map view of geocoded prospects. Tap pin → bottom sheet with name/score/CTA.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const _initialCamera = CameraPosition(
    target: LatLng(45.5017, -73.5673), // Montréal centre
    zoom: 11,
  );

  @override
  Widget build(BuildContext context) {
    final fg = context.klFg();
    final async = ref.watch(prospectsProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('map.title'), style: KlarisType.h3(fg)),
      ),
      child: SafeArea(
        child: async.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('$e', style: KlarisType.body(KlarisColors.destructive))),
          data: (list) {
            final geocoded = list.where((p) => p.latitude != null && p.longitude != null).toList();
            if (geocoded.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.map, size: 48, color: context.klMutedFg()),
                      const SizedBox(height: 12),
                      Text(ref.s('map.empty'), textAlign: TextAlign.center, style: KlarisType.body(context.klMutedFg())),
                    ],
                  ),
                ),
              );
            }

            final annotations = geocoded.map((p) => Annotation(
                  annotationId: AnnotationId(p.id),
                  position: LatLng(p.latitude!, p.longitude!),
                  icon: BitmapDescriptor.markerAnnotationWithHue(_hueFor(p.score)),
                  infoWindow: InfoWindow(
                    title: p.nom ?? '—',
                    snippet: '${p.score}/10 · ${p.secteur ?? ''}',
                    onTap: () => _showProspectSheet(context, p),
                  ),
                )).toSet();

            return Stack(
              children: [
                AppleMap(
                  initialCameraPosition: _initialCamera,
                  annotations: annotations,
                  myLocationEnabled: true,
                  compassEnabled: true,
                ),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.klCard(),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: context.klBorder()),
                    ),
                    child: Text(
                      ref.s('map.count').replaceFirst('{n}', '${geocoded.length}'),
                      style: KlarisType.bodySmall(fg).copyWith(fontFamily: 'GeistMono', fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _hueFor(int score) {
    // Match heat scale on a hue ring (BitmapDescriptor.markerAnnotationWithHue).
    if (score >= 7) return BitmapDescriptor.hueRed;       // hot
    if (score >= 4) return BitmapDescriptor.hueOrange;    // warm
    return BitmapDescriptor.hueAzure;                     // cold
  }

  void _showProspectSheet(BuildContext context, Prospect p) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        decoration: BoxDecoration(color: context.klBg(), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: context.klBorder(), borderRadius: BorderRadius.circular(2))),
                Row(
                  children: [
                    Expanded(child: Text(p.nom ?? '—', style: KlarisType.h2(context.klFg()))),
                    HeatLabel(score: p.score),
                  ],
                ),
                if (p.secteur != null) ...[
                  const SizedBox(height: 6),
                  Text(p.secteur!, style: KlarisType.bodySmall(context.klMutedFg())),
                ],
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/prospects/${p.id}');
                  },
                  child: Text('Voir la fiche', style: KlarisType.body(KlarisColors.primaryFg).copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
