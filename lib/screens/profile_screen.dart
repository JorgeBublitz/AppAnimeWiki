import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

/// Tela de Perfil. Sem backend de contas ainda, o "login" aqui é só estado
/// local (não persiste entre aberturas do app) — serve para já deixar o
/// fluxo de navegação e a UI prontos para quando existir uma API de contas.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  String? _displayName;

  Future<void> _goToLogin() async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (success == true && mounted) {
      setState(() {
        _isLoggedIn = true;
        _displayName = _emailToDisplayName();
      });
    }
  }

  Future<void> _goToSignup() async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
    if (success == true && mounted) {
      setState(() {
        _isLoggedIn = true;
        _displayName = _emailToDisplayName();
      });
    }
  }

  String _emailToDisplayName() => 'Otaku';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cor1,
      appBar: AppBar(
        backgroundColor: AppColors.cor1,
        elevation: 0,
        title: Text(
          'Perfil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _isLoggedIn
              ? _LoggedInHeader(name: _displayName!)
              : _GuestHeader(onLogin: _goToLogin, onSignup: _goToSignup),
          if (_isLoggedIn) ...[
            const SizedBox(height: 32),
            _SectionLabel('Conta'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Sair',
              onTap: () => setState(() {
                _isLoggedIn = false;
                _displayName = null;
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  const _GuestHeader({required this.onLogin, required this.onSignup});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 42,
          backgroundColor: AppColors.cor2,
          child: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 44),
        ),
        const SizedBox(height: 16),
        Text(
          'Você ainda não entrou',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Entre para salvar favoritos e preferências.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSignup,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cor3),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Criar conta',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cor4,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Entrar',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoggedInHeader extends StatelessWidget {
  final String name;
  const _LoggedInHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.cor4,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cor2,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
