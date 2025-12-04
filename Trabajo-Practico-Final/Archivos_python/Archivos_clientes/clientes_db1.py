import customtkinter as ctk
from tkinter import ttk, messagebox
from Archivos_clientes.agregar_modificar_clientes import AddModCliente
import time

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

class Clientes(ctk.CTkToplevel):
    def __init__(self, master: ctk.CTkToplevel, sc):
        super().__init__(master)
        self.title("Sistema de Ventas en Línea - Clientes")
        self.geometry("1000x700")
        self.__sc = sc

        self.__frame = FrameClientes(self, self.__sc)
        self.__tabla = Table(self, columns=("dni", "nombre", "apellido", "numero_telefono"), show="headings", height=500)

        self.__frame.pack(padx=10, pady=25)
        self.__tabla.pack(padx=10, pady=30)
        self.get_table("")

    # Llena la tabla con los datos que coincidan con la búsqueda en el entry desde la base de datos
    def get_table(self, text, *args):
        consulta = "SELECT dni, nombre, apellido, numero_telefono FROM clientes WHERE dni LIKE %s"
        self.__sc.cursor.execute(consulta, (text + "%",))
        filas = self.__sc.cursor.fetchall()

        for item in self.__tabla.get_children():
            self.__tabla.delete(item)

        for fila in filas:
            self.__tabla.insert("", "end", values=fila)

class FrameClientes(ctk.CTkFrame):
    def __init__(self, master: Clientes, sc, **kwargs):
        super().__init__(master, **kwargs)
        self.__sc = sc
        self.__entry_dni = DebouncedEntry(self, lambda texto: master.get_table(texto), width=200, height=20)
        self.__btn_add = ctk.CTkButton(self, width=200, height=20, text="Añadir", command=self.add_user)
        self.__btn_modify = ctk.CTkButton(self, width=200, height=20, text="Modificar", command=self.modify_user)
        self.__btn_delete = ctk.CTkButton(self, width=200, height=20, text="Eliminar", command=self.delete_user)

        self.__entry_dni.pack(side="left", padx=5)
        self.__btn_add.pack(side="left", padx=5)
        self.__btn_modify.pack(side="left", padx=5)
        self.__btn_delete.pack(side="left", padx=5)

    def add_user(self):
        amClientes = AddModCliente(self.master, self.__sc, True)
        amClientes.grab_set()
        amClientes.transient(self.master)
        amClientes.focus()
        amClientes.wait_window()

    def modify_user(self):
        consulta = "SELECT dni, nombre, apellido, numero_telefono FROM clientes WHERE dni = %s"
        self.__sc.cursor.execute(consulta, (self.__entry_dni.get(),))
        fila = self.__sc.cursor.fetchone()
        if fila:
            amClientes = AddModCliente(self.master, self.__sc, False, fila)
            amClientes.grab_set()
            amClientes.transient(self.master)
            amClientes.focus()
            amClientes.wait_window()
        else:
            messagebox.showerror("Error", f"No se ha podido establecer conexión o no se ha encontrado el DNI: {self.__entry_dni.get()} en la base de datos")

    # Eliminar filas de forma segura con SqlConnection
    def delete_user(self):
        dni = self.__entry_dni.get()
        consulta = "SELECT * from clientes WHERE dni = %s"
        self.__sc.cursor.execute(consulta, (dni,))
        filas = self.__sc.cursor.fetchall()
        if len(filas) == 0:
            messagebox.showerror("No encontrado", f"No se ha encontrado ningún cliente con el DNI: {dni}")
        else:
            if messagebox.askokcancel("Eliminar cliente", f"Estás seguro que deseas eliminar al cliente con DNI: {dni}"):
                try:
                    consulta = "DELETE FROM clientes WHERE dni = %s"
                    self.__sc.cursor.execute(consulta, (dni,))
                    self.__sc.conn.commit()
                    messagebox.showinfo("Cliente eliminado", "Cliente eliminado con éxito")
                except Exception as e:
                    self.__sc.conn.rollback()
                    messagebox.showerror("Error", f"No se ha podido eliminar al cliente\n{e}")
            else:
                messagebox.showinfo("Cancelada", "Operación cancelada")

# Clase DebouncedEntry hereda de CTkEntry y es modificado para poder ser usado como buscador
class DebouncedEntry(ctk.CTkEntry):
    def __init__(self, master: ctk.CTkToplevel, callback, **kwargs):
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

# Tabla creada heredando de tkinter.ttk.Treeview armada para asemejarse a un datagridview
class Table(ttk.Treeview):
    def __init__(self, master: ctk.CTkToplevel, **kwargs):
        super().__init__(master, **kwargs)
        self.heading("dni", text="DNI")
        self.heading("nombre", text="Nombre")
        self.heading("apellido", text="Apellido")
        self.heading("numero_telefono", text="Número de teléfono")

        self.column("dni", width=100)
        self.column("nombre", width=350)
        self.column("apellido", width=350)
        self.column("numero_telefono", width=350)