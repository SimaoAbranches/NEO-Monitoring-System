import customtkinter as ctk
from tkinter import messagebox, ttk
import Application.db_access as db  
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from PIL import Image
import os
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")


class NEOMonitoringApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("NEO Monitoring System v2.0")
        self.geometry("1100x700")

        self.sidebar = ctk.CTkFrame(self, width=200, corner_radius=0)
        self.sidebar.grid(row=0, column=0, sticky="nsew")
        self.logo_text = ctk.CTkLabel(self.sidebar, text="NASA NEO\nPROJECT", font=ctk.CTkFont(size=20, weight="bold"))
        self.logo_text.pack(pady=(30, 10))


        caminho_imagem = r"C:\Users\simao\Downloads\c01c9651-2f91-4dda-80ed-52c5b29f68a8.jpg"
        
        try:
            img_original = Image.open(caminho_imagem)

            img_vertical = img_original.rotate(90, expand=True)

            self.logo_image = ctk.CTkImage(light_image=img_vertical,
                                           dark_image=img_vertical,
                                           size=(190, 600))
            self.image_label = ctk.CTkLabel(self.sidebar, image=self.logo_image, text="")
            self.image_label.pack(pady=10, padx=10)
        except Exception as e:
            print(f"Erro ao carregar imagem: {e}")


        # Configuração das colunas e Tabview
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

        self.tabview = ctk.CTkTabview(self)
        self.tabview.grid(row=0, column=1, padx=20, pady=20, sticky="nsew")
        self.tabview.add("Monitorização")
        self.tabview.add("Pesquisa Técnica")
        self.tabview.add("Estatísticas")


        self.setup_monitor_tab()
        self.setup_search_tab()
        self.setup_stats_tab()
        self.load_alerts_data()
    def setup_monitor_tab(self):

        tab = self.tabview.tab("Monitorização")

        self.label_alerts = ctk.CTkLabel(tab, text="Alertas Críticos Ativos", font=ctk.CTkFont(size=16, weight="bold"))
        self.label_alerts.pack(pady=10)


        self.tree = ttk.Treeview(tab, columns=("ID", "Nível", "Mensagem"), show="headings")
        self.tree.heading("ID", text="SPKID")
        self.tree.heading("Nível", text="Prioridade")
        self.tree.heading("Mensagem", text="Alerta")
        self.tree.pack(fill="both", expand=True, padx=20, pady=10)

        self.btn_update = ctk.CTkButton(tab, text="Atualizar Alertas", command=self.load_alerts_data)
        self.btn_update.pack(pady=10)

    def setup_search_tab(self):

        tab = self.tabview.tab("Pesquisa Técnica")

        self.search_entry = ctk.CTkEntry(tab, placeholder_text="Procurar por Nome ou ID...", width=400)
        self.search_entry.pack(pady=20)

        self.btn_search = ctk.CTkButton(tab, text="Pesquisar 🔍", command=self.run_search_logic)
        self.btn_search.pack(pady=10)

        self.details_box = ctk.CTkTextbox(tab, width=600, height=250)
        self.details_box.pack(pady=10)

    def load_alerts_data(self):
        """Carrega alertas ativos."""
        for i in self.tree.get_children(): self.tree.delete(i)
        try:

            alerts = db.get_active_alerts()

            if not alerts:
                print("Aviso: A base de dados não devolveu nenhum alerta ativo.")
                return

            for row in alerts:

                self.tree.insert("", "end", values=(row[0], row[1], row[2]))

        except Exception as e:
            messagebox.showerror("Erro de Dados", f"Falha ao ler alertas: {e}")

    def run_search_logic(self):

        term = self.search_entry.get()
        self.details_box.delete("0.0", "end")

        results = db.search_by_id(term) or db.search_by_full_name(term)

        if results:
            for res in results:
                info = f"ID: {res[0]}\nNome: {res[1]}\nDiâmetro: {res[2]} km\n{'-' * 30}\n"
                self.details_box.insert("end", info)
        else:
            self.details_box.insert("end", "Nenhum resultado encontrado.")

    def setup_stats_tab(self):
        tab = self.tabview.tab("Estatísticas")
        for widget in tab.winfo_children(): widget.destroy()

        try:
            total_asteroides = db.get_total_asteroids_count()
            data = db.get_alert_counts_fixed()

            fig, ax = plt.subplots(figsize=(7, 5), dpi=100)
            fig.patch.set_facecolor('#242424')

            niveis = [str(row[0]) for row in data]
            quantidades = [row[1] for row in data]

            cores = ['#4dff4d', '#ffff4d', '#ffa64d', '#ff4d4d']  # Verde a Vermelho

            ax.bar(niveis, quantidades, color=cores)
            ax.set_xticks([1, 2, 3, 4])
            ax.set_xticklabels(['1-Baixa', '2-Média', '3-Alta', '4-Crítica'])

            ax.set_ylim(0, total_asteroides)  
            ax.set_ylabel("Quantidade de Alertas", color='white')
            ax.set_xlabel("Nível de Alerta (1 a 4)", color='white')
            ax.set_title(f"Alertas vs Total de Inventário ({total_asteroides:,} objetos)", color='white', pad=20)

            ax.set_facecolor('#242424')
            ax.tick_params(colors='white')
            plt.tight_layout()

            canvas = FigureCanvasTkAgg(fig, master=tab)
            canvas.draw()
            canvas.get_tk_widget().pack(pady=20, fill="both", expand=True)

        except Exception as e:
            print(f"Erro ao gerar estatística comparativa: {e}")


if __name__ == "__main__":
    app = NEOMonitoringApp()
    app.mainloop()
