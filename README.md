<p align="center">
<img height="80" alt="Althyn" src="https://github.com/user-attachments/assets/675f447b-dbf2-42cc-8a31-f7851afa1087" />
</p>
<p align="center">
  Adaptive user interface for desktop, mobile, and more.
</p>

> [!IMPORTANT]
> This is **Althyn-x11**, the X11 build of Althyn (developed and tested on Openbox). It exists as a
> compatibility track for non-Wayland systems and is **not** where active development happens.
>
> The prioritized, actively developed version is **[Althyn](https://github.com/TheVamoraProject/Althyn/)
> (Wayland)**. The upcoming **Vamora compositor** is Wayland-only and will not support X11 — Althyn-x11
> will not run under it. If you're starting fresh or just evaluating VamoraOS, use the Wayland build.

## One Interface, Every Screen

<a href="https://vamora.vercel.app/blog/vamui">VamoraUI</a> is a single set of rules for color, shape, and spacing — not a per-platform redesign. The same components and code paths adapt density automatically across phone, tablet, and desktop, so every surface stays recognizably Vamora.

- **Phone:** single column, bottom navigation, minimal controls
- **Tablet:** two-column density, navigation grows with the width
- **Desktop:** full grid density, side navigation, room for everything

## Components

This repo hosts the X11 builds of the Althyn shell:

- [`StatusBar/`](./StatusBar) — top status bar, start menu, calendar
- [`HomeScreen/`](./HomeScreen) — desktop/home layer (app grid, right-click actions)
- [`WelcomeScreen/`](./WelcomeScreen) — first-boot welcome flow

Each has its own README with build instructions. To build and install a full X11 session in one
go, see [`install.sh`](./install.sh).

## License

See [`LICENSE`](./LICENSE) in the project root.

---
<p align="center">
  <sub>
    Made by
    <a href="https://rb.gy/7jh0i9" target="_blank">
      <img src="https://github.com/user-attachments/assets/efb3ad9b-6b07-4488-9c16-79586297ee5d" alt="Vamora" height="10">
    </a>
  </sub>
</p>
