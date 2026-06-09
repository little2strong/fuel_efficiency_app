import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/features/onboarding/onboarding_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          switch (controller.step.value) {
            case 0:
              return _SplashIntroStep(onNext: controller.nextStep);
            case 1:
              return _WelcomeStep(onContinue: controller.moveToSignIn);
            case 2:
              return _SignInStep(
                controller: controller,
                onContinue: controller.moveToVehicleMode,
              );
            case 3:
              return _VehicleModeStep(
                controller: controller,
                onContinue: controller.nextStep,
              );
            default:
              return _VehicleDetailsStep(
                controller: controller,
                onBack: controller.backStep,
                onSubmit: controller.saveAndContinue,
              );
          }
        }),
      ),
    );
  }
}

class _SplashIntroStep extends StatelessWidget {
  const _SplashIntroStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.speed_rounded,
            size: 92,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          Text(
            AppConstants.appName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Track real efficiency. Save more. Drive smarter.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Welcome!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover your vehicle\'s true efficiency by comparing what your vehicle claims vs what you actually achieve.',
          ),
          const SizedBox(height: 20),
          const _BulletText('Track fuel or charge logs'),
          const _BulletText('See real efficiency trends'),
          const _BulletText('Compare and save money'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInStep extends StatelessWidget {
  const _SignInStep({
    required this.controller,
    required this.onContinue,
  });

  final OnboardingController controller;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Text('Log in quickly to continue'),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.g_mobiledata_rounded),
            label: const Text('Continue with Google'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.apple),
            label: const Text('Continue with Apple'),
          ),
          const SizedBox(height: 14),
          const Text('or'),
          const SizedBox(height: 14),
          TextField(
            controller: controller.nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleModeStep extends StatelessWidget {
  const _VehicleModeStep({
    required this.controller,
    required this.onContinue,
  });

  final OnboardingController controller;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'What type of vehicle do you use?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text('Select your energy mode'),
          const SizedBox(height: 18),
          Obx(
            () => Column(
              children: EnergyMode.values
                  .map(
                    (mode) => _EnergyModeTile(
                      mode: mode,
                      selected: controller.selectedMode.value == mode,
                      onTap: () => controller.selectedMode.value = mode,
                    ),
                  )
                  .toList(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleDetailsStep extends StatelessWidget {
  const _VehicleDetailsStep({
    required this.controller,
    required this.onBack,
    required this.onSubmit,
  });

  final OnboardingController controller;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              Text(
                'Tell us about your vehicle',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: controller.selectedVehicleType.value,
                    decoration: const InputDecoration(labelText: 'Vehicle type'),
                    items: const [
                      DropdownMenuItem(value: 'Car', child: Text('Car')),
                      DropdownMenuItem(value: 'Motorbike', child: Text('Motorbike')),
                      DropdownMenuItem(value: 'Truck', child: Text('Truck')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedVehicleType.value = value;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.vehicleNameController,
                  decoration: const InputDecoration(labelText: 'Vehicle nickname'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.makeModelController,
                  decoration: const InputDecoration(labelText: 'Make / Model'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Year'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller.odometerController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Current odometer',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(
                  () {
                    final mode = controller.selectedMode.value;
                    return Column(
                      children: [
                        if (mode == EnergyMode.fuel || mode == EnergyMode.hybrid)
                          TextField(
                            controller: controller.claimedMpgController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Claimed MPG (optional)',
                            ),
                          ),
                        if (mode == EnergyMode.fuel || mode == EnergyMode.hybrid)
                          const SizedBox(height: 12),
                        if (mode == EnergyMode.charge || mode == EnergyMode.hybrid)
                          TextField(
                            controller: controller.batteryCapacityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Battery capacity kWh (optional)',
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSubmit,
              child: const Text('Save & Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnergyModeTile extends StatelessWidget {
  const _EnergyModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final EnergyMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: selected ? AppColors.primary.withValues(alpha: 0.1) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                mode == EnergyMode.fuel
                    ? Icons.local_gas_station
                    : mode == EnergyMode.charge
                        ? Icons.bolt
                        : Icons.auto_awesome_motion_rounded,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      mode.subtitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
