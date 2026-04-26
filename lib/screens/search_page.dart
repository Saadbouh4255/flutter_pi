import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/tourist_place.dart';
import '../theme/app_theme.dart';
import 'place_detail_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  final _controller = TextEditingController();
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = ThemeProvider.of(context).isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recherche',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trouvez le lieu parfait',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkSubText
                          : AppColors.lightSubText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Search Bar ───────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _searchQuery.isNotEmpty
                            ? AppColors.gold
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                        width: _searchQuery.isNotEmpty ? 1.5 : 1.0,
                      ),
                      boxShadow: AppShadows.soft,
                    ),
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Restaurant, hôtel, marché...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(10),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppGradients.goldShimmer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.search_rounded,
                              color: Colors.white, size: 18),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: isDark
                                      ? AppColors.darkSubText
                                      : AppColors.lightSubText,
                                ),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: AnimatedBuilder(
                animation: appState,
                builder: (context, _) {
                  final places = _searchQuery.isEmpty
                      ? <TouristPlace>[]
                      : appState.searchPlaces(_searchQuery);

                  if (_searchQuery.isEmpty) {
                    return _IdleState(
                        isDark: isDark, pulseAnim: _pulse);
                  }

                  if (places.isEmpty) {
                    return _NoResultsState(
                        query: _searchQuery, isDark: isDark);
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SearchResultCard(
                            place: place, isDark: isDark),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH RESULT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SearchResultCard extends StatefulWidget {
  final TouristPlace place;
  final bool isDark;

  const _SearchResultCard({required this.place, required this.isDark});

  @override
  State<_SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<_SearchResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final isDark = widget.isDark;
    final color = place.category.color;

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PlaceDetailScreen(place: place)),
        );
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: AppShadows.card(color),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20)),
                child: place.buildImage(
                    height: 110, width: 110, fit: BoxFit.cover),
              ),
              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          place.category.displayName
                              .replaceAll(RegExp(r'[^\w\s]'), '')
                              .trim(),
                          style: GoogleFonts.poppins(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        place.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (place.moughataa != null)
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.darkSubText
                                    : AppColors.lightSubText),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                place.moughataa!,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkSubText
                                      : AppColors.lightSubText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Text(
                        place.description,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          height: 1.4,
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark
                        ? AppColors.darkSubText
                        : AppColors.lightSubText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IDLE STATE
// ─────────────────────────────────────────────────────────────────────────────

class _IdleState extends StatelessWidget {
  final bool isDark;
  final Animation<double> pulseAnim;

  const _IdleState({required this.isDark, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: pulseAnim,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppGradients.goldShimmer,
                shape: BoxShape.circle,
                boxShadow: AppShadows.glow(AppColors.gold),
              ),
              child: const Icon(Icons.travel_explore_rounded,
                  color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Explorez Nouakchott',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tapez un nom de restaurant,\nhôtel ou quartier...',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NO RESULTS STATE
// ─────────────────────────────────────────────────────────────────────────────

class _NoResultsState extends StatelessWidget {
  final String query;
  final bool isDark;

  const _NoResultsState({required this.query, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.catActivity.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 40, color: AppColors.catActivity),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aucun lieu ne correspond à\n"$query"',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
