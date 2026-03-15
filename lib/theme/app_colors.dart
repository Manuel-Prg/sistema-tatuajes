import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---- Brand / Primary ----
  static const Color primary = Color(0xFF6366F1); // Indigo vibrante

  // ---- Module accent colors (richer, more saturated) ----
  static const Color homeAccent       = Color(0xFF7C3AED); // Purple deep
  static const Color clientesAccent   = Color(0xFF0EA5E9); // Sky blue
  static const Color tatuadoresAccent = Color(0xFFA855F7); // Vivid purple
  static const Color disenosAccent    = Color(0xFFF59E0B); // Amber
  static const Color citasAccent      = Color(0xFFEF4444); // Red vivid
  static const Color pagosAccent      = Color(0xFF10B981); // Emerald
  static const Color reportesAccent   = Color(0xFF3B82F6); // Blue vivid
  static const Color configAccent     = Color(0xFF8B5CF6); // Violet

  // ---- Semantic colors ----
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);

  // ---- LIGHT THEME ----
  static const Color lightBackground      = Color(0xFFF1F5FB);
  static const Color lightSurface         = Color(0xFFFFFFFF);
  static const Color lightSidebarStart    = Color(0xFF1E1B4B); // indigo‑950
  static const Color lightSidebarEnd      = Color(0xFF312E81); // indigo‑800
  static const Color lightTextPrimary     = Color(0xFF1E293B);
  static const Color lightTextSecondary   = Color(0xFF64748B);
  static const Color lightDivider         = Color(0xFFE2E8F0);
  static const Color lightNavSelected     = Color(0x336366F1); // primary 20%
  static const Color lightNavText         = Color(0xFFE0E7FF); // sidebar label
  static const Color lightNavTextSub      = Color(0xFF818CF8); // sidebar sublabel

  // ---- DARK THEME ----
  static const Color darkBackground      = Color(0xFF0B0E1A);
  static const Color darkSurface         = Color(0xFF141828);
  static const Color darkSurfaceElevated = Color(0xFF1E2235);
  static const Color darkSidebarStart    = Color(0xFF0B0E1A);
  static const Color darkSidebarEnd      = Color(0xFF141828);
  static const Color darkTextPrimary     = Color(0xFFE8EAF6);
  static const Color darkTextSecondary   = Color(0xFF8892B0);
  static const Color darkDivider         = Color(0xFF1E2235);
  static const Color darkNavSelected     = Color(0x406366F1); // primary 25%

  // ---- Helpers ----
  static Color background(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? darkBackground : lightBackground;

  static Color surface(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color textPrimary(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  static Color divider(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? darkDivider : lightDivider;
}
