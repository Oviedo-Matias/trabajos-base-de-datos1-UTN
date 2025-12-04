import customtkinter as ctk
from tkinter import messagebox
from Archivos_clientes.clientes_db1 import Clientes
from Archivos_ordenes.ordenes_db1 import Ordenes
from Archivos_productos.productos_db1 import Productos
from busqueda_avanzada_db1 import Busqueda
import mysql.connector as sc

# Apariencia y tema de customtkinter
# Se usará customtkinter acompañado de tkinter para hacer una interfaz visual estética y completa
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

# Ventana principal, root hereda de la clase ctk.CTk para poder crear una clase CTk personalizada
# Se usará herencia y polimorfismo para los principales widgets de la aplicación facilitando su personalización
class Root(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Sistema de Ventas en Línea")
        self.geometry("1000x700")
        self.__frame_inicio = Frame_inicio(self)
        self.__frame_inicio.place(relx=0.5, rely=0.5, anchor=ctk.CENTER)

# Frame centrado para facilitar la posición de widgets
class Frame_inicio(ctk.CTkFrame):
    def __init__(self, master: Root, **kwargs):
        super().__init__(master, **kwargs)
        self.__label_inicio = ctk.CTkLabel(self, text="¿Qué desea ver/modificar?", font=('arial', 20))
        self.__btn_clientes = ctk.CTkButton(self, text="Clientes", command=self.open_clientes)
        self.__btn_ordenes = ctk.CTkButton(self, text="Órdenes", command=self.open_ordenes)
        self.__btn_productos = ctk.CTkButton(self, text="Productos", command=self.open_productos)
        self.__btn_busqueda_avanzada = ctk.CTkButton(self, text="Búsqueda avanzada", command=self.open_busqueda_avanzada)

        self.__label_inicio.grid(column=1, row=0, padx=5, pady=20)
        self.__btn_clientes.grid(column=0, row=1, padx=30, pady=20)
        self.__btn_ordenes.grid(column=1, row=1, padx=30, pady=20)
        self.__btn_productos.grid(column=2, row=1, padx=30, pady=20)
        self.__btn_busqueda_avanzada.grid(column=1, row=2, pady=20)

        self.__sqlConnection = SqlConnection()

    def open_busqueda_avanzada(self):
        busqueda = Busqueda(self.master, self.__sqlConnection)
        busqueda.grab_set()
        busqueda.transient(self.master)
        busqueda.focus()
        busqueda.wait_window()

    def open_clientes(self):
        clientes = Clientes(self.master, self.__sqlConnection)
        clientes.grab_set()
        clientes.transient(self.master)
        clientes.focus()
        clientes.wait_window()

    def open_ordenes(self):
        ordenes = Ordenes(self.master, self.__sqlConnection)
        ordenes.grab_set()
        ordenes.transient(self.master)
        ordenes.focus()
        ordenes.wait_window()

    def open_productos(self):
        productos = Productos(self.master, self.__sqlConnection)
        productos.grab_set()
        productos.transient(self.master)
        productos.focus()
        productos.wait_window()

# Clase SqlConnection con todas las propiedades necesarias para poder ser instanciada y realizar consultas parametrizadas
# Gracias a esta clase se puede hacer commit y rollback desde python ahorrando la necesidad de programarlo en SQL
# Gracias al manejo de excepciones, no es necesario usar rollback el cual, en caso de que el problema fuera de conexión, fallaría
class SqlConnection:
    def __init__(self):
        try:
            self.__conn = sc.connect(
                host="localhost",
                user="root",
                password="root",
                database="tp_final_db1"
            )
            self.__cursor = self.__conn.cursor()
        except:
            messagebox.showerror("Error", "Ejecutando sin conexión")

    @property
    def conn(self):
        return self.__conn

    @property
    def cursor(self):
        return self.__cursor

if __name__ == '__main__':
    root = Root()
    root.mainloop()