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

public const string USER = _("User");
public const string UNABLE_CONTACT = "Unable to contact ";
public const int WINDOW_WIDTH = 250;

[DBus (name="org.gnome.SessionManager")]
public interface SessionManager : Object
{
    public abstract async void Reboot() throws Error;
    public abstract async void Shutdown() throws Error;
}

[DBus (name="org.freedesktop.DisplayManager.Seat")]
public interface DMSeat : Object
{
    public abstract void lock() throws IOError;
}

public class UserIndicatorWindow : Gtk.Popover {
    public Gtk.Box? menu = null;
    public Gtk.Revealer? user_section = null;

    private DMSeat? saver = null;
    private SessionManager? session = null;
    private LogindInterface? logind_interface = null;
    
    private AccountsInterface? user_manager = null;
    private string? current_user = null;
    private PropertiesInterface? current_user_props = null;
    
    private IndicatorItem? user_item = null;

    async void setup_dbus() {
        var path = Environment.get_variable("XDG_SEAT_PATH");
        
        try {
            user_manager = yield Bus.get_proxy(BusType.SYSTEM, "org.freedesktop.Accounts", "/org/freedesktop/Accounts");
            
            string uid = user_manager.find_user_by_name(current_user);
            message("UID: %s", uid);
            try {
                try {
                    current_user_props = yield Bus.get_proxy(BusType.SYSTEM, "org.freedesktop.Accounts", uid);
                    update_userinfo();
                    current_user_props.properties_changed.connect(update_userinfo);
                } catch (Error e) {
                    warning(UNABLE_CONTACT + "Account User Service: %s", e.message);
                }
            } catch (Error e) {
                warning(UNABLE_CONTACT + "Account User Service: %s", e.message);
            }
        } catch (Error e) {
            warning(UNABLE_CONTACT + "Accounts Service: %s", e.message);
        }            
       
        try {
            logind_interface = yield Bus.get_proxy(BusType.SYSTEM, "org.freedesktop.login1", "/org/freedesktop/login1");
        } catch (Error e) {
            warning(UNABLE_CONTACT + "logind: %s", e.message);
        }

        try {
            saver = yield Bus.get_proxy(BusType.SYSTEM, "org.freedesktop.DisplayManager", path);
        } catch (Error e) {
            warning(UNABLE_CONTACT + "login manager: %s", e.message);
            return;
        }

        try {
            session = yield Bus.get_proxy(BusType.SESSION, "org.gnome.SessionManager", "/org/gnome/SessionManager");
        } catch (Error e) {
            warning(UNABLE_CONTACT + "GNOME Session: %s", e.message);
        }
    }

    public UserIndicatorWindow(Gtk.Widget? window_parent) {
        Object(relative_to: window_parent);
        current_user = GLib.Environment.get_user_name();

        setup_dbus.begin();

        // Menu creation
        menu = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        Gtk.ListBox items = new Gtk.ListBox();

        get_style_context().add_class("user-menu");       
        items.get_style_context().add_class("content-box");

        // User Menu Creation

        user_item = new IndicatorItem(_("User"), USER_SYMBOLIC_ICON, true); // Default to "User" and symbolic icon
        user_section = create_usersection();

        // The rest
        Gtk.Separator separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);

        IndicatorItem lock_menu = new IndicatorItem(_("Lock"), "system-lock-screen-symbolic", false);
        IndicatorItem suspend_menu = new IndicatorItem(_("Suspend"), "media-playback-pause-symbolic", false);
        IndicatorItem reboot_menu = new IndicatorItem(_("Restart"), "media-playlist-repeat-symbolic", false);
        IndicatorItem shutdown_menu = new IndicatorItem(_("Shutdown"), "system-shutdown-symbolic", false);

        // Adding stuff
        items.add(user_item);
        items.add(user_section);
        items.add(separator);
        items.add(lock_menu);
        items.add(suspend_menu);
        items.add(reboot_menu);
        items.add(shutdown_menu);
        
        menu.pack_start(items, false, false, 0); 
        add(menu);

        set_size_request(WINDOW_WIDTH, 0);

        // Events
        
        user_item.button_release_event.connect((e) => {
            if (e.button != 1) {
                return Gdk.EVENT_PROPAGATE;
            }
            toggle_usersection();
            return Gdk.EVENT_STOP;
        });
        
        lock_menu.button_release_event.connect((e) => {
            if (e.button != 1) {
                return Gdk.EVENT_PROPAGATE;
            }
            lock_screen();
            return Gdk.EVENT_STOP;                
        });

        reboot_menu.button_release_event.connect((e) => {
            if (e.button != 1) {
                return Gdk.EVENT_PROPAGATE;
            }
            reboot();
            return Gdk.EVENT_STOP;
        });

        shutdown_menu.button_release_event.connect((e) => {
            if (e.button != 1) {
                return Gdk.EVENT_PROPAGATE;
            }
            shutdown();
            return Gdk.EVENT_STOP;
        });

        suspend_menu.button_release_event.connect((e) => {
            if (e.button != 1) {
                return Gdk.EVENT_PROPAGATE;
            }
            suspend();
            return Gdk.EVENT_STOP;
        });

        this.closed.connect(() => { // When the UserIndicatorWindow closes
            hide_usersection(); // Ensure User Section is hidden.
        });
    }

    private Gtk.Revealer create_usersection() {
        Gtk.Revealer user_section = new Gtk.Revealer();
        Gtk.Box user_section_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        //IndicatorItem switch_user_menu = new IndicatorItem(_("Switch User"), "network-transmit-receive-symbolic", false);
        IndicatorItem logout_menu = new IndicatorItem(_("Logout"), "application-exit-symbolic", false);
        //user_section_box.pack_start(switch_user_menu, false, false, 0); // Add the Switch User item
        user_section_box.pack_start(logout_menu, false, false, 0); // Add the Logout item
        user_section.add(user_section_box); // Add the User Section box
        
        return user_section;
    }    

    public void toggle_usersection() {
        if (user_section != null){
            if (!user_section.child_revealed) { // If the User Section is not revealed
                show_usersection();
            } else {
                hide_usersection();
            }
        }
    }

    public void show_usersection() {
        if (!user_section.child_revealed) {
            user_section.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            user_section.reveal_child = true;
        }
    }

    public void hide_usersection() {
        if (user_section.child_revealed) {
            user_section.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
            user_section.reveal_child = false;
        }
    }
    
    // Set up User info in user_item
    public void update_userinfo() {
        string user_image = get_user_image();
        string user_name = get_user_name();
        
        user_item.set_image(user_image); // Ensure we have updated image
        user_item.set_label(user_name); // Ensure we have updated label
    }

    // Get the user image and if we fallback to icon_name
    string get_user_image() {
        string image = USER_SYMBOLIC_ICON; // Default to symbolic icon
        
        if (current_user_props != null) {
            try {
                string icon_file = current_user_props.get("org.freedesktop.Accounts.User", "IconFile").get_string();
                if (icon_file != "") {
                    image = icon_file;
                }
            } catch (Error e) {
                warning("Failed to fetch IconFile: %s", e.message);
            }
        }
        
        message("Fetched image: %s", image);
        return image;   
    }

    // Get the User's name
    string get_user_name() {
        string user_name = current_user; // Default to current_user
        
        if (current_user_props != null) {
            try {
                string real_name = current_user_props.get("org.freedesktop.Accounts.User", "RealName").get_string();

                if (real_name != ""){ // If a real name is set
                    user_name = real_name;
                }
            } catch (Error e) {
                warning("Failed to fetch RealName: %s", e.message);
            }
        }
        
        message("Fetched name: %s", user_name);
        return user_name;
    }

    void reboot() {
        if (session == null) {
            return;
        }

        session.Reboot.begin();
    }

    void shutdown() {
        if (session == null) {
            return;
        }

        session.Shutdown.begin();
    }
    
    void suspend() {
        if (logind_interface == null) {
            return;
        }
        
        try {
            logind_interface.suspend(true);
        } catch (Error e) {
            warning("Cannot suspend: %s", e.message);
        }
    }

    void lock_screen() {
        try {
            saver.lock();
        } catch (Error e) {
            warning("Cannot lock screen: %s", e.message);
        }
    }
}

// Individual Indicator Items
public class IndicatorItem : Gtk.Button {   
    private Gtk.Box? menu_item = null;
    private Gtk.Image? button_image = null;
    private Gtk.Label? button_label = null;

    private string? _image_source = null;
    public string? image_source {
        get { return _image_source; }
        set {
            _image_source = image_source;
            set_image(image_source);
        }
    }
    
    private string? _label_text = null;
    public string? label_text {
        get { return _label_text; }
        set {
            _label_text = label_text;
            set_label(label_text);
        }
    }

    public IndicatorItem(string label_string, string image_source, bool? add_arrow) {
        menu_item = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        set_image(image_source); // Set the image
        set_label(label_string); // Set the label

        menu_item.pack_start(button_image, false, false, 0);
        menu_item.pack_start(button_label, false, false, 0);

        if (add_arrow) {
            Gtk.Image arrow = new Gtk.Image.from_icon_name("pan-down-symbolic", Gtk.IconSize.MENU);
            menu_item.pack_end(arrow, false, false, 0);
        }

        add(menu_item);
        get_style_context().add_class("indicator-item");
        get_style_context().add_class("flat");
    }
    
    public void set_image(string source) {
        Gdk.Pixbuf pixbuf = null;

        if (this.button_image == null) {
            this.button_image = new Gtk.Image();
        }

        int image_size = 24;

        if (source.has_prefix("/")) {
            try {
                pixbuf = new Gdk.Pixbuf.from_file_at_size(source, image_size, image_size);
            } catch (Error e) {
                message("File does not exist: %s", e.message);
            }
        } else {
            try {
                if (source != USER_SYMBOLIC_ICON) {
                    image_size = 16;
                }

                Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default(); // Get the icon theme
                Gtk.IconInfo icon_info = icon_theme.lookup_icon(source, image_size, 0);
                pixbuf = icon_info.load_icon();               
            } catch (Error e) {
                message("Unable to get the default icon theme: %s", e.message);
            }
        }
        
        if (pixbuf != null) {
            this.button_image.set_from_pixbuf(pixbuf);
        }
    }
    
    public void set_label(string text) {
        if (this.button_label == null) {
            this.button_label = new Gtk.Label(text);
            this.button_label.use_markup = true;
        } else {
            this.button_label.set_label(text);
        }
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
