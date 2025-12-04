import customtkinter as ctk
from tkinter import ttk, messagebox

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

# Se realizan algunas búsquedas especiales llamanado a procedimientos almacenados pre-establecidos
class Busqueda(ctk.CTkToplevel):
    def __init__(self, master: ctk.CTk, sc):
        super().__init__(master)
        self.title("Búsqueda avanzada")
        self.geometry("1000x700")
        self.__sc = sc
        self.__frame = FrameBusqueda(self, self.__sc)
        self.__tabla_productos = TableProductos(self, columns=("id", "nombre", "stock_existente", "stock_disponible", "pedidos"), show="headings", height=500)
        self.__tabla_clientes = TableClientes(self, columns=("dni", "nombre", "apellido", "numero_telefono", "pedidos"), show="headings", height=500)
        
        self.__frame.pack(side='top', anchor='n', padx=10, pady=20)
        self.__diccionario = {
            "Productos más vendidos" : "productos_mas_vendidos",
            "Productos menos vendidos" : "productos_menos_vendidos",
            "Reporte del producto más vendido" : "reporte_producto_mas_vendido",
            "Clientes con más compras" : "clientes_con_mas_compras",
            "Clientes con menos compras" : "clientes_con_menos_compras"
        }

    @property
    def tabla_productos(self):
        return self.__tabla_productos
    
    @property
    def tabla_clientes(self):
        return self.__tabla_clientes
    
    @property
    def diccionario(self):
        return self.__diccionario

class FrameBusqueda(ctk.CTkFrame):
    def __init__(self, master: Busqueda, sc, **kwargs):
        super().__init__(master, **kwargs)
        self.__sc = sc
        self.__master = master
        self.__lista_productos = ["Productos más vendidos", "Productos menos vendidos", "Reporte del producto más vendido"]
        self.__lista_clientes = ["Clientes con más compras", "Clientes con menos compras"]

        self.__comboBox = ctk.CTkComboBox(self, width=700, state='readonly', values=["Productos más vendidos", 
            "Productos menos vendidos", "Reporte del producto más vendido", "Clientes con más compras", "Clientes con menos compras"])
        self.__btn_search = ctk.CTkButton(self, text="Buscar", command=self.buscar)

        self.__comboBox.pack(side='left', padx=5, pady=5)
        self.__btn_search.pack(side='right', padx=5, pady=5)

    def buscar(self):
        if self.__comboBox.get() in self.__lista_productos:
            self.__master.tabla_clientes.pack_forget()
            self.__master.tabla_productos.pack(side='top', anchor='n', padx=10, pady=30)
            self.__sc.cursor.callproc(self.__master.diccionario[self.__comboBox.get()])
            for result in self.__sc.cursor.stored_results():
                filas = result.fetchall()

            for item in self.__master.tabla_productos.get_children():
                self.__master.tabla_productos.delete(item)

            for fila in filas:
                self.__master.tabla_productos.insert("", "end", values=fila)
        elif self.__comboBox.get() in self.__lista_clientes:
            self.__master.tabla_productos.pack_forget()
            self.__master.tabla_clientes.pack(side='top', anchor='n', padx=10, pady=30)
            self.__sc.cursor.callproc(self.__master.diccionario[self.__comboBox.get()])
            for result in self.__sc.cursor.stored_results():
                filas = result.fetchall()

            for item in self.__master.tabla_clientes.get_children():
                self.__master.tabla_clientes.delete(item)

            for fila in filas:
                self.__master.tabla_clientes.insert("", "end", values=fila)
        else:
            messagebox.showerror("No encontrado", "Ha habido un error en la búsqueda")

class TableProductos(ttk.Treeview):
    def __init__(self, master, **kwargs):
        super().__init__(master, **kwargs)
        self.heading("id", text="ID")
        self.heading("nombre", text="Nombre")
        self.heading("stock_existente", text="Stock existente")
        self.heading("stock_disponible", text="Stock disponible")
        self.heading("pedidos", text="Pedidos")

        self.column("id", width=100)
        self.column("nombre", width=350)
        self.column("stock_existente", width=250)
        self.column("stock_disponible", width=250)
        self.column("pedidos", width=200)

class TableClientes(ttk.Treeview):
    def __init__(self, master: ctk.CTkToplevel, **kwargs):
        super().__init__(master, **kwargs)
        self.heading("dni", text="DNI")
        self.heading("nombre", text="Nombre")
        self.heading("apellido", text="Apellido")
        self.heading("numero_telefono", text="Número de teléfono")
        self.heading("pedidos", text="Pedidos realizados")

        self.column("dni", width=100)
        self.column("nombre", width=250)
        self.column("apellido", width=250)
        self.column("numero_telefono", width=350)
        self.column("pedidos", width=200)