/*
 * This file is part of budgie-desktop
 * 
 * Copyright (C) 2016 Ikey Doherty <ikey@solus-project.com>
 * Copyright (C) GNOME Shell Developers (Heavy inspiration, logic theft)
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

namespace Budgie {

/**
 * Simple callback, compatible with GNOME Shell API
 */
public delegate void ScreenshotCallback (Screenshot? shot,
                                         bool success,
                                         out Cairo.RectangleInt rect,
                                         string filename_used);

public class Screenshot : GLib.Object {


    public unowned Budgie.BudgieWM? wm { construct set ; public get; }

    private string? filename = null;
    private unowned ScreenshotCallback? cb = null;
    private bool include_frame = false;
    private bool include_cursor = false;

    Cairo.RectangleInt screenshot_area;

    public Screenshot(Budgie.BudgieWM? wm)
    {
        Object(wm: wm);
        screenshot_area = Cairo.RectangleInt() {
            x = 0, y = 0, width = 0, height = 0
        };
    }

    void grab_area_screenshot(Clutter.Actor? stage)
    {
        /* TODO: Implement */
    }

    /* Take a screenshot of the given area */
    public void take_area(int x, int y, int width, int height, string filename, ScreenshotCallback? cb)
    {
        unowned Meta.Screen? screen = wm.get_screen();
        unowned Clutter.Actor? stage = Meta.Compositor.get_stage_for_screen(screen);

        if (this.filename != null) {
            if (cb != null) {
                cb(this, false, null, "");
            }
            return;
        }

        this.filename = filename;
        this.cb = cb;
        this.screenshot_area = Cairo.RectangleInt() {
            x = x, y = y, width = width, height = height
        };

        Meta.Util.disable_unredirect_for_screen(screen);
        stage.paint.connect_after(grab_area_screenshot);
        stage.queue_redraw();
    }


    void grab_window_screenshot(Clutter.Actor? stage)
    {
        /* TODO: Implement */
    }

    /* Take a screenshot of the active window */
    public void take_window(bool include_frame, bool include_cursor, string filename, ScreenshotCallback? cb)
    {
        unowned Meta.Screen? screen = wm.get_screen();
        unowned Meta.Display? display = screen.get_display();

        unowned Meta.Window? window = display.get_focus_window();

        if (this.filename != null || window == null) {
            if (cb != null) {
                cb(this, false, null, "");
            }
            return;
        }

        this.filename = filename;
        this.cb = cb;
        this.include_frame = include_frame;
        this.include_cursor = include_cursor;

        unowned Clutter.Actor? stage = Meta.Compositor.get_stage_for_screen(screen);

        Meta.Util.disable_unredirect_for_screen(screen);
        stage.paint.connect_after(grab_window_screenshot);
        stage.queue_redraw();
    }

    void grab_screenshot(Clutter.Actor? stage)
    {
        /* TODO: Implement */
    }

    /* Take a screenshot of the whole desktop */
    public void take(bool include_cursor, string filename, ScreenshotCallback? cb)
    {
        unowned Meta.Screen? screen = wm.get_screen();
        unowned Clutter.Actor? stage = Meta.Compositor.get_stage_for_screen(screen);

        if (this.filename != null) {
            if (cb != null) {
                cb(this, false, null, "");
            }
            return;
        }

        this.filename = filename;
        this.cb = cb;
        this.include_cursor = include_cursor;

        Meta.Util.disable_unredirect_for_screen(screen);
        stage.paint.connect_after(grab_screenshot);
        stage.queue_redraw();
    }

} /* End Screenshot */

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
