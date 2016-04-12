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

            // Popover & Popover Menu stuff
            menu = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
        
            string user_image = get_user_image();
            string user_name = get_user_name();

            // User Menu Creation
            IndicatorItem user_menu = new IndicatorItem(user_name, user_image);
            user_menu.margin_top = 10;
            
            user_menu.arrow = new Gtk.Image.from_icon_name("pan-down-symbolic", Gtk.IconSize.MENU);
            user_menu.pack_start(user_menu.arrow, false, false, 0);

            // The rest
            Gtk.Separator separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);

            IndicatorItem lock_menu = new IndicatorItem(_("Lock"), "system-lock-screen-symbolic");
            IndicatorItem suspend_menu = new IndicatorItem(_("Suspend"), "media-playback-pause-symbolic");
            IndicatorItem reboot_menu = new IndicatorItem(_("Restart"), "media-playlist-repeat-symbolic");
            
            IndicatorItem shutdown_menu = new IndicatorItem(_("Shutdown"), "system-shutdown-symbolic");
            shutdown_menu.margin_bottom = 10;

            menu.pack_start(user_menu, false, false, 0);
            menu.pack_start(separator, false, false, 0);
            menu.pack_start(lock_menu, false, false, 0);
            menu.pack_start(suspend_menu, false, false, 0);
            menu.pack_start(reboot_menu, false, false, 0);
            menu.pack_start(shutdown_menu, false, false, 0);
            add(menu);

            set_size_request(250, 0);
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

public class IndicatorItem : Gtk.Box {
    public Gtk.Image arrow { public set ; public get; }
    public Gtk.Image? image;

    public IndicatorItem(string label_string, string image_source) {
        Gtk.Box menu_item = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
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
        menu_item.pack_start(label, true, true, 0);
        
        menu_item.baseline_position = Gtk.BaselinePosition.CENTER;
        menu_item.margin_start = 10;
        menu_item.margin_end = 10;

        add(menu_item);
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
