/*
 *    SqliteTools.vala
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
  public errordomain SqliteStatementError {
    INDEX,
    BIND
  }
  public errordomain SqliteDbError {
    OPEN,
    QUERY
  }
  public class SqliteTools {
    private SqliteTools() {}

    public static void put_int(Sqlite.Statement statement, string name, int value) throws SqliteStatementError {
      int index = statement.bind_parameter_index(name);
      if(index == 0) {
        throw new SqliteStatementError.INDEX(_("Index for %s not found.").printf(name));
      }
      if(statement.bind_int(index, value) != Sqlite.OK) {
        throw new SqliteStatementError.BIND(_("Could not bind int to %s.").printf(name));
      }
    }

    public static void put_int64(Sqlite.Statement statement, string name, int64 value) throws SqliteStatementError {
      int index = statement.bind_parameter_index(name);
      if(index == 0) {
        throw new SqliteStatementError.INDEX(_("Index for %s not found.").printf(name));
      }
      if(statement.bind_int64(index, value) != Sqlite.OK) {
        throw new SqliteStatementError.BIND(_("Could not bind int64 to %s.").printf(name));
      }
    }

    public static void put_text(Sqlite.Statement statement, string name, string value) throws SqliteStatementError {
      int index = statement.bind_parameter_index(name);
      if(index == 0) {
        throw new SqliteStatementError.INDEX(_("Index for %s not found.").printf(name));
      }
      if(statement.bind_text(index, value) != Sqlite.OK) {
        throw new SqliteStatementError.BIND(_("Could not bind text to %s").printf(name));
      }
    }

    public static void open_db(string filepath, out Sqlite.Database db) throws SqliteDbError, Error {

      // Open/Create a database:
      File file = File.new_for_path(filepath);
      if(file.query_exists()) {
        GLib.FileUtils.chmod(filepath, 0600);
      } else {
        file.create(GLib.FileCreateFlags.PRIVATE);
      }

      if(Sqlite.Database.open (filepath, out db) != Sqlite.OK) {
        throw new SqliteDbError.OPEN(_("Can't open database: %d: %s\n"), db.errcode (), db.errmsg ());
      }
    }
  }
}
