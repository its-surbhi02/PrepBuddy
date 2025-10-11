import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  // Ad objects
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // State tracking
  bool _isBannerAdLoaded = false;
  int _coins = 0;

  // --- ( Google's test IDs) ---
  final String _bannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
final String _interstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';
final String _rewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (err) {},
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (err) {},
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) return;
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        setState(() => _coins += reward.amount.toInt());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ads Showcase'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Coins: $_coins',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _interstitialAd?.show(),
              child: const Text('Show Interstitial Ad'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showRewardedAd,
              child: const Text('Watch Ad for Coins'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isBannerAdLoaded
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox(),
    );
  }
}
