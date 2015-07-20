/*
 *    ContactListCellRenderer.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
 *
 *    This file is part of Venom.
 *
 *    Venom is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Venom is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Venom.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Venom {
  public class ContactListCellRenderer : Gtk.CellRenderer {
    public IContact entry { get; set; }
    private static Gdk.RGBA unread_message_bgcolor = Gdk.RGBA() { red = 0.419607843, green = 0.760784314, blue = 0.376470588, alpha = 1.0 };
    private static Gdk.RGBA unread_message_fgcolor = Gdk.RGBA() { red = 0, green = 0, blue = 0, alpha = 1.0 };

    public override void get_size(Gtk.Widget widget, Gdk.Rectangle? cell_area, out int x_offset, out int y_offset, out int width, out int height) {
      x_offset = 0;
      y_offset = 0;
      width = 50;
      height = 59;
    }

    public override void render(Cairo.Context ctx, Gtk.Widget widget, Gdk.Rectangle background_area, Gdk.Rectangle cell_area, Gtk.CellRendererState flags) {
      int y = 6 + cell_area.y;
      Gtk.StateFlags state_flags = get_state(widget, flags);
      Pango.Rectangle ink_rect = render_name(ctx, widget, background_area, cell_area, y, state_flags);
      y += ink_rect.height;
      render_status(ctx, widget, background_area, cell_area, y);
      render_image(ctx, widget, background_area, cell_area, y);
      render_userstatus(ctx, widget, background_area, cell_area);
      render_unread_messages(ctx, widget, background_area, cell_area);
    }

    private void render_image(Cairo.Context ctx, Gtk.Widget widget, Gdk.Rectangle background_area, Gdk.Rectangle cell_area, int y_offset) {
      Gdk.Pixbuf? icon;
      if(entry is Contact) {
        Contact contact = (Contact)entry;
        icon = contact.image != null ? contact.image : ResourceFactory.instance.default_contact;
      } else {
        GroupChat groupchat = (GroupChat)entry;
        icon = groupchat.image != null ? groupchat.image : ResourceFactory.instance.default_groupchat;
      }
      Gdk.Rectangle image_rect = {8, 9 + background_area.y, 44, 41};
      if(icon != null) {
        Gdk.cairo_rectangle(ctx, image_rect);
        Gdk.cairo_set_source_pixbuf(ctx, icon, image_rect.x, image_rect.y);
			  ctx.fill();
			}
    }

    private void render_userstatus(Cairo.Context ctx, Gtk.Widget widget, Gdk.Rectangle background_area, Gdk.Rectangle cell_area) {
      Gdk.Pixbuf? status = null;
      
      if(entry is Contact) {
        Contact contact = (Contact)entry;

        if(!contact.online) {
          status = contact.unread_messages > 0 ? ResourceFactory.instance.offline_glow : ResourceFactory.instance.offline;
        }
        else {
          switch(contact.user_status) {
            case Tox.UserStatus.NONE:
              status = contact.unread_messages > 0 ? ResourceFactory.instance.online_glow : ResourceFactory.instance.online;
              break;
            case Tox.UserStatus.AWAY:
              status = contact.unread_messages > 0 ? ResourceFactory.instance.away_glow : ResourceFactory.instance.away;
              break;
            case Tox.UserStatus.BUSY:
              status = contact.unread_messages > 0 ? ResourceFactory.instance.busy_glow : ResourceFactory.instance.busy;
              break;
            case Tox.UserStatus.INVALID:
              status = contact.unread_messages > 0 ? ResourceFactory.instance.offline_glow : ResourceFactory.instance.offline;
              break;
          }
        }
      } else if(entry is GroupChat) {
        GroupChat groupchat = (GroupChat)entry;
        if(groupchat.peer_count > 0) {
          status = groupchat.unread_messages > 0 ? ResourceFactory.instance.online_glow : ResourceFactory.instance.online;
        } else {
          status = groupchat.unread_messages > 0 ? ResourceFactory.instance.offline_glow :ResourceFactory.instance.offline;
        }
      }
      if(status != null) {
        Gdk.Rectangle image_rect = {cell_area.x + cell_area.width - 24, cell_area.y + cell_area.height / 2 - 13, 26, 26};
        Gdk.cairo_rectangle(ctx, image_rect);
        Gdk.cairo_set_source_pixbuf(ctx, status, image_rect.x, image_rect.y);
		    ctx.fill();
		  }
    }

    private Pango.Rectangle? render_name(Cairo.Context ctx, Gtk.Widget widget, Gdk.Rectangle background_area, Gdk.Rectangle cell_area, int y_offset, Gtk.StateFlags state_flags) {
      Pango.Rectangle? ink_rect, logical_rect;
      Pango.FontDescription font = new Pango.FontDescription();
      Pango.Layout layout = widget.create_pango_layout(null);
      layout.set_font_description(font);
      Gdk.RGBA color = widget.get_style_context().get_color(state_flags);

      layout.set_markup(entry.get_name_string(), -1);
      layout.set_ellipsize(Pango.EllipsizeMode.END);
      layout.set_width((cell_area.width - 58 - 26) * Pango.SCALE);
      layout.get_pixel_extents(out ink_rect, out logical_rect);

      if (ctx != null) {
        ctx.save();
        Gdk.cairo_set_source_rgba(ctx, color);
        ctx.move_to(cell_area.x + 58, cell_area.y + cell_area.height / 2 - ink_rect.height - 8);
        Pango.cairo_show_layout(ctx, layout);
        ctx.restore();
      }
      return ink_rect;
    }

    private Pango.Rectangle render_status(Cairo.Context ctx, Gtk.Widget widget, Gdk.Rectangle background_area, Gdk.Rectangle cell_area, int y_offset) {
      Pango.Rectangle? ink_rect, logical_rect;
      Pango.FontDescription font = new Pango.FontDescription();
      Pango.Layout layout = widget.create_pango_layout(null);
      layout.set_font_description(font);
      Gdk.RGBA color = widget.get_style_context().get_color(Gtk.StateFlags.NORMAL);
      //FIXME find a better way for this (css styling if possible)
      color.red -= 0.4;
      color.green -= 0.4;
      color.blue -= 0.4;
      layout.set_markup(entry.get_status_string(), -1);
      layout.set_ellipsize(Pango.EllipsizeMode.END);
      layout.set_width((cell_area.width - 58 - 26) * Pango.SCALE);
      layout.get_pixel_extents(out ink_rect, out logical_rect);

      if (ctx != null) {
        ctx.save();
        Gdk.cairo_set_source_rgba(ctx, color);
        ctx.move_to(cell_area.x + 58, cell_area.y + cell_area.height / 2 - 2);
        Pango.cairo_show_layout(ctx, layout);
        ctx.restore();
      }
      return ink_rect;
    }
    private void render_unread_messages(Cairo.Context ctx, Gtk.Widget widget, Gdk.Rectangle background_area, Gdk.Rectangle cell_area) {
      int unread_messages = 0;
      if(entry is Contact) {
        unread_messages = ((Contact)entry).unread_messages;
      } else if(entry is GroupChat) {
        unread_messages = ((GroupChat)entry).unread_messages;
      }
      if(unread_messages == 0) {
        return;
      }
      string str = unread_messages < 10 ? unread_messages.to_string() : "+";

      Pango.Rectangle? ink_rect, logical_rect;
      Gdk.Rectangle image_rect_border = {cell_area.x + cell_area.width - 24 , cell_area.y + cell_area.height / 2, 13, 13};
      Gdk.Rectangle image_rect = {cell_area.x + cell_area.width - 23 , cell_area.y + cell_area.height / 2 + 1, 11, 11};

      Pango.FontDescription font = new Pango.FontDescription();
      font.set_absolute_size(10 * Pango.SCALE);
      Pango.Layout layout = widget.create_pango_layout(null);
      layout.set_font_description(font);
      layout.set_markup("<tt>%s</tt>".printf(str), -1);
      layout.get_pixel_extents(out ink_rect, out logical_rect);

      ctx.save();
      Gdk.cairo_rectangle(ctx, image_rect_border);
      Gdk.cairo_set_source_rgba(ctx, unread_message_fgcolor);
      ctx.fill();
      Gdk.cairo_rectangle(ctx, image_rect);
      Gdk.cairo_set_source_rgba(ctx, unread_message_bgcolor);
	    ctx.fill();
      Gdk.cairo_set_source_rgba(ctx, unread_message_fgcolor);
      //FIXME correct centering, maybe fixed-size font
      ctx.move_to(image_rect.x + image_rect.width / 2 - logical_rect.width / 2, image_rect.y + image_rect.height / 2 - logical_rect.height / 2);
      Pango.cairo_show_layout(ctx, layout);
      ctx.restore();
		}
  }
}
