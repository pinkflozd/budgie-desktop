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
                                         out string filename_used);

public class Screenshot : GLib.Object {


    public unowned Budgie.BudgieWM? wm { construct set ; public get; }

    public Screenshot(Budgie.BudgieWM? wm)
    {
        Object(wm: wm);
    }

    /* Take a screenshot of the given area */
    public void take_area(int x, int y, int width, int height, string filename, ScreenshotCallback? cb)
    {

    }

    /* Take a screenshot of the active window */
    public void take_window(bool include_frame, bool include_cursor, string filename, ScreenshotCallback? cb)
    {

    }

    /* Take a screenshot of the whole desktop */
    public void take(bool include_cursor, string filename, ScreenshotCallback? cb)
    {

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
