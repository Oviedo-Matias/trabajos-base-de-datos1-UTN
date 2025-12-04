import customtkinter as ctk
from tkinter import messagebox
#from GUI_proyecto_db1 import SqlConnection

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

class AddModCliente(ctk.CTkToplevel):
    def __init__(self, master: ctk.CTkToplevel, sc, agregar: bool, fila = None):
        super().__init__(master)
        __titulo = "Sistema de Ventas en Línea - Agregar cliente" if agregar else "Sistema de Ventas en Línea - Modificar cliente"
        self.title(__titulo)
        self.geometry("1000x700")
        self.__sc = sc
        self.__agregar = agregar

        self.__frame = FrameDatos(self, agregar, fila)
        self.__btn_aceptar = ctk.CTkButton(self, text='Aceptar', command=self.guardar_datos)
        self.__btn_cancelar = ctk.CTkButton(self, text='Cancelar', command=self.destroy)

        self.__frame.place(relx=0.5, rely=0.5, anchor=ctk.CENTER)
        self.__btn_aceptar.place(relx=0.5, rely=0.75, anchor="ne", x=-self.__frame.winfo_reqwidth() / 2)
        self.__btn_cancelar.place(relx=0.5, rely=0.75, anchor="nw", x=self.__frame.winfo_reqwidth() / 2)

    # Esta función ejecutará insert o update según sea solicitado y manejará excepciones de forma segura
    def guardar_datos(self):
        try:
            if self.__agregar:
                consulta = "INSERT INTO clientes (dni, nombre, apellido, numero_telefono) VALUES (%s, %s, %s, %s)"
                self.__sc.cursor.execute(consulta, (self.__frame.DNI, self.__frame.Nombre, self.__frame.Apellido, self.__frame.Telefono))
            else:
                consulta = "UPDATE clientes SET nombre = %s, apellido = %s, numero_telefono = %s WHERE dni = %s"
                self.__sc.cursor.execute(consulta, (self.__frame.Nombre, self.__frame.Apellido, self.__frame.Telefono, self.__frame.DNI))
            self.__sc.conn.commit()
            self.destroy()
        except Exception as ex:
            messagebox.showerror("Error", f"Ha habido un error en la conexión con la base de datos:\n{ex}")

class FrameDatos(ctk.CTkFrame):
    def __init__(self, master: ctk.CTkToplevel, agregar: bool, fila = None, **kwargs):
        super().__init__(master, **kwargs)
        self.__label_dni = ctk.CTkLabel(self, text='DNI:')
        self.__label_nombre = ctk.CTkLabel(self, text='Nombre:')
        self.__label_apellido = ctk.CTkLabel(self, text='Apellido:')
        self.__label_telefono = ctk.CTkLabel(self, text='Número de teléfono:')

        self.__entry_dni = ctk.CTkEntry(self, width=200, height=20)
        self.__entry_nombre = ctk.CTkEntry(self, width=200, height=20)
        self.__entry_apellido = ctk.CTkEntry(self, width=200, height=20)
        self.__entry_telefono = ctk.CTkEntry(self, width=200, height=20)

        self.__label_dni.grid(row=0, column=0, padx=20, pady=5)
        self.__label_nombre.grid(row=1, column=0, padx=20, pady=5)
        self.__label_apellido.grid(row=2, column=0, padx=20, pady=5)
        self.__label_telefono.grid(row=3, column=0, padx=20, pady=5)

        self.__entry_dni.grid(row=0, column=1, padx=20, pady=5)
        self.__entry_nombre.grid(row=1, column=1, padx=20, pady=5)
        self.__entry_apellido.grid(row=2, column=1, padx=20, pady=5)
        self.__entry_telefono.grid(row=3, column=1, padx=20, pady=5)

        if not agregar:
            self.__entry_dni.insert(0, fila[0])
            self.__entry_dni.configure(state='disabled')
            self.__entry_nombre.insert(0, fila[1])
            self.__entry_apellido.insert(0, fila[2])
            self.__entry_telefono.insert(0, fila[3])

    @property
    def DNI(self):
        return self.__entry_dni.get()

    @property
    def Nombre(self):
        return self.__entry_nombre.get()
    
    @property
    def Apellido(self):
        return self.__entry_apellido.get()
    
    @property
    def Telefono(self):
        return self.__entry_telefono.get()