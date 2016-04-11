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

public class UserIndicator : Budgie.Applet {

    public Gtk.Image? image = null;
    public Gtk.EventBox? ebox = null;
    public Gtk.Popover? popover = null;
    public Gtk.Box? menu = null;

    //public Act.User? current_user = null;
    //protected Act.UserManager? user_manager = null;
    //protected SList<Act.User>? users = null;
   
    public UserIndicator() {
        //this.user_manager = new Act.UserManager();
        
        //if (user_manager != null){
            //users = user_manager.list_users(); // Get users
       
            //get_current_user();
            string user_image = get_user_image();

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
        //}
    }
       
    // Create a Gtk.Box with the provided label and image
    Gtk.Box create_menuitem(string label_string, string image_source, bool is_icon) {
        Gtk.Box menu_item = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
 
        Gtk.Image image;

        if (!is_icon) {
            image = new Gtk.Image.from_file(image_source);
        } else {
            image = new Gtk.Image.from_icon_name(image_source, Gtk.IconSize.LARGE_TOOLBAR);
        }
        
        Gtk.Label label = new Gtk.Label(label_string);

        menu_item.pack_start(image, false, false, 0);
        menu_item.pack_start(label, false, false, 0);
        return menu_item;
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
            return "systems-user-symbolic";
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
