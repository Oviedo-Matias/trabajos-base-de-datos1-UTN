import customtkinter as ctk
from tkinter import ttk, messagebox
from Archivos_productos.agregar_modificar_productos import AddModProducto
import time

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

class Productos(ctk.CTkToplevel):
    def __init__(self, master, sc):
        super().__init__(master)
        self.title("Sistema de Ventas en Línea - Productos")
        self.geometry("1000x700")
        self.__sc = sc

        self._frame = FrameProductos(self, self.__sc)
        self.__tabla = Table(self, columns=("id", "nombre", "stock_existente", "stock_disponible"), show="headings", height=500)

        self._frame.pack(padx=10, pady=25)
        self.__tabla.pack(padx=10, pady=30)
        self.get_table("")

    def get_table(self, text, *args):
        consulta = "SELECT id, nombre, stock_existente, stock_disponible FROM productos WHERE id LIKE %s"
        self.__sc.cursor.execute(consulta, (text + "%",))
        filas = self.__sc.cursor.fetchall()

        for item in self.__tabla.get_children():
            self.__tabla.delete(item)

        for fila in filas:
            self.__tabla.insert("", "end", values=fila)

class FrameProductos(ctk.CTkFrame):
    def __init__(self, master, sc, **kwargs):
        super().__init__(master, **kwargs)
        self.__sc = sc
        self.__entry_id = DebouncedEntry(self, lambda texto: master.get_table(texto), width=200, height=20)
        self.__btn_add = ctk.CTkButton(self, width=200, height=20, text="Añadir", command=self.add_product)
        self.__btn_modify = ctk.CTkButton(self, width=200, height=20, text="Modificar", command=self.modify_product)
        self.__btn_delete = ctk.CTkButton(self, width=200, height=20, text="Eliminar", command=self.delete_product)

        self.__entry_id.pack(side="left", padx=5)
        self.__btn_add.pack(side="left", padx=5)
        self.__btn_modify.pack(side="left", padx=5)
        self.__btn_delete.pack(side="left", padx=5)

    def add_product(self):
        amProductos = AddModProducto(self.master, self.__sc, True)
        amProductos.grab_set()
        amProductos.transient(self.master)
        amProductos.focus()
        amProductos.wait_window()

    def modify_product(self):
        consulta = "SELECT id, nombre, stock_disponible, stock_existente FROM productos WHERE id = %s"
        self.__sc.cursor.execute(consulta, (self.__entry_id.get(),))
        fila = self.__sc.cursor.fetchone()
        if fila:
            amProductos = AddModProducto(self.master, self.__sc, False, fila)
            amProductos.grab_set()
            amProductos.transient(self.master)
            amProductos.focus()
            amProductos.wait_window()
        else:
            messagebox.showerror("Error", f"No se ha podido establecer conexión o no se ha encontrado la ID: {self.__entry_id.get()} en la base de datos")

    def delete_product(self):
        id = self.__entry_id.get()
        consulta = "SELECT * from productos WHERE id = %s"
        self.__sc.cursor.execute(consulta, (id,))
        filas = self.__sc.cursor.fetchall()
        if len(filas) == 0:
            messagebox.showerror("No encontrado", f"No se ha encontrado ningún producto con el ID: {id}")
        else:
            if messagebox.askokcancel("Eliminar producto", f"Estás seguro que deseas eliminar al producto con ID: {id}"):
                try:
                    consulta = "DELETE FROM productos WHERE id = %s"
                    self.__sc.cursor.execute(consulta, (id,))
                    self.__sc.conn.commit()
                    messagebox.showinfo("Producto eliminado", "Producto eliminado con éxito")
                except Exception as e:
                    self.__sc.conn.rollback()
                    messagebox.showerror("Error", f"No se ha podido eliminar el producto\n{e}")
            else:
                messagebox.showinfo("Cancelada", "Operación cancelada")

class DebouncedEntry(ctk.CTkEntry):
    def __init__(self, master, callback, **kwargs):
        self.__var = ctk.StringVar()
        super().__init__(master, textvariable=self.__var, **kwargs)

        self.__callback = callback
        self.__last_call_time = 0
        self.__pending = False

        self.__var.trace_add("write", self._on_change)

    def _on_change(self, *args):
        now = time.time()
        if now - self.__last_call_time >= 0.2:
            self._execute()
        else:
            if not self.__pending:
                remaining = 0.2 - (now - self.__last_call_time)
                self.__pending = True
                self.after(int(remaining * 1000), self._execute)

    def _execute(self):
        self.__last_call_time = time.time()
        self.__pending = False
        self.__callback(self.__var.get())

class Table(ttk.Treeview):
    def __init__(self, master, **kwargs):
        super().__init__(master, **kwargs)
        self.heading("id", text="ID")
        self.heading("nombre", text="Nombre")
        self.heading("stock_existente", text="Stock existente")
        self.heading("stock_disponible", text="Stock disponible")

        self.column("id", width=100)
        self.column("nombre", width=350)
        self.column("stock_existente", width=350)
        self.column("stock_disponible", width=350)