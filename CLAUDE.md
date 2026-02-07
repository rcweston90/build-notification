# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

macOS native notifications for Claude Code task completion. Uses `osascript` to trigger notifications via Script Editor, with support for both Mac and iPhone (including during Focus modes).

## Repository Structure

- `install.sh` — Installer script that adds the `clauden` function to `~/.zshrc`
- `claude-code-notifications-setup.md` — Manual setup guide and configuration reference

## Usage

Run `bash install.sh` to install, then `source ~/.zshrc` to load. Use `clauden` instead of `claude` to get notifications on completion.

## Key Concept

The `clauden` shell function wraps the `claude` CLI, captures the exit code, and fires a macOS notification with different sounds for success (Glass) and failure (Basso).
