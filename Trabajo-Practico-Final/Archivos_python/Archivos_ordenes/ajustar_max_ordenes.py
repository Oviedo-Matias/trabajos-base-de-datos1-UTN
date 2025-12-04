import customtkinter as ctk
from tkinter import messagebox

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

class AjustarMax(ctk.CTkToplevel):
    def __init__(self, master: ctk.CTkToplevel, sc):
        super().__init__(master)
        self.title("Sistema de Ventas en Línea - Ajustar maximo de ordenes")
        self.geometry("1000x700")

        frame = Frame(self, sc)
        frame.place(relx=0.5, rely=0.5, anchor=ctk.CENTER)

class Frame(ctk.CTkFrame):
    def __init__(self, master: AjustarMax, sc):
        super().__init__(master)
        self.__sc = sc

        self.__label_id = ctk.CTkLabel(self, text="ID:")
        self.__label_max = ctk.CTkLabel(self, text="Cantidad máxima:")
        self.__entry_id = ctk.CTkEntry(self)
        self.__entry_max = ctk.CTkEntry(self)
        self.__btn_aceptar = ctk.CTkButton(self, text="Aceptar", command=self.aceptar)
        self.__btn_cancelar = ctk.CTkButton(self, text="Cancelar", command=master.destroy)

        self.__label_id.grid(row=0, column=0, padx=5, pady=5)
        self.__label_max.grid(row=1, column=0, padx=5, pady=5)
        self.__entry_id.grid(row=0, column=1, padx=5, pady=5)
        self.__entry_max.grid(row=1, column=1, padx=5, pady=5)
        self.__btn_aceptar.grid(row=2, column=0, padx=5, pady=5)
        self.__btn_cancelar.grid(row=2, column=1, padx=5, pady=5)

    def aceptar(self):
        try:
            args = (self.__entry_id.get(), self.__entry_max.get())
            self.__sc.cursor.callproc("ajustar_cantidad_maxima", args)
            self.__sc.conn.commit()
            messagebox.showinfo("Éxito", "Se ha completado correctamente el ajuste")
        except Exception as e:
            messagebox.showerror("Error", f"Ha ocurrido un error:\n{e}")