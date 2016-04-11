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

    public UserIndicatorWindow() {
        //this.user_manager = new Act.UserManager();
        
        //if (user_manager != null){
            //users = user_manager.list_users(); // Get users
       
            //get_current_user();

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
