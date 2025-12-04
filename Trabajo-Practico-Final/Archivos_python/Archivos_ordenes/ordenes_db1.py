import customtkinter as ctk
from tkinter import ttk, messagebox
from Archivos_ordenes.ajustar_max_ordenes import AjustarMax
import time

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

class Ordenes(ctk.CTkToplevel):
    def __init__(self, master: ctk.CTk, sc):
        super().__init__(master)
        self.title("Sistema de Ventas en Línea - Ordenes")
        self.geometry("1000x700")
        self.__sc = sc

        self.__frame = FrameOrdenes(self, self.__sc)
        self.__tabla = Table(self, columns=("id", "dni_cliente", "id_producto", "fecha_compra", "estado", "cantidad_producto"), show="headings", height=500)

        self.__frame.pack(padx=10, pady=25)
        self.__tabla.pack(padx=10, pady=30)
        self.get_table("")

    def get_table(self, text, *args):
        consulta = "SELECT id, dni_cliente, id_producto, fecha_compra, estado, cantidad_producto FROM ordenes WHERE id LIKE %s"
        self.__sc.cursor.execute(consulta, (text + "%",))
        filas = self.__sc.cursor.fetchall()

        for item in self.__tabla.get_children():
            self.__tabla.delete(item)

        for fila in filas:
            self.__tabla.insert("", "end", values=fila)

    def search_order(self):
        dni = self.__frame.ID
        consulta = "SELECT id, dni_cliente, id_producto, fecha_compra, estado, cantidad_producto FROM ordenes WHERE dni_cliente = %s"
        self.__sc.cursor.execute(consulta, (dni,))
        filas = self.__sc.cursor.fetchall()
        
        for item in self.__tabla.get_children():
            self.__tabla.delete(item)

        for fila in filas:
            self.__tabla.insert("", "end", values=fila)

class FrameOrdenes(ctk.CTkFrame):
    def __init__(self, master: Ordenes, sc, **kwargs):
        super().__init__(master, **kwargs)
        self.__sc = sc
        self.__entry_id = DebouncedEntry(self, lambda texto: master.get_table(texto), width=200, height=20)
        self.__btn_search = ctk.CTkButton(self, width=150, height=20, text="Buscar por DNI", command=master.search_order)
        self.__btn_finish = ctk.CTkButton(self, width=150, height=20, text="Terminar orden", command=self.finish_order)
        self.__btn_cancel = ctk.CTkButton(self, width=150, height=20, text="Cancelar orden", command=self.cancel_order)
        self.__btn_ajustar_maximo = ctk.CTkButton(self, width=150, height=20, text="Ajustar máximo", command=self.ajustar_max)

        self.__entry_id.pack(side="left", padx=5)
        self.__btn_search.pack(side="left", padx=5)
        self.__btn_finish.pack(side="left", padx=5)
        self.__btn_cancel.pack(side="left", padx=5)
        self.__btn_ajustar_maximo.pack(side="left", padx=5)

    @property
    def ID(self):
        return self.__entry_id.get()

    # Se cambia el estado de la orden a Terminado
    def finish_order(self):
        id = self.__entry_id.get()
        consulta = "SELECT * from ordenes WHERE id = %s"
        self.__sc.cursor.execute(consulta, (id,))
        filas = self.__sc.cursor.fetchall()
        if len(filas) == 0:
            messagebox.showerror("No encontrado", f"No se ha encontrado ninguna orden con la ID: {id}")
        else:
            if messagebox.askokcancel("Finalizar orden", f"Estás seguro que deseas marcar como terminada la orden con ID: {id}"):
                try:
                    consulta = "UPDATE ordenes SET estado = 'Terminado' WHERE id = %s"
                    self.__sc.cursor.execute(consulta, (id,))
                    self.__sc.conn.commit()
                    messagebox.showinfo("Orden completada", "Orden completada con éxito")
                except Exception as e:
                    self.__sc.conn.rollback()
                    messagebox.showerror("Error", f"No se ha podido completar la orden\n{e}")
            else:
                messagebox.showinfo("Operación cancelada")

    # Se cambia el estado de la orden a Cancelado
    def cancel_order(self):
        id = self.__entry_id.get()
        consulta = "SELECT * from ordenes WHERE id = %s"
        self.__sc.cursor.execute(consulta, (id,))
        filas = self.__sc.cursor.fetchall()
        if len(filas) == 0:
            messagebox.showerror("No encontrado", f"No se ha encontrado ninguna orden con la ID: {id}")
        else:
            if messagebox.askokcancel("Cancelar orden", f"Estás seguro que deseas cancelar la orden con ID: {id}"):
                try:
                    consulta = "UPDATE ordenes SET estado = 'Cancelado' WHERE id = %s"
                    self.__sc.cursor.execute(consulta, (id,))
                    self.__sc.conn.commit()
                    messagebox.showinfo("Orden cancelada", "Orden cancelada con éxito")
                except Exception as e:
                    self.__sc.conn.rollback()
                    messagebox.showerror("Error", f"No se ha podido cancelar la orden\n{e}")
            else:
                messagebox.showinfo("Operación cancelada")

    def ajustar_max(self):
        ajustar = AjustarMax(self.master, self.__sc)
        ajustar.grab_set()
        ajustar.transient(self.master)
        ajustar.focus()
        ajustar.wait_window()

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
        self.heading("dni_cliente", text="DNI del cliente")
        self.heading("id_producto", text="ID del producto")
        self.heading("fecha_compra", text="Fecha de compra")
        self.heading("estado", text="Estado")
        self.heading("cantidad_producto", text="Cantidad")

        self.column("id", width=100)
        self.column("dni_cliente", width=100)
        self.column("id_producto", width=100)
        self.column("fecha_compra", width=350)
        self.column("estado", width=350)
        self.column("cantidad_producto", width=150)