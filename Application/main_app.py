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
        self.geometry("1100x750")

        # Configuração da Grid Principal
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

        # --- SIDEBAR ---
        self.sidebar = ctk.CTkFrame(self, width=200, corner_radius=0)
        self.sidebar.grid(row=0, column=0, sticky="nsew")

        self.logo_text = ctk.CTkLabel(self.sidebar, text="NASA NEO\nPROJECT", font=ctk.CTkFont(size=20, weight="bold"))
        self.logo_text.pack(pady=(30, 10))

        # Imagem Lateral (NASA/Terra)
        caminho_imagem = r"C:\Users\simao\Downloads\c01c9651-2f91-4dda-80ed-52c5b29f68a8.jpg"
        try:
            img_original = Image.open(caminho_imagem)
            img_vertical = img_original.rotate(90, expand=True)
            self.logo_image = ctk.CTkImage(light_image=img_vertical, dark_image=img_vertical, size=(190, 450))
            self.image_label = ctk.CTkLabel(self.sidebar, image=self.logo_image, text="")
            self.image_label.pack(pady=10, padx=10)
        except Exception as e:
            print(f"Erro ao carregar imagem: {e}")

        # --- PAINEL DE ESTATÍSTICAS NA SIDEBAR (O QUE PEDISTE) ---
        self.stats_frame = ctk.CTkFrame(self.sidebar, corner_radius=10, fg_color="transparent")
        self.stats_frame.pack(side="bottom", fill="x", padx=10, pady=20)

        # Obter dados reais da BD
        try:
            total_ast = db.get_total_asteroids_count()
            # Soma os alertas de todos os níveis para o total
            data_niveis = db.get_alert_counts_fixed()
            total_alr = sum(row[1] for row in data_niveis)
        except Exception:
            total_ast, total_alr = 0, 0

        self.label_total = ctk.CTkLabel(
            self.stats_frame,
            text=f"Inventário: {total_ast:,} objetos",
            font=("Arial", 11, "bold")
        )
        self.label_total.pack(pady=2)

        self.label_alerts = ctk.CTkLabel(
            self.stats_frame,
            text=f"Alertas: {total_alr:,}",
            text_color="orange",
            font=("Arial", 11, "bold")
        )
        self.label_alerts.pack(pady=2)

        # --- TABVIEW PRINCIPAL ---
        self.tabview = ctk.CTkTabview(self)
        self.tabview.grid(row=0, column=1, padx=20, pady=20, sticky="nsew")
        self.tabview.add("Monitorização")
        self.tabview.add("Pesquisa Técnica")
        self.tabview.add("Estatísticas")

        # Configuração das Abas
        self.setup_monitor_tab()
        self.setup_search_tab()
        self.setup_stats_tab()

        # Carregar Alertas iniciais
        self.load_alerts_data()

        # Protocolo para fechar a janela sem erros de background
        self.protocol("WM_DELETE_WINDOW", self.on_closing)

    def setup_monitor_tab(self):
        tab = self.tabview.tab("Monitorização")
        self.label_alerts_title = ctk.CTkLabel(tab, text="Alertas Críticos Ativos",
                                               font=ctk.CTkFont(size=16, weight="bold"))
        self.label_alerts_title.pack(pady=10)

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

    def setup_stats_tab(self):
        tab = self.tabview.tab("Estatísticas")

        for widget in tab.winfo_children(): widget.destroy()

        try:
            total_asteroides = db.get_total_asteroids_count()
            data = db.get_alert_counts_fixed()

            fig, ax = plt.subplots(figsize=(7, 5), dpi=100)
            fig.patch.set_facecolor('#242424')

            posicoes = [1, 2, 3, 4]
            niveis_labels = ['1-Baixa', '2-Média', '3-Alta', '4-Crítica']

            quantidades = [row[1] for row in data]
            cores = ['#4dff4d', '#ffff4d', '#ffa64d', '#ff4d4d']

            ax.bar(posicoes, quantidades, color=cores, align='center', width=0.6)

            ax.set_xlim(0.5, 4.5)

            ax.set_xticks(posicoes)
            ax.set_xticklabels(niveis_labels)

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

    def load_alerts_data(self):
        for i in self.tree.get_children(): self.tree.delete(i)
        try:
            alerts = db.get_active_alerts()
            if alerts:
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

    def on_closing(self):
        self.quit()
        self.destroy()


if __name__ == "__main__":
    app = NEOMonitoringApp()
    app.mainloop()
