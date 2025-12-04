import customtkinter as ctk
from tkinter import messagebox
#from GUI_proyecto_db1 import SqlConnection

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

class AddModProducto(ctk.CTkToplevel):
    def __init__(self, master: ctk.CTkToplevel, sc, agregar: bool, fila = None):
        super().__init__(master)
        __titulo = "Sistema de Ventas en Línea - Agregar producto" if agregar else "Sistema de Ventas en Línea - Modificar producto"
        self.title(__titulo)
        self.geometry("1000x700")
        self.__sc = sc
        self.__agregar = agregar

        self.__frame = FrameDatos(self, self.__sc, agregar, fila)
        self.__btn_aceptar = ctk.CTkButton(self, text='Aceptar', command=self.guardar_datos)
        self.__btn_cancelar = ctk.CTkButton(self, text='Cancelar', command=self.destroy)

        self.__frame.place(relx=0.5, rely=0.5, anchor=ctk.CENTER)
        self.__btn_aceptar.place(relx=0.5, rely=0.75, anchor="ne", x=-self.__frame.winfo_reqwidth() / 2)
        self.__btn_cancelar.place(relx=0.5, rely=0.75, anchor="nw", x=self.__frame.winfo_reqwidth() / 2)

    def guardar_datos(self):
        try:
            if self.__agregar:
                consulta = "INSERT INTO productos (nombre, stock_disponible, stock_existente) VALUES (%s, %s, %s)"
                self.__sc.cursor.execute(consulta, (self.__frame.Nombre, self.__frame.Stock_disponible, self.__frame.Stock_existente))
            else:
                consulta = "UPDATE productos SET nombre = %s, stock_disponible = %s, stock_existente = %s WHERE id = %s"
                self.__sc.cursor.execute(consulta, (self.__frame.Nombre, self.__frame.Stock_disponible, self.__frame.Stock_existente, self.__frame.ID))
            self.__sc.conn.commit()
            self.destroy()
        except Exception as ex:
            messagebox.showerror("Error", f"Ha habido un error en la conexión con la base de datos:\n{ex}")

class FrameDatos(ctk.CTkFrame):
    def __init__(self, master: ctk.CTkToplevel, sc, agregar: bool, fila = None, **kwargs):
        super().__init__(master, **kwargs)
        self.__sc = sc

        self.__label_id = ctk.CTkLabel(self, text='ID:')
        self.__label_nombre = ctk.CTkLabel(self, text='Nombre:')
        self.__label_stock_disponible = ctk.CTkLabel(self, text='Stock disponible:')
        self.__label_stock_existente = ctk.CTkLabel(self, text='Stock existente:')

        self.__entry_id = ctk.CTkEntry(self, width=200, height=20)
        self.__entry_nombre = ctk.CTkEntry(self, width=200, height=20)
        self.__entry_stock_disponible = ctk.CTkEntry(self, width=200, height=20)
        self.__entry_stock_existente = ctk.CTkEntry(self, width=200, height=20)

        self.__label_id.grid(row=0, column=0, padx=20, pady=5)
        self.__label_nombre.grid(row=1, column=0, padx=20, pady=5)
        self.__label_stock_disponible.grid(row=2, column=0, padx=20, pady=5)
        self.__label_stock_existente.grid(row=3, column=0, padx=20, pady=5)

        self.__entry_id.grid(row=0, column=1, padx=20, pady=5)
        self.__entry_nombre.grid(row=1, column=1, padx=20, pady=5)
        self.__entry_stock_disponible.grid(row=2, column=1, padx=20, pady=5)
        self.__entry_stock_existente.grid(row=3, column=1, padx=20, pady=5)

        try:
            if agregar:
                consulta = "SELECT AUTO_INCREMENT FROM information_schema.tables WHERE table_name = 'productos' AND table_schema = DATABASE();"
                self.__sc.cursor.execute(consulta)
                fila = self.__sc.cursor.fetchone()
                self.__entry_id.insert(0, str(fila[0]))
                self.__entry_id.configure(state='disabled')
            else:
                self.__entry_id.insert(0, fila[0])
                self.__entry_id.configure(state='disabled')
                self.__entry_nombre.insert(0, fila[1])
                self.__entry_stock_disponible.insert(0, fila[2])
                self.__entry_stock_existente.insert(0, fila[3])
        except Exception as ex:
            messagebox.showerror("Error", f"Ha habido un error en la conexión con la base de datos:\n{ex}")

    @property
    def ID(self):
        return self.__entry_id.get()

    @property
    def Nombre(self):
        return self.__entry_nombre.get()
    
    @property
    def Stock_disponible(self):
        return self.__entry_stock_disponible.get()
    
    @property
    def Stock_existente(self):
        return self.__entry_stock_existente.get()