import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:manzoma/features/auth/presentation/cubit/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              const LoginView(),
              if (state is AuthLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  late AnimationController _animController;
  late Animation<Offset> _slideIn;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ⚡ تحميل الصور مسبقًا (من غير لاج)
    precacheImage(const AssetImage("assets/images/Asset 1.png"), context);
    precacheImage(const AssetImage("assets/images/patternBlue.png"), context);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          return isMobile ? _buildMobile(context) : _buildDesktop(context);
        },
      ),
    );
  }

  // ----- Mobile Layout -----
  Widget _buildMobile(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideIn,
              child: _loginCard(context, isMobile: true),
            ),
          ),
        ),
      ),
    );
  }

  // ----- Desktop Layout -----
  Widget _buildDesktop(BuildContext context) {
    return Row(
      children: [
        // Background side
        Expanded(
          flex: 1,
          child: Stack(
            children: [
              Image.asset(
                'assets/images/patternBlue.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                opacity: const AlwaysStoppedAnimation(0.08),
              ),
              Center(
                child: Hero(
                  tag: "logo",
                  child: Image.asset(
                    "assets/images/Asset 1.png",
                    width: 280,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Form side
        Expanded(
          flex: 1,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SlideTransition(
                position: _slideIn,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: _loginCard(context, isMobile: false),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ----- Login Form card -----
  Widget _loginCard(BuildContext context, {required bool isMobile}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: "logo",
                child: Image.asset("assets/images/Asset 1.png", width: 140),
              ),
              const SizedBox(height: 15),
              Text(
                "Welcome Back 👋",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) =>
                    v == null || !v.contains("@") ? "Enter valid email" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    v != null && v.length < 6 ? "Min 6 characters" : null,
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ),
              const SizedBox(height: 25),
              _animatedButton(context),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text("Quick Demo", style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _emailCtrl.text = "admin@demo.com";
                        _passCtrl.text = "demo123";
                      },
                      child: const Text("Admin"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _emailCtrl.text = "employee@demo.com";
                        _passCtrl.text = "demo123";
                      },
                      child: const Text("Employee"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ----- Nice Button with simple animation -----
  Widget _animatedButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (_formKey.currentState!.validate()) {
            context
                .read<AuthCubit>()
                .signIn(email: _emailCtrl.text, password: _passCtrl.text);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xff222DFF), Color(0xff0D47A1)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            "Sign In",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
