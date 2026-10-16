// vkchord: press one key chord in the focused window, e.g. `vkchord ctrl+shift 47`
// (47 = Linux key code of V; see /usr/include/linux/input-event-codes.h).
//
// The chord goes out through a Wayland virtual keyboard (zwp_virtual_keyboard_v1)
// that uploads the seat's own keymap, so a key code means the same key as on
// the real keyboard, also in clients that ignore keymap changes (GTK3, Chromium,
// XWayland; wtype's generated keymap breaks there). The virtual keyboard sends
// its own modifier state, so keys held on the real keyboard (the Super of a
// niri bind) are not part of the chord, and niri binds never see it.
//
// Build: cc -O2 -o vkchord vkchord.c -lwayland-client  (uclip does it on demand)
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <wayland-client.h>

// virtual-keyboard-unstable-v1, as wayland-scanner would generate it.
static const struct wl_interface vk_interface;
static const struct wl_interface *types[] = {
    NULL, NULL, NULL, NULL, &wl_seat_interface, &vk_interface,
};
static const struct wl_message vk_requests[] = {
    {"keymap", "uhu", types},
    {"key", "uuu", types},
    {"modifiers", "uuuu", types},
    {"destroy", "", types},
};
static const struct wl_interface vk_interface = {
    "zwp_virtual_keyboard_v1", 1, 4, vk_requests, 0, NULL,
};
static const struct wl_message manager_requests[] = {
    {"create_virtual_keyboard", "on", types + 4},
};
static const struct wl_interface manager_interface = {
    "zwp_virtual_keyboard_manager_v1", 1, 1, manager_requests, 0, NULL,
};
enum { VK_KEYMAP, VK_KEY, VK_MODIFIERS, VK_DESTROY };

static struct wl_seat *seat;
static struct wl_proxy *manager;
static uint32_t keymap_format, keymap_size;
static int keymap_fd = -1;

static void global(void *data, struct wl_registry *reg, uint32_t name,
                   const char *interface, uint32_t version) {
    if (!seat && !strcmp(interface, wl_seat_interface.name))
        seat = wl_registry_bind(reg, name, &wl_seat_interface, 1);
    else if (!strcmp(interface, manager_interface.name))
        manager = wl_registry_bind(reg, name, &manager_interface, 1);
}
static void global_remove(void *data, struct wl_registry *reg, uint32_t name) {}
static const struct wl_registry_listener registry_listener = {global, global_remove};

static void keymap(void *data, struct wl_keyboard *kb, uint32_t format, int32_t fd,
                   uint32_t size) {
    keymap_format = format, keymap_fd = fd, keymap_size = size;
}
static void enter(void *data, struct wl_keyboard *kb, uint32_t serial,
                  struct wl_surface *surface, struct wl_array *keys) {}
static void leave(void *data, struct wl_keyboard *kb, uint32_t serial,
                  struct wl_surface *surface) {}
static void key(void *data, struct wl_keyboard *kb, uint32_t serial, uint32_t time,
                uint32_t key, uint32_t state) {}
static void modifiers(void *data, struct wl_keyboard *kb, uint32_t serial,
                      uint32_t depressed, uint32_t latched, uint32_t locked,
                      uint32_t group) {}
static const struct wl_keyboard_listener keyboard_listener = {
    keymap, enter, leave, key, modifiers,
};

int main(int argc, char **argv) {
    // xkb real modifiers have fixed indices in every keymap.
    uint32_t mods = 0;
    char *end = NULL;
    long code = argc == 3 ? strtol(argv[2], &end, 10) : 0;
    if (code <= 0 || code > 0x2ff || *end) {
        fprintf(stderr, "usage: vkchord ctrl|shift|alt|super[+...]|none KEYCODE\n");
        return 2;
    }
    for (char *mod = strtok(argv[1], "+"); mod; mod = strtok(NULL, "+")) {
        if (!strcmp(mod, "shift")) mods |= 1 << 0;
        else if (!strcmp(mod, "ctrl")) mods |= 1 << 2;
        else if (!strcmp(mod, "alt")) mods |= 1 << 3;
        else if (!strcmp(mod, "super")) mods |= 1 << 6;
        else if (strcmp(mod, "none")) {
            fprintf(stderr, "vkchord: unknown modifier '%s'\n", mod);
            return 2;
        }
    }

    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "vkchord: cannot connect to the Wayland display\n");
        return 1;
    }
    wl_registry_add_listener(wl_display_get_registry(display), &registry_listener, NULL);
    wl_display_roundtrip(display);
    if (!seat || !manager) {
        fprintf(stderr, "vkchord: compositor offers no seat or virtual keyboard\n");
        return 1;
    }
    // The seat sends its current keymap as soon as a keyboard is created.
    wl_keyboard_add_listener(wl_seat_get_keyboard(seat), &keyboard_listener, NULL);
    wl_display_roundtrip(display);
    if (keymap_fd < 0) {
        fprintf(stderr, "vkchord: the seat sent no keymap\n");
        return 1;
    }

    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    uint32_t t = ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
    struct wl_proxy *vk = wl_proxy_marshal_flags(manager, 0, &vk_interface, 1, 0, seat, NULL);
    wl_proxy_marshal_flags(vk, VK_KEYMAP, NULL, 1, 0, keymap_format, keymap_fd, keymap_size);
    wl_proxy_marshal_flags(vk, VK_MODIFIERS, NULL, 1, 0, mods, 0, 0, 0);
    wl_proxy_marshal_flags(vk, VK_KEY, NULL, 1, 0, t, (uint32_t)code, 1);
    wl_proxy_marshal_flags(vk, VK_KEY, NULL, 1, 0, t, (uint32_t)code, 0);
    wl_proxy_marshal_flags(vk, VK_MODIFIERS, NULL, 1, 0, 0, 0, 0, 0);
    wl_proxy_marshal_flags(vk, VK_DESTROY, NULL, 1, WL_MARSHAL_FLAG_DESTROY);
    int ok = wl_display_roundtrip(display) >= 0;
    wl_display_disconnect(display);
    return ok ? 0 : 1;
}
