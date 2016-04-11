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
 
public class WeatherWidget : Gtk.Box {
    private Budgie.HeaderWidget? header = null;
    private Gtk.Revealer? revealer = null;
    private GWeather.Location current_location = null; // Define current_location as GWeather.Location
    
    public bool expanded {
        public set {
            this.revealer.set_reveal_child(value);
        }
        public get {
            return this.revealer.get_reveal_child();
        }
        default = true;
    }
    
    public WeatherWidget(){
        Object(orientation: Gtk.Orientation.VERTICAL);
        
        current_location = GWeather.Location.get_world(); // Create a new GWeather.Location
        string location_name = current_location.get_name();
        
        header = new Budgie.HeaderWidget(current_location.get_name(), get_best_forecast_icon(current_location), false);
        pack_start(header, false, false);

        revealer = new Gtk.Revealer();
        pack_start(revealer, false, false, 0);        
    }
    
    // This function will return the more relevant / best icon relating to the forecase of location
    public string get_best_forecast_icon(GWeather.Location location){
        if (location == null){
            return "";
        }
        
        GWeather.Info location_info = new GWeather.Info(location, GWeather.ForecastType.LIST); // Get the information of this location
        return location_info.get_symbolic_icon_name(); // Return the symbolic icon name
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