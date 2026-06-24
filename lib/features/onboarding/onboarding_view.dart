import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/core/widgets/app_logo.dart';
import 'package:fuel_efficiency_app/core/widgets/app_text_field.dart';
import 'package:fuel_efficiency_app/core/widgets/energy_mode_selector.dart';
import 'package:fuel_efficiency_app/features/onboarding/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final step = controller.step.value;
          return Column(
            children: [
              _TopBar(step: step, onBack: controller.back),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(step),
                    child: switch (step) {
                      0 => const _WelcomeStep(),
                      1 => const _LoginStep(),
                      2 => const _VehicleModeStep(),
                      _ => const _VehicleDetailsStep(),
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.step, required this.onBack});
  final int step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          AnimatedOpacity(
            opacity: step == 0 ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              onPressed: step == 0 ? null : onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(
              OnboardingController.lastStep + 1,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 7,
                width: index == step ? 22 : 7,
                decoration: BoxDecoration(
                  color: index == step ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<OnboardingController>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const AppLogo(size: 64),
          const SizedBox(height: 22),
          Text('Welcome!', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Track real efficiency vs dashboard estimates. Log fuel and '
            'charging stops, see your true MPG or mi/kWh, and save money.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          const _FeatureRow(
            icon: Icons.local_gas_station_rounded,
            title: 'Track Fuel or Charging',
            subtitle: 'Log fuel, charge and hybrid entries.',
          ),
          const _FeatureRow(
            icon: Icons.insights_rounded,
            title: 'See Real Efficiency',
            subtitle: 'Get real MPG or mi/kWh, not marketing numbers.',
          ),
          const _FeatureRow(
            icon: Icons.savings_rounded,
            title: 'Compare & Save More',
            subtitle: 'Improve efficiency and save money.',
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: controller.next,
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginStep extends StatelessWidget {
  const _LoginStep();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<OnboardingController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Obx(() {
        final signUp = controller.isSignUp.value;
        final authLoading = controller.isAuthLoading.value;
        return Form(
          key: controller.loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                signUp ? 'Create Account' : 'Welcome Back',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                signUp
                    ? 'Sign up to start tracking your real efficiency'
                    : 'Log in to continue',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              if (signUp) ...[
                AppTextField(
                  controller: controller.nameController,
                  label: 'Full Name',
                  hint: 'Your name',
                  validator: controller.validateName,
                ),
                const SizedBox(height: 16),
              ],
              AppTextField(
                controller: controller.emailController,
                label: 'Email',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    validator: controller.validatePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      hintText: '••••••',
                      suffixIcon: IconButton(
                        onPressed: controller.togglePassword,
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (!signUp) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: authLoading ? null : controller.resetPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton(
                onPressed: authLoading ? null : controller.submitAuth,
                child: authLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(signUp ? 'Sign Up' : 'Log In'),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: authLoading ? null : controller.toggleAuthMode,
                  child: Text.rich(
                    TextSpan(
                      text: signUp
                          ? 'Already have an account? '
                          : "Don't have an account? ",
                      style: theme.textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: signUp ? 'Log in' : 'Sign up',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _VehicleModeStep extends StatelessWidget {
  const _VehicleModeStep();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<OnboardingController>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Select your energy mode', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'This determines which fields and calculations you\'ll see when '
            'logging stops.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => EnergyModeSelector(
              selected: controller.selectedMode.value,
              onSelected: (mode) => controller.selectedMode.value = mode,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: controller.next,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleDetailsStep extends StatelessWidget {
  const _VehicleDetailsStep();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<OnboardingController>();
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Form(
              key: controller.vehicleFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell us about your vehicle',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You can edit this later anytime.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppTextField(
                    controller: controller.vehicleNameController,
                    label: 'Vehicle Nickname',
                    hint: 'My Car',
                    validator: (v) =>
                        controller.validateRequired(v, 'Nickname'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: controller.makeModelController,
                    label: 'Make / Model',
                    hint: 'Toyota Prius',
                    validator: (v) =>
                        controller.validateRequired(v, 'Make / Model'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vehicle Type',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.selectedVehicleType.value,
                      items: OnboardingController.vehicleTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedVehicleType.value = value;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: controller.yearController,
                          label: 'Year (Optional)',
                          hint: '2018',
                          numeric: true,
                          validator: controller.validateYear,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: controller.odometerController,
                          label: 'Odometer',
                          hint: '0',
                          numeric: true,
                          validator: controller.validateOdometer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final mode = controller.selectedMode.value;
                    return Column(
                      children: [
                        if (mode.usesFuel)
                          AppTextField(
                            controller: controller.claimedMpgController,
                            label: 'Claimed MPG (Optional)',
                            hint: '58.0',
                            numeric: true,
                          ),
                        if (mode.usesFuel) const SizedBox(height: 16),
                        if (mode.usesCharge)
                          AppTextField(
                            controller: controller.claimedMiPerKwhController,
                            label: 'Claimed mi/kWh (Optional)',
                            hint: '4.2',
                            numeric: true,
                          ),
                        if (mode.usesCharge) const SizedBox(height: 16),
                        if (mode.usesCharge)
                          AppTextField(
                            controller: controller.batteryCapacityController,
                            label: 'Battery Capacity kWh (Optional)',
                            hint: '40',
                            numeric: true,
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SizedBox(
            width: double.infinity,
            child: Obx(
              () => FilledButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.finish,
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save & Continue'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
