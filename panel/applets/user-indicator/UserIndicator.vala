/*
 * This file is part of budgie-desktop
 * 
 * Copyright (C) 2015-2016 Solus Project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

public static const string USER_SYMBOLIC_ICON = "system-users-symbolic";

public class UserIndicator : Budgie.Plugin, Peas.ExtensionBase
{
    public Budgie.Applet get_panel_widget(string uuid)
    {
        return new UserIndicatorApplet(uuid);
    }
}

public class UserIndicatorApplet : Budgie.Applet {

    private unowned Budgie.PopoverManager? manager = null;
    public string uuid { public set ; public get; }

    public Gtk.Image? image = null;
    public Gtk.EventBox? ebox = null;
    public Gtk.Popover? popover = null;
    public Gtk.Box? menu = null;

    public UserIndicator(string uuid) {
        Object(uuid: uuid);
        image = new Gtk.Image.from_icon_name(USER_SYMBOLIC_ICON, Gtk.IconSize.MENU);
        
        ebox = new Gtk.EventBox();
        add(ebox);

        ebox.add(image);            
        
        // Popover & Popover Menu stuff
        menu = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
    
        string user_name = get_user_name();

        Gtk.Box user_menu = create_menuitem(user_name, user_image, (user_image == USER_SYMBOLIC_ICON));
        Gtk.Box lock_menu = create_menuitem(_("Lock"), "system-lock-screen-symbolic", true);
        Gtk.Box suspend_menu = create_menuitem(_("Suspend"), "media-playback-pause-symbolic", true);
        Gtk.Box reboot_menu = create_menuitem(_("Restart"), "media-playlist-repeat-symbolic", true);
        Gtk.Box shutdown_menu = create_menuitem(_("Shutdown"), "system-shutdown-symbolic", true);
        
        menu.pack_start(user_menu, false, false, 0);
        menu.pack_start(suspend_menu, false, false, 0);
        menu.pack_start(reboot_menu, false, false, 0);
        menu.pack_start(shutdown_menu, false, false, 0);
        add(menu);

        popover = new Gtk.Popover(ebox);

        show_all();
    }
}

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
