/*
 * This file is part of budgie-desktop
 * 
 * Copyright (C) 2015-2016 Ikey Doherty <ikey@solus-project.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

namespace Budgie
{

[DBus (name="org.gnome.SessionManager")]
public interface SessionManager : Object
{
    public abstract async void Shutdown() throws Error;
}

[DBus (name="org.freedesktop.DisplayManager.Seat")]
public interface DMSeat : Object
{
    public abstract void lock() throws IOError;
}


class PowerStrip : Gtk.EventBox
{

    private DMSeat? saver = null;
    private SessionManager? session = null;

    private Gtk.Button? lock_btn = null;
    private Gtk.Button? power_btn = null;

    async void setup_dbus()
    {
        var path = Environment.get_variable("XDG_SEAT_PATH");
        try {
            saver = yield Bus.get_proxy(BusType.SYSTEM, "org.freedesktop.DisplayManager", path);
        } catch (Error e) {
            warning("Unable to contact login manager: %s", e.message);
            return;
        }
        try {
            session = yield Bus.get_proxy(BusType.SESSION, "org.gnome.SessionManager", "/org/gnome/SessionManager");
        } catch (Error e) {
            power_btn.sensitive = false;
            warning("Unable to contact GNOME Session: %s", e.message);
        }
    }
            
    public PowerStrip(Budgie.Raven? raven)
    {
        Gtk.Box? bottom = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 20);

        margin_top = 10;
        get_style_context().add_class("raven-header");
        get_style_context().add_class("powerstrip");
        get_style_context().add_class("bottom");
        bottom.halign = Gtk.Align.CENTER;
        bottom.margin_top = 5;
        bottom.margin_bottom = 5;
        add(bottom);

        get_style_context().add_class("primary-control");

        var btn = new Gtk.Button.from_icon_name("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        btn.clicked.connect(()=> {
            try {
                raven.set_expanded(false);
                Process.spawn_command_line_async("gnome-control-center");
            } catch (Error e) {
                message("Error invoking gnome-control-center: %s", e.message);
            }
        });
        btn.halign = Gtk.Align.START;
        btn.get_style_context().add_class("flat");
        bottom.pack_start(btn, false, false, 0);

        btn = new Gtk.Button.from_icon_name("system-lock-screen-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        btn.clicked.connect(()=> {
            raven.set_expanded(false);
            lock_screen();
        });
        lock_btn = btn;
        btn.halign = Gtk.Align.START;
        btn.get_style_context().add_class("flat");
        bottom.pack_start(btn, false, false, 0);

        btn = new Gtk.Button.from_icon_name("system-shutdown-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        power_btn = btn;
        btn.clicked.connect(()=> {
            try {
                raven.set_expanded(false);
                if (session == null) {
                    return;
                }
                /* TODO: Swap this out for gnome-session stuff */
                session.Shutdown.begin();
            } catch (Error e) {
                message("Error invoking end session dialog: %s", e.message);
            }
        });
        btn.halign = Gtk.Align.START;
        btn.get_style_context().add_class("flat");
        bottom.pack_start(btn, false, false, 0);

        lock_btn.no_show_all = true;
        lock_btn.hide();
        setup_dbus.begin((obj,res)=> {
            if (saver != null) {
                lock_btn.no_show_all = false;
                lock_btn.show_all();
            }
        });
    }

    void lock_screen() {

        try {
            saver.lock();
        } catch (Error e) {
            warning("Cannot lock screen: %s", e.message);
        }
    }    
}

} /* End namespace */

/*
 * Editor modelines  -  https://www.wireshark.org/tools/modelines.html
 *
 * Local variables:
 * c-basic-offset: 4
 * tab-width: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vi: set shiftwidth=4 tabstop=4 expandtab:
 * :indentSize=4:tabSize=4:noTabs=true:
 */
