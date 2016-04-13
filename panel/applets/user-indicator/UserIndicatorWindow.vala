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

public const int WINDOW_WIDTH = 250;

public class UserIndicatorWindow : Gtk.Popover {

    //public Act.User? current_user = null;
    //protected Act.UserManager? user_manager = null;
    //protected SList<Act.User>? users = null;

    public Gtk.Box? menu = null;

    public UserIndicatorWindow(Gtk.Widget? window_parent) {
        Object(relative_to: window_parent);
        //this.user_manager = new Act.UserManager();
        
        //if (user_manager != null){
            //users = user_manager.list_users(); // Get users
       
            //get_current_user();

            // Menu creation
            menu = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            Gtk.ListBox items = new Gtk.ListBox();

            get_style_context().add_class("user-menu");       
            items.get_style_context().add_class("content-box");
        
            string user_image = get_user_image();
            string user_name = get_user_name();

            // User Menu Creation
            IndicatorItem user_menu = new IndicatorItem(user_name, user_image, true);

            // The rest
            Gtk.Separator separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);

            IndicatorItem lock_menu = new IndicatorItem(_("Lock"), "system-lock-screen-symbolic", false);
            IndicatorItem suspend_menu = new IndicatorItem(_("Suspend"), "media-playback-pause-symbolic", false);
            IndicatorItem reboot_menu = new IndicatorItem(_("Restart"), "media-playlist-repeat-symbolic", false);
            IndicatorItem shutdown_menu = new IndicatorItem(_("Shutdown"), "system-shutdown-symbolic", false);

            // Adding stuff
            items.add(user_menu);
            items.add(separator);
            items.add(lock_menu);
            items.add(suspend_menu);
            items.add(reboot_menu);
            items.add(shutdown_menu);
            
            menu.pack_start(items, false, false, 0); 
            add(menu);

            set_size_request(WINDOW_WIDTH, 0);
        //}   
    }

    // Get the current user
    /*void get_current_user() {
        if (this.users == null){
            return;
        }
        
        foreach (Act.User user in this.users) {
            if (user.is_logged_in()) {
                this.current_user = user;
                break;
            }
        }
    }*/
    
    // Get the user image and if we fallback to icon_name
    string get_user_image() {
        //if ((this.current_user != null) && (this.current_user.icon_file != "")) { // If User has icon
          //  return current_user.icon_file;
        //} else {
            return USER_SYMBOLIC_ICON;
        //}       
    }

    // Get the User's name
    string get_user_name() {
        string user_name;
        
        /*if (this.current_user != null) {
            user_name = this.current_user.user_name; // Default user_name to current user's username
            
            if (this.current_user.real_name != ""){ // If a real name is set
                user_name = this.current_user.real_name;
            }
        } else {*/
            user_name = _("User");
        //}
        
        return user_name;
    }   
}

public class IndicatorItem : Gtk.Button {
    public IndicatorItem(string label_string, string image_source, bool? add_arrow) {
        Gtk.Box menu_item = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        Gtk.Image image;

        int image_size = 16;

        if (image_source.has_prefix("file:///")) {
            image_size = 24;
            image = new Gtk.Image.from_file(image_source);
        } else {
            if (image_source == USER_SYMBOLIC_ICON) {
                image_size = 24;
            }

            image = new Gtk.Image.from_icon_name(image_source, Gtk.IconSize.INVALID);
        }
        
        image.pixel_size = image_size; // Change to pixel size
        
        Gtk.Label label = new Gtk.Label(label_string);

        menu_item.pack_start(image, false, false, 0);
        menu_item.pack_start(label, false, false, 0);

        if (add_arrow) {
            Gtk.Image arrow = new Gtk.Image.from_icon_name("pan-down-symbolic", Gtk.IconSize.MENU);
            menu_item.pack_end(arrow, false, false, 0);
        }

        add(menu_item);
        get_style_context().add_class("indicator-item");
        get_style_context().add_class("flat");
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
