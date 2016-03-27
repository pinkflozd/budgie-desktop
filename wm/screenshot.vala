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

    /* for le callbacks */
    SourceFunc? async_cb = null;
    private Cairo.ImageSurface? image = null;

    public Screenshot(Budgie.BudgieWM? wm)
    {
        Object(wm: wm);
        screenshot_area = Cairo.RectangleInt() {
            x = 0, y = 0, width = 0, height = 0
        };
    }

    private bool wrote_screenshot = false;
    private string? final_filename = null;


    OutputStream? get_stream_for_unique_path(string path, string filename, out string used_filename) throws Error
    {
        string? real_filename = null;

        if (filename.has_suffix(".png")) {
            real_filename = filename.substring(0, filename.length-4);
        } else {
            real_filename = filename;
        }

        int index = 0;
        string? name = null;

        while (true) {
            if (index == 0) {
                name = "%s.png".printf(real_filename);
            } else {
                name = "%s - %d.png".printf(real_filename, index);
            }

            var real_path = Path.build_filename(path, name, null);
            var file = File.new_for_path(real_path);
            var stream = file.create(FileCreateFlags.NONE, null);
            if (stream != null) {
                used_filename = real_path;
                return stream;
            }
            index++;
        }
        return null;
    }

    OutputStream? get_stream_for_filename(string filename, out string used_filename) throws Error
    {
        string path = Environment.get_user_special_dir(UserDirectory.PICTURES);
        if (!FileUtils.test(path, FileTest.EXISTS)) {
            path = Environment.get_home_dir();
            if (!FileUtils.test(path, FileTest.EXISTS)) {
                return null;
            }
        }

        string? tmp = null;
        var stream = this.get_stream_for_unique_path(path, filename, out tmp);
        used_filename = tmp;
        return stream;
    }

    OutputStream? prepare_stream(string filename, out string used_filename) throws Error
    {
        used_filename = null;
        if (Path.is_absolute(filename)) {
            var file = File.new_for_path(filename);
            used_filename = filename;
            return file.replace(null, false, FileCreateFlags.NONE, null);
        } else {
            string? tmp = null;
            var stream = get_stream_for_filename(filename, out tmp);
            used_filename = tmp;
            return stream;
        }
    }

    void *write_screenshot()
    {
        this.wrote_screenshot = false;

        string? filename_used = null;
        OutputStream? stream = null;

        /* Catch-all for the errors */
        try {
            stream = this.prepare_stream(this.filename, out filename_used);
        } catch (Error e) {
            Idle.add(this.async_cb);
            return null;
        }

        /* No stream */
        if (stream == null) {
            Idle.add(this.async_cb);
            return null;
        }
        this.final_filename = filename_used;

        var pixbuf = Gdk.pixbuf_get_from_surface(image, 0, 0, image.get_width(), image.get_height());

        try {
            if (!pixbuf.save_to_stream(stream, "png", null, null, "tEXt::Software", "gnome-screenshot", null)) {
                this.wrote_screenshot = false;
            } else {
                this.wrote_screenshot = true;
            }
        } catch (Error e) {
            this.wrote_screenshot = false;
        }

        Idle.add(this.async_cb);
        return null;
    }


    /* Begin actual screenshot taking logic */


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
        float actor_x, actor_y;
        Meta.Rectangle? rect;
        Cairo.RectangleInt clip;
        unowned Meta.ShapedTexture? stex = null;

        unowned Meta.Screen? screen = wm.get_screen();
        unowned Meta.Display? display = screen.get_display();

        unowned Meta.Window? window = display.get_focus_window();
        var win_actor = window.get_compositor_private() as Meta.WindowActor;

        win_actor.get_position(out actor_x, out actor_y);
        rect = window.get_frame_rect();
        if (this.include_frame) {
            rect = window.frame_rect_to_client_rect(rect);
        }

        this.screenshot_area = Cairo.RectangleInt() {
            x = rect.x, y = rect.y, width = rect.width, height = rect.height
        };
        clip = Cairo.RectangleInt() {
            x = rect.x - (int) actor_x, y = rect.y - (int) actor_y,
            width = rect.width, height = rect.height
        };

        stex = win_actor.get_texture() as Meta.ShapedTexture;
        this.image = (Cairo.ImageSurface)stex.get_image(clip);

        /* TODO: Add cursor rendering */
        SignalHandler.disconnect_by_func(stage, (void*)grab_window_screenshot, this);

        /* Write the screenshot in a new thread, which will call back to take_window */
        Thread.create<void*>(write_screenshot, false);
    }

    /* Take a screenshot of the active window */
    public async bool take_window(bool include_frame, bool include_cursor, string filename, out Cairo.RectangleInt? area, out string? out_filename)
    {
        unowned Meta.Screen? screen = wm.get_screen();
        unowned Meta.Display? display = screen.get_display();

        unowned Meta.Window? window = display.get_focus_window();

        if (window == null) {
            return false;
        }

        this.async_cb = take_window.callback;

        this.filename = filename;
        this.include_frame = include_frame;
        this.include_cursor = include_cursor;

        unowned Clutter.Actor? stage = Meta.Compositor.get_stage_for_screen(screen);

        Meta.Util.disable_unredirect_for_screen(screen);
        stage.paint.connect_after(grab_window_screenshot);
        stage.queue_redraw();
        yield;

        /* Back from the thread */
        Meta.Util.enable_unredirect_for_screen(screen);

        if (this.wrote_screenshot) {
            area = this.screenshot_area;
            out_filename = this.final_filename;
        }
        return this.wrote_screenshot;
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
